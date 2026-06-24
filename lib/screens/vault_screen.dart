import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../controllers/vault_controller.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  static const _tabs = ['Photos', 'Videos', 'Documents'];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VaultController());

    return EdithScaffold(
      title: 'Vault',
      actions: [
        IconButton(
          icon: const Icon(Icons.search,
              color: EdithColors.textSecondary, size: 22),
          onPressed: () {},
        ),
      ],
      body: Column(
        children: [
          // Tab bar — driven by controller's TabController
          Container(
            color: EdithColors.surface,
            child: TabBar(
              controller: controller.tabController,
              indicatorColor: EdithColors.accent,
              indicatorWeight: 2,
              labelColor: EdithColors.accent,
              unselectedLabelColor: EdithColors.textSecondary,
              labelStyle: const TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          // Grid
          Expanded(
            child: Obx(() {
              if (controller.rxIsLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: EdithColors.accent));
              }

              if (controller.rxError.value != null) {
                return Center(
                  child: GestureDetector(
                    onTap: controller.retry,
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

              if (controller.rxItems.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline,
                          color: EdithColors.textDim, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'VAULT IS EMPTY',
                        style: TextStyle(
                          color: EdithColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontFamily: 'SpaceMono',
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: controller.rxItems.length,
                itemBuilder: (ctx, i) =>
                    _VaultGridItem(item: controller.rxItems[i]),
              );
            }),
          ),
          // Vault protected badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: EdithColors.border)),
              color: EdithColors.surface,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, color: EdithColors.accent, size: 14),
                SizedBox(width: 6),
                Text(
                  'Vault is protected',
                  style: TextStyle(
                    color: EdithColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'SpaceMono',
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultGridItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _VaultGridItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final hasImage = item['thumbnail_url'] != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: EdithColors.card,
          child: hasImage
              ? CachedNetworkImage(
                  imageUrl: item['thumbnail_url'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Center(
                  child: Icon(
                    item['type'] == 'video'
                        ? Icons.play_circle_outline
                        : item['type'] == 'document'
                            ? Icons.description_outlined
                            : Icons.image_outlined,
                    color: EdithColors.textDim,
                    size: 32,
                  ),
                ),
        ),
        // Locked overlay
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: EdithColors.bg.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.lock_outline,
                color: EdithColors.accent, size: 12),
          ),
        ),
        // Date label
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  EdithColors.bg.withValues(alpha: 0.8),
                  Colors.transparent
                ],
              ),
            ),
            child: Text(
              item['saved_at'] ?? '',
              style: const TextStyle(
                color: EdithColors.textDim,
                fontSize: 8,
                fontFamily: 'SpaceMono',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
