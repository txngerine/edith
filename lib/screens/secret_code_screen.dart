import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SecretCodeScreen extends StatefulWidget {
  final String mediaUrl;
  final String mediaType;
  final VoidCallback? onUnlocked;

  const SecretCodeScreen({
    super.key,
    required this.mediaUrl,
    required this.mediaType,
    this.onUnlocked,
  });

  @override
  State<SecretCodeScreen> createState() => _SecretCodeScreenState();
}

class _SecretCodeScreenState extends State<SecretCodeScreen> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  String? _error;

  Future<void> _unlock() async {
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    // In real app: verify code against Supabase vault_items.secret_code
    if (_codeController.text.isNotEmpty) {
      widget.onUnlocked?.call();
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() {
        _isVerifying = false;
        _error = 'Invalid code. Try again.';
      });
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Enter Save Code',
              style: TextStyle(
                color: EdithColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ask the sender for the secret code to save this media to your vault.',
              style: TextStyle(
                color: EdithColors.textSecondary,
                fontSize: 12,
                height: 1.6,
                fontFamily: 'SpaceMono',
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _codeController,
              style: const TextStyle(
                color: EdithColors.accent,
                fontSize: 16,
                fontFamily: 'SpaceMono',
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. MOON-78-WOLF',
                filled: true,
                fillColor: EdithColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: EdithColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: EdithColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: EdithColors.accent),
                ),
                hintStyle: const TextStyle(
                  color: EdithColors.textDim,
                  fontFamily: 'SpaceMono',
                  fontSize: 13,
                  letterSpacing: 2,
                ),
                errorText: _error,
                errorStyle: const TextStyle(
                  color: EdithColors.danger,
                  fontFamily: 'SpaceMono',
                  fontSize: 11,
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            EdithButton(
              label: 'Unlock',
              onTap: _unlock,
              isLoading: _isVerifying,
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
