import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../controllers/chat_controller.dart';
import 'media_send_screen.dart';
import 'burn_chat_screen.dart';

class ChatScreen extends StatelessWidget {
  final String channelId;
  final String channelName;

  const ChatScreen(
      {super.key, required this.channelId, required this.channelName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ChatController(channelId: channelId),
      tag: channelId,
    );

    return Scaffold(
      backgroundColor: EdithColors.bg,
      appBar: AppBar(
        backgroundColor: EdithColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EdithColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              channelName,
              style: const TextStyle(
                color: EdithColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceMono',
              ),
            ),
            const Text(
              'End-to-end encrypted · Auto-expires',
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
                Get.to(() => BurnChatScreen(channelId: channelId));
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
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: controller.rxMessages.length,
              itemBuilder: (ctx, i) {
                final msg = controller.rxMessages[i];
                final isMe = msg['sender'] == 'me';
                final showHeader = i == 0 ||
                    controller.rxMessages[i - 1]['sender'] != msg['sender'];
                return _MessageBubble(
                  message: msg,
                  isMe: isMe,
                  showHeader: showHeader,
                ).animate().fadeIn(delay: Duration(milliseconds: i * 30));
              },
            )),
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
                    onPressed: () => Get.to(
                        () => MediaSendScreen(channelId: channelId)),
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
                        controller: controller.textController,
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
                        onSubmitted: (_) => controller.sendMessage(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: EdithColors.accent, size: 20),
                    onPressed: () => controller.sendMessage(),
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
              Text(
                '> ',
                style: TextStyle(
                  color: isMe ? EdithColors.textDim : EdithColors.accent,
                  fontSize: 12,
                  fontFamily: 'SpaceMono',
                ),
              ),
              Expanded(
                child: Text(
                  message['content'] ?? '',
                  style: TextStyle(
                    color: isMe
                        ? EdithColors.textSecondary
                        : EdithColors.textPrimary,
                    fontSize: 13,
                    fontFamily: 'SpaceMono',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
