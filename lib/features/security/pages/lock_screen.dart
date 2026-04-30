import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:local_sharer/core/constants/app_colors.dart';
import 'package:local_sharer/features/security/logic/security_provider.dart';
import 'package:local_sharer/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _enteredPin = "";
  bool _isError = false;

  void _onNumberTap(String number) {
    if (_enteredPin.length < 6) {
      setState(() {
        _enteredPin += number;
        _isError = false;
      });
      if (_enteredPin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final success = await context.read<SecurityProvider>().authenticateWithPIN(
      _enteredPin,
    );
    if (!success) {
      setState(() {
        _enteredPin = "";
        _isError = true;
      });
      // Vibrate or show error
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNight : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Logo & Title
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedLockPassword,
                color: AppColors.primary,
                size: 48,
              ),
            ).animate().scale(),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.locked,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.enterYour6digitPINToUnlock,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                bool filled = index < _enteredPin.length;
                return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isError
                            ? Colors.redAccent
                            : (filled
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.3)),
                        border: Border.all(
                          color: filled
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                    )
                    .animate(target: _isError ? 1 : 0)
                    .shake(hz: 10, curve: Curves.easeInOut);
              }),
            ),

            const Spacer(),

            // Number Pad
            _buildNumberPad(provider),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad(SecurityProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["1", "2", "3"].map((n) => _numberButton(n)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["4", "5", "6"].map((n) => _numberButton(n)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["7", "8", "9"].map((n) => _numberButton(n)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _biometricButton(provider),
              _numberButton("0"),
              _deleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numberButton(String label) {
    return InkWell(
      onTap: () => _onNumberTap(label),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _biometricButton(SecurityProvider provider) {
    if (!provider.isBiometricAvailable || !provider.isBiometricEnabled) {
      return const SizedBox(width: 70, height: 70);
    }
    return InkWell(
      onTap: () => provider.authenticateWithBiometrics(),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedFingerPrint,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return InkWell(
      onTap: _onDelete,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedDelete02,
          color: AppColors.textSecondary,
          size: 28,
        ),
      ),
    );
  }
}
