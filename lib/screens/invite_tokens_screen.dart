import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../controllers/invite_tokens_controller.dart';

class InviteTokensScreen extends StatelessWidget {
  const InviteTokensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InviteTokensController());

    return EdithScaffold(
      title: 'Active Tokens',
      actions: [
        Obx(() => controller.rxIsGenerating.value
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: EdithColors.accent, strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.add, color: EdithColors.accent, size: 22),
                tooltip: 'Generate new token',
                onPressed: controller.generateToken,
              )),
      ],
      body: Obx(() {
        if (controller.rxIsLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: EdithColors.accent));
        }

        if (controller.rxError.value != null) {
          return Center(
            child: GestureDetector(
              onTap: controller.loadTokens,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_outlined,
                      color: EdithColors.textDim, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    controller.rxError.value!,
                    style: const TextStyle(
                      color: EdithColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'SpaceMono',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.rxTokens.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.token_outlined,
                    color: EdithColors.textDim, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'NO ACTIVE TOKENS',
                  style: TextStyle(
                    color: EdithColors.textSecondary,
                    fontSize: 14,
                    letterSpacing: 2,
                    fontFamily: 'SpaceMono',
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 24),
                const Text(
                  'Tap + to generate a new invite token',
                  style: TextStyle(
                    color: EdithColors.textDim,
                    fontSize: 11,
                    fontFamily: 'SpaceMono',
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.rxTokens.length,
          itemBuilder: (ctx, i) {
            final t = controller.rxTokens[i];
            final token = t['token'] as String? ?? '';
            final expiresStr = t['expires_at'] != null
                ? DateTime.parse(t['expires_at'] as String)
                    .toLocal()
                    .toString()
                    .split('.')[0]
                : 'Unknown';

            // Compute whether token is still valid
            final isExpired = t['expires_at'] != null &&
                DateTime.parse(t['expires_at'] as String)
                    .toLocal()
                    .isBefore(DateTime.now());

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: EdithColors.card,
                border: Border.all(
                  color: isExpired ? EdithColors.danger : EdithColors.border,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          token,
                          style: TextStyle(
                            color: isExpired
                                ? EdithColors.textDim
                                : EdithColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontFamily: 'SpaceMono',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              isExpired
                                  ? Icons.timer_off_outlined
                                  : Icons.timer_outlined,
                              color: isExpired
                                  ? EdithColors.danger
                                  : EdithColors.textSecondary,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isExpired
                                  ? 'Expired'
                                  : 'Expires: $expiresStr',
                              style: TextStyle(
                                color: isExpired
                                    ? EdithColors.danger
                                    : EdithColors.textSecondary,
                                fontSize: 11,
                                fontFamily: 'SpaceMono',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Copy to clipboard
                  IconButton(
                    icon: const Icon(Icons.copy_outlined,
                        color: EdithColors.textDim, size: 18),
                    tooltip: 'Copy token',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: token));
                      Get.snackbar(
                        'Copied',
                        'Token copied to clipboard',
                        backgroundColor: EdithColors.accent,
                        colorText: EdithColors.bg,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                  // Revoke
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: EdithColors.danger, size: 20),
                    tooltip: 'Revoke token',
                    onPressed: () => controller.revokeToken(token),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 50 * i));
          },
        );
      }),
    );
  }
}
