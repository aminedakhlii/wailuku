import 'dart:io';
import 'package:wailuku/src/http/request.dart';
import 'package:wailuku/src/http/response.dart';
import 'package:wailuku/wailuku.dart';

/// A class that handles routing of HTTP requests to their corresponding handlers.
///
/// The Router class is responsible for:
/// - Registering routes with their handlers
/// - Matching incoming requests to registered routes
/// - Managing middleware execution
class Router {
  /// List of global middleware functions
  final List<Function(Request, Response, Function)> _middleware = [];

  /// Map of path-specific middleware functions
  final Map<String, List<Function(Request, Response, Function)>> _pathMiddlewares = {};

  /// Map of routes organized by HTTP method and path.
  ///
  /// The structure is:
  /// ```dart
  /// {
  ///   '/path1': {
  ///     'GET': Function(Request, Response),
  ///     'POST': Function(Request, Response),
  ///   },
  ///   '/path2': {
  ///     'GET': Function(Request, Response),
  ///   }
  /// }
  /// ```
  final Map<String, Map<String, Function(Request, Response)>> _routes = {};

  /// Adds a global middleware function
  void use(Function(Request, Response, Function) middleware) {
    _middleware.add(middleware);
  }

  /// Adds a path-specific middleware function
  void usePath(String path, Function(Request, Response, Function) middleware) {
    _pathMiddlewares.putIfAbsent(path, () => []).add(middleware);
  }

  /// Registers a new route with the specified HTTP method, path, and handler.
  ///
  /// [method] The HTTP method (e.g., 'GET', 'POST', etc.)
  /// [path] The path pattern (e.g., '/users')
  /// [middleware] Optional middleware or list of middleware functions
  /// [handler] The handler function that will be executed for this route
  void register(
    String method, 
    String path, 
    dynamic middleware, 
    Function(Request, Response) handler
  ) {
    _routes[path] ??= {};
    _routes[path]![method] = handler;

    // Handle middleware
    if (middleware != null) {
      if (middleware is List) {
        // Convert List<dynamic> to List<Function(Request, Response, Function)>
        _pathMiddlewares[path] = middleware.whereType<Function(Request, Response, Function)>().toList();
      } else if (middleware is Function(Request, Response, Function)) {
        // Single middleware function
        _pathMiddlewares[path] = [middleware];
      }
    }
  }

  /// Routes an incoming HTTP request to the appropriate handler.
  ///
  /// This method:
  /// 1. Matches the request to a registered route
  /// 2. Creates Request and Response objects
  /// 3. Executes middleware
  /// 4. Executes the handler
  ///
  /// [httpRequest] The incoming HTTP request to route
  Future<void> route(HttpRequest httpRequest) async {
    final response = Response(httpRequest.response);
    final request = Request(httpRequest);

    // Execute global middleware
    for (final middleware in _middleware) {
      await middleware(request, response, () {});
    }

    // Find matching route
    final path = httpRequest.uri.path;
    final method = httpRequest.method;
    final handler = _routes[path]?[method];

    if (handler != null) {
      // Get all middleware that should be executed
      List<Function(Request, Response, Function)> allMiddleware = [];
      
      // Add path-specific middleware if any
      if (_pathMiddlewares.containsKey(path)) {
        allMiddleware.addAll(_pathMiddlewares[path]!);
      }

      // Execute middleware chain
      if (allMiddleware.isNotEmpty) {
        var iterator = allMiddleware.iterator;
        await _executeMiddlewares(request, response, iterator, () async {
          await _handleRequest(request, response, handler);
        });
      } else {
        await _handleRequest(request, response, handler);
      }
    } else {
      response.statusCode = HttpStatus.notFound;
      response.send('Not Found');
    }
  }

  /// Handles the request after middleware execution.
  Future<void> _handleRequest(Request request, Response response, Function(Request, Response) handler) async {
    // For POST, PUT, and DELETE requests, parse the body
    if (['POST', 'PUT', 'DELETE'].contains(request.method)) {
      try {
        await request.parseBody();
        await handler(request, response);
      } catch (e) {
        response.statusCode = HttpStatus.badRequest;
        response.send('Bad Request');
      }
    } else {
      await handler(request, response);
    }
  }

  /// Executes middleware functions in sequence.
  Future<void> _executeMiddlewares(
    Request request,
    Response response,
    Iterator<Function(Request, Response, Function)> iterator,
    Function next
  ) async {
    if (iterator.moveNext()) {
      await iterator.current(request, response, () async {
        await _executeMiddlewares(request, response, iterator, next);
      });
    } else {
      await next();
    }
  }
}
