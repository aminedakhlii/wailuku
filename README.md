# Wailuku

A minimalist backend framework for Dart, designed to provide a simple and intuitive way to build scalable server-side applications.

## Getting Started

To use the Wailuku framework, you'll need to have Dart installed on your machine. You can download Dart from the [official Dart SDK page](https://dart.dev/get-dart).

### Installation

1. Create a new Dart project:
   ```bash
   mkdir my_project
   cd my_project
   dart create .
   ```
2. Add Wailuku to your pubspec.yaml file:
   ```
   dependencies:
     wailuku:
       git: https://github.com/aminedakhlii/wailuku.git
   ```
3. Run the following command to get the package:
   ```
   dart pub get
   ```
### Example Usage

Here is a simple example to get you started with Wailuku:

```
// Import the Wailuku package
import 'package:wailuku/wailuku.dart';

void main() {
  var server = WailukuServer();

  // Define a simple GET route
  server.get('/', (req, res) {
    res.send('Welcome to Wailuku!');
  });

  // Start the server
  server.listen('localhost', 8080);
}
```

Run your application: 

```
dart run yourProjectMainEntry.dart
```

Visit http://localhost:8080 in your browser to see the server in action.

### Reasons to use Dart on the server

1. Robust Community and Support: Dart boasts a thriving community and extensive support through documentation and third-party packages.
2. Excellent Package Manager: Dart's package manager, Pub, provides a vast array of libraries and tools, facilitating integration with databases, authentication services, and more.
3. Firebase and ORM Integration: Dart's compatibility with Firebase and various ORM tools makes it an excellent choice for developing complex applications.
4. Underutilized on the Server Side: While Dart is popular for client-side development, especially with Flutter, its potential on the server side remains largely untapped. Wailuku aims to bridge this gap, demonstrating Dart's capabilities beyond mobile and frontend development.

### License 

Wailuku is BSD 3-clause licensed

### Contributions

Contributions are welcome! Please fork the repository and submit pull requests, or file issues with any suggestions, bugs, or enhancements.

Thank you for considering Wailuku for your next server-side project in Dart!
