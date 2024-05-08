import 'dart:io';
import 'router.dart';

class WailukuServer {
  HttpServer? _server;
  final Router _router = Router();

  WailukuServer();

  void get(String path, Function handler) {
    _router.register('GET', path, handler);
  }

  void post(String path, Function handler) {
    _router.register('POST', path, handler);
  }

  void put(String path, Function handler) {
    _router.register('PUT', path, handler);
  }

  void delete(String path, Function handler) {
    _router.register('DELETE', path, handler);
  }

  Future<void> listen(String address, int port) async {
    _server = await HttpServer.bind(address, port);
    print('Server running on http://$address:$port');
    await for (HttpRequest request in _server!) {
      _router.route(request);
    }
  }
}
