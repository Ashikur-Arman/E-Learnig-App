import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_with_noman_android_studio/Home_Page/drawerHome.dart';
import '../playlists/biology_playlist/biology_youtube_playlist_page.dart';
import '../playlists/chemistry_playlist/chemistry_youtube_playlist_page.dart';
import '../playlists/math_playlist/math_youtube_playlist_page.dart';
import '../playlists/physics_playlist/physics_playlist_page.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<String> imagePaths = [
    'assets/images/study_image.jpg',
    'assets/images/slider.png',
    'assets/images/img.png',
    'assets/images/img_1.png',
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDD0).withOpacity(.6),
        title: Text("Home"),
      ),
      drawer: DrawerHome(),
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          decoration: BoxDecoration(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slider Section
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: .98,
                    aspectRatio: 16 / 9,
                    autoPlayInterval: Duration(seconds: 3),
                  ),
                  items: imagePaths.map((imagePath) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Video Classes",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(.7)),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  subjectBox(
                    title: "Physics",
                    classCount: "72 classes",
                    imagePath: 'assets/images/physics.webp',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => YouTubePlaylistPage_physics()),
                    ),
                  ),
                  subjectBox(
                    title: "Math",
                    classCount: "36 classes",
                    imagePath: 'assets/images/math.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => YouTubePlaylistPage_math()),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  subjectBox(
                    title: "Chemistry",
                    classCount: "11 classes",
                    imagePath: 'assets/images/chemistry_bg.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => YouTubePlaylistPage_chemistry()),
                    ),
                  ),
                  subjectBox(
                    title: "Biology",
                    classCount: "8 classes",
                    imagePath: 'assets/images/biology_bg.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => YouTubePlaylistPage_biology()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Discover the Power of E-Learning",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.6), // <-- কালো রঙ
                      ),
                    ),
                    SizedBox(height: 10),

                    ...[
                      "Access education anytime, from anywhere in the world.",
                      "Learn at your own pace with flexible schedules.",
                      "Save time and travel costs with online learning.",
                      "Access diverse courses and expert instructors worldwide.",
                      "Develop self-discipline and digital skills for the future.",
                    ].map(
                          (message) => Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message,
                          style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)), // <-- কালো রঙ
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget subjectBox({
    required String title,
    required String classCount,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 180,
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.7), // এখানে কালো রঙ
              ),
            ),
            Text(
              classCount,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.7), // এখানে কালো রঙ
              ),
            ),
          ],
        ),
      ),
    );
  }
}
