import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/supabase_service.dart';
import 'onboarding_screen.dart';

class EmergencyWipeScreen extends StatefulWidget {
  const EmergencyWipeScreen({super.key});

  @override
  State<EmergencyWipeScreen> createState() => _EmergencyWipeScreenState();
}

class _EmergencyWipeScreenState extends State<EmergencyWipeScreen> {
  bool _vault = true;
  bool _messages = true;
  bool _keysAndSessions = true;
  bool _identityHistory = true;
  bool _isWiping = false;

  Future<void> _wipeEverything() async {
    developer.log('[EmergencyWipe] Starting emergency wipe', name: 'EDITH');
    setState(() => _isWiping = true);
    try {
      // emergencyWipe() now handles signOut() internally
      await SupabaseService.emergencyWipe();
      developer.log('[EmergencyWipe] Wipe + sign-out complete — navigating to onboarding', name: 'EDITH');
      // Clear entire navigation stack — user must re-onboard
      Get.offAll(() => const OnboardingScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 600));
    } catch (e) {
      if (mounted) setState(() => _isWiping = false);
      // Use Get.snackbar to avoid BuildContext-across-async-gap warning
      Get.snackbar(
        'Wipe Failed',
        e.toString(),
        backgroundColor: EdithColors.danger,
        colorText: EdithColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdithColors.bg,
      appBar: AppBar(
        backgroundColor: EdithColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EdithColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: EdithColors.border),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.warning_amber, color: EdithColors.danger, size: 52),
            const SizedBox(height: 20),
            const Text(
              'Emergency Wipe',
              style: TextStyle(
                color: EdithColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This will permanently delete all your data from this device.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: EdithColors.textSecondary,
                fontSize: 12,
                height: 1.6,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 40),
            // Checklist of what gets wiped
            _WipeItem(label: 'Vault', value: _vault,
                onChanged: (v) => setState(() => _vault = v!)),
            _WipeItem(label: 'Messages', value: _messages,
                onChanged: (v) => setState(() => _messages = v!)),
            _WipeItem(label: 'Keys & Sessions', value: _keysAndSessions,
                onChanged: (v) => setState(() => _keysAndSessions = v!)),
            _WipeItem(label: 'Identity History', value: _identityHistory,
                onChanged: (v) => setState(() => _identityHistory = v!)),
            const Spacer(),
            EdithButton(
              label: 'Wipe Everything',
              isDanger: true,
              icon: Icons.delete_sweep,
              onTap: () => _confirmWipe(context),
              isLoading: _isWiping,
            ),
            const SizedBox(height: 12),
            EdithButton(
              label: 'Cancel',
              isOutlined: true,
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmWipe(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: EdithColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: EdithColors.danger),
        ),
        title: const Text(
          'ARE YOU SURE?',
          style: TextStyle(
            color: EdithColors.danger,
            fontSize: 14,
            letterSpacing: 3,
            fontFamily: 'SpaceMono',
          ),
        ),
        content: const Text(
          'This will permanently destroy everything. There is no recovery.',
          style: TextStyle(
            color: EdithColors.textSecondary,
            fontSize: 12,
            fontFamily: 'SpaceMono',
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL',
                style: TextStyle(color: EdithColors.textSecondary, fontFamily: 'SpaceMono')),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _wipeEverything();
            },
            child: const Text('CONFIRM WIPE',
                style: TextStyle(
                    color: EdithColors.danger,
                    fontFamily: 'SpaceMono',
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _WipeItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _WipeItem({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_box : Icons.check_box_outline_blank,
            color: EdithColors.danger,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: EdithColors.textPrimary,
              fontSize: 13,
              fontFamily: 'SpaceMono',
            ),
          ),
        ],
      ),
    );
  }
}
