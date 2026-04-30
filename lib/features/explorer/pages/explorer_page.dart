import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:local_sharer/core/constants/app_colors.dart';
import 'package:local_sharer/features/explorer/logic/explorer_provider.dart';
import 'package:local_sharer/features/explorer/models/file_item.dart';
import 'package:local_sharer/features/home/logic/web_provider.dart';
import 'package:local_sharer/features/home/pages/web_share_page.dart';
import 'package:local_sharer/features/transfer/pages/discovery_page.dart';
import 'package:local_sharer/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_sharer/features/explorer/pages/private_safe_page.dart';

class ExplorerPage extends StatefulWidget {
  final FileType? initialCategory;
  const ExplorerPage({super.key, this.initialCategory});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ExplorerProvider>().initialize(
        initialCategory: widget.initialCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExplorerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNight : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () {
            if (provider.currentCategory != null) {
              provider.setCategory(null);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _getTitle(provider),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        actions: [
          if (provider.selectedFiles.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  "${provider.selectedFiles.length} ${AppLocalizations.of(context)!.selected}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (provider.currentCategory == null)
            Expanded(child: _buildCategoryGrid(provider, isDark))
          else ...[
            if (provider.currentCategory == FileType.folder)
              _buildBreadcrumbs(provider),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildFileList(provider, isDark),
            ),
          ],
        ],
      ),
      bottomNavigationBar: provider.selectedFiles.isEmpty
          ? null
          : _buildBottomActionBar(context, provider),
    );
  }

  String _getTitle(ExplorerProvider provider) {
    if (provider.currentCategory == null) {
      return AppLocalizations.of(context)!.explorer;
    }
    switch (provider.currentCategory!) {
      case FileType.image:
        return "Images";
      case FileType.video:
        return AppLocalizations.of(context)!.videosCategory;
      case FileType.audio:
        return AppLocalizations.of(context)!.musicCategory;
      case FileType.document:
        return "Documents";
      case FileType.apk:
        return "Apps (APKs)";
      case FileType.folder:
        return AppLocalizations.of(context)!.allFiles;
      default:
        return "Files";
    }
  }

  Widget _buildCategoryGrid(ExplorerProvider provider, bool isDark) {
    final categories = [
      {
        'type': FileType.image,
        'label': 'Images',
        'icon': HugeIcons.strokeRoundedImage02,
        'color': Colors.blue,
      },
      {
        'type': FileType.video,
        'label': AppLocalizations.of(context)!.videosCategory,
        'icon': HugeIcons.strokeRoundedVideo01,
        'color': Colors.purple,
      },
      {
        'type': FileType.audio,
        'label': AppLocalizations.of(context)!.musicCategory,
        'icon': HugeIcons.strokeRoundedMusicNote01,
        'color': Colors.pink,
      },
      {
        'type': FileType.document,
        'label': 'Documents',
        'icon': HugeIcons.strokeRoundedNote01,
        'color': Colors.teal,
      },
      {
        'type': FileType.apk,
        'label': 'Apps',
        'icon': HugeIcons.strokeRoundedApple,
        'color': Colors.orange,
      },
      {
        'type': FileType.folder,
        'label': AppLocalizations.of(context)!.allFiles,
        'icon': HugeIcons.strokeRoundedFolder01,
        'color': Colors.amber,
      },
      {
        'type': FileType.other, // We'll use this for the Safe trigger
        'label': 'Secure Vault',
        'icon': HugeIcons.strokeRoundedFolderLocked,
        'color': Colors.redAccent,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return _categoryCard(
              context,
              provider,
              cat['type'] as FileType,
              cat['label'] as String,
              cat['icon'] as dynamic,
              cat['color'] as Color,
              isDark,
            )
            .animate()
            .fadeIn(delay: (index * 50).ms)
            .scale(delay: (index * 50).ms);
      },
    );
  }

  Widget _categoryCard(
    BuildContext context,
    ExplorerProvider provider,
    FileType type,
    String label,
    dynamic icon,
    Color color,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        if (label == 'Secure Vault') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrivateSafePage()),
          );
        } else if (type == FileType.folder) {
          provider.scanDirectory("/storage/emulated/0");
        } else {
          provider.setCategory(type);
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(icon: icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs(ExplorerProvider provider) {
    String displayPath = provider.currentPath;
    const String rootPath = "/storage/emulated/0";

    List<String> parts = [];
    if (displayPath.startsWith(rootPath)) {
      parts.add("Internal Storage");
      final relative = displayPath.replaceFirst(rootPath, "");
      if (relative.isNotEmpty) {
        parts.addAll(relative.split('/').where((e) => e.isNotEmpty));
      }
    } else {
      parts = displayPath.split('/').where((e) => e.isNotEmpty).toList();
      if (parts.isEmpty) parts.add("Root");
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: parts.length,
        separatorBuilder: (context, index) => HugeIcon(
          icon: HugeIcons.strokeRoundedArrowRight02,
          size: 16,
          color: AppColors.textLight,
        ),
        itemBuilder: (context, index) {
          return Center(
            child: InkWell(
              onTap: () {
                // Reconstruct path up to this index
                if (parts[index] == "Internal Storage") {
                  provider.scanDirectory(rootPath);
                } else {
                  // Find index in original path
                  final subParts = parts.sublist(1, index + 1);
                  provider.scanDirectory("$rootPath/${subParts.join("/")}");
                }
              },
              child: Text(
                parts[index],
                style: TextStyle(
                  fontSize: 12,
                  color: index == parts.length - 1
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: index == parts.length - 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileList(ExplorerProvider provider, bool isDark) {
    if (provider.files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedFolderOpen,
              color: AppColors.textLight,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noFileFoundInThisCategory,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.files.length,
      itemBuilder: (context, index) {
        final item = provider.files[index];
        return _fileTile(context, provider, item, isDark);
      },
    );
  }

  Widget _fileTile(
    BuildContext context,
    ExplorerProvider provider,
    FileItem item,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: item.isSelected
            ? AppColors.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          if (item.type == FileType.folder) {
            provider.scanDirectory(item.path);
          } else {
            OpenFilex.open(item.path);
          }
        },
        onLongPress: () => provider.toggleSelection(item),
        leading: _getFileIcon(item),
        title: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          item.type == FileType.folder ? "Folder" : _formatSize(item.size),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: item.type != FileType.folder
            ? Checkbox(
                value: item.isSelected,
                onChanged: (_) => provider.toggleSelection(item),
                shape: const CircleBorder(),
                activeColor: AppColors.primary,
              )
            : HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 20,
                color: AppColors.textLight,
              ),
      ),
    );
  }

  Widget _getFileIcon(FileItem item) {
    dynamic iconData;
    Color color;

    switch (item.type) {
      case FileType.folder:
        iconData = HugeIcons.strokeRoundedFolder01;
        color = Colors.amber;
      case FileType.image:
        iconData = HugeIcons.strokeRoundedImage02;
        color = Colors.blue;
      case FileType.video:
        iconData = HugeIcons.strokeRoundedVideo01;
        color = Colors.purple;
      case FileType.audio:
        iconData = HugeIcons.strokeRoundedMusicNote01;
        color = Colors.pink;
      case FileType.document:
        iconData = HugeIcons.strokeRoundedNote01;
        color = Colors.teal;
      case FileType.apk:
        iconData = HugeIcons.strokeRoundedApple;
        color = Colors.orange;
      case FileType.other:
        iconData = HugeIcons.strokeRoundedFile01;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: HugeIcon(icon: iconData, color: color, size: 20),
    );
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

  Widget _buildBottomActionBar(
    BuildContext context,
    ExplorerProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.deepNight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${provider.selectedFiles.length} ${AppLocalizations.of(context)!.itemSelected}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${AppLocalizations.of(context)!.total}: ${_formatTotalSize(provider.selectedFiles)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                final webProvider = context.read<WebProvider>();
                for (var f in provider.selectedFiles) {
                  webProvider.addFile(File(f.path));
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "${provider.selectedFiles.length} ${AppLocalizations.of(context)!.filesAddedToWebShare}",
                    ),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)!.view,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WebSharePage(),
                        ),
                      ),
                    ),
                  ),
                );
                provider.clearSelection();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("WEB"),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _confirmMoveToSafe(context, provider),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedFolderSecurity,
                color: Colors.white,
              ),
              tooltip: AppLocalizations.of(context)!.moveToVault,
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final files = provider.selectedFiles
                    .map((f) => File(f.path))
                    .toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiscoveryPage(filesToSend: files),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.send),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTotalSize(List<FileItem> files) {
    int total = 0;
    for (var f in files) {
      total += f.size;
    }
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    double size = total.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < suffixes.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return "${size.toStringAsFixed(1)} ${suffixes[unitIndex]}";
  }

  void _confirmMoveToSafe(BuildContext context, ExplorerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.moveToSecureVault),
        content: Text(
          AppLocalizations.of(
            context,
          )!.selectedFilesWillBeMovedToAPrivateFolderAndHiddenFromOtherApps,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.moveToSafe(List.from(provider.selectedFiles));
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.move),
          ),
        ],
      ),
    );
  }
}
