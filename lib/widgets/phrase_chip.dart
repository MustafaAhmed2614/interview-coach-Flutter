import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PhraseChip extends StatelessWidget {
  final String label;
  final bool isStrong;

  const PhraseChip({super.key, required this.label, this.isStrong = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isStrong ? AppColors.strongChip : AppColors.weakChip,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isStrong
              ? AppColors.strongChipText.withOpacity(0.3)
              : AppColors.weakChipText.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isStrong ? Icons.check_circle_outline : Icons.warning_amber_outlined,
            size: 14,
            color: isStrong ? AppColors.strongChipText : AppColors.weakChipText,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: isStrong
                    ? AppColors.strongChipText
                    : AppColors.weakChipText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
