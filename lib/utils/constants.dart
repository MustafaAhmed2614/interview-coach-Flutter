import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF03DAC6);

  // Backgrounds
  static const Color bgDark = Color(0xFF0F0F1A);
  static const Color cardDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF16213E);

  // Score colors
  static const Color contentScore = Color(0xFF378ADD);
  static const Color clarityScore = Color(0xFF7F77DD);
  static const Color confidenceScore = Color(0xFF1D9E75);

  // Difficulty
  static const Color easy = Color(0xFF4CAF50);
  static const Color medium = Color(0xFFFFC107);
  static const Color hard = Color(0xFFF44336);

  // Text
  static const Color textPrimary = Color(0xFFEAEAFF);
  static const Color textSecondary = Color(0xFF9E9EC8);
  static const Color textMuted = Color(0xFF5A5A8A);

  // Chips
  static const Color strongChip = Color(0xFF1B4332);
  static const Color weakChip = Color(0xFF4A1515);
  static const Color strongChipText = Color(0xFF52B788);
  static const Color weakChipText = Color(0xFFFF6B6B);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0F0F1A), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppConstants {
  static const String appName = 'InterviewCoach';
  static const String appSubtitle = 'Practice. Improve. Get hired.';
  static const String appVersion = '1.0.0';
  static const String geminiModel = 'gemini-1.5-flash';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String apiKeyStorageKey = 'gemini_api_key';

  static const List<String> jobRoles = [
    'Flutter Developer',
    'Frontend Developer',
    'Backend Developer',
    'Full Stack Developer',
    'Data Scientist',
    'Product Manager',
    'UI/UX Designer',
    'DevOps Engineer',
    'Android Developer',
    'iOS Developer',
  ];

  static const List<String> interviewTypes = [
    'Technical',
    'Behavioural',
    'HR Round',
  ];

  static const List<String> difficulties = ['Easy', 'Medium', 'Hard'];

  static const List<int> questionCounts = [3, 5, 7, 10];

  static const List<String> ttsLanguages = ['en-US', 'en-GB'];

  static const List<String> ttsLanguageLabels = [
    'English (US)',
    'English (UK)',
  ];
}

class AppRoutes {
  static const String home = '/';
  static const String session = '/session';
  static const String feedback = '/feedback';
  static const String summary = '/summary';
  static const String history = '/history';
  static const String settings = '/settings';
}
