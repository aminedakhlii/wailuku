import 'package:wailuku/wailuku.dart';

void main() async {
  var server = WailukuServer();
  
  server.get('/', (Request req, Response res) {
    res
      ..send('Hello from GET!')
      ..close();
  });

  server.post('/', (Request req, Response res) {
    res
      ..send(req.body["key"])
      ..close();
  });

  server.put('/', (Request req, Response res) {
    res
      ..send('Hello from PUT!')
      ..close();
  });

  server.delete('/', (Request req, Response res) {
    res
      ..send('Hello from DELETE!')
      ..close();
  });

  await server.listen('localhost', 8080);
}
