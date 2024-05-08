import 'dart:convert';
import 'dart:io';

class Response {
  final HttpResponse _response;

  Response(this._response);

  void status(int statusCode) {
    _response.statusCode = statusCode;
  }

  void send(String message) {
    _response.write(message);
    close();
  }

  void json(Map<String, dynamic> jsonData) {
    _response.headers.contentType = ContentType.json;
    _response.write(jsonEncode(jsonData));
    close();
  }

  void close() {
    _response.close();
  }
}
