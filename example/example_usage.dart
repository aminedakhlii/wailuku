import 'package:wailuku/wailuku.dart';

void main() async {
  // Create a new server instance
  var server = WailukuServer();
  
  // Root route - GET
  server.get('/', (Request req, Response res) {
    res.send('Hello from GET!');
  });

  // Root route - POST
  server.post('/', (Request req, Response res) {
    // Access the parsed request body
    var name = req.body['name'];
    var age = req.body['age'];

    // Validate required fields
    if (name != null && age != null) {
      // Send success response with the received data
      res.json({
        'message': 'Data received successfully',
        'data': {
          'name': name,
          'age': age
        }
      });
    } else {
      // Send error response for missing data
      res.status(400).send('Missing name or age in the request body');
    }
  });

  // User routes
  // GET /users - List users with pagination
  server.get('/users', (Request req, Response res) {
    // Get pagination parameters from query
    var page = req.query['page'];
    var limit = req.query['limit'];
    
    // Return paginated response
    res.json({
      'page': page,
      'limit': limit,
      'users': [
        // Add your user data here
      ]
    });
  });

  // PUT /users/:id - Update a user
  server.put('/users/:id', (Request req, Response res) {
    // Get user ID from route parameters
    var userId = req.getParam('id');
    
    // Get update data from request body
    var name = req.body['name'];
    var age = req.body['age'];

    // Validate required fields
    if (name != null && age != null) {
      // Return success response
      res.json({
        'message': 'User updated successfully',
        'userId': userId,
        'data': {
          'name': name,
          'age': age
        }
      });
    } else {
      // Return error response
      res.status(400).send('Missing name or age in the request body');
    }
  });

  // DELETE /users/:id - Delete a user
  server.delete('/users/:id', (Request req, Response res) {
    // Get user ID from route parameters
    var userId = req.getParam('id');
    
    // Add your deletion logic here
    
    // Return success response
    res.json({
      'message': 'User deleted successfully',
      'userId': userId
    });
  });

  // Start the server
  await server.listen('localhost', 8080);
  print('Server running at http://localhost:8080');
}
