import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class ChatController extends GetxController {
  final String channelId;
  ChatController({required this.channelId});

  final rxMessages = <Map<String, dynamic>>[].obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  
  RealtimeChannel? _subscription;

  @override
  void onInit() {
    super.onInit();
    loadMessages();
    subscribeToMessages();
  }

  Future<void> loadMessages() async {
    try {
      final msgs = await SupabaseService.getMessages(channelId);
      rxMessages.value = msgs.map((m) => {
        'sender': m['sender_id'] == SupabaseService.userId ? 'me' : 'other',
        'handle': m['sender_id'] == SupabaseService.userId ? 'YOU' : 'CONTACT',
        'content': m['content'] ?? '',
        'time': m['created_at'] ?? '',
      }).toList();
      _scrollToBottom();
    } catch (e) {
      print('Failed to load messages: $e');
    }
  }

  void subscribeToMessages() {
    _subscription = SupabaseService.subscribeToMessages(
      channelId,
      (msg) {
        rxMessages.add({
          'sender': msg['sender_id'] == SupabaseService.userId ? 'me' : 'other',
          'handle': msg['sender_id'] == SupabaseService.userId ? 'YOU' : 'CONTACT',
          'content': msg['content'] ?? '',
          'time': DateTime.now().toString(),
        });
        _scrollToBottom();
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    textController.clear();
    
    // Optimistic UI update
    rxMessages.add({
      'sender': 'me',
      'handle': 'YOU',
      'content': text,
      'time': DateTime.now().toString(),
    });
    _scrollToBottom();
    
    try {
      await SupabaseService.sendMessage(
        channelId: channelId,
        content: text,
        expiresInMinutes: 1440,
      );
    } catch (e) {
      print('Failed to send message: $e');
    }
  }

  @override
  void onClose() {
    _subscription?.unsubscribe();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
