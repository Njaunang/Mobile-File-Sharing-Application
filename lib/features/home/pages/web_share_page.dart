import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:local_sharer/core/constants/app_colors.dart';
import 'package:local_sharer/features/explorer/pages/explorer_page.dart';
import 'package:local_sharer/features/home/logic/web_provider.dart';
import 'package:local_sharer/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path/path.dart' as p;

class WebSharePage extends StatelessWidget {
  const WebSharePage({super.key});

  @override
  Widget build(BuildContext context) {
    final webProvider = context.watch<WebProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNight : AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.webShare),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildServerStatusCard(context, webProvider, isDark),
            const SizedBox(height: 24),
            if (webProvider.isRunning)
              _buildConnectionInfo(context, webProvider, isDark),
            const SizedBox(height: 24),
            _buildBasketSection(context, webProvider, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildServerStatusCard(
    BuildContext context,
    WebProvider provider,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: provider.isRunning
            ? AppColors.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.slate : Colors.white),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: provider.isRunning ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: provider.isRunning
                      ? AppColors.primary
                      : Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedGlobal,
                  color: provider.isRunning ? Colors.white : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Web Server",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      provider.isRunning
                          ? AppLocalizations.of(context)!.serverIsActive
                          : AppLocalizations.of(context)!.hostFilesOnLocalWeb,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.isRunning,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  if (!provider.isRunning && provider.basketFiles.isEmpty) {
                    _showNoFilesToast();
                    return;
                  }
                  provider.toggleServer();
                },
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  void _showNoFilesToast() {
    // Basic toast replacement
    debugPrint("Please add files to share first");
  }

  Widget _buildConnectionInfo(
    BuildContext context,
    WebProvider provider,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.scanToAccess,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              QrImageView(
                data: provider.serverAddress,
                version: QrVersions.auto,
                size: 200.0,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              _infoTile(
                AppLocalizations.of(context)!.address,
                provider.serverAddress,
                isDark,
              ),
              const SizedBox(height: 12),
              _infoTile(
                AppLocalizations.of(context)!.securityPin,
                provider.pin,
                isDark,
                isHighlight: true,
              ),
            ],
          ),
        ).animate().fadeIn().scale(),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.openThisLinkInYourPCBrowser,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _infoTile(
    String label,
    String value,
    bool isDark, {
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.deepNight : AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isHighlight ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketSection(
    BuildContext context,
    WebProvider provider,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "${AppLocalizations.of(context)!.sharedFiles} (${provider.basketFiles.length})",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExplorerPage()),
                );
              },
              child: Text(AppLocalizations.of(context)!.addFiles),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.basketFiles.isEmpty)
          _buildEmptyBasket(context, isDark)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.basketFiles.length,
            itemBuilder: (context, index) {
              final file = provider.basketFiles[index];
              return _fileItem(file, provider, isDark);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyBasket(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedFolderOpen,
            color: Colors.grey,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noFilesAddedToWebShareYet,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _fileItem(dynamic file, WebProvider provider, bool isDark) {
    final name = p.basename(file.path);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedFile01,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.remove_circle_outline,
            color: Colors.redAccent,
            size: 20,
          ),
          onPressed: () => provider.removeFile(file),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
