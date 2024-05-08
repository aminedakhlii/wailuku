import 'package:wailuku/wailuku.dart';

void main() async {
  var server = WailukuServer();
  
  server.get('/', (Request req, Response res) {
    res
      ..send('Hello from GET!')
      ..close();
  });

  server.post('/', (Request req, Response res) {
    var name = req.body['name'];
    var age = req.body['age'];

    // Perform some operations with the data
    if (name != null && age != null) {
      // Send a response indicating success and echo the received data
      res.status(200); // HTTP 200 OK
      res.json({
        'message': 'Data received successfully',
        'yourData': {
          'name': name,
          'age': age
        }
      });
    } else {
      // Send an error response if required data is missing
      res.status(400); // HTTP 400 Bad Request
      res.send('Missing name or age in the request body');
    }
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
