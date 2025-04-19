# Wailuku

A minimalist Dart backend framework inspired by Express.js.

## Features

- Simple and intuitive API similar to Express.js
- Built-in routing system with parameter support
- Request body parsing for JSON and form data
- Query parameter handling
- Route parameter extraction
- Middleware support
- Clean and maintainable codebase

## Getting Started

### Installation

Add Wailuku to your `pubspec.yaml`:

```yaml
dependencies:
  wailuku: ^0.1.0
```

### Basic Usage

```dart
import 'package:wailuku/wailuku.dart';

void main() async {
  var server = WailukuServer();
  
  // GET request
  server.get('/', (Request req, Response res) {
    res.send('Hello World!');
  });

  // POST request with JSON body
  server.post('/users', (Request req, Response res) {
    var name = req.body['name'];
    var age = req.body['age'];
    
    res.json({
      'message': 'User created',
      'data': {'name': name, 'age': age}
    });
  });

  // Route with parameters
  server.get('/users/:id', (Request req, Response res) {
    var userId = req.getParam('id');
    res.send('User ID: $userId');
  });

  // Query parameters
  server.get('/search', (Request req, Response res) {
    var query = req.getQuery('q');
    res.send('Search query: $query');
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

  // Single middleware
  server.get("/single-middleware", simpleMiddleware, (req, res) => res.send("Hello"));

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

  await server.listen('localhost', 8080);
}
```

## API Reference

### Request

The `Request` class provides access to:
- Request body (`req.body`)
- Query parameters (`req.query`)
- Route parameters (`req.params`)
- HTTP method (`req.method`)

### Response

The `Response` class provides methods for:
- Sending text responses (`res.send()`)
- Sending JSON responses (`res.json()`)
- Setting status codes (`res.status()`)
- Managing response headers

### Routing

Routes can be registered using:
- `server.get(path, handler)`
- `server.post(path, handler)`
- `server.put(path, handler)`
- `server.delete(path, handler)`

Path patterns can include parameters:
- `/users/:id` - Matches `/users/123`
- `/posts/:postId/comments/:commentId` - Matches `/posts/123/comments/456`

## Example

Check out the [example](example/main.dart) for a complete CRUD API implementation.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.
