import 'dart:async';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import '../services/supabase_service.dart';

class IdentityController extends GetxController {
  final rxHandle = 'Loading...'.obs;
  final rxTimeLeft = const Duration(hours: 24).obs;
  final rxActiveChannels = 0.obs;
  final rxMediaTransmissions = 0.obs;
  final rxDataPurity = 0.0.obs;
  final rxStorageHealth = 'Unknown'.obs;
  
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    loadIdentity();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (rxTimeLeft.value.inSeconds > 0) {
        rxTimeLeft.value = rxTimeLeft.value - const Duration(seconds: 1);
      } else {
        rxTimeLeft.value = const Duration(hours: 24);
      }
    });
  }

  Future<void> loadIdentity() async {
    try {
      final data = await SupabaseService.getCurrentIdentity();
      final stats = await SupabaseService.getUserStats();

      if (data != null) {
        rxHandle.value = data['handle'] ?? 'Unknown';

        // 1.3 FIX: Calculate real time remaining from rotated_at timestamp
        final rotatedAtStr = data['rotated_at'] as String?;
        if (rotatedAtStr != null) {
          final rotatedAt = DateTime.tryParse(rotatedAtStr)?.toLocal();
          if (rotatedAt != null) {
            final elapsed = DateTime.now().difference(rotatedAt);
            final remaining = const Duration(hours: 24) - elapsed;
            // If already expired, set to zero — identity needs rotation
            rxTimeLeft.value =
                remaining.isNegative ? Duration.zero : remaining;
          }
        }
      }

      rxActiveChannels.value = stats['messages_destroyed'] ?? 0;
      rxMediaTransmissions.value = stats['media_expired'] ?? 0;
      rxDataPurity.value = (stats['data_purity'] ?? 0).toDouble();
      rxStorageHealth.value = 'Good';
    } catch (e) {
      developer.log('[IdentityController] Failed to load identity: $e',
          name: 'EDITH');
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
