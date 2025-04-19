---
layout: default
title: Wailuku - A Lightweight Dart Web Framework
---

# Wailuku

A lightweight, flexible, and easy-to-use web framework for Dart.

## Features

- Simple and intuitive API
- Middleware support
- Route parameters
- Request body parsing
- Response utilities
- Built-in error handling

## Getting Started

### Installation

Add Wailuku to your `pubspec.yaml`:

```yaml
dependencies:
  wailuku: ^1.0.0
```

### Basic Usage

```dart
import 'package:wailuku/wailuku.dart';

void main() async {
  final app = WailukuServer();

  // Define routes
  app.get('/', (req, res) {
    res.send('Hello, World!');
  });

  // Start the server
  await app.listen('localhost', 8080);
}
```

## Middleware

Wailuku supports both global and path-specific middleware:

```dart
// Global middleware
app.use((req, res, next) {
  print('Request received: ${req.method} ${req.path}');
  next();
});

// Path-specific middleware
app.usePath('/api', (req, res, next) {
  // API-specific middleware
  next();
});
```

## Route Parameters

Access route parameters in your handlers:

```dart
app.get('/users/:id', (req, res) {
  final userId = req.params['id'];
  res.send('User ID: $userId');
});
```

## Request Body

Parse request bodies for POST, PUT, and DELETE requests:

```dart
app.post('/users', (req, res) async {
  final body = await req.body;
  // Handle the request body
});
```

## Response Utilities

Use the built-in response utilities:

```dart
app.get('/api/data', (req, res) {
  ResponseUtils.sendOk(res, 'Data retrieved successfully');
});

app.get('/api/error', (req, res) {
  ResponseUtils.sendError(res, 'Something went wrong', statusCode: 500);
});
```

## API Reference

### WailukuServer

- `use(middleware)`: Add global middleware
- `usePath(path, middleware)`: Add path-specific middleware
- `get(path, [middleware, handler])`: Register GET route
- `post(path, [middleware, handler])`: Register POST route
- `put(path, [middleware, handler])`: Register PUT route
- `delete(path, [middleware, handler])`: Register DELETE route
- `listen(address, port)`: Start the server

### Request

- `method`: HTTP method
- `path`: Request path
- `params`: Route parameters
- `body`: Request body (async)
- `headers`: Request headers

### Response

- `status(code)`: Set status code
- `send(data)`: Send response data
- `close()`: Close the response

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

Wailuku is licensed under the MIT License. 