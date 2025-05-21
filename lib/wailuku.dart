/// A minimalist Dart backend framework inspired by Express.js.
///
/// This library provides a simple and intuitive way to create HTTP servers
/// and handle routing in Dart applications. It follows a similar pattern to
/// Express.js while maintaining Dart's idiomatic style.
///
/// Example:
/// ```dart
/// import 'package:wailuku/wailuku.dart';
///
/// void main() {
///   final app = Server();
///   app.get('/', (req, res) => res.send('Hello World!'));
///   app.listen(3000);
/// }
/// ```
library wailuku;

// Export core functionalities.
export 'src/core/server.dart';
export 'src/core/router.dart';

// Export http request and response.
export 'src/http/request.dart';
export 'src/http/response.dart';

// Export utilities.
export 'src/utils/response_utils.dart';

