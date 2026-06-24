import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'secret_code_screen.dart';

class VideoViewerScreen extends StatefulWidget {
  final String videoUrl;
  final int expiresInSeconds;
  final bool canSaveToVault;

  const VideoViewerScreen({
    super.key,
    required this.videoUrl,
    this.expiresInSeconds = 2290,
    this.canSaveToVault = true,
  });

  @override
  State<VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<VideoViewerScreen> {
  VideoPlayerController? _videoController;
  late int _secondsLeft;
  Timer? _expiryTimer;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.expiresInSeconds;
    _initVideo();
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
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

  Future<void> _initVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _videoController!.initialize();
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted) setState(() => _initialized = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _expiryTimer?.cancel();
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
          'Secure Video',
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
          // Video area
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_initialized && _videoController != null)
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                else
                  _buildVideoPlaceholder(),
                // Play/pause overlay
                GestureDetector(
                  onTap: () {
                    if (_videoController == null) return;
                    setState(() {
                      _videoController!.value.isPlaying
                          ? _videoController!.pause()
                          : _videoController!.play();
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: (_videoController?.value.isPlaying ?? false) ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                            border: Border.all(color: EdithColors.textPrimary, width: 1.5),
                          ),
                          child: const Icon(Icons.play_arrow,
                              color: EdithColors.textPrimary, size: 30),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom controls
          Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              children: [
                // Video progress bar (if initialized)
                if (_initialized && _videoController != null)
                  ValueListenableBuilder(
                    valueListenable: _videoController!,
                    builder: (_, value, __) {
                      final pos = value.position.inMilliseconds.toDouble();
                      final dur = value.duration.inMilliseconds.toDouble();
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: EdithColors.accent,
                              inactiveTrackColor: EdithColors.border,
                              thumbColor: EdithColors.accent,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              trackHeight: 2,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: dur > 0 ? pos / dur : 0,
                              onChanged: (v) {
                                _videoController!.seekTo(
                                  Duration(milliseconds: (v * dur).toInt()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      );
                    },
                  ),
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
                EdithProgressBar(
                  value: _progress,
                  height: 3,
                  color: _progress < 0.2 ? EdithColors.danger : EdithColors.accent,
                ),
                const SizedBox(height: 16),
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
                                      mediaUrl: widget.videoUrl,
                                      mediaType: 'video',
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

  Widget _buildVideoPlaceholder() {
    return Container(
      color: EdithColors.surface,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_outlined, color: EdithColors.textDim, size: 64),
            SizedBox(height: 12),
            Text(
              'Loading secure video...',
              style: TextStyle(
                color: EdithColors.textDim,
                fontSize: 11,
                fontFamily: 'SpaceMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
