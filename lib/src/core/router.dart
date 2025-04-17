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
  ///   // Handle the request
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
    var methodRoutes = _routes[httpRequest.method];
    var matchedEntry = methodRoutes?.entries.firstWhere(
      (entry) => entry.key.hasMatch(httpRequest.uri.path),
      orElse: () => null
    );

    if (matchedEntry != null) {
      var handler = matchedEntry.value;
      var params = _extractParams(matchedEntry.key, httpRequest.uri.path);

      Request parsableRequest = Request(httpRequest, params: params);
      Response response = Response(httpRequest.response);

      parsableRequest.parseBody().then((_) {
        handler(parsableRequest, response);
      }).catchError((e) {
        ResponseUtils.sendError(response, "Internal Server Error");
      });
    } else {
      Response response = Response(httpRequest.response);
      ResponseUtils.sendError(response, "Internal Server Error");
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
    String escapedPath = RegExp.escape(path).replaceAllMapped(
      RegExp(r'\\:([a-zA-Z0-9_]+)'),
      (match) => '(?<' + match[1] + '>[^/]+)'
    );
    return RegExp('^' + escapedPath + r'$');
  }

  /// Extracts parameters from a path using a regular expression.
  ///
  /// [regExp] The regular expression used to match the path
  /// [path] The actual path to extract parameters from
  /// Returns a [Map] of parameter names to their values
  Map<String, String> _extractParams(RegExp regExp, String path) {
    var match = regExp.firstMatch(path);
    return match != null
      ? Map.fromEntries(match.groupNames.map((name) => MapEntry(name, match.namedGroup(name))))
      : {};
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
