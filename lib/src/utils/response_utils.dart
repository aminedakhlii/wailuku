import 'dart:io';

import 'package:wailuku/wailuku.dart';

class ResponseUtils {
  static void sendOk(Response res, String message) {
    res
      ..status(200)
      ..send(message)
      ..close();
  }

  static void sendError(Response res, String message, {int statusCode = HttpStatus.internalServerError}) {
    res
      ..status(statusCode)
      ..send(message)
      ..close();
  }
}
