import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/feedback_result.dart';
import '../utils/constants.dart';
import '../utils/prompt_builder.dart';

class ClaudeService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  static const _secureStorage = FlutterSecureStorage();

  static Future<String?> getApiKey() async {
    return await _secureStorage.read(key: AppConstants.apiKeyStorageKey);
  }

  static Future<void> saveApiKey(String key) async {
    await _secureStorage.write(
      key: AppConstants.apiKeyStorageKey,
      value: key,
    );
  }

  // ─── Gemini request helper ──────────────────────────────────────────────────

  static Future<String?> _callGemini({
    required String prompt,
    required String apiKey,
    required BuildContext context,
    int retryCount = 0,
  }) async {
    try {
      final url = '${AppConstants.geminiBaseUrl}?key=$apiKey';
      final response = await _dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          },
        },
      );
      final text = response
          .data['candidates'][0]['content']['parts'][0]['text'] as String;
      return text;
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      // Auto-retry on 429 up to 3 times with increasing delay
      if (status == 429 && retryCount < 3) {
        final waitSeconds = (retryCount + 1) * 5;
        await Future.delayed(Duration(seconds: waitSeconds));
        return _callGemini(
          prompt: prompt,
          apiKey: apiKey,
          context: context,
          retryCount: retryCount + 1,
        );
      }

      if (context.mounted) {
        // Extract real error message from Google's response
        String msg;
        try {
          final body = e.response?.data;
          final googleMsg = body?['error']?['message'] as String?;
          msg = '[$status] ${googleMsg ?? e.message}';
        } catch (_) {
          msg = '[$status] ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
              textColor: Colors.white,
            ),
          ),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─── Public API ─────────────────────────────────────────────────────────────

  static Future<List<String>> generateQuestions({
    required String role,
    required String type,
    required String difficulty,
    required int count,
    required BuildContext context,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add your Gemini API key in Settings'),
            backgroundColor: Color(0xFF6C63FF),
          ),
        );
      }
      return [];
    }

    final prompt = PromptBuilder.generateQuestionsPrompt(
      role: role,
      type: type,
      difficulty: difficulty,
      count: count,
    );

    final text = await _callGemini(
      prompt: prompt,
      apiKey: apiKey,
      context: context,
    );
    if (text == null) return [];

    try {
      final cleaned = _cleanJson(text);
      final decoded = jsonDecode(cleaned) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<FeedbackResult> getFeedback({
    required String question,
    required String transcript,
    required String role,
    required BuildContext context,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add your Gemini API key in Settings'),
            backgroundColor: Color(0xFF6C63FF),
          ),
        );
      }
      return FeedbackResult.defaultResult;
    }

    final prompt = PromptBuilder.getFeedbackPrompt(
      question: question,
      transcript: transcript,
      role: role,
    );

    final text = await _callGemini(
      prompt: prompt,
      apiKey: apiKey,
      context: context,
    );
    if (text == null) return FeedbackResult.defaultResult;

    try {
      final cleaned = _cleanJson(text);
      final decoded = jsonDecode(cleaned) as Map<String, dynamic>;
      return FeedbackResult.fromJson(decoded);
    } catch (_) {
      return FeedbackResult.defaultResult;
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  static String _cleanJson(String raw) {
    return raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
  }
}
