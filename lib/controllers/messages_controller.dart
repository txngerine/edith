import 'package:get/get.dart';
import '../services/supabase_service.dart';

class MessagesController extends GetxController {
  // Observables
  final rxChannels = <Map<String, dynamic>>[].obs;
  final rxIsLoading = true.obs;
  final rxIdentityHandle = 'Loading...'.obs;

  @override
  void onInit() {
    super.onInit();
    loadChannels();
  }

  Future<void> loadChannels() async {
    rxIsLoading.value = true;
    try {
      final real = await SupabaseService.getChannels();
      final identity = await SupabaseService.getCurrentIdentity();
      
      rxChannels.value = real;
      
      if (identity != null) {
        rxIdentityHandle.value = identity['handle'] ?? 'Unknown';
      }
    } catch (e) {
      print('Failed to load channels: $e');
    } finally {
      rxIsLoading.value = false;
    }
  }
}
