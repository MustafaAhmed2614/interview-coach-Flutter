import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/session_result.dart';
import '../providers/history_provider.dart';
import '../utils/constants.dart';
import '../widgets/session_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(historyProvider);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: FadeInDown(
                child: Text(
                  'History',
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (sessions.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        color: AppColors.textMuted,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No sessions yet',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete an interview to see your history',
                        style: GoogleFonts.poppins(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Score trend chart
                      if (sessions.length >= 2)
                        FadeInDown(
                          child: _buildTrendChart(sessions),
                        ),
                      const SizedBox(height: 16),

                      // Session cards
                      ...sessions.asMap().entries.map((entry) {
                        final session = entry.value;
                        final isExpanded = _expandedId == session.id;
                        return FadeInUp(
                          delay: Duration(
                            milliseconds: entry.key * 50,
                          ),
                          child: Column(
                            children: [
                              SessionCard(
                                session: session,
                                onTap: () {
                                  setState(() {
                                    _expandedId = isExpanded
                                        ? null
                                        : session.id;
                                  });
                                },
                                onDelete: () {
                                  ref
                                      .read(historyProvider.notifier)
                                      .deleteSession(session.id);
                                },
                              ),
                              if (isExpanded)
                                _buildExpandedDetail(session),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(List<SessionResult> sessions) {
    final recent = sessions.take(10).toList().reversed.toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Trend',
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.primary.withOpacity(0.08),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: GoogleFonts.poppins(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= recent.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          DateFormat('M/d').format(recent[i].date),
                          style: GoogleFonts.poppins(
                            color: AppColors.textMuted,
                            fontSize: 9,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: recent.asMap().entries.map((e) {
                      return FlSpot(
                        e.key.toDouble(),
                        e.value.overallScore,
                      );
                    }).toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: AppColors.bgDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetail(SessionResult session) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgDark.withOpacity(0.5),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: session.questions.asMap().entries.map((entry) {
            final i = entry.key;
            final q = entry.value;
            final content = i < session.contentScores.length
                ? session.contentScores[i]
                : 0;
            final clarity = i < session.clarityScores.length
                ? session.clarityScores[i]
                : 0;
            final confidence = i < session.confidenceScores.length
                ? session.confidenceScores[i]
                : 0;
            final avg = (content + clarity + confidence) / 3.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Q${i + 1}',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        avg.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    q,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  if (i < session.feedbacks.length) ...[
                    const SizedBox(height: 6),
                    Text(
                      session.feedbacks[i],
                      style: GoogleFonts.poppins(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
