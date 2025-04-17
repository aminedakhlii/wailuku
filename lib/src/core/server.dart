import 'dart:io';
import 'router.dart';

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

  /// Registers a handler for GET requests at the specified path.
  ///
  /// [path] The URL path pattern to match (e.g., '/users/:id')
  /// [handler] The function to handle matching requests
  ///
  /// Example:
  /// ```dart
  /// server.get('/users/:id', (req, res) {
  ///   res.send('User ${req.params['id']}');
  /// });
  /// ```
  void get(String path, Function handler) {
    _router.register('GET', path, handler);
  }

  /// Registers a handler for POST requests at the specified path.
  ///
  /// [path] The URL path pattern to match
  /// [handler] The function to handle matching requests
  ///
  /// Example:
  /// ```dart
  /// server.post('/users', (req, res) {
  ///   // Handle user creation
  /// });
  /// ```
  void post(String path, Function handler) {
    _router.register('POST', path, handler);
  }

  /// Registers a handler for PUT requests at the specified path.
  ///
  /// [path] The URL path pattern to match
  /// [handler] The function to handle matching requests
  ///
  /// Example:
  /// ```dart
  /// server.put('/users/:id', (req, res) {
  ///   // Handle user update
  /// });
  /// ```
  void put(String path, Function handler) {
    _router.register('PUT', path, handler);
  }

  /// Registers a handler for DELETE requests at the specified path.
  ///
  /// [path] The URL path pattern to match
  /// [handler] The function to handle matching requests
  ///
  /// Example:
  /// ```dart
  /// server.delete('/users/:id', (req, res) {
  ///   // Handle user deletion
  /// });
  /// ```
  void delete(String path, Function handler) {
    _router.register('DELETE', path, handler);
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
