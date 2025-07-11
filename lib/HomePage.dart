import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Authentication_part/login_screen.dart';
import 'Books.dart';
import 'EnrollPage.dart';
import 'AboutPage.dart';
import 'ProgressPage.dart';
import 'chemistry_play_list/youtube_playlist_page.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userName = doc['name'] ?? 'User';
        userEmail = doc['email'] ?? 'admin@example.com';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text("Home"),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.of(context).size;
            final double height = size.height;
            final double width = size.width;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 40, left: 5, right: 5, bottom: 10),
                  height: height * 0.25,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.grey,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.015),
                      CircleAvatar(
                        radius: width * 0.08,
                        backgroundColor: Colors.white.withOpacity(.5),
                        // backgroundImage: AssetImage('assets/images/Arman_round.png'),
                      ),
                      SizedBox(height: height * 0.015),
                      Text(
                        "Welcome $userName",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.04,
                        ),
                      ),
                      SizedBox(height: height * 0.04),
                      // Center(
                      //   child: Text(
                      //     "$userEmail",
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: width * 0.05,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.home, size: width * 0.06),
                        title: Text("Home", style: TextStyle(fontSize: width * 0.045)),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: width * 0.04,
                          color: Colors.grey[400],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.settings, size: width * 0.06),
                        title: Text("Settings", style: TextStyle(fontSize: width * 0.045)),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: width * 0.04,
                          color: Colors.grey[400],
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.info, size: width * 0.06),
                        title: Text("About", style: TextStyle(fontSize: width * 0.045)),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: width * 0.04,
                          color: Colors.grey[400],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Aboutpage()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete, color: Colors.red, size: width * 0.06),
                        title: Text("Delete", style: TextStyle(fontSize: width * 0.045)),
                        subtitle: Text(
                          "(If deleted then can't recover)",
                          style: TextStyle(fontSize: width * 0.035),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: width * 0.04,
                          color: Colors.grey[400],
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red, size: width * 0.06),
                        title: Text(
                          "Log Out",
                          style: TextStyle(color: Colors.red, fontSize: width * 0.045),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: width * 0.04,
                          color: Colors.grey[400],
                        ),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                                (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFA8D8),
                Color(0xFF7D4DA1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                height: 200,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/images/study_image.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("60% Discount", style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold, letterSpacing: 2.0,),),
                    Text('January 17 to February 09', style: TextStyle(fontSize: 15,color: Colors.white),),
                    TextButton(
                      onPressed: () {
                        // Navigate to EnrollPage when the button is pressed
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EnrollPage()),
                        );
                      },
                      child: Text("Enroll Now"),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(.6)),
                        shadowColor: MaterialStateProperty.all(Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text("Courses", style: TextStyle(fontSize: 20,color: Colors.white),),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProgressPage()),
                      );
                    },
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
                            'assets/images/physics.webp',
                            height: 120,
                            width: 120,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            'Physic',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '7 classes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProgressPage()),
                      );
                    },
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
                            'assets/images/math.png',
                            height: 120,
                            width: 120,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            'Math',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '17 classes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => YouTubePlaylistPage()),
                      );
                    },
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
                            'assets/images/chemistry_bg.png',
                            height: 120,
                            width: 120,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            'Chemistry',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '21 classes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProgressPage()),
                      );
                    },
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
                            'assets/images/biology_bg.png',
                            height: 120,
                            width: 120,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            'Biology',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '15 classes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.all(10),
                child: Text("Test Schedule", style: TextStyle(fontSize: 20,color: Colors.white),),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 10,),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProgressPage()),
                        );
                      },
                      child: Container(
                        height: 110,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      height: 110,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      height: 110,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                SizedBox(width: 10,),
                Container(
                  height: 110,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    ),
                   ),
                    SizedBox(width: 10,),
                    Container(
                      height: 110,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text("Thank You!!!", style: TextStyle(fontSize: 20,color: Colors.brown),)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
