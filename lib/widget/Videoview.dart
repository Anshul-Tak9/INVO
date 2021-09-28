import 'package:flutter/material.dart';
import 'package:cached_video_player/cached_video_player.dart';

class VideoView extends StatefulWidget {
  @override
  String s;
  VideoView(String h) {
    s = h;
  }
  _VideoViewState createState() => _VideoViewState(s);
}

class _VideoViewState extends State<VideoView> {
  @override
  String s;
  CachedVideoPlayerController _controller;
  _VideoViewState(String h) {
    s = h;
  }
  void initState() {
    _controller = CachedVideoPlayerController.network(s);
    _controller.initialize().then((value) {
      setState(() {
        _controller.play();
        _controller.setLooping(true);
      });
    });
  }

  Widget build(BuildContext context) {
    return _controller.value != null && _controller.value.initialized
        ? AspectRatio(
            child: CachedVideoPlayer(_controller),
            aspectRatio: _controller.value.aspectRatio)
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
