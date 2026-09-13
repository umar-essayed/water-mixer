import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/custom_button.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF00B4D8), width: 3.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0077B6).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Text(
                'الإعدادات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sound Toggle
            _buildSettingTile(
              icon: audio.isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              title: 'المؤثرات الصوتية',
              value: audio.isSoundEnabled,
              activeColor: AppColors.primary,
              onChanged: (_) => audio.toggleSound(),
            ),
            const Divider(color: Color(0xFFE2E8F0), thickness: 1.5),

            // Vibration Toggle
            _buildSettingTile(
              icon: audio.isVibrationEnabled ? Icons.vibration_rounded : Icons.smartphone_rounded,
              title: 'الاهتزاز اللمسي',
              value: audio.isVibrationEnabled,
              activeColor: const Color(0xFF8B5CF6),
              onChanged: (_) => audio.toggleVibration(),
            ),
            const SizedBox(height: 26),

            // Close 2D Button
            CustomButton(
              text: 'تم',
              height: 52,
              fontSize: 18,
              baseColor: const Color(0xFF22C55E),
              shadowColor: const Color(0xFF15803D),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: activeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            activeThumbColor: activeColor,
            activeTrackColor: activeColor.withValues(alpha: 0.35),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
