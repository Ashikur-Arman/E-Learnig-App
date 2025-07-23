import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerPage_chemistry extends StatefulWidget {
  final List<dynamic> playlist;
  final int initialIndex;

  const VideoPlayerPage_chemistry({
    Key? key,
    required this.playlist,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<VideoPlayerPage_chemistry> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage_chemistry> {
  late YoutubePlayerController _youtubeController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _initPlayer(widget.playlist[currentIndex]);
  }

  void _initPlayer(dynamic video) {
    String videoId = video["snippet"]["resourceId"]["videoId"];
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(autoPlay: true),
    );
  }

  void _playVideo(int index) {
    setState(() {
      currentIndex = index;
      String videoId = widget.playlist[index]["snippet"]["resourceId"]["videoId"];
      _youtubeController.load(videoId);
    });
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentVideo = widget.playlist[currentIndex]["snippet"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDD0), // Cream Color
        title: Text(
          currentVideo["title"],
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2EBF2), // Light Cyan
              Color(0xFF4DD0E1), // Teal-ish
              Color(0xFF00838F), // Darker blue-teal
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            YoutubePlayer(
              controller: _youtubeController,
              showVideoProgressIndicator: true,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
              onEnded: (meta) {
                // ভিডিও শেষ হলে পরের ভিডিও প্লে করতে চাইলে নিচের কোড আনকমেন্ট করো
                // int nextIndex = (currentIndex + 1) % widget.playlist.length;
                // _playVideo(nextIndex);
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.playlist.length,
                itemBuilder: (context, index) {
                  var video = widget.playlist[index]["snippet"];
                  bool isSelected = index == currentIndex;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Colors.white.withOpacity(0.3),
                    leading: Image.network(video["thumbnails"]["default"]["url"]),
                    title: Text(video["title"], style: const TextStyle(color: Colors.white)),
                    subtitle: Text(video["channelTitle"], style: TextStyle(color: Colors.grey[200])),
                    onTap: () => _playVideo(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
