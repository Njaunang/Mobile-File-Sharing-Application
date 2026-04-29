import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:local_sharer/core/constants/app_colors.dart';
import 'package:local_sharer/features/home/logic/transfer_provider.dart';
import 'package:local_sharer/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiverPage extends StatefulWidget {
  const ReceiverPage({super.key});

  @override
  State<ReceiverPage> createState() => _ReceiverPageState();
}

class _ReceiverPageState extends State<ReceiverPage> {
  final userController = TextEditingController(text: "android");
  final passController = TextEditingController(text: "1234");
  final nameController = TextEditingController(text: "My Device");
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNight : AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.receivesFiles),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () {
            provider.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (provider.status != TransferStatus.idle &&
                provider.status != TransferStatus.transferring)
              _buildStatusBanner(provider, isDark),

            const SizedBox(height: 10),

            if (!provider.isBroadcasting)
              _buildSetupForm(provider, isDark)
            else
              _buildWaitingState(provider, isDark),

            if (provider.status == TransferStatus.transferring) ...[
              const SizedBox(height: 32),
              _buildProgressCard(provider, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(TransferProvider provider, bool isDark) {
    Color color = AppColors.primary;
    String message = "";
    IconData icon = Icons.info;

    switch (provider.status) {
      case TransferStatus.success:
        color = AppColors.success;
        message = AppLocalizations.of(context)!.fileReceiveSuccessfully;
        icon = Icons.check_circle;
        break;
      case TransferStatus.error:
        color = AppColors.error;
        message = provider.errorMessage.isNotEmpty
            ? provider.errorMessage
            : AppLocalizations.of(context)!.anErrorOccurredDuringTransfer;
        icon = Icons.error;
        break;
      case TransferStatus.connecting:
        color = AppColors.warning;
        message = AppLocalizations.of(context)!.incomingConnection;
        icon = Icons.sync;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedCancel01,
              size: 16,
              color: color,
            ),
            onPressed: () {
              // We should have a way to reset status without stopping broadcast
              // For now, provider.stop() works but resets everything.
            },
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildSetupForm(TransferProvider provider, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedSecurity,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.setYourCredentials,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.otherUserWillNeedTheseToSendYouFiles,
          style: TextStyle(
            color: isDark ? AppColors.textLight : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        _textField(
          nameController,
          AppLocalizations.of(context)!.deviceName,
          HugeIcons.strokeRoundedComputerPhoneSync,
          isDark,
        ),
        const SizedBox(height: 16),
        _textField(
          userController,
          AppLocalizations.of(context)!.username,
          HugeIcons.strokeRoundedUser03,
          isDark,
        ),
        const SizedBox(height: 16),
        _textField(
          passController,
          AppLocalizations.of(context)!.password,
          HugeIcons.strokeRoundedLockPassword,
          isDark,
          isPasswordField: true,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => provider.startReceiving(
              nameController.text,
              userController.text,
              passController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              AppLocalizations.of(context)!.startWaiting,
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildWaitingState(TransferProvider provider, bool isDark) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.scanToConnect,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: QrImageView(
            data: provider.qrData,
            version: QrVersions.auto,
            size: 220.0,
            gapless: false,
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 32),
        _infoCard(
          AppLocalizations.of(context)!.username,
          userController.text,
          isDark,
        ),
        const SizedBox(height: 12),
        _infoCard(
          AppLocalizations.of(context)!.password,
          passController.text,
          isDark,
        ),
        const SizedBox(height: 40),
        TextButton.icon(
          onPressed: () => provider.stop(),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedStopCircle,
            color: AppColors.error,
          ),
          label: Text(
            AppLocalizations.of(context)!.stopReceiving,
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _infoCard(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.textLight : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    dynamic icon,
    bool isDark, {
    bool isPasswordField = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPasswordField ? _obscurePassword : false,
      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textSecondary,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: HugeIcon(icon: icon, color: AppColors.primary),
        ),
        suffixIcon: isPasswordField
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: HugeIcon(
                  icon: _obscurePassword
                      ? HugeIcons.strokeRoundedViewOff
                      : HugeIcons.strokeRoundedView,
                  color: AppColors.primary,
                ),
              )
            : null,
        filled: true,
        fillColor: isDark ? AppColors.slate : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildProgressCard(TransferProvider provider, bool isDark) {
    final progress = provider.currentProgress;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedDownload04,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  progress?.fileName ?? AppLocalizations.of(context)!.receiving,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (progress != null)
                Text(
                  "${(progress.progress * 100).toInt()}%",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress?.progress,
              minHeight: 10,
              backgroundColor: isDark
                  ? AppColors.deepNight
                  : AppColors.background,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0);
  }
}
