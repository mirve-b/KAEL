import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get geminiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError(
        'GEMINI_API_KEY is missing. Add it to your .env file at the project root.',
      );
    }
    return key;
  }
}
