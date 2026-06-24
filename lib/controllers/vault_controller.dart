import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_service.dart';

class VaultController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final rxItems = <Map<String, dynamic>>[].obs;
  final rxIsLoading = false.obs;
  final rxError = RxnString();
  final rxTabIndex = 0.obs;

  late final TabController tabController;

  static const _types = ['photo', 'video', 'document'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    // Only reload when the animation settles on a new tab
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        rxTabIndex.value = tabController.index;
        loadItems(_types[tabController.index]);
      }
    });
    loadItems('photo');
  }

  Future<void> loadItems(String type) async {
    developer.log('[VaultController] Loading vault items for type: $type',
        name: 'EDITH');
    rxIsLoading.value = true;
    rxError.value = null;
    try {
      final data = await SupabaseService.getVaultItems(type);
      developer.log(
          '[VaultController] Loaded ${data.length} vault items', name: 'EDITH');
      rxItems.value = data;
    } catch (e) {
      developer.log('[VaultController] Failed to load vault items: $e',
          name: 'EDITH');
      rxError.value = 'Failed to load. Tap to retry.';
    } finally {
      rxIsLoading.value = false;
    }
  }

  void retry() => loadItems(_types[tabController.index]);

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
