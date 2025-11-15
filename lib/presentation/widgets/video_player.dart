import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DemoVideoPlayer extends StatefulWidget {
  final String videoAsset;
  const DemoVideoPlayer({super.key, required this.videoAsset});

  @override
  State<DemoVideoPlayer> createState() => _DemoVideoPlayerState();
}

class _DemoVideoPlayerState extends State<DemoVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initVideo(widget.videoAsset);
  }

  // ⭐ When parent updates videoAsset, reload the video
  @override
  void didUpdateWidget(covariant DemoVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoAsset != widget.videoAsset) {
      _initVideo(widget.videoAsset);
    }
  }

  void _initVideo(String asset) {
    _controller = VideoPlayerController.asset(asset)
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
          onTap: () {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          },
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 600,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            ),
          ),
        )
        : const Center(child: CircularProgressIndicator());
  }
}
