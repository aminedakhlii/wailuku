import 'dart:convert';
import 'dart:io';

class Request {
  final HttpRequest _request;
  late final Map<String, String> queryParameters;
  late final dynamic body;

  Request(this._request) {
    queryParameters = _request.uri.queryParameters;
  }

  Future<void> parseBody() async {
    if (_request.headers.contentType?.mimeType == 'application/json') {
      var content = await utf8.decoder.bind(_request).join();
      body = jsonDecode(content);
    } else if (_request.headers.contentType?.mimeType == 'application/x-www-form-urlencoded') {
      var content = await utf8.decoder.bind(_request).join();
      body = Uri.splitQueryString(content);
    }
    // Add more content types as needed
  }
}
