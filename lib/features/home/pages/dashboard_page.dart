import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:local_sharer/core/constants/app_colors.dart';
import 'package:local_sharer/features/explorer/logic/explorer_provider.dart';
import 'package:local_sharer/features/explorer/models/file_item.dart';
import 'package:local_sharer/features/explorer/pages/explorer_page.dart';
import 'package:local_sharer/features/home/logic/home_provider.dart';
import 'package:local_sharer/features/transfer/pages/receiver_page.dart';
import 'package:local_sharer/l10n/app_localizations.dart';
import 'package:local_sharer/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ExplorerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNight : AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                  Text(
                    AppLocalizations.of(context)!.categories,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryGrid(),
                  const SizedBox(height: 32),
                  _buildPcTransferCard(isDark),
                  const SizedBox(height: 16),
                  _buildRecentStorageCard(isDark),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildMainActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: isDark ? AppColors.deepNight : AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/icon.png',
              width: 20,
              height: 20,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Text(
              "Local Sharer",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            showSeetingModal();
          },
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedSettings02,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _quickActionCard(
          AppLocalizations.of(context)!.history,
          HugeIcons.strokeRoundedClock01,
          AppColors.primary,
        ),
        const SizedBox(width: 12),
        _quickActionCard(
          AppLocalizations.of(context)!.received,
          HugeIcons.strokeRoundedDownload02,
          AppColors.secondary,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _quickActionCard(String title, dynamic icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            HugeIcon(icon: icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {
        'name': 'Apps',
        'icon': HugeIcons.strokeRoundedApple,
        'color': Colors.orange,
      },
      {
        'name': 'Images',
        'icon': HugeIcons.strokeRoundedImage02,
        'color': Colors.blue,
      },
      {
        'name': 'Videos',
        'icon': HugeIcons.strokeRoundedVideo01,
        'color': Colors.purple,
      },
      {
        'name': 'Music',
        'icon': HugeIcons.strokeRoundedMusicNote01,
        'color': Colors.pink,
      },
      {
        'name': 'Docs',
        'icon': HugeIcons.strokeRoundedNote01,
        'color': Colors.teal,
      },
      {
        'name': 'Files',
        'icon': HugeIcons.strokeRoundedFolder01,
        'color': Colors.indigo,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return _categoryCard(
              cat['name'] as String,
              cat['icon'] as dynamic,
              cat['color'] as Color,
            )
            .animate()
            .fadeIn(delay: (index * 50).ms)
            .scale(begin: const Offset(0.9, 0.9));
      },
    );
  }

  Widget _categoryCard(String name, dynamic icon, Color color) {
    return InkWell(
      onTap: () {
        FileType? targetType;
        switch (name) {
          case 'Apps':
            targetType = FileType.apk;
            break;
          case 'Images':
            targetType = FileType.image;
            break;
          case 'Videos':
            targetType = FileType.video;
            break;
          case 'Music':
            targetType = FileType.audio;
            break;
          case 'Docs':
            targetType = FileType.document;
            break;
          case 'Files':
            targetType = FileType.folder;
            break;
        }

        if (targetType != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExplorerPage(initialCategory: targetType),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(icon: icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPcTransferCard(bool isDark) {
    final homeProvider = context.watch<HomeProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: homeProvider.isRunning
            ? AppColors.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.slate : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: homeProvider.isRunning
              ? AppColors.primary
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: homeProvider.isRunning
                      ? AppColors.primary
                      : AppColors.textLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedComputerArrowDown,
                  color: homeProvider.isRunning
                      ? Colors.white
                      : AppColors.textLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Connect to PC",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      homeProvider.isRunning
                          ? "Server is Active"
                          : "Transfer via Browser/WinSCP",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: homeProvider.isRunning,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => homeProvider.toggleServer(),
              ),
            ],
          ),
          if (homeProvider.isRunning) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Colors.black12),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SERVER ADDRESS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        homeProvider.serverAddress,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showConnectionGuide(homeProvider),
                  icon: const Icon(
                    Icons.help_outline,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  void showSeetingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.settings,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),

                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          localeProvider.setLocale(Locale('en'));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: localeProvider.locale.languageCode == 'en'
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'EN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          localeProvider.setLocale(Locale('fr'));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: localeProvider.locale.languageCode == 'fr'
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'FR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConnectionGuide(HomeProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Connection Guide",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _guideStep(1, "Ensure PC and Phone are on the same Wi-Fi network."),
            _guideStep(2, "On your PC, open File Explorer or WinSCP."),
            _guideStep(3, "Type the address: ftp://${provider.serverAddress}"),
            _guideStep(4, "When prompted, enter:"),
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _infoRow("Username", provider.username),
                    const Divider(),
                    _infoRow("Password", provider.password),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text("GOT IT"),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _guideStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary,
            child: Text(
              number.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentStorageCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedDatabase,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.storage,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              const Text(
                "85%",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.85,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _storageDetail("110.5 GB", AppLocalizations.of(context)!.used),
              _storageDetail("128 GB", AppLocalizations.of(context)!.total),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _storageDetail(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMainActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.deepNight,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionBtn(
            AppLocalizations.of(context)!.send,
            HugeIcons.strokeRoundedSent,
            AppColors.primary,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExplorerPage()),
              );
            },
          ),
          Container(
            height: 24,
            width: 1,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          _actionBtn(
            AppLocalizations.of(context)!.receive,
            HugeIcons.strokeRoundedDownload01,
            AppColors.secondary,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReceiverPage()),
              );
            },
          ),
        ],
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: 600.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _actionBtn(
    String label,
    dynamic icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          HugeIcon(icon: icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
