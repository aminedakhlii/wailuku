import 'dart:io';

void loggerMiddleware(HttpRequest request, Function next) {
  print('Request made to ${request.uri}');
  next(request);
}
