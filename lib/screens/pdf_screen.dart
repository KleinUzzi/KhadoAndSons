import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:KhadoAndSons/utils/resources/size.dart';
import 'package:KhadoAndSons/utils/widgets.dart';
import 'package:video_player/video_player.dart';

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  String title = "";
  PDFScreen(this.pathPDF, this.title);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: headingText(context, title),
          iconTheme: Theme.of(context).iconTheme,
          centerTitle: true,
          elevation: spacing_control,
        ),
        path: pathPDF);
  }
}

class VideoApp extends StatefulWidget {
  String filePath;
  VideoApp(this.filePath);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath));
    _controller.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.initialized
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
