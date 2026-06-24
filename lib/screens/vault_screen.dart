import 'dart:developer' as developer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/supabase_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['Photos', 'Videos', 'Documents'];
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadItems('photo');
  }

  void _onTabChanged() {
    final types = ['photo', 'video', 'document'];
    _loadItems(types[_tabController.index]);
  }

  Future<void> _loadItems(String type) async {
    developer.log('[VaultScreen] Loading vault items for type: $type',
        name: 'EDITH');
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.getVaultItems(type);
      developer.log('[VaultScreen] Loaded ${data.length} vault items',
          name: 'EDITH');
      if (mounted) {
        setState(() {
          _items = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('[VaultScreen] Failed to load vault items: $e',
          name: 'EDITH');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // Tab bar
          Container(
            color: EdithColors.surface,
            child: TabBar(
              controller: _tabController,
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: EdithColors.accent))
                : GridView.builder(
                    padding: const EdgeInsets.all(2),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) {
                      final item = _items[i];
                      return _VaultGridItem(item: item);
                    },
                  ),
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
                colors: [EdithColors.bg.withValues(alpha: 0.8), Colors.transparent],
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
