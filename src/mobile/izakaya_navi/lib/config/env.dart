import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get hotpepperApiKey {
    return dotenv.env['HOTPEPPER_API_KEY'] ?? '';
  }
} 