import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class YouTubeController_chemistry extends GetxController {
  var videoList = <dynamic>[].obs;
  final String playlistId = "PL_tDXnRj0WZUmDHPj2DbI4656RbWuqq4A";  // তোমার Chemistry Playlist ID
  final String apiKey = dotenv.env['GOOGLE_API_KEY']!;
  String? nextPageToken;

  @override
  void onInit() {
    fetchPlaylistVideos();
    super.onInit();
  }

  void fetchPlaylistVideos() async {
    String url =
        "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=$playlistId&maxResults=50&key=$apiKey";

    if (nextPageToken != null) {
      url += "&pageToken=$nextPageToken";
    }

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        nextPageToken = data["nextPageToken"];
        videoList.addAll(data["items"]);
      } else {
        print("Failed to load videos, status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching videos: $e");
    }
  }
}
