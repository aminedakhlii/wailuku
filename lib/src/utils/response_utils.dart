import 'dart:io';

import 'package:wailuku/wailuku.dart';

/// A utility class that provides common response handling methods.
///
/// This class contains static methods for sending standardized responses,
/// such as success and error responses.
class ResponseUtils {
  /// Sends a successful response with a 200 status code.
  ///
  /// This method:
  /// 1. Sets the status code to 200 (OK)
  /// 2. Sends the message
  /// 3. Closes the response
  ///
  /// [res] The Response object to send the response through
  /// [message] The success message to send
  ///
  /// Example:
  /// ```dart
  /// ResponseUtils.sendOk(res, 'Operation completed successfully');
  /// ```
  static void sendOk(Response res, String message) {
    res
      ..status(200)
      ..send(message)
      ..close();
  }

  /// Sends an error response with the specified status code.
  ///
  /// This method:
  /// 1. Sets the status code (defaults to 500)
  /// 2. Sends the error message
  /// 3. Closes the response
  ///
  /// [res] The Response object to send the response through
  /// [message] The error message to send
  /// [statusCode] The HTTP status code to use (defaults to 500)
  ///
  /// Example:
  /// ```dart
  /// ResponseUtils.sendError(res, 'Resource not found', statusCode: 404);
  /// ```
  static void sendError(Response res, String message, {int statusCode = HttpStatus.internalServerError}) {
    res
      ..status(statusCode)
      ..send(message)
      ..close();
  }
}