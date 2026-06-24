import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'secret_code_screen.dart';

class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;
  final int expiresInSeconds;
  final bool canSaveToVault;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    this.expiresInSeconds = 2722,
    this.canSaveToVault = true,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.expiresInSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          Navigator.pop(context);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(int s) {
    final h = (s ~/ 3600).toString().padLeft(2, '0');
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$h:$m:$sec';
  }

  double get _progress => _secondsLeft / widget.expiresInSeconds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EdithColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transmission active',
          style: TextStyle(
            color: EdithColors.textPrimary,
            fontSize: 13,
            fontFamily: 'SpaceMono',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: EdithColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Image
          Expanded(
            child: widget.imageUrl.startsWith('http')
                ? Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const _PlaceholderImage(),
                  )
                : const _PlaceholderImage(),
          ),
          // Bottom controls
          Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              children: [
                // Expiry row
                Row(
                  children: [
                    const Text(
                      'Expires in',
                      style: TextStyle(
                        color: EdithColors.textSecondary,
                        fontSize: 11,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _format(_secondsLeft),
                      style: const TextStyle(
                        color: EdithColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                EdithProgressBar(
                  value: _progress,
                  height: 3,
                  color: _progress < 0.2 ? EdithColors.danger : EdithColors.accent,
                ),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: EdithButton(
                        label: 'Save to Vault',
                        icon: Icons.download_outlined,
                        onTap: widget.canSaveToVault
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SecretCodeScreen(
                                      mediaUrl: widget.imageUrl,
                                      mediaType: 'photo',
                                    ),
                                  ),
                                )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: EdithButton(
                        label: 'Close',
                        isOutlined: true,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EdithColors.surface,
      child: const Center(
        child: Icon(Icons.image_outlined, color: EdithColors.textDim, size: 64),
      ),
    );
  }
}
