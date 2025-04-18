import 'dart:convert';
import 'dart:io';

/// A class that wraps an HTTP request and provides convenient access to its data.
///
/// The Request class provides:
/// - Access to query parameters
/// - Parsing of request body for different content types
/// - Access to the underlying HttpRequest
class Request {
  /// The underlying HTTP request object.
  final HttpRequest _request;

  /// Query parameters extracted from the request URL.
  /// Similar to Express.js req.query
  late final Map<String, String> query;

  /// Route parameters extracted from the URL path.
  /// Similar to Express.js req.params
  final Map<String, String> params;

  /// The parsed request body.
  /// Similar to Express.js req.body
  ///
  /// The type of this field depends on the content type:
  /// - For JSON: Map<String, dynamic>
  /// - For form data: Map<String, String>
  late final dynamic body;

  /// The HTTP method of the request (GET, POST, PUT, DELETE, etc.)
  String get method => _request.method;

  /// Get all headers from the request
  Map<String, String> get headers {
    final Map<String, String> result = {};
    _request.headers.forEach((name, values) {
      result[name] = values.join(',');
    });
    return result;
  }

  /// Creates a new Request instance from an HttpRequest.
  ///
  /// [request] The underlying HTTP request
  /// [params] Optional route parameters extracted from the URL path
  Request(this._request, {Map<String, String>? params}) 
      : params = params ?? {} {
    // Initialize query parameters
    if (_request.uri.queryParameters.isEmpty && _request.uri.query.isNotEmpty) {
      // If queryParameters is empty but we have a query string, parse it manually
      query = Uri.splitQueryString(_request.uri.query);
    } else {
      query = _request.uri.queryParameters;
    }
  }

  /// Gets a query parameter value.
  /// Similar to Express.js req.query[key]
  ///
  /// [key] The query parameter key
  /// Returns the value of the query parameter or null if not found
  String? getQuery(String key) {
    return query[key];
  }

  /// Gets a route parameter value.
  /// Similar to Express.js req.params[key]
  ///
  /// [key] The route parameter key
  /// Returns the value of the route parameter or null if not found
  String? getParam(String key) {
    return params[key];
  }

  /// Parses the request body based on its content type.
  ///
  /// This method:
  /// 1. Checks the content type of the request
  /// 2. Parses the body accordingly:
  ///    - For 'application/json': Parses as JSON
  ///    - For 'application/x-www-form-urlencoded': Parses as form data
  ///    - For multipart/form-data: Handles file uploads
  ///
  /// Currently supported content types:
  /// - application/json
  /// - application/x-www-form-urlencoded
  /// - multipart/form-data
  ///
  /// Example:
  /// ```dart
  /// await request.parseBody();
  /// var data = request.body; // Access parsed data
  /// ```
  Future<void> parseBody() async {
    if (_request.headers.contentType == null) {
      body = null;
      return;
    }

    final contentType = _request.headers.contentType!;
    
    try {
      if (contentType.mimeType == 'application/json') {
        var content = await utf8.decoder.bind(_request).join();
        if (content.isNotEmpty) {
          body = jsonDecode(content);
        } else {
          body = null;
        }
      } else if (contentType.mimeType == 'application/x-www-form-urlencoded') {
        var content = await utf8.decoder.bind(_request).join();
        body = Uri.splitQueryString(content);
      } else if (contentType.mimeType == 'multipart/form-data') {
        var formData = <String, dynamic>{};
        var boundary = contentType.parameters['boundary']!;
        
        // Read the entire request body
        var content = await utf8.decoder.bind(_request).join();
        
        // Split the content by the boundary
        var parts = content.split('--$boundary');
        
        // Process each part
        for (var part in parts) {
          if (part.trim().isEmpty || part == '--') continue;
          
          // Split the part into headers and content
          var lines = part.split('\r\n');
          var headers = <String, String>{};
          var contentStart = 0;
          
          // Parse headers
          for (var i = 0; i < lines.length; i++) {
            if (lines[i].isEmpty) {
              contentStart = i + 1;
              break;
            }
            
            var header = lines[i].split(':');
            if (header.length == 2) {
              headers[header[0].trim().toLowerCase()] = header[1].trim();
            }
          }
          
          // Get the content
          var content = lines.sublist(contentStart).join('\r\n').trim();
          
          // Parse content-disposition
          var disposition = headers['content-disposition'];
          if (disposition != null) {
            var name = disposition
                .split(';')
                .map((s) => s.trim())
                .firstWhere((s) => s.startsWith('name='), orElse: () => '')
                .substring(5)
                .replaceAll('"', '');
                
            if (name.isNotEmpty) {
              formData[name] = content;
            }
          }
        }
        
        body = formData;
      }
    } catch (e) {
      body = null;
    }
  }
}
