import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feedback_result.dart';

class SessionState {
  final List<String> questions;
  final int currentIndex;
  final bool isRecording;
  final String currentTranscript;
  final List<FeedbackResult> allFeedbacks;
  final List<String> allTranscripts;
  final bool isLoading;
  final String role;
  final String interviewType;
  final String difficulty;

  const SessionState({
    this.questions = const [],
    this.currentIndex = 0,
    this.isRecording = false,
    this.currentTranscript = '',
    this.allFeedbacks = const [],
    this.allTranscripts = const [],
    this.isLoading = false,
    this.role = '',
    this.interviewType = '',
    this.difficulty = '',
  });

  SessionState copyWith({
    List<String>? questions,
    int? currentIndex,
    bool? isRecording,
    String? currentTranscript,
    List<FeedbackResult>? allFeedbacks,
    List<String>? allTranscripts,
    bool? isLoading,
    String? role,
    String? interviewType,
    String? difficulty,
  }) {
    return SessionState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      isRecording: isRecording ?? this.isRecording,
      currentTranscript: currentTranscript ?? this.currentTranscript,
      allFeedbacks: allFeedbacks ?? this.allFeedbacks,
      allTranscripts: allTranscripts ?? this.allTranscripts,
      isLoading: isLoading ?? this.isLoading,
      role: role ?? this.role,
      interviewType: interviewType ?? this.interviewType,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  bool get isLastQuestion => currentIndex >= questions.length - 1;
  String? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(const SessionState());

  void startSession({
    required List<String> questions,
    required String role,
    required String interviewType,
    required String difficulty,
  }) {
    state = SessionState(
      questions: questions,
      role: role,
      interviewType: interviewType,
      difficulty: difficulty,
    );
  }

  void setRecording(bool recording) {
    state = state.copyWith(isRecording: recording);
  }

  void updateTranscript(String transcript) {
    state = state.copyWith(currentTranscript: transcript);
  }

  void addFeedback(FeedbackResult feedback, String transcript) {
    final newFeedbacks = [...state.allFeedbacks, feedback];
    final newTranscripts = [...state.allTranscripts, transcript];
    state = state.copyWith(
      allFeedbacks: newFeedbacks,
      allTranscripts: newTranscripts,
    );
  }

  void nextQuestion() {
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      currentTranscript: '',
      isRecording: false,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void reset() {
    state = const SessionState();
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>(
  (ref) => SessionNotifier(),
);
