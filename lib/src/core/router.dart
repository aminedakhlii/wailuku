import 'dart:io';
import 'package:wailuku/src/http/request.dart';
import 'package:wailuku/src/http/response.dart';
import 'package:wailuku/wailuku.dart';

/// Class to hold the result of route pattern parsing
class RoutePattern {
  final RegExp regex;
  final List<String> paramNames;

  RoutePattern(this.regex, this.paramNames);
}

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

  /// Map of route patterns for parameterized routes
  final Map<String, RoutePattern> _routePatterns = {};

  /// Adds a global middleware function
  void use(Function(Request, Response, Function) middleware) {
    _middleware.add(middleware);
  }

  /// Adds a path-specific middleware function
  void usePath(String path, Function(Request, Response, Function) middleware) {
    _pathMiddlewares.putIfAbsent(path, () => []).add(middleware);
  }

  /// Converts a route pattern to a regular expression and extracts parameter names
  RoutePattern _parseRoutePattern(String pattern) {
    final segments = pattern.split('/');
    final paramNames = <String>[];
    final regexParts = <String>[];

    for (var segment in segments) {
      if (segment.startsWith(':')) {
        paramNames.add(segment.substring(1));
        regexParts.add('([^/]+)');
      } else {
        regexParts.add(RegExp.escape(segment));
      }
    }

    final regex = RegExp('^${regexParts.join('/')}\$');
    return RoutePattern(regex, paramNames);
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
    // Parse route pattern and extract parameters
    final routePattern = _parseRoutePattern(path);
    
    _routes[path] ??= {};
    _routes[path]![method] = handler;
    _routePatterns[path] = routePattern;

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
    
    // Find matching route pattern
    String? matchedRoute;
    Map<String, String>? params;
    
    for (final routePath in _routes.keys) {
      final routePattern = _routePatterns[routePath]!;
      final match = routePattern.regex.firstMatch(path);
      
      if (match != null) {
        matchedRoute = routePath;
        params = {};
        
        // Extract parameter values
        for (var i = 0; i < routePattern.paramNames.length; i++) {
          params[routePattern.paramNames[i]] = match.group(i + 1)!;
        }
        
        break;
      }
    }

    if (matchedRoute != null) {
      final handler = _routes[matchedRoute]?[method];
      
      if (handler != null) {
        // Create request with parameters
        final requestWithParams = Request(httpRequest, params: params);
        
        // Get all middleware that should be executed
        List<Function(Request, Response, Function)> allMiddleware = [];
        
        // Add path-specific middleware if any
        if (_pathMiddlewares.containsKey(matchedRoute)) {
          allMiddleware.addAll(_pathMiddlewares[matchedRoute]!);
        }

        // Execute middleware chain
        if (allMiddleware.isNotEmpty) {
          var iterator = allMiddleware.iterator;
          await _executeMiddlewares(requestWithParams, response, iterator, () async {
            await _handleRequest(requestWithParams, response, handler);
          });
        } else {
          await _handleRequest(requestWithParams, response, handler);
        }
      } else {
        response.statusCode = HttpStatus.methodNotAllowed;
        response.send('Method Not Allowed');
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
        try {
          await request.parseBody();
        } catch (e) {
          
        }
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
    try {
      await request.parseBody();
    } catch (e) {
      
    }
    if (iterator.moveNext()) {
      await iterator.current(request, response, () async {
        await _executeMiddlewares(request, response, iterator, next);
      });
    } else {
      await next();
    }
  }
}
