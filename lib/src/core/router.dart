import 'dart:io';
import 'package:wailuku/src/http/request.dart';
import 'package:wailuku/src/http/response.dart';
import 'package:wailuku/wailuku.dart';

/// A class that handles routing of HTTP requests to their corresponding handlers.
///
/// The Router class is responsible for:
/// - Registering routes with their handlers
/// - Matching incoming requests to registered routes
/// - Extracting parameters from route paths
/// - Managing middleware execution
class Router {
  /// List of middleware functions that will be executed for each request.
  final List<Function> _middlewares = [];

  /// Map of routes organized by HTTP method.
  ///
  /// The structure is:
  /// ```dart
  /// {
  ///   'GET': { RegExp: Function },
  ///   'POST': { RegExp: Function },
  ///   ...
  /// }
  /// ```
  final Map<String, Map<RegExp, Function>> _routes = {};

  /// Registers a new route with the specified HTTP method, path pattern, and handler.
  ///
  /// [method] The HTTP method (e.g., 'GET', 'POST', etc.)
  /// [path] The path pattern that may include parameters (e.g., '/users/:id')
  /// [handler] The function that will handle requests matching this route
  ///
  /// Example:
  /// ```dart
  /// router.register('GET', '/users/:id', (req, res) {
  ///   res.send('User ${req.params['id']}');
  /// });
  /// ```
  void register(String method, String path, Function handler) {
    var pathRegex = _pathToRegExp(path);
    _routes.putIfAbsent(method, () => {})[pathRegex] = handler;
  }

  /// Routes an incoming HTTP request to the appropriate handler.
  ///
  /// This method:
  /// 1. Matches the request to a registered route
  /// 2. Extracts parameters from the path
  /// 3. Creates Request and Response objects
  /// 4. Parses the request body
  /// 5. Executes the handler
  ///
  /// [httpRequest] The incoming HTTP request to route
  void route(HttpRequest httpRequest) {
    // Parse the query string manually if needed
    var queryParams = <String, String>{};
    if (httpRequest.uri.query.isNotEmpty) {
      queryParams = Uri.splitQueryString(httpRequest.uri.query);
    }

    var methodRoutes = _routes[httpRequest.method];
    if (methodRoutes == null) {
      Response response = Response(httpRequest.response);
      ResponseUtils.sendError(response, "Method Not Allowed", statusCode: HttpStatus.methodNotAllowed);
      return;
    }

    // Get the path without query parameters
    var path = httpRequest.uri.path;
    if (path.isEmpty) path = '/';

    var matchedEntry = methodRoutes.entries.firstWhere(
      (entry) => entry.key.hasMatch(path),
      orElse: () => MapEntry(RegExp(''), (_, __) {})
    );

    if (matchedEntry.key.pattern.isNotEmpty) {
      var handler = matchedEntry.value;
      var params = _extractParams(matchedEntry.key, path);

      // Create a new request with the manually parsed query parameters
      var request = Request(httpRequest, params: params);
      Response response = Response(httpRequest.response);

      // Execute middleware chain
      if (_middlewares.isNotEmpty) {
        var iterator = _middlewares.iterator;
        _executeMiddlewares(httpRequest, iterator, () {
          _handleRequest(request, response, handler);
        });
      } else {
        _handleRequest(request, response, handler);
      }
    } else {
      Response response = Response(httpRequest.response);
      ResponseUtils.sendError(response, "Not Found", statusCode: HttpStatus.notFound);
    }
  }

  /// Handles the request after middleware execution.
  ///
  /// [request] The parsed request object
  /// [response] The response object
  /// [handler] The route handler function
  void _handleRequest(Request request, Response response, Function handler) {
    // For POST, PUT, and DELETE requests, parse the body
    if (['POST', 'PUT', 'DELETE'].contains(request.method)) {
      request.parseBody().then((_) {
        handler(request, response);
      }).catchError((e) {
        ResponseUtils.sendError(response, "Bad Request", statusCode: HttpStatus.badRequest);
      });
    } else {
      // For GET and other methods, execute handler directly
      handler(request, response);
    }
  }

  /// Converts a path pattern into a regular expression.
  ///
  /// This method:
  /// 1. Escapes special characters in the path
  /// 2. Converts parameter placeholders (e.g., ':id') into named capture groups
  ///
  /// [path] The path pattern to convert
  /// Returns a [RegExp] that can match the path pattern
  RegExp _pathToRegExp(String path) {
    // First, escape all special regex characters
    String escapedPath = RegExp.escape(path);
    
    // Then, replace the parameter placeholders with named capture groups
    String regexPattern = escapedPath.replaceAllMapped(
      RegExp(r':([a-zA-Z0-9_]+)'),
      (match) => '(?<${match[1]}>[^/]+)'
    );
    
    // Add start and end anchors
    return RegExp('^$regexPattern\$');
  }

  /// Extracts parameters from a path using a regular expression.
  ///
  /// [regExp] The regular expression used to match the path
  /// [path] The actual path to extract parameters from
  /// Returns a [Map] of parameter names to their values
  Map<String, String> _extractParams(RegExp regExp, String path) {
    var match = regExp.firstMatch(path);
    if (match == null) return {};
    
    return Map.fromEntries(
      match.groupNames.map((name) {
        var value = match.namedGroup(name);
        return MapEntry(name, value ?? '');
      })
    );
  }

  /// Executes middleware functions in sequence.
  ///
  /// This method:
  /// 1. Executes the current middleware
  /// 2. Calls the next middleware in sequence
  /// 3. Finally calls the provided [next] function
  ///
  /// [request] The HTTP request being processed
  /// [iterator] Iterator over the middleware functions
  /// [next] Function to call after all middleware has executed
  void _executeMiddlewares(HttpRequest request, Iterator<Function> iterator, Function next) {
    if (iterator.moveNext()) {
      iterator.current(request, () => _executeMiddlewares(request, iterator, next));
    } else {
      next();
    }
  }
}
