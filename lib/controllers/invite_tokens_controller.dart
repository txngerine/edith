import 'dart:developer' as developer;
import 'package:get/get.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class InviteTokensController extends GetxController {
  final rxTokens = <Map<String, dynamic>>[].obs;
  final rxIsLoading = true.obs;
  final rxIsGenerating = false.obs;
  final rxError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadTokens();
  }

  Future<void> loadTokens() async {
    rxIsLoading.value = true;
    rxError.value = null;
    try {
      final tokens = await SupabaseService.getInviteTokens();
      rxTokens.value = tokens;
      developer.log(
          '[InviteTokensController] Loaded ${tokens.length} tokens',
          name: 'EDITH');
    } catch (e) {
      developer.log('[InviteTokensController] Failed to load tokens: $e',
          name: 'EDITH');
      rxError.value = 'Failed to load tokens. Tap to retry.';
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> generateToken() async {
    rxIsGenerating.value = true;
    try {
      await SupabaseService.generateInviteToken();
      developer.log('[InviteTokensController] New token generated',
          name: 'EDITH');
      // Reload so the new token appears with its DB-generated expiry
      await loadTokens();
    } catch (e) {
      developer.log('[InviteTokensController] Failed to generate token: $e',
          name: 'EDITH');
      Get.snackbar(
        'Error',
        'Could not generate token. Try again.',
        backgroundColor: EdithColors.danger,
        colorText: EdithColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      rxIsGenerating.value = false;
    }
  }

  Future<void> revokeToken(String token) async {
    try {
      await SupabaseService.revokeInviteToken(token);
      developer.log(
          '[InviteTokensController] Token revoked: $token', name: 'EDITH');
      rxTokens.removeWhere((t) => t['token'] == token);
    } catch (e) {
      developer.log('[InviteTokensController] Failed to revoke token: $e',
          name: 'EDITH');
      Get.snackbar(
        'Error',
        'Could not revoke token.',
        backgroundColor: EdithColors.danger,
        colorText: EdithColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
