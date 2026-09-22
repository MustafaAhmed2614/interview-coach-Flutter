import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/session_provider.dart';
import '../services/claude_service.dart';
import '../utils/constants.dart';
import 'session_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedRole = AppConstants.jobRoles[0];
  String _selectedType = AppConstants.interviewTypes[0];
  String _selectedDifficulty = 'Medium';
  int _questionCount = 5;
  bool _isLoading = false;

  Future<void> _startInterview() async {
    setState(() => _isLoading = true);
    try {
      final questions = await ClaudeService.generateQuestions(
        role: _selectedRole,
        type: _selectedType,
        difficulty: _selectedDifficulty,
        count: _questionCount,
        context: context,
      );

      if (questions.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      ref
          .read(sessionProvider.notifier)
          .startSession(
            questions: questions,
            role: _selectedRole,
            interviewType: _selectedType,
            difficulty: _selectedDifficulty,
          );

      if (mounted) {
        Navigator.push(
          context,
          _slideRoute(const SessionScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Header
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.psychology_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppConstants.appName,
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 56),
                          child: Text(
                            AppConstants.appSubtitle,
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Hero card
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.25),
                            AppColors.secondary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI-Powered Practice',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get real-time feedback on your interview answers',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mic_none_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Job Role
                  FadeInUp(
                    delay: const Duration(milliseconds: 150),
                    child: _sectionLabel('Job Role'),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 180),
                    child: _buildDropdown(
                      value: _selectedRole,
                      items: AppConstants.jobRoles,
                      onChanged: (v) => setState(() => _selectedRole = v!),
                      icon: Icons.work_outline,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Interview Type
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _sectionLabel('Interview Type'),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 230),
                    child: _buildDropdown(
                      value: _selectedType,
                      items: AppConstants.interviewTypes,
                      onChanged: (v) => setState(() => _selectedType = v!),
                      icon: Icons.category_outlined,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Difficulty
                  FadeInUp(
                    delay: const Duration(milliseconds: 260),
                    child: _sectionLabel('Difficulty Level'),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 290),
                    child: _buildDifficultyPicker(),
                  ),
                  const SizedBox(height: 20),

                  // Question Count
                  FadeInUp(
                    delay: const Duration(milliseconds: 320),
                    child: _sectionLabel('Number of Questions'),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 350),
                    child: _buildQuestionCountPicker(),
                  ),
                  const SizedBox(height: 40),

                  // Start Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildStartButton(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          isExpanded: true,
          dropdownColor: AppColors.surfaceDark,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDifficultyPicker() {
    final colors = {
      'Easy': AppColors.easy,
      'Medium': AppColors.medium,
      'Hard': AppColors.hard,
    };

    return Row(
      children: AppConstants.difficulties.map((d) {
        final isSelected = d == _selectedDifficulty;
        final color = colors[d] ?? AppColors.primary;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDifficulty = d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  d,
                  style: GoogleFonts.poppins(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionCountPicker() {
    return Row(
      children: AppConstants.questionCounts.map((count) {
        final isSelected = count == _questionCount;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _questionCount = count),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: GoogleFonts.poppins(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _startInterview,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: _isLoading
              ? null
              : AppColors.primaryGradient,
          color: _isLoading ? AppColors.cardDark : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Start Interview',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
