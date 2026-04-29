import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:local_sharer/core/constants/app_colors.dart';
import 'package:local_sharer/features/history/logic/history_provider.dart';
import 'package:local_sharer/features/history/models/transfer_history.dart';
import 'package:local_sharer/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNight : AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.history),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        actions: [
          if (provider.history.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClear(context, provider),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: Colors.redAccent,
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.history.isEmpty
          ? _buildEmptyState(context, isDark)
          : _buildHistoryList(provider, isDark),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedClock01,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.noTransferHistory,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.yourRecentTransfersWillAppearHere,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildHistoryList(HistoryProvider provider, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.history.length,
      itemBuilder: (context, index) {
        final item = provider.history[index];
        return _historyTile(
          context,
          item,
          provider,
          isDark,
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _historyTile(
    BuildContext context,
    TransferHistoryItem item,
    HistoryProvider provider,
    bool isDark,
  ) {
    final dateStr = DateFormat('MMM dd, yyyy • HH:mm').format(item.timestamp);
    final color = _getStatusColor(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          if (item.status == HistoryStatus.success) {
            OpenFilex.open(item.filePath);
          }
        },
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getTypeColor(item.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: HugeIcon(
            icon: _getTypeIcon(item.type),
            color: _getTypeColor(item.type),
            size: 24,
          ),
        ),
        title: Text(
          item.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "${_formatSize(item.fileSize)} • $dateStr",
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedUser03,
                  size: 12,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  item.peerName,
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18, color: AppColors.textLight),
          onPressed: () => provider.deleteEntry(item.id),
        ),
      ),
    );
  }

  dynamic _getTypeIcon(TransferType type) {
    switch (type) {
      case TransferType.send:
        return HugeIcons.strokeRoundedSent;
      case TransferType.receive:
        return HugeIcons.strokeRoundedDownload01;
      case TransferType.web:
        return HugeIcons.strokeRoundedGlobal;
    }
  }

  Color _getTypeColor(TransferType type) {
    switch (type) {
      case TransferType.send:
        return AppColors.primary;
      case TransferType.receive:
        return AppColors.secondary;
      case TransferType.web:
        return Colors.orange;
    }
  }

  Color _getStatusColor(HistoryStatus status) {
    switch (status) {
      case HistoryStatus.success:
        return Colors.green;
      case HistoryStatus.failed:
        return Colors.red;
      case HistoryStatus.cancelled:
        return Colors.grey;
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    double size = bytes.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < suffixes.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return "${size.toStringAsFixed(1)} ${suffixes[unitIndex]}";
  }

  void _confirmClear(BuildContext context, HistoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${AppLocalizations.of(context)!.clearHistory}?"),
        content: Text(
          AppLocalizations.of(
            context,
          )!.thisWillPermanentlyDeleteAllTransferLogs,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.clear,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
