import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_noman_android_studio/quiz/take_quiz_page.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ViewCoursesPage extends StatefulWidget {
  @override
  State<ViewCoursesPage> createState() => _ViewCoursesPageState();
}

class _ViewCoursesPageState extends State<ViewCoursesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage box = GetStorage();

  Set<String> enrolledCourseIds = {};
  String? cacheKey;
  List<QueryDocumentSnapshot> filteredCourses = [];

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      cacheKey = 'enrolledCourses_${user.uid}';
      List<dynamic>? cachedCourses = box.read(cacheKey!);
      if (cachedCourses != null) {
        enrolledCourseIds = cachedCourses.cast<String>().toSet();
      }
    }
    _loadEnrolledCourses();
  }

  Future<void> _loadEnrolledCourses() async {
    final user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      List<dynamic>? enrolledCourses = userDoc.get('enrolledCourses');
      if (enrolledCourses != null) {
        setState(() {
          enrolledCourseIds = enrolledCourses.cast<String>().toSet();
        });
        box.write('enrolledCourses_${user.uid}', enrolledCourseIds.toList());
      }
    }
  }

  Future<void> enrollInCourse(String courseId, String courseName) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ Please login first to enroll'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (enrolledCourseIds.contains(courseId)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✅ Already enrolled in $courseName'),
        backgroundColor: Colors.green,
      ));
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();
      String userName = userDoc.get('name') ?? 'Anonymous';
      String userEmail = userDoc.get('email') ?? 'No Email';

      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('enrolledUsers')
          .doc(user.uid)
          .set({
        'userName': userName,
        'email': userEmail,
        'userId': user.uid,
        'enrolledAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(user.uid).set({
        'enrolledCourses': FieldValue.arrayUnion([courseId])
      }, SetOptions(merge: true));

      setState(() {
        enrolledCourseIds.add(courseId);
      });

      box.write('enrolledCourses_${user.uid}', enrolledCourseIds.toList());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✅ Enrolled in $courseName'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ Failed: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void showCourseDescriptionDialog(BuildContext context, String courseId,
      String courseName, String description, bool isEnrolled) async {
    final user = _auth.currentUser;
    if (!isEnrolled) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(courseName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: Text(description.isNotEmpty ? description : "No description available."),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.grey.shade200,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Close", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final quizSnapshot = await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('quizzes')
        .get();

    bool hasQuiz = quizSnapshot.docs.isNotEmpty;

    DocumentSnapshot result = await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('results')
        .doc(user!.uid)
        .get();

    bool hasGivenQuiz = result.exists;
    int score = 0;
    int total = 0;
    if (hasGivenQuiz) {
      score = result['score'];
      total = result['total'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(courseName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description.isNotEmpty ? description : "No description available."),
            SizedBox(height: 20),
            if (!hasQuiz)
              Text("⚠️ No Quiz available for this course",
                  style: TextStyle(color: Colors.orange, fontSize: 16))
            else if (hasGivenQuiz)
              Text("You have already given the Quiz.\nScore: $score/$total",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TakeQuizPage(
                          courseId: courseId,
                          courseName: courseName,
                          quizQuestions: quizSnapshot.docs
                              .map((doc) => doc.data() as Map<String, dynamic>)
                              .toList(),
                        ),
                      ),
                    );
                  },
                  child: Text("Start Quiz"),
                ),
              )
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.grey.shade200,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(List<QueryDocumentSnapshot> allCourses) {
    String selectedOption = 'Course Name';
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Search Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedOption,
                isExpanded: true,
                items: ['Course Name', 'Start Date'].map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  setModalState(() {
                    selectedOption = value!;
                    searchController.clear();
                  });
                },
              ),
              SizedBox(height: 10),
              if (selectedOption == 'Course Name')
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(labelText: 'Enter course name'),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      String formatted = DateFormat('yyyy-MM-dd').format(picked);
                      setModalState(() {
                        searchController.text = formatted;
                      });
                    }
                  },
                  child: Text(searchController.text.isEmpty
                      ? "Pick Start Date"
                      : searchController.text),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String query = searchController.text.trim().toLowerCase();

                List<QueryDocumentSnapshot> results = allCourses.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  if (selectedOption == 'Course Name') {
                    String name = (data['courseName'] ?? '').toString().toLowerCase();
                    return name.contains(query);
                  } else {
                    dynamic startDate = data['startDate'];
                    String formattedStartDate = '';

                    if (startDate is Timestamp) {
                      formattedStartDate =
                          DateFormat('yyyy-MM-dd').format(startDate.toDate());
                    } else if (startDate is String) {
                      formattedStartDate = startDate.trim();
                    }

                    return formattedStartDate == query;
                  }
                }).toList();

                Navigator.pop(context);

                if (results.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Course not found'),
                    backgroundColor: Colors.red,
                  ));
                } else {
                  setState(() {
                    filteredCourses = results;
                  });
                }
              },
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDD0).withOpacity(.6),
        title: Text("Available Courses"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final snapshot = await _firestore
                  .collection('courses')
                  .orderBy('timestamp', descending: true)
                  .get();
              _showSearchDialog(snapshot.docs);
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2EBF2),
              Color(0xFF4DD0E1),
              Color(0xFF00838F),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('courses')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            final allCourses = snapshot.data!.docs;
            final coursesToDisplay =
            filteredCourses.isNotEmpty ? filteredCourses : allCourses;

            if (coursesToDisplay.isEmpty) {
              return Center(child: Text("No courses available"));
            }

            return ListView.builder(
              itemCount: coursesToDisplay.length,
              itemBuilder: (context, index) {
                final course = coursesToDisplay[index];
                final data = course.data()! as Map<String, dynamic>;
                final isEnrolled = enrolledCourseIds.contains(course.id);

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      data['courseName'] ?? 'No Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Chapter: ${data['chapterNumber'] ?? 'N/A'} | Starts: ${data['startDate']} | Ends: ${data['endDate']}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Level: ${data['difficultyLevel'] ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: isEnrolled
                          ? null
                          : () => enrollInCourse(course.id, data['courseName'] ?? ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEnrolled ? Colors.green : Colors.cyan,
                      ),
                      child: Text(isEnrolled ? "Enrolled" : "Enroll"),
                    ),
                    onTap: () {
                      showCourseDescriptionDialog(
                        context,
                        course.id,
                        data['courseName'] ?? 'No Name',
                        data['description'] ?? '',
                        isEnrolled,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
