import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../controllers/identity_controller.dart';

class IdentityDashboardScreen extends StatelessWidget {
  const IdentityDashboardScreen({super.key});

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IdentityController());
    return EdithScaffold(
      showAppBar: false,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: EdithColors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu, color: EdithColors.textSecondary, size: 22),
                  const Spacer(),
                  const Icon(Icons.lock_outline, color: EdithColors.textSecondary, size: 22),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      "TODAY'S IDENTITY",
                      style: const TextStyle(
                        color: EdithColors.textDim,
                        fontSize: 10,
                        letterSpacing: 3,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Text(
                      controller.rxHandle.value,
                      style: const TextStyle(
                        color: EdithColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        fontFamily: 'SpaceMono',
                      ),
                    ).animate().fadeIn().scale()),
                    const SizedBox(height: 8),
                    Text(
                      'Rotates in',
                      style: const TextStyle(
                        color: EdithColors.textDim,
                        fontSize: 11,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => Text(
                      _formatDuration(controller.rxTimeLeft.value),
                      style: const TextStyle(
                        color: EdithColors.accent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SpaceMono',
                        letterSpacing: 4,
                      ),
                    )),
                    const SizedBox(height: 40),
                    // Stats grid
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.wifi_outlined,
                            value: controller.rxActiveChannels.value.toString(),
                            label: 'Active\nChannels',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.send_outlined,
                            value: controller.rxMediaTransmissions.value.toString(),
                            label: 'Media\nTransmissions',
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(height: 12),
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.shield_outlined,
                            value: '${controller.rxDataPurity.value.toInt()}%',
                            label: 'Data\nPurity',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.storage_outlined,
                            value: controller.rxStorageHealth.value,
                            label: 'Storage\nHealth',
                            valueColor: EdithColors.accent,
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EdithColors.card,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: EdithColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: EdithColors.textSecondary, size: 18),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? EdithColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'SpaceMono',
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: EdithColors.textSecondary,
              fontSize: 10,
              height: 1.5,
              letterSpacing: 0.5,
              fontFamily: 'SpaceMono',
            ),
          ),
        ],
      ),
    );
  }
}
