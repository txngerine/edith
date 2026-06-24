import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/supabase_service.dart';

class BurnChatScreen extends StatefulWidget {
  final String channelId;

  const BurnChatScreen({super.key, required this.channelId});

  @override
  State<BurnChatScreen> createState() => _BurnChatScreenState();
}

class _BurnChatScreenState extends State<BurnChatScreen> {
  bool _messages = true;
  bool _media = true;
  bool _metadata = true;
  bool _isBurning = false;

  Future<void> _burnChat() async {
    developer.log('[BurnChat] Burning channel: ${widget.channelId}', name: 'EDITH');
    setState(() => _isBurning = true);
    try {
      await SupabaseService.burnChannel(widget.channelId);
      developer.log('[BurnChat] Channel burned successfully', name: 'EDITH');
      if (mounted) {
        Navigator.of(context)
          ..pop() // close burn screen
          ..pop() // close chat screen
          ..pop(); // back to messages list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat burned. Nothing remains.'),
            backgroundColor: EdithColors.dangerDim,
          ),
        );
      }
    } catch (e) {
      setState(() => _isBurning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdithColors.bg,
      appBar: AppBar(
        backgroundColor: EdithColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EdithColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: EdithColors.border),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: EdithColors.dangerDim,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.delete_forever, color: EdithColors.danger, size: 32),
            ),
            const SizedBox(height: 24),
            const Text(
              'Burn this chat?',
              style: TextStyle(
                color: EdithColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: EdithColors.textSecondary,
                fontSize: 12,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 40),
            // Checkboxes
            _BurnCheckItem(
              label: 'Messages',
              value: _messages,
              onChanged: (v) => setState(() => _messages = v!),
            ),
            _BurnCheckItem(
              label: 'Media',
              value: _media,
              onChanged: (v) => setState(() => _media = v!),
            ),
            _BurnCheckItem(
              label: 'Metadata',
              value: _metadata,
              onChanged: (v) => setState(() => _metadata = v!),
            ),
            const Spacer(),
            EdithButton(
              label: 'Burn Now',
              isDanger: true,
              onTap: _burnChat,
              isLoading: _isBurning,
              icon: Icons.local_fire_department,
            ),
            const SizedBox(height: 12),
            EdithButton(
              label: 'Cancel',
              isOutlined: true,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _BurnCheckItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _BurnCheckItem({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? EdithColors.danger : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: value ? EdithColors.danger : EdithColors.border,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: EdithColors.textPrimary,
                fontSize: 13,
                fontFamily: 'SpaceMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
