class PromptBuilder {
  static String generateQuestionsPrompt({
    required String role,
    required String type,
    required String difficulty,
    required int count,
  }) {
    return '''You are a senior interviewer hiring for a $role position. Generate exactly $count ${difficulty.toLowerCase()} level $type interview questions. Return ONLY a valid JSON array of strings, no explanation, no markdown, no extra text.
Example format: ["Question 1?", "Question 2?"]''';
  }

  static String getFeedbackPrompt({
    required String question,
    required String transcript,
    required String role,
  }) {
    return '''You are an expert interview coach evaluating a candidate for a $role position. Analyse their interview answer below.

Question: $question
Candidate's Answer: $transcript

Return ONLY a valid JSON object with exactly these keys:
{
  "content": <integer 0-10>,
  "clarity": <integer 0-10>,
  "confidence": <integer 0-10>,
  "feedback": <string, 2-3 sentences of constructive feedback>,
  "strong": <array of 2-3 strong phrases from their answer>,
  "weak": <array of 2-3 phrases or areas to improve>
}
Return ONLY the JSON, no markdown, no explanation.''';
  }
}
