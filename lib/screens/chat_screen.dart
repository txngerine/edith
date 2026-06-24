import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import 'media_send_screen.dart';
import 'burn_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  final String channelId;
  final String channelName;

  const ChatScreen(
      {super.key, required this.channelId, required this.channelName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  RealtimeChannel? _subscription;



  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeToMessages();
  }

  Future<void> _loadMessages() async {
    developer.log('[ChatScreen] Loading messages for channel: ${widget.channelId}', name: 'EDITH');
    try {
      final msgs = await SupabaseService.getMessages(widget.channelId);
      developer.log('[ChatScreen] Loaded ${msgs.length} messages', name: 'EDITH');
      if (mounted) {
        setState(() => _messages = msgs
            .map((m) => {
                  'sender':
                      m['sender_id'] == SupabaseService.userId ? 'me' : 'other',
                  'handle': m['sender_id'] == SupabaseService.userId
                      ? 'YOU'
                      : 'CONTACT',
                  'content': m['content'] ?? '',
                  'time': m['created_at'] ?? '',
                })
            .toList());
      }
    } catch (e) {
      developer.log('[ChatScreen] Failed to load messages: $e', name: 'EDITH');
    }
  }

  void _subscribeToMessages() {
    developer.log('[ChatScreen] Subscribing to realtime messages for: ${widget.channelId}', name: 'EDITH');
    _subscription = SupabaseService.subscribeToMessages(
      widget.channelId,
      (msg) {
        developer.log('[ChatScreen] New message via realtime', name: 'EDITH');
        if (!mounted) return;
        setState(() => _messages.add({
              'sender':
                  msg['sender_id'] == SupabaseService.userId ? 'me' : 'other',
              'handle': 'CONTACT',
              'content': msg['content'] ?? '',
              'time': DateTime.now().toString(),
            }));
        _scrollToBottom();
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _messages.add({
          'sender': 'me',
          'handle': 'YOU',
          'content': text,
          'time': TimeOfDay.now().format(context),
        }));
    _scrollToBottom();
    try {
      await SupabaseService.sendMessage(
        channelId: widget.channelId,
        content: text,
        expiresInMinutes: 1440,
      );
      developer.log('[ChatScreen] Message sent', name: 'EDITH');
    } catch (e) {
      developer.log('[ChatScreen] Failed to send message: $e', name: 'EDITH');
    }
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.channelName,
              style: const TextStyle(
                color: EdithColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceMono',
              ),
            ),
            const Text(
              'FALCON_19 · Rotates in 12h 42m',
              style: TextStyle(
                color: EdithColors.textDim,
                fontSize: 10,
                fontFamily: 'SpaceMono',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline,
                color: EdithColors.textSecondary, size: 20),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: EdithColors.textSecondary, size: 20),
            color: EdithColors.card,
            onSelected: (val) {
              if (val == 'burn') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            BurnChatScreen(channelId: widget.channelId)));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'burn',
                child: Text('Burn Chat',
                    style: TextStyle(
                        color: EdithColors.danger,
                        fontFamily: 'SpaceMono',
                        fontSize: 12)),
              ),
            ],
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: EdithColors.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                final isMe = msg['sender'] == 'me';
                final showHeader =
                    i == 0 || _messages[i - 1]['sender'] != msg['sender'];
                return _MessageBubble(
                  message: msg,
                  isMe: isMe,
                  showHeader: showHeader,
                ).animate().fadeIn(delay: Duration(milliseconds: i * 30));
              },
            ),
          ),
          // "New messages" divider if applicable
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const Expanded(child: Divider(color: EdithColors.accentDim)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'New messages',
                    style: TextStyle(
                        color: EdithColors.accentDim,
                        fontSize: 10,
                        fontFamily: 'SpaceMono'),
                  ),
                ),
                const Expanded(child: Divider(color: EdithColors.accentDim)),
              ],
            ),
          ),
          // Input bar
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: EdithColors.border)),
              color: EdithColors.surface,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file,
                        color: EdithColors.textSecondary, size: 20),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              MediaSendScreen(channelId: widget.channelId)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_camera_outlined,
                        color: EdithColors.textSecondary, size: 20),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: EdithColors.card,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: EdithColors.border),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(
                          color: EdithColors.textPrimary,
                          fontSize: 13,
                          fontFamily: 'SpaceMono',
                        ),
                        decoration: const InputDecoration(
                          hintText: '>',
                          hintStyle: TextStyle(
                            color: EdithColors.accent,
                            fontFamily: 'SpaceMono',
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none,
                        color: EdithColors.textSecondary, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final bool showHeader;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showHeader,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            const SizedBox(height: 12),
            Text(
              '${message['time']}',
              style: const TextStyle(
                color: EdithColors.textDim,
                fontSize: 9,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isMe ? 'YOU' : (message['handle'] ?? 'CONTACT'),
              style: TextStyle(
                color: isMe ? EdithColors.textSecondary : EdithColors.accent,
                fontSize: 10,
                letterSpacing: 1,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              if (!isMe) ...[
                const Text(
                  '> ',
                  style: TextStyle(
                    color: EdithColors.textDim,
                    fontSize: 12,
                    fontFamily: 'SpaceMono',
                  ),
                ),
              ] else ...[
                const Text(
                  '> ',
                  style: TextStyle(
                    color: EdithColors.textDim,
                    fontSize: 12,
                    fontFamily: 'SpaceMono',
                  ),
                ),
              ],
              Text(
                message['content'] ?? '',
                style: TextStyle(
                  color: isMe
                      ? EdithColors.textSecondary
                      : EdithColors.textPrimary,
                  fontSize: 13,
                  fontFamily: 'SpaceMono',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
