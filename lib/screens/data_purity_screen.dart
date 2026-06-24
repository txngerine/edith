import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/supabase_service.dart';

class DataPurityScreen extends StatefulWidget {
  const DataPurityScreen({super.key});

  @override
  State<DataPurityScreen> createState() => _DataPurityScreenState();
}

class _DataPurityScreenState extends State<DataPurityScreen> {
  Map<String, dynamic> _stats = {
    'messages_destroyed': 48221,
    'media_expired': 8127,
    'identities_rotated': 1247,
    'tokens_recycled': 3911,
    'data_purity': 98,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    developer.log('[DataPurityScreen] Loading user stats', name: 'EDITH');
    try {
      final data = await SupabaseService.getUserStats();
      developer.log('[DataPurityScreen] Stats loaded', name: 'EDITH');
      if (mounted && data.isNotEmpty) {
        setState(() => _stats = data);
      }
    } catch (e) {
      developer.log('[DataPurityScreen] Failed to load stats: $e',
          name: 'EDITH');
    }
  }

  @override
  Widget build(BuildContext context) {
    final purity = (_stats['data_purity'] as num?)?.toDouble() ?? 98.0;

    return EdithScaffold(
      title: 'Data Purity',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Circular indicator
            CircularPercentIndicator(
              radius: 90,
              lineWidth: 8,
              percent: purity / 100,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${purity.toInt()}%',
                    style: const TextStyle(
                      color: EdithColors.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpaceMono',
                    ),
                  ),
                  const Text(
                    'Excellent',
                    style: TextStyle(
                      color: EdithColors.accent,
                      fontSize: 12,
                      fontFamily: 'SpaceMono',
                    ),
                  ),
                ],
              ),
              progressColor: EdithColors.accent,
              backgroundColor: EdithColors.border,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 40),
            // Stats
            _StatRow(
              label: 'Messages Destroyed',
              value: _formatNum(_stats['messages_destroyed']),
            ),
            _StatRow(
              label: 'Media Expired',
              value: _formatNum(_stats['media_expired']),
            ),
            _StatRow(
              label: 'Identities Rotated',
              value: _formatNum(_stats['identities_rotated']),
            ),
            _StatRow(
              label: 'Tokens Recycled',
              value: _formatNum(_stats['tokens_recycled']),
            ),
            const SizedBox(height: 32),
            const Divider(color: EdithColors.border),
            const SizedBox(height: 12),
            const Text(
              'Keep it clean. Keep it private.',
              style: TextStyle(
                color: EdithColors.textDim,
                fontSize: 11,
                letterSpacing: 2,
                fontFamily: 'SpaceMono',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNum(dynamic val) {
    if (val == null) return '0';
    final n = (val as num).toInt();
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k'.replaceAll('.0k', 'k');
    }
    return n.toString();
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

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
          Text(
            label,
            style: const TextStyle(
              color: EdithColors.textSecondary,
              fontSize: 12,
              fontFamily: 'SpaceMono',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: EdithColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'SpaceMono',
            ),
          ),
        ],
      ),
    );
  }
}
