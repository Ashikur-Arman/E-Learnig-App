import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chemistry_youtube_controller.dart';
import 'chemistry_video_player_page.dart';

class YouTubePlaylistPage_chemistry extends StatelessWidget {
  final YouTubeController_chemistry controller = Get.put(YouTubeController_chemistry());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDD0), // Cream Color
        title: const Text(
          "Chemistry Videos",
          style: TextStyle(color: Colors.black),
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
        child: Obx(() {
          if (controller.videoList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: controller.videoList.length,
            itemBuilder: (context, index) {
              var video = controller.videoList[index]["snippet"];
              String videoId = video["resourceId"]["videoId"];

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage_chemistry(
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black, // কালো টেক্সট
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                video["channelTitle"],
                                style: const TextStyle(
                                  color: Colors.black, // কালো টেক্সট
                                  fontSize: 13,
                                ),
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
      ),
    );
  }
}
