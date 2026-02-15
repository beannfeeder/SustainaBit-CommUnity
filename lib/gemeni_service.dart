import 'dart:convert';
import 'package:http/http.dart' as http;
import 'gemini_config.dart';

class GeminiService {
  static Future<String> generate(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'];
  }
}
