import 'package:animate_do/animate_do.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';
import '../services/claude_service.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import '../utils/constants.dart';
import '../widgets/waveform_bar.dart';
import 'feedback_screen.dart';
import 'summary_screen.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  bool _answerRecorded = false;
  bool _isFetchingFeedback = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayQuestion());
  }

  Future<void> _autoPlayQuestion() async {
    final settings = ref.read(settingsProvider);
    final session = ref.read(sessionProvider);
    if (settings.autoPlayQuestion && session.currentQuestion != null) {
      await TtsService.speak(session.currentQuestion!);
    }
  }

  Future<void> _toggleRecording() async {
    final session = ref.read(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);

    if (session.isRecording) {
      await SttService.stopListening();
      notifier.setRecording(false);
      if (session.currentTranscript.isNotEmpty) {
        setState(() => _answerRecorded = true);
      }
    } else {
      await TtsService.stop();
      await SttService.initialize();
      notifier.setRecording(true);
      await SttService.startListening(
        onResult: (text) {
          notifier.updateTranscript(text);
        },
        onDone: () {
          notifier.setRecording(false);
          final t = ref.read(sessionProvider).currentTranscript;
          if (t.isNotEmpty) setState(() => _answerRecorded = true);
        },
      );
    }
  }

  Future<void> _nextQuestion() async {
    final session = ref.read(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);

    setState(() => _isFetchingFeedback = true);

    final feedback = await ClaudeService.getFeedback(
      question: session.currentQuestion ?? '',
      transcript: session.currentTranscript,
      role: session.role,
      context: context,
    );

    notifier.addFeedback(feedback, session.currentTranscript);
    setState(() {
      _isFetchingFeedback = false;
      _answerRecorded = false;
    });

    if (!mounted) return;

    final isLast = session.isLastQuestion;

    await Navigator.push(
      context,
      _slideRoute(
        FeedbackScreen(
          question: session.currentQuestion ?? '',
          transcript: session.currentTranscript,
          feedback: feedback,
          isLastQuestion: isLast,
          onNext: () {
            Navigator.pop(context);
            if (isLast) {
              Navigator.pushReplacement(
                context,
                _slideRoute(const SummaryScreen()),
              );
            } else {
              notifier.nextQuestion();
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _autoPlayQuestion(),
              );
            }
          },
        ),
      ),
    );
  }

  PageRoute _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    SttService.stopListening();
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final settings = ref.watch(settingsProvider);
    final total = session.questions.length;
    final current = session.currentIndex + 1;
    final progress = total > 0 ? current / total : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Question $current of $total',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.cardDark,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Question card
                      FadeInDown(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: AppColors.cardGradient,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Q$current',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      if (session.currentQuestion != null) {
                                        TtsService.speak(
                                          session.currentQuestion!,
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.volume_up_outlined,
                                      color: AppColors.secondary,
                                      size: 20,
                                    ),
                                    tooltip: 'Read question',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                session.currentQuestion ??
                                    'Loading question...',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Waveform + Mic
                      FadeInUp(
                        delay: const Duration(milliseconds: 150),
                        child: Column(
                          children: [
                            AvatarGlow(
                              animate: session.isRecording,
                              glowColor: AppColors.hard,
                              duration: const Duration(milliseconds: 2000),
                              repeat: true,
                              child: GestureDetector(
                                onTap: _toggleRecording,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: session.isRecording
                                          ? [
                                              AppColors.hard,
                                              AppColors.hard.withOpacity(0.7),
                                            ]
                                          : [
                                              AppColors.primary,
                                              AppColors.primary.withOpacity(
                                                0.7,
                                              ),
                                            ],
                                    ),
                                  ),
                                  child: Icon(
                                    session.isRecording
                                        ? Icons.stop_rounded
                                        : Icons.mic_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              session.isRecording
                                  ? 'Recording... tap to stop'
                                  : _answerRecorded
                                  ? 'Answer recorded ✓'
                                  : 'Tap mic to start answering',
                              style: GoogleFonts.poppins(
                                color: session.isRecording
                                    ? AppColors.hard
                                    : _answerRecorded
                                    ? AppColors.easy
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            WaveformBar(
                              isActive: session.isRecording,
                              height: 50,
                              color: session.isRecording
                                  ? AppColors.hard
                                  : AppColors.primary,
                            ),
                          ],
                        ),
                      ),

                      // Transcript
                      if (settings.showTranscript &&
                          session.currentTranscript.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        FadeInUp(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.text_snippet_outlined,
                                      color: AppColors.secondary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Live Transcript',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.secondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  session.currentTranscript,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Next button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: GestureDetector(
                  onTap: (_answerRecorded && !_isFetchingFeedback)
                      ? _nextQuestion
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: (_answerRecorded && !_isFetchingFeedback)
                          ? AppColors.primaryGradient
                          : null,
                      color: (_answerRecorded && !_isFetchingFeedback)
                          ? null
                          : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: (_answerRecorded && !_isFetchingFeedback)
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: _isFetchingFeedback
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              session.isLastQuestion
                                  ? 'Finish & Get Feedback'
                                  : 'Next Question →',
                              style: GoogleFonts.poppins(
                                color: _answerRecorded
                                    ? Colors.white
                                    : AppColors.textMuted,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
