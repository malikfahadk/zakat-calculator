import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'zakat.dart';

class GeminiService {
  GeminiService(this.config);

  final AppConfig config;

  Future<String> explain(ZakatInput input, String question) async {
    final key = config.geminiApiKey;
    if (key == null || key.isEmpty) {
      throw GeminiException('Gemini integration is not configured', 503);
    }
    final trimmedQuestion = question.trim();
    final safeQuestion = trimmedQuestion.length > 1000
        ? trimmedQuestion.substring(0, 1000)
        : trimmedQuestion;
    final prompt = '''
You are a careful Zakat calculator assistant. Explain the following calculation
in simple language. Do not issue a religious ruling; recommend consulting a
qualified scholar for questions about personal circumstances.
Calculation: ${jsonEncode(input.toJson())}
User question: $safeQuestion
''';
    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '${config.geminiModel}:generateContent?key=$key',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'contents': [{'parts': [{'text': prompt}]}]}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GeminiException('Gemini request failed', 502);
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = body['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw GeminiException('Gemini returned no answer', 502);
    }
    final candidate = candidates.first;
    final content = candidate is Map ? candidate['content'] : null;
    final parts = content is Map ? content['parts'] : null;
    if (parts is! List || parts.isEmpty) {
      throw GeminiException('Gemini returned no answer', 502);
    }
    final firstPart = parts.first;
    if (firstPart is! Map || firstPart['text'] == null) {
      throw GeminiException('Gemini returned no answer', 502);
    }
    return firstPart['text'].toString();
  }
}

class GeminiException implements Exception {
  const GeminiException(this.message, this.statusCode);
  final String message;
  final int statusCode;
}
