import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/supabase_service.dart';

class StorageHealthScreen extends StatefulWidget {
  const StorageHealthScreen({super.key});

  @override
  State<StorageHealthScreen> createState() => _StorageHealthScreenState();
}

class _StorageHealthScreenState extends State<StorageHealthScreen> {
  double _currentUsageMb = 125.4;
  double _totalMb = 512;
  double _mediaScheduledDeletionMb = 42.3;
  double _vaultUsageMb = 83.1;
  double _cleanupEfficiency = 0.98;
  double _dataPurity = 0.98;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    developer.log('[StorageHealth] Loading user stats', name: 'EDITH');
    try {
      final data = await SupabaseService.getUserStats();
      developer.log('[StorageHealth] Stats loaded', name: 'EDITH');
      if (mounted && data.isNotEmpty) {
        setState(() {
          _currentUsageMb = (data['storage_used_mb'] as num?)?.toDouble() ?? 125.4;
        });
      }
    } catch (e) {
      developer.log('[StorageHealth] Failed to load stats: $e', name: 'EDITH');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usagePercent = _currentUsageMb / _totalMb;

    return EdithScaffold(
      title: 'Storage Health',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Current usage
            const Text(
              'CURRENT USAGE',
              style: TextStyle(
                color: EdithColors.textDim,
                fontSize: 10,
                letterSpacing: 2,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_currentUsageMb.toStringAsFixed(1)} MB',
              style: const TextStyle(
                color: EdithColors.textPrimary,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 12),
            EdithProgressBar(
              value: usagePercent,
              height: 6,
              color: usagePercent > 0.8 ? EdithColors.danger : EdithColors.accent,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(usagePercent * 100).toInt()}% used',
                  style: const TextStyle(
                      color: EdithColors.textSecondary,
                      fontSize: 11,
                      fontFamily: 'SpaceMono'),
                ),
                const Text(
                  'Good',
                  style: TextStyle(
                      color: EdithColors.accent,
                      fontSize: 11,
                      fontFamily: 'SpaceMono',
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Breakdown
            _StorageLine(
                label: 'Media Scheduled for Deletion',
                value: '${_mediaScheduledDeletionMb.toStringAsFixed(1)} MB'),
            _StorageLine(
                label: 'Vault Usage',
                value: '${_vaultUsageMb.toStringAsFixed(1)} MB'),
            _StorageLine(
                label: 'Cleanup Efficiency',
                value: '${(_cleanupEfficiency * 100).toInt()}%'),
            _StorageLine(
                label: 'Data Purity',
                value: '${(_dataPurity * 100).toInt()}%'),
            const SizedBox(height: 32),
            // Storage bars breakdown
            const Text(
              'BREAKDOWN',
              style: TextStyle(
                color: EdithColors.textDim,
                fontSize: 10,
                letterSpacing: 2,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 16),
            _BreakdownBar(
                label: 'Messages',
                percent: 0.08,
                color: EdithColors.accent),
            const SizedBox(height: 10),
            _BreakdownBar(
                label: 'Vault',
                percent: _vaultUsageMb / _totalMb,
                color: EdithColors.accentDim),
            const SizedBox(height: 10),
            _BreakdownBar(
                label: 'Pending Deletion',
                percent: _mediaScheduledDeletionMb / _totalMb,
                color: EdithColors.danger),
          ],
        ),
      ),
    );
  }
}

class _StorageLine extends StatelessWidget {
  final String label;
  final String value;

  const _StorageLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: EdithColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: EdithColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'SpaceMono')),
          Text(value,
              style: const TextStyle(
                  color: EdithColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SpaceMono')),
        ],
      ),
    );
  }
}

class _BreakdownBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _BreakdownBar(
      {required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: EdithColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'SpaceMono')),
            Text('${(percent * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                    color: color, fontSize: 11, fontFamily: 'SpaceMono')),
          ],
        ),
        const SizedBox(height: 6),
        EdithProgressBar(value: percent, color: color),
      ],
    );
  }
}
