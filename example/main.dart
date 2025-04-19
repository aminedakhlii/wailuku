import 'package:wailuku/wailuku.dart';

void main() async {
  // Create a new server instance
  var server = WailukuServer();
  
  // Root route - GET
  server.get('/', (Request req, Response res) {
    res.send('Hello from GET!');
  });

  // Root route - POST
  server.post('/', (){}, (Request req, Response res) {
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
    var page = req.getQuery('page');
    var limit = req.getQuery('limit');
    
    // Return paginated response
    res.json({
      'page': page,
      'limit': limit,
      'users': [
        // Add your user data here
      ]
    });
  });

  // PUT /users/:id/comment/:id - Update a user
  server.put('/users/:id/comment/:commentId', (Request req, Response res) {
    // Get user ID from route parameters
    var userId = req.getParam('id');
    var commentId = req.getParam('commentId');
    
    // Get update data from request body
    var name = req.body['name'];
    var age = req.body['age'];

    // Validate required fields
    if (name != null && age != null) {
      // Return success response
      res.json({
        'message': 'User updated successfully',
        'userId': userId,
        'commentId': commentId,
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

  //Middleware examples 

  // simple middleware functions
  void simpleMiddleware(Request req, Response res, Function next) {
    print('simple middleware');
    next();
  }

  void simpleMiddleware2(Request req, Response res, Function next) {
    print('simple middleware 2');
    next();
  }

  // a middleware that parses the body of the request
  void simpleMiddleware3(Request req, Response res, Function next) {
    print(req.body);
    print('simple middleware 2');
    next();
  }

  // Single middleware
  server.get("/single-middleware", simpleMiddleware, (req, res) => res.send("Hello"));

  // an application of a middleware that parses the body of the request
  server.post("/single-middleware", simpleMiddleware3, (req, res) => res.send("Hello"));

  // Multiple middlewares
  server.get("/multiple-middlewares", [
    simpleMiddleware,
    simpleMiddleware2
  ], (req, res) => res.send("Hello"));

  // No middleware
  server.get("/no-middleware", (req, res) => res.send("Hello"));

  // Register a Global middleware
  server.use((req, res, next) { 
    print('Global middleware');
    next();
  });

  // Register a Route-specific middleware
  server.usePath("/users", (req, res, next) {
    print('Route-specific middleware');
    next();
  });

  // Start the server
  await server.listen('localhost', 8080);
  print('Server running at http://localhost:8080');
}
