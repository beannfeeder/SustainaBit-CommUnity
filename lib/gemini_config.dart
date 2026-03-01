import 'package:flutter_dotenv/flutter_dotenv.dart';

// Load Gemini API key from environment variables
String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
