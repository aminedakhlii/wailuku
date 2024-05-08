import 'dart:io';

import 'package:wailuku/src/http/request.dart';
import 'package:wailuku/src/http/response.dart';
import 'package:wailuku/wailuku.dart';

class Router {
  final List<Function> _middlewares = [];
  final Map<String, Map<String, Function>> _routes = {};

  void use(Function middleware) {
    _middlewares.add(middleware);
  }

  void register(String method, String path, Function handler) {
    _routes.putIfAbsent(method, () => {})[path] = handler;
  }

  void route(HttpRequest request) {
    var methodRoutes = _routes[request.method];
    var handler = methodRoutes?[request.uri.path];
    Function next = () {
      if (handler != null) {
        //convert the request to a Request object to parse the body and queryParams
        Request parsableRequest = Request(request);
        Response response = Response(request.response);
        parsableRequest.parseBody().then((_) {
          handler(parsableRequest, response);
        }).catchError((e) {
          ResponseUtils.sendError(response, "Internal Server Error");
        });
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found')
          ..close();
      }
    };

    // Execute middlewares in sequence, finally calling the handler
    _executeMiddlewares(request, _middlewares.iterator, next);
  }

  void _executeMiddlewares(HttpRequest request, Iterator<Function> iterator, Function next) {
    if (iterator.moveNext()) {
      iterator.current(request, () => _executeMiddlewares(request, iterator, next));
    } else {
      next();
    }
  }
}
