import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:local_sharer/core/constants/app_colors.dart';
import 'package:local_sharer/features/home/logic/transfer_provider.dart';
import 'package:local_sharer/l10n/app_localizations.dart';
import 'package:local_sharer/services/transfer_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoveryPage extends StatefulWidget {
  final List<File> filesToSend;
  const DiscoveryPage({super.key, required this.filesToSend});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  bool _isScanning = false;
  MobileScannerController? _scannerController;
  bool _hasCameraPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    Future.microtask(() {
      if (!mounted) return;
      context.read<TransferProvider>().startDiscovery();
    });
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _hasCameraPermission = status.isGranted;
      });
    }
  }

  void _toggleScanner() {
    if (!_hasCameraPermission) {
      _checkPermissions();
      return;
    }

    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _scannerController = MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
        );
      } else {
        _scannerController?.dispose();
        _scannerController = null;
      }
    });
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNight : AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.sendFiles),
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
        actions: [
          IconButton(
            onPressed: () => _showManualConnectDialog(context, provider),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedWireless,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            onPressed: _toggleScanner,
            icon: HugeIcon(
              icon: _isScanning
                  ? HugeIcons.strokeRoundedSearch01
                  : HugeIcons.strokeRoundedQrCode01,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          if (_isScanning)
            _buildScanner(provider)
          else
            Column(
              children: [
                if (provider.status != TransferStatus.idle)
                  _buildStatusBanner(provider, isDark),
                const SizedBox(height: 20),
                _buildRadar(provider),
                const SizedBox(height: 40),
                Text(
                      AppLocalizations.of(context)!.searchingForNearbyDevices,
                      style: GoogleFonts.plusJakartaSans(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn()
                    .fadeOut(delay: 1.seconds),
                const SizedBox(height: 20),
                Expanded(child: _buildPeerList(provider, isDark)),
              ],
            ),
          if (provider.status == TransferStatus.transferring ||
              provider.status == TransferStatus.connecting)
            _buildProgressOverlay(provider, isDark),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(TransferProvider provider, bool isDark) {
    Color color = AppColors.primary;
    String message = "";
    dynamic icon = HugeIcons.strokeRoundedInformationCircle;

    switch (provider.status) {
      case TransferStatus.connecting:
        color = AppColors.warning;
        message = AppLocalizations.of(context)!.establishingConnection;
        icon = HugeIcons.strokeRoundedFileSync;
        break;
      case TransferStatus.success:
        color = AppColors.success;
        message = AppLocalizations.of(context)!.transferCompletedSuccessfully;
        icon = HugeIcons.strokeRoundedCheckmarkCircle02;
        break;
      case TransferStatus.error:
        color = AppColors.error;
        message = provider.errorMessage;
        icon = HugeIcons.strokeRoundedAlertCircle;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: color, size: 20),
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
          if (provider.status == TransferStatus.success ||
              provider.status == TransferStatus.error)
            GestureDetector(
              onTap: () => provider.stop(),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCancel01,
                size: 16,
                color: color,
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildScanner(TransferProvider provider) {
    if (!_hasCameraPermission) {
      return Center(
        child: Text(AppLocalizations.of(context)!.cameraPermissionRequired),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final rawValue = barcode.rawValue;
              if (rawValue != null && rawValue.startsWith("ls://")) {
                _toggleScanner();
                _processQrData(provider, rawValue);
                break;
              }
            }
          },
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 4),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppLocalizations.of(context)!.alignQRCodeWithinTheFrame,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _processQrData(TransferProvider provider, String data) {
    try {
      final parts = data.replaceFirst("ls://", "").split("|");
      final address = parts[0].split(":");
      final ip = address[0];
      final port = int.parse(address[1]);
      final user = parts[1];
      final pass = parts[2];

      final peer = Peer(name: "QR Device", ip: ip, port: port);
      provider.sendToPeer(peer, widget.filesToSend, user, pass);
    } catch (e) {
      debugPrint("Invalid QR Data: $e");
    }
  }

  void _showManualConnectDialog(
    BuildContext context,
    TransferProvider provider,
  ) {
    final ipController = TextEditingController(text: "192.168.");
    final portController = TextEditingController(text: "42360");
    final userController = TextEditingController(text: "android");
    final passController = TextEditingController(text: "1234");
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate : Colors.white,
        title: Text(
          AppLocalizations.of(context)!.manualConnect,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ipController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.receiverIP,
                ),
              ),
              TextField(
                controller: portController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.port,
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: userController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.username,
                ),
              ),
              TextField(
                controller: passController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final peer = Peer(
                name: "Manual Device",
                ip: ipController.text,
                port: int.parse(portController.text),
              );
              provider.sendToPeer(
                peer,
                widget.filesToSend,
                userController.text,
                passController.text,
              );
            },
            child: Text(AppLocalizations.of(context)!.connect),
          ),
        ],
      ),
    );
  }

  Widget _buildRadar(TransferProvider provider) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(3, (index) {
            return Container(
                  width: 100.0 + (index * 60),
                  height: 100.0 + (index * 60),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.5, 1.5),
                  duration: 2.seconds,
                  delay: (index * 500).ms,
                )
                .fadeOut();
          }),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedSent,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerList(TransferProvider provider, bool isDark) {
    if (provider.discoveredPeers.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noDevicesFoundYet,
          style: TextStyle(
            color: isDark ? AppColors.textLight : AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      itemCount: provider.discoveredPeers.length,
      itemBuilder: (context, index) {
        final peer = provider.discoveredPeers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
              ),
            ],
          ),
          child: ListTile(
            onTap: () => _showLoginDialog(context, provider, peer),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedSmartPhone01,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              peer.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              peer.ip,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.textLight,
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2, end: 0);
      },
    );
  }

  void _showLoginDialog(
    BuildContext context,
    TransferProvider provider,
    Peer peer,
  ) {
    final userController = TextEditingController(text: "android");
    final passController = TextEditingController(text: "1234");
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          "${AppLocalizations.of(context)!.connectTo} ${peer.name}",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.username,
                prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedUser03),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password,
                prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedLockPassword),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.sendToPeer(
                peer,
                widget.filesToSend,
                userController.text,
                passController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.connectAndSend),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverlay(TransferProvider provider, bool isDark) {
    final progress = provider.currentProgress;
    final isConnecting = provider.status == TransferStatus.connecting;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate : AppColors.deepNight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedFileAttachment,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isConnecting
                          ? AppLocalizations.of(context)!.connecting
                          : (progress?.fileName ??
                                AppLocalizations.of(context)!.preparing),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isConnecting && progress != null)
                    Text(
                      "${(progress.progress * 100).toInt()}%",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: isConnecting ? null : progress?.progress,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isConnecting
                    ? AppLocalizations.of(context)!.waitingForReceiverToAccept
                    : AppLocalizations.of(context)!.streamingDataToDestination,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }
}
