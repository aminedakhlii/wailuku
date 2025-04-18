import 'dart:io';
import 'router.dart';
import '../http/request.dart';
import '../http/response.dart';

/// A server class that provides a simple interface for creating HTTP servers.
///
/// WailukuServer is the main entry point for creating web applications with Wailuku.
/// It provides methods for:
/// - Registering route handlers for different HTTP methods
/// - Starting and managing the HTTP server
/// - Handling incoming requests
class WailukuServer {
  /// The underlying HTTP server instance.
  HttpServer? _server;

  /// The router instance that handles request routing.
  final Router _router = Router();

  /// Creates a new WailukuServer instance.
  WailukuServer();

  /// Adds a global middleware function
  void use(Function(Request, Response, Function) middleware) {
    _router.use(middleware);
  }

  /// Adds a path-specific middleware function
  void usePath(String path, Function(Request, Response, Function) middleware) {
    _router.usePath(path, middleware);
  }

  /// Registers a GET route with optional middleware
  void get(
    String path, 
    [dynamic middleware, 
    Function(Request, Response)? handler]
  ) {
    if (handler == null) {
      if (middleware is Function(Request, Response)) {
        handler = middleware;
        middleware = null;
      } else {
        throw ArgumentError('Handler must be provided');
      }
    }
    _router.register('GET', path, middleware, handler);
  }

  /// Registers a POST route with optional middleware
  void post(
    String path, 
    [dynamic middleware, 
    Function(Request, Response)? handler]
  ) {
    if (handler == null) {
      if (middleware is Function(Request, Response)) {
        handler = middleware;
        middleware = null;
      } else {
        throw ArgumentError('Handler must be provided');
      }
    }
    _router.register('POST', path, middleware, handler);
  }

  /// Registers a PUT route with optional middleware
  void put(
    String path, 
    [dynamic middleware, 
    Function(Request, Response)? handler]
  ) {
    if (handler == null) {
      if (middleware is Function(Request, Response)) {
        handler = middleware;
        middleware = null;
      } else {
        throw ArgumentError('Handler must be provided');
      }
    }
    _router.register('PUT', path, middleware, handler);
  }

  /// Registers a DELETE route with optional middleware
  void delete(
    String path, 
    [dynamic middleware, 
    Function(Request, Response)? handler]
  ) {
    if (handler == null) {
      if (middleware is Function(Request, Response)) {
        handler = middleware;
        middleware = null;
      } else {
        throw ArgumentError('Handler must be provided');
      }
    }
    _router.register('DELETE', path, middleware, handler);
  }

  /// Starts the HTTP server and begins listening for requests.
  ///
  /// This method:
  /// 1. Binds the server to the specified address and port
  /// 2. Prints a startup message
  /// 3. Begins listening for incoming requests
  /// 4. Routes each request to the appropriate handler
  ///
  /// [address] The address to bind to (e.g., 'localhost' or '0.0.0.0')
  /// [port] The port number to listen on
  ///
  /// Example:
  /// ```dart
  /// await server.listen('localhost', 8080);
  /// ```
  Future<void> listen(String address, int port) async {
    _server = await HttpServer.bind(address, port);
    print('Server running on http://$address:$port');
    await for (HttpRequest request in _server!) {
      _router.route(request);
    }
  }
}
