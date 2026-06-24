import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class MediaSendScreen extends StatefulWidget {
  final String channelId;

  const MediaSendScreen({super.key, required this.channelId});

  @override
  State<MediaSendScreen> createState() => _MediaSendScreenState();
}

class _MediaSendScreenState extends State<MediaSendScreen> {
  File? _selectedImage;
  bool _viewOnce = true;
  bool _secretCodeRequired = true;
  bool _allowVaultSave = true;
  Duration _expiresIn = const Duration(hours: 1);
  bool _isSending = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _send() async {
    setState(() => _isSending = true);
    try {
      // Upload image to Supabase Storage, then send message
      // For demo, just close
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image transmitted securely'),
            backgroundColor: EdithColors.accentDim,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
    }
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours.toString().padLeft(2, '0')}:00:00';
    return '00:${d.inMinutes.toString().padLeft(2, '0')}:00';
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
        title: const Text(
          'SEND IMAGE',
          style: TextStyle(
            color: EdithColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            fontFamily: 'SpaceMono',
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: EdithColors.border),
        ),
      ),
      body: Column(
        children: [
          // Image preview
          if (_selectedImage != null)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                color: EdithColors.surface,
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            )
          else
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                color: EdithColors.surface,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          color: EdithColors.textDim, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'Tap to select image',
                        style: TextStyle(
                            color: EdithColors.textDim,
                            fontSize: 12,
                            fontFamily: 'SpaceMono'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Expiry bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: EdithColors.border)),
            ),
            child: Row(
              children: [
                Text(
                  'Expires in',
                  style: const TextStyle(
                    color: EdithColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'SpaceMono',
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDuration(_expiresIn),
                  style: const TextStyle(
                    color: EdithColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SpaceMono',
                  ),
                ),
                const Spacer(),
                const Icon(Icons.lock_outline, color: EdithColors.accent, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Protected',
                  style: TextStyle(
                      color: EdithColors.accent, fontSize: 11, fontFamily: 'SpaceMono'),
                ),
              ],
            ),
          ),
          // Duration slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('1h',
                    style: TextStyle(
                        color: EdithColors.textDim, fontSize: 10, fontFamily: 'SpaceMono')),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: EdithColors.accent,
                      inactiveTrackColor: EdithColors.border,
                      thumbColor: EdithColors.accent,
                      overlayColor: EdithColors.accentDim.withValues(alpha: 0.2),
                      trackHeight: 2,
                    ),
                    child: Slider(
                      value: _expiresIn.inMinutes.toDouble(),
                      min: 60,
                      max: 1440,
                      onChanged: (v) =>
                          setState(() => _expiresIn = Duration(minutes: v.toInt())),
                    ),
                  ),
                ),
                const Text('24h',
                    style: TextStyle(
                        color: EdithColors.textDim, fontSize: 10, fontFamily: 'SpaceMono')),
              ],
            ),
          ),
          // Options
          ToggleRow(
            icon: Icons.visibility_outlined,
            title: 'View once',
            subtitle: 'Self-destructs after viewing',
            value: _viewOnce,
            onChanged: (v) => setState(() => _viewOnce = v),
          ),
          ToggleRow(
            icon: Icons.vpn_key_outlined,
            title: 'Secret code required',
            subtitle: 'Recipient needs code to save',
            value: _secretCodeRequired,
            onChanged: (v) => setState(() => _secretCodeRequired = v),
          ),
          ToggleRow(
            icon: Icons.save_outlined,
            title: 'Allow vault save',
            subtitle: 'Recipient can save with code',
            value: _allowVaultSave,
            onChanged: (v) => setState(() => _allowVaultSave = v),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: EdithButton(
                    label: 'Send',
                    onTap: _send,
                    isLoading: _isSending,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EdithButton(
                    label: 'Cancel',
                    isOutlined: true,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
