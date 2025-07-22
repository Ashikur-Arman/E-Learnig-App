import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';


class YouTubeControllerforBiology extends GetxController {
  var videoList = [].obs;

  final String playlistId = "PLh2EsjwYJx7u1-WTlv9BPn7iXC9J3uQ8i";
  final String apiKey = "AIzaSyDoLgDLKhwfyLKbuh8pcHFS-N3QR8_iPlg";

  @override
  void onInit() {
    fetchPlaylistVideos();
    super.onInit();
  }

  void fetchPlaylistVideos() async {
    String url =
        "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=$playlistId&maxResults=20&key=$apiKey";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        videoList.value = data["items"];
      } else {
        print("Failed to load videos, status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching videos: $e");
    }
  }
}

