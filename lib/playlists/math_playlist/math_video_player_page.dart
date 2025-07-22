import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerPage_math extends StatefulWidget {
  final List<dynamic> playlist;
  final int initialIndex;

  const VideoPlayerPage_math({
    Key? key,
    required this.playlist,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<VideoPlayerPage_math> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage_math> {
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
        title: Text(currentVideo["title"]),
      ),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _youtubeController,
            showVideoProgressIndicator: true,
            progressColors: ProgressBarColors(
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
                  selectedTileColor: Colors.grey.shade300,
                  leading: Image.network(video["thumbnails"]["default"]["url"]),
                  title: Text(video["title"]),
                  subtitle: Text(video["channelTitle"]),
                  onTap: () => _playVideo(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
