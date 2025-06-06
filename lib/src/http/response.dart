import 'dart:convert';
import 'dart:io';

/// A class that provides a convenient interface for sending HTTP responses.
///
/// The Response class wraps an HttpResponse and provides methods for:
/// - Setting HTTP status codes
/// - Sending text responses
/// - Sending JSON responses
/// - Managing response headers
class Response {
  /// The underlying HTTP response object.
  final HttpResponse _response;
  int _statusCode;

  /// Creates a new Response instance from an HttpResponse.
  ///
  /// [response] The underlying HTTP response
  Response(this._response) : _statusCode = 200;

  /// Get the current status code
  int get statusCode => _statusCode;

  /// Set the status code
  set statusCode(int code) {
    _statusCode = code;
    _response.statusCode = code;
  }

  /// Sets the HTTP status code for the response.
  ///
  /// [statusCode] The HTTP status code to set (e.g., 200, 404, 500)
  /// Returns this Response instance for method chaining
  ///
  /// Example:
  /// ```dart
  /// res.status(200).send('OK');
  /// ```
  Response status(int statusCode) {
    _response.statusCode = statusCode;
    return this;
  }

  /// Sends a text response and closes the connection.
  ///
  /// [message] The text message to send in the response body
  /// Returns this Response instance for method chaining
  ///
  /// Example:
  /// ```dart
  /// res.send('Hello, World!');
  /// ```
  Response send(String message) {
    _response.write(message);
    close();
    return this;
  }

  /// Sends a JSON response and closes the connection.
  ///
  /// This method:
  /// 1. Sets the content type to application/json
  /// 2. Encodes the data as JSON
  /// 3. Writes the JSON to the response
  /// 4. Closes the connection
  ///
  /// [jsonData] The data to send as JSON
  /// Returns this Response instance for method chaining
  ///
  /// Example:
  /// ```dart
  /// res.json({
  ///   'name': 'John',
  ///   'age': 30
  /// });
  /// ```
  Response json(Map<String, dynamic> jsonData) {
    _response.headers.contentType = ContentType.json;
    _response.write(jsonEncode(jsonData));
    close();
    return this;
  }

  /// Closes the HTTP response connection.
  ///
  /// This method should be called after sending the response to ensure
  /// the connection is properly closed.
  /// Returns this Response instance for method chaining
  void close() {
    _response.close();
  }
}
