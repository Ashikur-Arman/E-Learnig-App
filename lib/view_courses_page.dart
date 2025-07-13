import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

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

    DocumentSnapshot userDoc =
    await _firestore.collection('users').doc(user.uid).get();

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
      DocumentSnapshot userDoc =
      await _firestore.collection("users").doc(user.uid).get();
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
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(courseName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: Text(description.isNotEmpty
              ? description
              : "No description available."),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(courseName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description.isNotEmpty
                ? description
                : "No description available."),
            SizedBox(height: 20),
            if (!hasQuiz)
              Text("⚠️ No Quiz available for this course",
                  style: TextStyle(color: Colors.orange, fontSize: 16))
            else if (hasGivenQuiz)
              Text("You have already given the Quiz.\nScore: $score/$total",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16))
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  child: Text("Give Quiz"),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDD0).withOpacity(.6),
          title: Text("Available Courses"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('courses')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final courses = snapshot.data!.docs;

          if (courses.isEmpty) {
            return Center(child: Text("No courses available"));
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final data = course.data()! as Map<String, dynamic>;
              final isEnrolled = enrolledCourseIds.contains(course.id);

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['courseName'] ?? 'No Name'),
                  subtitle: Text(
                      "Starts: ${data['startDate']} | Ends: ${data['endDate']}"),
                  trailing: ElevatedButton(
                    onPressed: isEnrolled
                        ? null
                        : () => enrollInCourse(
                        course.id, data['courseName'] ?? ''),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isEnrolled ? Colors.green : Colors.cyan,
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
    );
  }
}

// =================== TakeQuizPage ==================

class TakeQuizPage extends StatefulWidget {
  final String courseId;
  final String courseName;
  final List<Map<String, dynamic>> quizQuestions;

  const TakeQuizPage({
    required this.courseId,
    required this.courseName,
    required this.quizQuestions,
  });

  @override
  _TakeQuizPageState createState() => _TakeQuizPageState();
}

class _TakeQuizPageState extends State<TakeQuizPage> {
  int currentIndex = 0;
  Map<int, int> selectedAnswers = {}; // questionIndex -> selectedOptionIndex
  bool isSubmitted = false;
  int score = 0;

  void nextQuestion() {
    if (currentIndex < widget.quizQuestions.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void prevQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void submitQuiz() async {
    int tempScore = 0;
    for (int i = 0; i < widget.quizQuestions.length; i++) {
      final question = widget.quizQuestions[i];
      final correctIndex = question['correctAnswerIndex'] ?? 0;

      if (selectedAnswers[i] == correctIndex) {
        tempScore++;
      }
    }

    setState(() {
      isSubmitted = true;
      score = tempScore;
    });

    // Firebase এ রেজাল্ট আপলোড
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('results')
          .doc(user.uid)
          .set({
        'score': score,
        'total': widget.quizQuestions.length,
        'userId': user.uid,
        'submittedAt': FieldValue.serverTimestamp(),
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Quiz Completed!"),
        content: Text("You scored $score out of ${widget.quizQuestions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to course list
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quizQuestions[currentIndex];
    final options = List<String>.from(question['options'] ?? []);
    final questionText = question['question'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text("Quiz for ${widget.courseName}")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: isSubmitted
            ? Center(
          child: Text(
            "You scored $score out of ${widget.quizQuestions.length}",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${currentIndex + 1} of ${widget.quizQuestions.length}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              questionText,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),

            ...List.generate(options.length, (i) {
              return RadioListTile<int>(
                value: i,
                groupValue: selectedAnswers[currentIndex],
                title: Text(options[i]),
                onChanged: (val) {
                  if (!isSubmitted) {
                    setState(() {
                      selectedAnswers[currentIndex] = val!;
                    });
                  }
                },
              );
            }),

            Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentIndex == 0 ? null : prevQuestion,
                  child: Text("Previous"),
                ),
                currentIndex == widget.quizQuestions.length - 1
                    ? ElevatedButton(
                  onPressed:
                  selectedAnswers.length == widget.quizQuestions.length
                      ? submitQuiz
                      : null,
                  child: Text("Submit"),
                )
                    : ElevatedButton(
                  onPressed: selectedAnswers.containsKey(currentIndex)
                      ? nextQuestion
                      : null,
                  child: Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
