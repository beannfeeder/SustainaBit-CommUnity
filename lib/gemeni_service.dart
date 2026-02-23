import 'dart:convert';
import 'package:http/http.dart' as http;
import 'gemini_config.dart';

class GeminiService {
  static Future<String> generate(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$geminiApiKey',
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

    // Check if the request was successful
    if (response.statusCode != 200) {
      throw Exception('API request failed with status ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    
    // Check if the response has the expected structure
    if (data == null) {
      throw Exception('Received null response from API');
    }
    
    if (data['candidates'] == null || (data['candidates'] as List).isEmpty) {
      // Check for API error message
      if (data['error'] != null) {
        throw Exception('API Error: ${data['error']['message'] ?? 'Unknown error'}');
      }
      throw Exception('No candidates in API response. Response: ${response.body}');
    }
    
    final candidate = data['candidates'][0];
    if (candidate['content'] == null || 
        candidate['content']['parts'] == null || 
        (candidate['content']['parts'] as List).isEmpty) {
      throw Exception('Invalid response structure from API');
    }
    
    return candidate['content']['parts'][0]['text'];
  }
}
