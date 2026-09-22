class FeedbackResult {
  final int content;
  final int clarity;
  final int confidence;
  final String feedback;
  final List<String> strong;
  final List<String> weak;

  const FeedbackResult({
    required this.content,
    required this.clarity,
    required this.confidence,
    required this.feedback,
    required this.strong,
    required this.weak,
  });

  factory FeedbackResult.fromJson(Map<String, dynamic> json) {
    return FeedbackResult(
      content: (json['content'] as num?)?.toInt() ?? 5,
      clarity: (json['clarity'] as num?)?.toInt() ?? 5,
      confidence: (json['confidence'] as num?)?.toInt() ?? 5,
      feedback:
          json['feedback'] as String? ??
          'Could not analyse answer. Please try again.',
      strong:
          (json['strong'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      weak:
          (json['weak'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  static FeedbackResult get defaultResult => const FeedbackResult(
    content: 5,
    clarity: 5,
    confidence: 5,
    feedback: 'Could not analyse answer. Please try again.',
    strong: [],
    weak: [],
  );

  double get averageScore => (content + clarity + confidence) / 3.0;

  Map<String, dynamic> toJson() => {
    'content': content,
    'clarity': clarity,
    'confidence': confidence,
    'feedback': feedback,
    'strong': strong,
    'weak': weak,
  };
}
