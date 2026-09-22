import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/session_result.dart';
import '../providers/history_provider.dart';
import '../providers/session_provider.dart';
import '../utils/constants.dart';
import '../widgets/phrase_chip.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveSession());
  }

  Future<void> _saveSession() async {
    if (_saved) return;
    _saved = true;

    final session = ref.read(sessionProvider);
    if (session.allFeedbacks.isEmpty) return;

    final allStrong = session.allFeedbacks
        .expand((f) => f.strong)
        .toList();
    final allWeak = session.allFeedbacks.expand((f) => f.weak).toList();

    final overallScore =
        session.allFeedbacks
            .map((f) => f.averageScore)
            .reduce((a, b) => a + b) /
        session.allFeedbacks.length;

    final result = SessionResult(
      id: const Uuid().v4(),
      role: session.role,
      interviewType: session.interviewType,
      difficulty: session.difficulty,
      date: DateTime.now(),
      questions: session.questions,
      transcripts: session.allTranscripts,
      contentScores: session.allFeedbacks.map((f) => f.content).toList(),
      clarityScores: session.allFeedbacks.map((f) => f.clarity).toList(),
      confidenceScores: session.allFeedbacks.map((f) => f.confidence).toList(),
      feedbacks: session.allFeedbacks.map((f) => f.feedback).toList(),
      strongPhrases: allStrong,
      weakPhrases: allWeak,
      overallScore: overallScore,
    );

    await ref.read(historyProvider.notifier).saveSession(result);
  }

  double _overallScore() {
    final feedbacks = ref.read(sessionProvider).allFeedbacks;
    if (feedbacks.isEmpty) return 0;
    return feedbacks.map((f) => f.averageScore).reduce((a, b) => a + b) /
        feedbacks.length;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final feedbacks = session.allFeedbacks;
    if (feedbacks.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final overallScore = _overallScore();
    final avgContent =
        feedbacks.map((f) => f.content).reduce((a, b) => a + b) /
        feedbacks.length;
    final avgClarity =
        feedbacks.map((f) => f.clarity).reduce((a, b) => a + b) /
        feedbacks.length;
    final avgConfidence =
        feedbacks.map((f) => f.confidence).reduce((a, b) => a + b) /
        feedbacks.length;

    final allWeak = feedbacks.expand((f) => f.weak).toSet().toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      icon: const Icon(
                        Icons.home_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Session Complete!',
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Trophy + score
                      FadeInDown(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.25),
                                AppColors.secondary.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '🏆',
                                style: TextStyle(fontSize: 56),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                overallScore.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  color: AppColors.primary,
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                'Overall Score / 10',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${session.role} • ${session.interviewType}',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Radar chart
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildCard(
                          child: Column(
                            children: [
                              Text(
                                'Skills Breakdown',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: RadarChart(
                                  RadarChartData(
                                    radarShape: RadarShape.polygon,
                                    dataSets: [
                                      RadarDataSet(
                                        fillColor: AppColors.primary.withOpacity(
                                          0.25,
                                        ),
                                        borderColor: AppColors.primary,
                                        borderWidth: 2,
                                        entryRadius: 4,
                                        dataEntries: [
                                          RadarEntry(value: avgContent),
                                          RadarEntry(value: avgClarity),
                                          RadarEntry(value: avgConfidence),
                                        ],
                                      ),
                                    ],
                                    radarBackgroundColor: Colors.transparent,
                                    borderData: FlBorderData(show: false),
                                    radarBorderData: BorderSide(
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                    gridBorderData: BorderSide(
                                      color: AppColors.primary.withOpacity(0.1),
                                    ),
                                    tickCount: 5,
                                    ticksTextStyle: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 9,
                                    ),
                                    titleTextStyle: GoogleFonts.poppins(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    getTitle: (index, angle) {
                                      const titles = [
                                        'Content',
                                        'Clarity',
                                        'Confidence',
                                      ];
                                      return RadarChartTitle(
                                        text: titles[index],
                                        angle: angle,
                                      );
                                    },
                                    tickBorderData: BorderSide(
                                      color: AppColors.primary.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Legend
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _scorePill(
                                    'Content',
                                    avgContent,
                                    AppColors.contentScore,
                                  ),
                                  _scorePill(
                                    'Clarity',
                                    avgClarity,
                                    AppColors.clarityScore,
                                  ),
                                  _scorePill(
                                    'Confidence',
                                    avgConfidence,
                                    AppColors.confidenceScore,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Per-question breakdown
                      FadeInUp(
                        delay: const Duration(milliseconds: 150),
                        child: _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question Breakdown',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...feedbacks.asMap().entries.map((e) {
                                final i = e.key;
                                final f = e.value;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgDark.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.15,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          session.questions[i],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            color: AppColors.textPrimary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        f.averageScore.toStringAsFixed(1),
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Weak areas
                      if (allWeak.isNotEmpty)
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '⚠️ Areas to Focus On',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.weakChipText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  children: allWeak
                                      .map(
                                        (p) =>
                                            PhraseChip(label: p, isStrong: false),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Practice Again',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        ref.read(sessionProvider.notifier).reset();
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'New Role',
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scorePill(String label, double score, Color color) {
    return Column(
      children: [
        Text(
          score.toStringAsFixed(1),
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
