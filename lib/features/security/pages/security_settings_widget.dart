import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:local_sharer/core/constants/app_colors.dart';
import 'package:local_sharer/features/security/logic/security_provider.dart';
import 'package:local_sharer/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SecuritySettingsWidget extends StatelessWidget {
  const SecuritySettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.security,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // App Lock Toggle
        _settingTile(
          title: AppLocalizations.of(context)!.appLock,
          subtitle: AppLocalizations.of(
            context,
          )!.requireAuthenticationToOpenApp,
          icon: HugeIcons.strokeRoundedLockPassword,
          trailing: Switch(
            value: provider.isAppLockEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              if (val && !provider.hasPINSet) {
                _showPINSetup(context, provider);
              } else {
                provider.setAppLockEnabled(val);
              }
            },
          ),
        ),

        // Biometric Toggle
        if (provider.isBiometricAvailable && provider.isAppLockEnabled)
          _settingTile(
            title: AppLocalizations.of(context)!.biometricUnlock,
            subtitle: AppLocalizations.of(
              context,
            )!.useFingerprintOrFaceRecognition,
            icon: HugeIcons.strokeRoundedFingerPrint,
            trailing: Switch(
              value: provider.isBiometricEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => provider.setBiometricEnabled(val),
            ),
          ),

        // Change PIN
        if (provider.hasPINSet)
          _settingTile(
            title: AppLocalizations.of(context)!.changeMasterPIN,
            subtitle: AppLocalizations.of(
              context,
            )!.updateYour6digitSecurityCode,
            icon: HugeIcons.strokeRoundedKey01,
            onTap: () => _showPINSetup(context, provider),
          ),
      ],
    );
  }

  Widget _settingTile({
    required String title,
    required String subtitle,
    required dynamic icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: HugeIcon(icon: icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
      trailing: trailing,
    );
  }

  void _showPINSetup(BuildContext context, SecurityProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.set6DigitPIN),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "••••••",
            counterText: "",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancell),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.length == 6) {
                provider.setPIN(controller.text);
                provider.setAppLockEnabled(true);
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }
}
