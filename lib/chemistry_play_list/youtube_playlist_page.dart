import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'youtube_controller.dart';

class YouTubePlaylistPage extends StatelessWidget {
  final YouTubeController controller = Get.put(YouTubeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("YouTube Playlist")),
      body: Obx(() {
        if (controller.videoList.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.videoList.length,
          itemBuilder: (context, index) {
            var video = controller.videoList[index]["snippet"];
            String videoId = video["resourceId"]["videoId"];
            return Card(
              child: Column(
                children: [
                  YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: videoId,
                      flags: YoutubePlayerFlags(autoPlay: false),
                    ),
                    showVideoProgressIndicator: true,
                  ),
                  ListTile(
                    title: Text(video["title"]),
                    subtitle: Text(video["channelTitle"]),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
