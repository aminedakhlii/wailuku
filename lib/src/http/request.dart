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
  late final Map<String, String> queryParameters;

  /// The parsed request body.
  ///
  /// The type of this field depends on the content type:
  /// - For JSON: Map<String, dynamic>
  /// - For form data: Map<String, String>
  late final dynamic body;

  /// Creates a new Request instance from an HttpRequest.
  ///
  /// [request] The underlying HTTP request
  Request(this._request) {
    queryParameters = _request.uri.queryParameters;
  }

  /// Parses the request body based on its content type.
  ///
  /// This method:
  /// 1. Checks the content type of the request
  /// 2. Parses the body accordingly:
  ///    - For 'application/json': Parses as JSON
  ///    - For 'application/x-www-form-urlencoded': Parses as form data
  ///
  /// Currently supported content types:
  /// - application/json
  /// - application/x-www-form-urlencoded
  ///
  /// Example:
  /// ```dart
  /// await request.parseBody();
  /// var data = request.body; // Access parsed data
  /// ```
  Future<void> parseBody() async {
    if (_request.headers.contentType?.mimeType == 'application/json') {
      var content = await utf8.decoder.bind(_request).join();
      body = jsonDecode(content);
    } else if (_request.headers.contentType?.mimeType == 'application/x-www-form-urlencoded') {
      var content = await utf8.decoder.bind(_request).join();
      body = Uri.splitQueryString(content);
    }
    // Add more content types as needed
  }
}
