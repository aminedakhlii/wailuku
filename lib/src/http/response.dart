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

  /// Creates a new Response instance from an HttpResponse.
  ///
  /// [response] The underlying HTTP response
  Response(this._response);

  /// Sets the HTTP status code for the response.
  ///
  /// [statusCode] The HTTP status code to set (e.g., 200, 404, 500)
  ///
  /// Example:
  /// ```dart
  /// res.status(200); // OK
  /// res.status(404); // Not Found
  /// ```
  void status(int statusCode) {
    _response.statusCode = statusCode;
  }

  /// Sends a text response and closes the connection.
  ///
  /// [message] The text message to send in the response body
  ///
  /// Example:
  /// ```dart
  /// res.send('Hello, World!');
  /// ```
  void send(String message) {
    _response.write(message);
    close();
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
  ///
  /// Example:
  /// ```dart
  /// res.json({
  ///   'name': 'John',
  ///   'age': 30
  /// });
  /// ```
  void json(Map<String, dynamic> jsonData) {
    _response.headers.contentType = ContentType.json;
    _response.write(jsonEncode(jsonData));
    close();
  }

  /// Closes the HTTP response connection.
  ///
  /// This method should be called after sending the response to ensure
  /// the connection is properly closed.
  void close() {
    _response.close();
  }
}
