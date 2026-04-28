import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:local_sharer/core/constants/app_colors.dart';
import 'package:local_sharer/features/home/logic/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNight : AppColors.background,
      appBar: AppBar(
        title: const Text("LOCAL SHARER"),
        actions: [
          IconButton(
            onPressed: () => provider.clearLogs(),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedClean,
              color: AppColors.error,
              size: 24,
            ),
            tooltip: "Clear Logs",
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // 1. Status Dashboard
              _buildStatusCard(
                provider,
                isDark,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // 2. Control Button
              _buildActionButton(
                provider,
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 20),

              // 3. Information Row (Username/Password)
              if (provider.isRunning)
                _buildCredentialsSection(provider, isDark)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 20),

              // 4. Terminal Logs
              Expanded(
                child: _buildTerminalLogs(
                  provider,
                  isDark,
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(HomeProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: provider.isRunning
            ? AppColors.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.slate : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: provider.isRunning
              ? AppColors.primary
              : Colors.grey.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          HugeIcon(
            icon: provider.isRunning
                ? HugeIcons.strokeRoundedWifi02
                : HugeIcons.strokeRoundedWifiDisconnected02,
            size: 64,
            color: provider.isRunning ? AppColors.primary : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            provider.isRunning ? "SERVER ONLINE" : "SERVER OFFLINE",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: provider.isRunning ? AppColors.primary : Colors.grey,
            ),
          ),
          if (provider.isRunning) ...[
            const SizedBox(height: 8),
            Text(
              "Address: ${provider.serverAddress}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(HomeProvider provider) {
    return SizedBox(
      height: 64,
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : () => provider.toggleServer(),
        style: ElevatedButton.styleFrom(
          backgroundColor: provider.isRunning
              ? AppColors.error
              : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor:
              (provider.isRunning ? AppColors.error : AppColors.primary)
                  .withValues(alpha: 0.4),
        ),
        child: provider.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: provider.isRunning
                        ? HugeIcons.strokeRoundedPower
                        : HugeIcons.strokeRoundedPlay,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    provider.isRunning
                        ? "SHUTDOWN SERVER"
                        : "INITIALIZE SERVER",
                    style: const TextStyle(letterSpacing: 1.1),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCredentialsSection(HomeProvider provider, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            label: "USERNAME",
            value: provider.username,
            icon: HugeIcons.strokeRoundedUser, // Using strokeRoundedUser which is standard IconData
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _infoCard(
            label: "PASSWORD",
            value: provider.password,
            icon: HugeIcons.strokeRoundedSquareLock02,
            isDark: isDark,
          ),
        ),
      ],
    );
  }


  Widget _infoCard({
    required String label,
    required String value,
    required dynamic icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(icon: icon, color: AppColors.textLight, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalLogs(HomeProvider provider, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Very dark blue
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Terminal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white.withValues(alpha: 0.05),
              child: Row(
                children: [
                  Row(
                    children: [
                      _dot(Colors.red),
                      const SizedBox(width: 6),
                      _dot(Colors.orange),
                      const SizedBox(width: 6),
                      _dot(Colors.green),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    "ftp_engine.log",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Log Content
            Expanded(
              child: provider.logs.isEmpty
                  ? Center(
                      child: Text(
                        "WAITING FOR INITIALIZATION...",
                        style: GoogleFonts.sourceCodePro(
                          color: Colors.white24,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.logs.length,
                      reverse:
                          true, // Show latest logs at bottom (standard for terminal)
                      itemBuilder: (context, index) {
                        final log =
                            provider.logs[provider.logs.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.sourceCodePro(
                                fontSize: 11,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      "[${log.timestamp.toString().substring(11, 19)}] ",
                                  style: const TextStyle(color: Colors.white30),
                                ),
                                TextSpan(
                                  text: log.isError ? "ERR " : "LOG ",
                                  style: TextStyle(
                                    color: log.isError
                                        ? Colors.red
                                        : AppColors.primary,
                                  ),
                                ),
                                TextSpan(
                                  text: log.message,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
