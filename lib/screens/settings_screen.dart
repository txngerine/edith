import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'privacy_screen.dart';
import 'data_purity_screen.dart';
import 'storage_health_screen.dart';
import 'emergency_wipe_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EdithScaffold(
      title: 'Settings',
      body: ListView(
        children: [
          const SectionHeader('Preferences'),
          NavRow(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            onTap: () {},
          ),
          NavRow(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          NavRow(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            onTap: () => Get.to(() => const PrivacyScreen()),
          ),
          const SectionHeader('Security'),
          NavRow(
            icon: Icons.security_outlined,
            title: 'Security',
            onTap: () {},
          ),
          NavRow(
            icon: Icons.lock_outline,
            title: 'Vault',
            onTap: () {},
          ),
          const SectionHeader('Storage'),
          NavRow(
            icon: Icons.shield_outlined,
            title: 'Data Purity',
            trailing: '98%',
            onTap: () => Get.to(() => const DataPurityScreen()),
          ),
          NavRow(
            icon: Icons.storage_outlined,
            title: 'Storage Health',
            trailing: 'Good >',
            onTap: () => Get.to(() => const StorageHealthScreen()),
          ),
          const SectionHeader('Danger Zone'),
          NavRow(
            icon: Icons.warning_amber_outlined,
            title: 'Emergency Wipe',
            iconColor: EdithColors.danger,
            onTap: () => Get.to(() => const EmergencyWipeScreen()),
          ),
          const SectionHeader('About'),
          NavRow(
            icon: Icons.info_outline,
            title: 'About EDITH',
            trailing: 'v1.0.0 >',
            onTap: () => _showAbout(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: EdithColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: EdithColors.border),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'E D I T H',
              style: TextStyle(
                color: EdithColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                fontFamily: 'SpaceMono',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Even Dead Im The Hero',
              style: TextStyle(
                color: EdithColors.textSecondary,
                fontSize: 11,
                letterSpacing: 2,
                fontFamily: 'SpaceMono',
              ),
            ),
            SizedBox(height: 24),
            Divider(color: EdithColors.border),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Version', style: TextStyle(color: EdithColors.textSecondary, fontFamily: 'SpaceMono', fontSize: 12)),
                Text('1.0.0', style: TextStyle(color: EdithColors.textPrimary, fontFamily: 'SpaceMono', fontSize: 12)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Private by default', style: TextStyle(color: EdithColors.textSecondary, fontFamily: 'SpaceMono', fontSize: 12)),
                Icon(Icons.check, color: EdithColors.accent, size: 16),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Temporary by nature', style: TextStyle(color: EdithColors.textSecondary, fontFamily: 'SpaceMono', fontSize: 12)),
                Icon(Icons.check, color: EdithColors.accent, size: 16),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CLOSE',
                style: TextStyle(color: EdithColors.accent, fontFamily: 'SpaceMono')),
          ),
        ],
      ),
    );
  }
}
