import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/supabase_service.dart';
import 'chat_screen.dart';
import 'identity_dashboard_screen.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  List<Map<String, dynamic>> _channels = [];
  bool _isLoading = true;
  String _identityHandle = 'Loading...';



  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    developer.log('[MessagesListScreen] Loading channels', name: 'EDITH');
    try {
      final real = await SupabaseService.getChannels();
      final identity = await SupabaseService.getCurrentIdentity();
      developer.log('[MessagesListScreen] Loaded ${real.length} channels', name: 'EDITH');
      if (mounted) {
        setState(() {
          _channels = real;
          _isLoading = false;
          if (identity != null) {
            _identityHandle = identity['handle'] ?? 'Unknown';
          }
        });
      }
    } catch (e) {
      developer.log('[MessagesListScreen] Failed to load channels: $e', name: 'EDITH');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return EdithScaffold(
      showAppBar: false,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: EdithColors.border)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Messages',
                    style: TextStyle(
                      color: EdithColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpaceMono',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: EdithColors.textSecondary, size: 22),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune, color: EdithColors.textSecondary, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Identity banner
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IdentityDashboardScreen()),
              ),
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: EdithColors.card,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: EdithColors.accentDim),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: EdithColors.accent, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _identityHandle,
                      style: const TextStyle(
                        color: EdithColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SpaceMono',
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('·',
                        style: TextStyle(color: EdithColors.textDim, fontSize: 12)),
                    const SizedBox(width: 8),
                    const Text(
                      'Identity Active',
                      style: TextStyle(
                        color: EdithColors.textDim,
                        fontSize: 11,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: EdithColors.textDim, size: 16),
                  ],
                ),
              ),
            ),
            // Channel list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: EdithColors.accent))
                  : ListView.builder(
                      itemCount: _channels.length,
                      itemBuilder: (ctx, i) {
                        final ch = _channels[i];
                        return _ChannelTile(
                          channel: ch,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                channelId: ch['id'] ?? 'demo',
                                channelName: ch['name'] ?? 'Channel',
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: i * 60));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final Map<String, dynamic> channel;
  final VoidCallback onTap;

  const _ChannelTile({required this.channel, required this.onTap});

  IconData _iconForType(String? type) {
    switch (type) {
      case 'trusted':
        return Icons.person_add_outlined;
      case 'circle':
        return Icons.group_outlined;
      default:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = channel['unread'] as int? ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: EdithColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: EdithColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: EdithColors.border),
              ),
              child: Icon(
                _iconForType(channel['type']),
                color: EdithColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel['name'] ?? '',
                    style: const TextStyle(
                      color: EdithColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpaceMono',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    channel['last_message'] ?? '',
                    style: const TextStyle(
                      color: EdithColors.textSecondary,
                      fontSize: 11,
                      fontFamily: 'SpaceMono',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  channel['time'] ?? '',
                  style: const TextStyle(
                    color: EdithColors.textDim,
                    fontSize: 10,
                    fontFamily: 'SpaceMono',
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: EdithColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unread.toString(),
                      style: const TextStyle(
                        color: EdithColors.bg,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
