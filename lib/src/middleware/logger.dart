import 'dart:io';

/// A middleware function that logs HTTP requests.
///
/// This middleware:
/// 1. Logs the URI of each incoming request
/// 2. Passes control to the next middleware in the chain
///
/// [request] The HTTP request being processed
/// [next] The next function in the middleware chain
///
/// Example usage:
/// ```dart
/// server.use(loggerMiddleware);
/// ```
///
/// This will log all incoming requests to the console in the format:
/// "Request made to /path/to/resource"
void loggerMiddleware(HttpRequest request, Function next) {
  print('Request made to ${request.uri}');
  next(request);
}
