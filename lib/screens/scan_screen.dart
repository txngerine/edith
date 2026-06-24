import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/supabase_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'invite_tokens_screen.dart';
import 'nearby_discovery_screen.dart';
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EdithScaffold(
      title: 'Discover',
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _DiscoverTile(
            icon: Icons.qr_code_scanner,
            title: 'Scan QR Code',
            subtitle: 'Connect instantly',
            onTap: () => _showQrScanner(context),
          ),
          _DiscoverTile(
            icon: Icons.link,
            title: 'Generate Invite',
            subtitle: 'Create a one-time invite token',
            onTap: () => _showGenerateInvite(context),
          ),
          _DiscoverTile(
            icon: Icons.location_on_outlined,
            title: 'Nearby Discovery',
            subtitle: 'Find users near you',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NearbyDiscoveryScreen()),
            ),
          ),
          _DiscoverTile(
            icon: Icons.token_outlined,
            title: 'Invite Tokens',
            subtitle: 'Manage your active tokens',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InviteTokensScreen()),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: EdithColors.card,
      builder: (_) => Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'QR SCANNER',
              style: TextStyle(
                color: EdithColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: EdithColors.accent, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: MobileScanner(
                      onDetect: (BarcodeCapture capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            developer.log('[ScanScreen] Scanned token: ${barcode.rawValue}', name: 'EDITH');
                            Navigator.pop(context);
                            _handleScannedToken(context, barcode.rawValue!);
                            break;
                          }
                        }
                      },
                    ),
                  ),
                  // Corner decorators
                  ..._buildCorners(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Point camera at QR code',
              style: TextStyle(
                color: EdithColors.textSecondary,
                fontSize: 12,
                fontFamily: 'SpaceMono',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleScannedToken(BuildContext context, String token) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scanned token: $token'),
        backgroundColor: EdithColors.accent,
      ),
    );
  }

  List<Widget> _buildCorners() {
    const size = 20.0;
    const thickness = 2.0;
    final color = EdithColors.accent;
    return [
      Positioned(
          top: 0, left: 0,
          child: Container(
              width: size, height: thickness, color: color)),
      Positioned(
          top: 0, left: 0,
          child: Container(
              width: thickness, height: size, color: color)),
      Positioned(
          top: 0, right: 0,
          child: Container(
              width: size, height: thickness, color: color)),
      Positioned(
          top: 0, right: 0,
          child: Container(
              width: thickness, height: size, color: color)),
      Positioned(
          bottom: 0, left: 0,
          child: Container(
              width: size, height: thickness, color: color)),
      Positioned(
          bottom: 0, left: 0,
          child: Container(
              width: thickness, height: size, color: color)),
      Positioned(
          bottom: 0, right: 0,
          child: Container(
              width: size, height: thickness, color: color)),
      Positioned(
          bottom: 0, right: 0,
          child: Container(
              width: thickness, height: size, color: color)),
    ];
  }

  void _showGenerateInvite(BuildContext context) async {
    developer.log('[ScanScreen] Generating invite token', name: 'EDITH');
    final token = await SupabaseService.generateInviteToken();
    developer.log('[ScanScreen] Invite token generated: $token', name: 'EDITH');
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: EdithColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: EdithColors.border),
        ),
        title: const Text(
          'INVITE TOKEN',
          style: TextStyle(
            color: EdithColors.textPrimary,
            fontSize: 14,
            letterSpacing: 3,
            fontFamily: 'SpaceMono',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: QrImageView(
                data: token,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: EdithColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: EdithColors.accent),
              ),
              child: Text(
                token,
                style: const TextStyle(
                  color: EdithColors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  fontFamily: 'SpaceMono',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This token expires in 24 hours',
              style: TextStyle(
                color: EdithColors.textDim,
                fontSize: 11,
                fontFamily: 'SpaceMono',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE',
                style: TextStyle(color: EdithColors.accent, fontFamily: 'SpaceMono')),
          ),
        ],
      ),
    );
  }
}

class _DiscoverTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DiscoverTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: EdithColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: EdithColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: EdithColors.border),
              ),
              child: Icon(icon, color: EdithColors.textSecondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: EdithColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpaceMono',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: EdithColors.textSecondary,
                      fontSize: 11,
                      fontFamily: 'SpaceMono',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: EdithColors.textDim, size: 20),
          ],
        ),
      ),
    );
  }
}
