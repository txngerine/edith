import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/supabase_service.dart';

class InviteTokensScreen extends StatefulWidget {
  const InviteTokensScreen({super.key});

  @override
  State<InviteTokensScreen> createState() => _InviteTokensScreenState();
}

class _InviteTokensScreenState extends State<InviteTokensScreen> {
  List<Map<String, dynamic>> _tokens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    setState(() => _isLoading = true);
    try {
      final tokens = await SupabaseService.getInviteTokens();
      if (mounted) {
        setState(() {
          _tokens = tokens;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _revokeToken(String token) async {
    try {
      await SupabaseService.revokeInviteToken(token);
      _loadTokens(); // reload list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to revoke token'),
          backgroundColor: EdithColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EdithScaffold(
      title: 'Active Tokens',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: EdithColors.accent))
          : _tokens.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.token_outlined, color: EdithColors.textDim, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'NO ACTIVE TOKENS',
                        style: TextStyle(
                          color: EdithColors.textSecondary,
                          fontSize: 14,
                          letterSpacing: 2,
                          fontFamily: 'SpaceMono',
                        ),
                      ).animate().fadeIn(),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tokens.length,
                  itemBuilder: (ctx, i) {
                    final t = _tokens[i];
                    final expiresStr = t['expires_at'] != null 
                        ? DateTime.parse(t['expires_at']).toLocal().toString().split('.')[0]
                        : 'Unknown';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: EdithColors.card,
                        border: Border.all(color: EdithColors.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['token'] ?? '',
                                  style: const TextStyle(
                                    color: EdithColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontFamily: 'SpaceMono',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Expires: $expiresStr',
                                  style: const TextStyle(
                                    color: EdithColors.textSecondary,
                                    fontSize: 11,
                                    fontFamily: 'SpaceMono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: EdithColors.danger),
                            onPressed: () => _revokeToken(t['token']),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * i));
                  },
                ),
    );
  }
}
