import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseService {
  static void _debugLog(String method, String reason,
      {Object? params, Object? result, Object? error}) {
    final buf = StringBuffer()..write('[Supabase API] $method — $reason');
    if (params != null) buf.write(' | params: $params');
    if (result != null) buf.write(' | result: $result');
    if (error != null) buf.write(' | ERROR: $error');
    developer.log(buf.toString(), name: 'EDITH');
  }

  static SupabaseClient get client => Supabase.instance.client;
  static final _uuid = const Uuid();

  // ─── Auth ───────────────────────────────────────────────────────────────────

  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static String? get userId => currentUser?.id;

  static Future<User?> waitForSession(
      {Duration timeout = const Duration(seconds: 5)}) async {
    if (currentUser != null) {
      _debugLog('waitForSession', 'User already logged in',
          result: currentUser?.id);
      return currentUser;
    }
    try {
      _debugLog('waitForSession', 'Waiting for auth session recovery');
      final event = await client.auth.onAuthStateChange.first.timeout(timeout);
      final user = event.session?.user;
      _debugLog('waitForSession', 'Session recovered', result: user?.id);
      return user;
    } catch (e) {
      _debugLog('waitForSession', 'Session recovery failed or timed out',
          error: e);
      return null;
    }
  }

  static Future<AuthResponse> signUpAnonymous() async {
    _debugLog('signUpAnonymous', 'Signing in anonymously');
    try {
      final res = await client.auth.signInAnonymously();
      _debugLog('signUpAnonymous', 'Anonymous sign-in succeeded',
          result: res.user?.id);
      return res;
    } catch (e) {
      _debugLog('signUpAnonymous', 'Anonymous sign-in failed', error: e);
      rethrow;
    }
  }

  static Future<AuthResponse> signInWithEmail(
      String email, String password) async {
    _debugLog('signInWithEmail', 'Signing in with email/password',
        params: {'email': email});
    try {
      final res = await client.auth
          .signInWithPassword(email: email, password: password);
      _debugLog('signInWithEmail', 'Sign-in succeeded', result: res.user?.id);
      return res;
    } catch (e) {
      _debugLog('signInWithEmail', 'Sign-in failed', error: e);
      rethrow;
    }
  }

  static Future<AuthResponse> signUpWithEmail(
      String email, String password) async {
    _debugLog('signUpWithEmail', 'Registering new account',
        params: {'email': email});
    try {
      final res = await client.auth.signUp(email: email, password: password);
      _debugLog('signUpWithEmail', 'Registration succeeded',
          result: res.user?.id);
      return res;
    } catch (e) {
      _debugLog('signUpWithEmail', 'Registration failed', error: e);
      rethrow;
    }
  }

  static Future<void> signOut() async {
    _debugLog('signOut', 'Signing out current user');
    try {
      await client.auth.signOut();
      _debugLog('signOut', 'Sign-out succeeded');
    } catch (e) {
      _debugLog('signOut', 'Sign-out failed', error: e);
      rethrow;
    }
  }

  // ─── Identity ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getCurrentIdentity() async {
    _debugLog('getCurrentIdentity', 'Fetching current identity');
    if (userId == null) {
      _debugLog('getCurrentIdentity', 'No user ID — skipping');
      return null;
    }
    try {
      final res = await client
          .from('identities')
          .select()
          .eq('user_id', userId!)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      _debugLog('getCurrentIdentity', 'Identity fetched', result: res);
      return res;
    } catch (e) {
      _debugLog('getCurrentIdentity', 'Failed to fetch identity', error: e);
      rethrow;
    }
  }

  static Future<void> rotateIdentity(String newHandle) async {
    _debugLog('rotateIdentity', 'Rotating identity',
        params: {'newHandle': newHandle});
    if (userId == null) {
      _debugLog('rotateIdentity', 'No user ID — skipping');
      return;
    }
    try {
      await client.from('identities').insert({
        'user_id': userId,
        'handle': newHandle,
        'rotated_at': DateTime.now().toIso8601String(),
      });
      _debugLog('rotateIdentity', 'Identity rotated successfully');
    } catch (e) {
      _debugLog('rotateIdentity', 'Failed to rotate identity', error: e);
      rethrow;
    }
  }

  // ─── Channels / Messages ────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getChannels() async {
    _debugLog('getChannels', 'Fetching user channels');
    if (userId == null) {
      _debugLog('getChannels', 'No user ID — returning empty');
      return [];
    }
    try {
      final res = await client
          .from('channel_members')
          .select('channel_id, channels(id, name, type, created_at)')
          .eq('user_id', userId!);
      // Flatten the nested join so the UI gets flat fields directly
      final channels = List<Map<String, dynamic>>.from(res).map((row) {
        final ch = (row['channels'] as Map<String, dynamic>?) ?? {};
        return <String, dynamic>{
          'id': ch['id'] ?? row['channel_id'],
          'name': ch['name'] ?? 'Unnamed',
          'type': ch['type'] ?? 'private',
          'last_message': '',
          'time': '',
          'unread': 0,
        };
      }).toList();
      _debugLog('getChannels', 'Channels fetched (flattened)',
          result: '${channels.length} channels');
      return channels;
    } catch (e) {
      _debugLog('getChannels', 'Failed to fetch channels', error: e);
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getMessages(
      String channelId) async {
    _debugLog('getMessages', 'Fetching messages for channel',
        params: {'channelId': channelId});
    try {
      final now = DateTime.now();
      final res = await client
          .from('messages')
          .select()
          .eq('channel_id', channelId)
          .or('expires_at.is.null,expires_at.gt.${now.toIso8601String()}')
          .order('created_at', ascending: true);
      final messages = List<Map<String, dynamic>>.from(res);
      _debugLog('getMessages', 'Messages fetched',
          result: '${messages.length} messages');
      return messages;
    } catch (e) {
      _debugLog('getMessages', 'Failed to fetch messages', error: e);
      rethrow;
    }
  }

  static Future<void> sendMessage({
    required String channelId,
    required String content,
    int? expiresInMinutes,
    String? mediaUrl,
    String? mediaType,
  }) async {
    _debugLog('sendMessage', 'Sending message', params: {
      'channelId': channelId,
      'contentLength': content.length,
      'expiresInMinutes': expiresInMinutes,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
    });
    if (userId == null) {
      _debugLog('sendMessage', 'No user ID — skipping');
      return;
    }
    try {
      await client.from('messages').insert({
        'channel_id': channelId,
        'sender_id': userId,
        'content': content,
        'media_url': mediaUrl,
        'media_type': mediaType,
        'expires_at': expiresInMinutes != null
            ? DateTime.now()
                .add(Duration(minutes: expiresInMinutes))
                .toIso8601String()
            : null,
      });
      _debugLog('sendMessage', 'Message sent successfully');
    } catch (e) {
      _debugLog('sendMessage', 'Failed to send message', error: e);
      rethrow;
    }
  }

  static Future<void> burnChannel(String channelId) async {
    _debugLog('burnChannel', 'Burning entire channel',
        params: {'channelId': channelId});
    try {
      await client.from('messages').delete().eq('channel_id', channelId);
      await client.from('channel_members').delete().eq('channel_id', channelId);
      await client.from('channels').delete().eq('id', channelId);
      _debugLog('burnChannel', 'Channel burned successfully');
    } catch (e) {
      _debugLog('burnChannel', 'Failed to burn channel', error: e);
      rethrow;
    }
  }

  static RealtimeChannel subscribeToMessages(
      String channelId, void Function(Map<String, dynamic>) onMessage) {
    _debugLog('subscribeToMessages', 'Opening realtime subscription',
        params: {'channelId': channelId});
    final channel = client
        .channel('messages:$channelId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'channel_id',
            value: channelId,
          ),
          callback: (payload) {
            _debugLog('subscribeToMessages', 'Realtime message received',
                params: {'channelId': channelId});
            onMessage(payload.newRecord);
          },
        )
        .subscribe((status, _) {
      _debugLog('subscribeToMessages', 'Subscription status changed',
          params: {'status': status.name});
    });
    _debugLog('subscribeToMessages', 'Subscription created');
    return channel;
  }

  // ─── Vault ──────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getVaultItems(String type) async {
    _debugLog('getVaultItems', 'Fetching vault items', params: {'type': type});
    if (userId == null) {
      _debugLog('getVaultItems', 'No user ID — returning empty');
      return [];
    }
    try {
      final res = await client
          .from('vault_items')
          .select()
          .eq('user_id', userId!)
          .eq('type', type)
          .order('saved_at', ascending: false);
      final items = List<Map<String, dynamic>>.from(res);
      _debugLog('getVaultItems', 'Vault items fetched',
          result: '${items.length} items');
      return items;
    } catch (e) {
      _debugLog('getVaultItems', 'Failed to fetch vault items', error: e);
      rethrow;
    }
  }

  static Future<void> saveToVault({
    required String mediaUrl,
    required String type,
    required String secretCode,
    String? thumbnailUrl,
  }) async {
    _debugLog('saveToVault', 'Saving item to vault', params: {
      'type': type,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
    });
    if (userId == null) {
      _debugLog('saveToVault', 'No user ID — skipping');
      return;
    }
    try {
      await client.from('vault_items').insert({
        'user_id': userId,
        'media_url': mediaUrl,
        'type': type,
        'secret_code': secretCode,
        'thumbnail_url': thumbnailUrl,
        'saved_at': DateTime.now().toIso8601String(),
      });
      _debugLog('saveToVault', 'Item saved to vault successfully');
    } catch (e) {
      _debugLog('saveToVault', 'Failed to save to vault', error: e);
      rethrow;
    }
  }

  // ─── Stats ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getUserStats() async {
    _debugLog('getUserStats', 'Fetching user stats');
    if (userId == null) {
      _debugLog('getUserStats', 'No user ID — returning default stats');
      return {};
    }
    try {
      final res = await client
          .from('user_stats')
          .select()
          .eq('user_id', userId!)
          .maybeSingle();
      _debugLog('getUserStats', 'User stats fetched', result: res);
      return res ??
          {
            'messages_destroyed': 0,
            'media_expired': 0,
            'identities_rotated': 0,
            'tokens_recycled': 0,
            'data_purity': 98,
            'storage_used_mb': 125.4,
          };
    } catch (e) {
      _debugLog('getUserStats', 'Failed to fetch user stats', error: e);
      rethrow;
    }
  }

  // ─── Invite tokens ──────────────────────────────────────────────────────────

  static Future<String> generateInviteToken() async {
    _debugLog('generateInviteToken', 'Generating invite token');
    final token = _uuid.v4().replaceAll('-', '').substring(0, 12).toUpperCase();
    if (userId == null) {
      _debugLog('generateInviteToken',
          'No user ID — returning token without persistence');
      return token;
    }
    try {
      await client.from('invite_tokens').insert({
        'token': token,
        'created_by': userId,
        'expires_at':
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      });
      _debugLog('generateInviteToken', 'Invite token persisted', result: token);
    } catch (e) {
      _debugLog('generateInviteToken', 'Failed to persist invite token',
          error: e);
      rethrow;
    }
    return token;
  }

  static Future<List<Map<String, dynamic>>> getInviteTokens() async {
    _debugLog('getInviteTokens', 'Fetching active invite tokens');
    if (userId == null) return [];
    try {
      final res = await client
          .from('invite_tokens')
          .select()
          .eq('created_by', userId!)
          .order('expires_at', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      _debugLog('getInviteTokens', 'Failed to fetch invite tokens', error: e);
      rethrow;
    }
  }

  static Future<void> revokeInviteToken(String token) async {
    _debugLog('revokeInviteToken', 'Revoking token', params: {'token': token});
    try {
      await client.from('invite_tokens').delete().eq('token', token);
      _debugLog('revokeInviteToken', 'Token revoked');
    } catch (e) {
      _debugLog('revokeInviteToken', 'Failed to revoke token', error: e);
      rethrow;
    }
  }

  // ─── Emergency wipe ─────────────────────────────────────────────────────────

  static Future<void> emergencyWipe() async {
    _debugLog('emergencyWipe', 'Starting emergency wipe of all user data');
    if (userId == null) {
      _debugLog('emergencyWipe', 'No user ID — skipping');
      return;
    }
    try {
      // Delete all user data from all tables
      await client.from('vault_items').delete().eq('user_id', userId!);
      await client.from('messages').delete().eq('sender_id', userId!);
      await client.from('identities').delete().eq('user_id', userId!);
      await client.from('invite_tokens').delete().eq('created_by', userId!);
      await client.from('channel_members').delete().eq('user_id', userId!);
      await client.from('user_stats').delete().eq('user_id', userId!);
      _debugLog('emergencyWipe', 'All data deleted — signing out session');
      // Sign out AFTER data deletion so userId is still valid during deletes
      await client.auth.signOut();
      _debugLog('emergencyWipe', 'Emergency wipe + sign-out completed');
    } catch (e) {
      _debugLog('emergencyWipe', 'Emergency wipe failed', error: e);
      rethrow;
    }
  }
}
