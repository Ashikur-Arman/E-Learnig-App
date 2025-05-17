import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class YouTubeController extends GetxController {
  var videoList = [].obs;
  final String playlistId = "PLVLoWQFkZbhVZkRbl1jBvgRr1VAnOeQ01";
  final String apiKey = "AIzaSyDHWGaJfs4iGAiq2TFYCuocnvmAslu2O94";  // এখানে আপনার API Key দিন

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
      }
    } catch (e) {
      print("Error fetching videos: $e");
    }
  }
}
