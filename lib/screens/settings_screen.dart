import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _obscureKey = true;
  bool _isLoadingKey = true;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    const storage = FlutterSecureStorage();
    final key = await storage.read(key: AppConstants.apiKeyStorageKey);
    if (mounted) {
      _apiKeyController.text = key ?? '';
      setState(() => _isLoadingKey = false);
    }
  }

  Future<void> _saveApiKey() async {
    await ClaudeServiceHelper.saveApiKey(_apiKeyController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API key saved!'),
          backgroundColor: Color(0xFF1D9E75),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Clear All History?',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will permanently delete all your interview sessions.',
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Clear',
              style: GoogleFonts.poppins(color: AppColors.hard),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(historyProvider.notifier).clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History cleared'),
            backgroundColor: Color(0xFF6C63FF),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              FadeInDown(
                child: Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // API Key section
              FadeInUp(
                delay: const Duration(milliseconds: 50),
                child: _sectionHeader('Gemini API Key', Icons.key_outlined),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 80),
                child: _buildCard(
                  child: Column(
                    children: [
                      _isLoadingKey
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            )
                          : TextField(
                              controller: _apiKeyController,
                              obscureText: _obscureKey,
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your Gemini API key',
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: AppColors.bgDark.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureKey
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureKey = !_obscureKey,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveApiKey,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Save Gemini API Key',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // TTS Settings
              FadeInUp(
                delay: const Duration(milliseconds: 130),
                child: _sectionHeader(
                  'Voice Settings',
                  Icons.record_voice_over_outlined,
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 160),
                child: _buildCard(
                  child: Column(
                    children: [
                      // Speed slider
                      Row(
                        children: [
                          const Icon(
                            Icons.speed_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Speech Speed',
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            settings.ttsSpeed < 0.4
                                ? 'Slow'
                                : settings.ttsSpeed < 0.65
                                ? 'Normal'
                                : 'Fast',
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: settings.ttsSpeed,
                        min: 0.2,
                        max: 0.9,
                        divisions: 7,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.primary.withOpacity(0.2),
                        onChanged: (v) => notifier.setTtsSpeed(v),
                      ),
                      const Divider(color: AppColors.cardDark, height: 1),
                      const SizedBox(height: 12),

                      // Language
                      Row(
                        children: [
                          const Icon(
                            Icons.language_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Language',
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          DropdownButton<String>(
                            value: settings.ttsLanguage,
                            dropdownColor: AppColors.surfaceDark,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            underline: const SizedBox.shrink(),
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                            items: AppConstants.ttsLanguages
                                .asMap()
                                .entries
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.value,
                                    child: Text(
                                      AppConstants.ttsLanguageLabels[e.key],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) notifier.setTtsLanguage(v);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Preferences
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _sectionHeader('Preferences', Icons.tune_outlined),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 230),
                child: _buildCard(
                  child: Column(
                    children: [
                      _buildToggle(
                        icon: Icons.volume_up_outlined,
                        label: 'Auto-play Questions',
                        subtitle: 'Read questions aloud automatically',
                        value: settings.autoPlayQuestion,
                        onChanged: (v) => notifier.setAutoPlay(v),
                      ),
                      const Divider(color: AppColors.cardDark, height: 24),
                      _buildToggle(
                        icon: Icons.subtitles_outlined,
                        label: 'Show Live Transcript',
                        subtitle: 'Display text while you speak',
                        value: settings.showTranscript,
                        onChanged: (v) => notifier.setShowTranscript(v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Danger zone
              FadeInUp(
                delay: const Duration(milliseconds: 270),
                child: _buildCard(
                  child: GestureDetector(
                    onTap: _clearHistory,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.hard.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.hard,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clear All History',
                                style: GoogleFonts.poppins(
                                  color: AppColors.hard,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Permanently delete all sessions',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.hard,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Version
              Center(
                child: Text(
                  'InterviewCoach v${AppConstants.appVersion}',
                  style: GoogleFonts.poppins(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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

  Widget _buildToggle({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          inactiveTrackColor: AppColors.cardDark,
        ),
      ],
    );
  }
}

// Helper to avoid circular import
class ClaudeServiceHelper {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: AppConstants.apiKeyStorageKey, value: key);
  }
}
