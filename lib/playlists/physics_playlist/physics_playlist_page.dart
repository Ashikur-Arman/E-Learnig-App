import 'package:flutter/material.dart';
import 'package:flutter_with_noman_android_studio/playlists/physics_playlist/physics_youtube_controller.dart';
import 'package:get/get.dart';

import 'physics_video_player_page.dart';

class YouTubePlaylistPage_physics extends StatefulWidget {
  @override
  _YouTubePlaylistPage_physicsState createState() => _YouTubePlaylistPage_physicsState();
}

class _YouTubePlaylistPage_physicsState extends State<YouTubePlaylistPage_physics> {
  final YouTubeController_physics controller = Get.put(YouTubeController_physics());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        if (controller.nextPageToken != null) {
          controller.fetchPlaylistVideos();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Physics Videos")),
      body: Obx(() {
        if (controller.videoList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(10),
          itemCount: controller.videoList.length,
          itemBuilder: (context, index) {
            var video = controller.videoList[index]["snippet"];
            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerPage_physics(
                        playlist: controller.videoList,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          video["thumbnails"]["medium"]["url"],
                          height: 80,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video["title"],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              video["channelTitle"],
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
