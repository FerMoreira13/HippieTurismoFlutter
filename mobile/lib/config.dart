import 'package:firebase_core/firebase_core.dart';

abstract final class Config {
  static const environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  static const demo = bool.fromEnvironment('DEMO_MODE', defaultValue: true);
  static const maps = bool.fromEnvironment('MAPS_ENABLED', defaultValue: false);
  static const api = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
  static FirebaseOptions get firebase => const FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    iosBundleId: 'br.com.hippieturismo.hippieTurismo',
  );
}
