import 'package:hive/hive.dart';

part 'session_result.g.dart';

@HiveType(typeId: 0)
class SessionResult extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String role;

  @HiveField(2)
  late String interviewType;

  @HiveField(3)
  late String difficulty;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late List<String> questions;

  @HiveField(6)
  late List<String> transcripts;

  @HiveField(7)
  late List<int> contentScores;

  @HiveField(8)
  late List<int> clarityScores;

  @HiveField(9)
  late List<int> confidenceScores;

  @HiveField(10)
  late List<String> feedbacks;

  @HiveField(11)
  late List<String> strongPhrases;

  @HiveField(12)
  late List<String> weakPhrases;

  @HiveField(13)
  late double overallScore;

  SessionResult({
    required this.id,
    required this.role,
    required this.interviewType,
    required this.difficulty,
    required this.date,
    required this.questions,
    required this.transcripts,
    required this.contentScores,
    required this.clarityScores,
    required this.confidenceScores,
    required this.feedbacks,
    required this.strongPhrases,
    required this.weakPhrases,
    required this.overallScore,
  });

  double get avgContent =>
      contentScores.isEmpty
          ? 0
          : contentScores.reduce((a, b) => a + b) / contentScores.length;

  double get avgClarity =>
      clarityScores.isEmpty
          ? 0
          : clarityScores.reduce((a, b) => a + b) / clarityScores.length;

  double get avgConfidence =>
      confidenceScores.isEmpty
          ? 0
          : confidenceScores.reduce((a, b) => a + b) / confidenceScores.length;
}
