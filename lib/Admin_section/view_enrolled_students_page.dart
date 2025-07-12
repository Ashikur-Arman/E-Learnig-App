import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EnrolledStudentsPage extends StatelessWidget {
  const EnrolledStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enrolled Students"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('courses').get(),
        builder: (context, courseSnapshot) {
          if (courseSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final courses = courseSnapshot.data?.docs ?? [];

          if (courses.isEmpty) {
            return Center(child: Text("No courses found"));
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadAllEnrollments(courses),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final allEnrollments = snapshot.data ?? [];

              if (allEnrollments.every((course) => course['students'].isEmpty)) {
                return Center(
                  child: Text(
                    "Sorry, no enrolled students found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: allEnrollments.length,
                itemBuilder: (context, index) {
                  final course = allEnrollments[index];
                  final courseName = course['courseName'];
                  final courseId = course['courseId'];
                  final students = course['students'];

                  return ExpansionTile(
                    title: Text(courseName, style: TextStyle(fontWeight: FontWeight.bold)),
                    children: students.isEmpty
                        ? [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("No students enrolled in this course."),
                      )
                    ]
                        : [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showMCQDialog(context, courseId, courseName);
                          },
                          child: Text("➕ Add Quiz for $courseName"),
                        ),
                      ),
                      ...students.map<Widget>((student) {
                        final score = student['score'];
                        final total = student['total'];
                        return ListTile(
                          leading: Icon(Icons.person),
                          title: Text(student['userName'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(student['email'] ?? ''),
                              if (score != null && total != null)
                                Text("✅ Score: $score / $total", style: TextStyle(color: Colors.green)),
                              if (score == null)
                                Text("⚠️ Quiz not attempted", style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadAllEnrollments(List<QueryDocumentSnapshot> courses) async {
    List<Map<String, dynamic>> result = [];

    for (var course in courses) {
      final courseId = course.id;
      final courseName = course['courseName'] ?? 'Unnamed Course';

      final enrolledSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('enrolledUsers')
          .get();

      final students = await Future.wait(enrolledSnapshot.docs.map((doc) async {
        final studentData = doc.data();
        final userId = studentData['userId'];

        final resultDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('results')
            .doc(userId)
            .get();

        if (resultDoc.exists) {
          final resultData = resultDoc.data()!;
          studentData['score'] = resultData['score'];
          studentData['total'] = resultData['total'];
        } else {
          studentData['score'] = null;
          studentData['total'] = null;
        }

        return studentData;
      }));

      result.add({
        'courseId': courseId,
        'courseName': courseName,
        'students': students,
      });
    }

    return result;
  }

  void showMCQDialog(BuildContext context, String courseId, String courseName) {
    int questionCount = 2;

    final List<Map<String, TextEditingController>> questionControllers = [];

    void initializeControllers(int count) {
      questionControllers.clear();
      for (int i = 0; i < count; i++) {
        questionControllers.add({
          'question': TextEditingController(),
          'option1': TextEditingController(),
          'option2': TextEditingController(),
          'option3': TextEditingController(),
          'option4': TextEditingController(),
          'correctAnswer': TextEditingController(),
        });
      }
    }

    initializeControllers(questionCount);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            return Dialog(
              insetPadding: EdgeInsets.zero,
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.95,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add MCQ for $courseName", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            DropdownButton<int>(
                              value: questionCount,
                              items: [2, 5, 10].map((count) {
                                return DropdownMenuItem(
                                  value: count,
                                  child: Text("Add $count Questions"),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    questionCount = value;
                                    initializeControllers(questionCount);
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            ...List.generate(questionCount, (index) {
                              final controllers = questionControllers[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(),
                                  Text("Question ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextField(controller: controllers['question'], decoration: InputDecoration(labelText: "Question")),
                                  TextField(controller: controllers['option1'], decoration: InputDecoration(labelText: "Option 1")),
                                  TextField(controller: controllers['option2'], decoration: InputDecoration(labelText: "Option 2")),
                                  TextField(controller: controllers['option3'], decoration: InputDecoration(labelText: "Option 3")),
                                  TextField(controller: controllers['option4'], decoration: InputDecoration(labelText: "Option 4")),
                                  TextField(controller: controllers['correctAnswer'], decoration: InputDecoration(labelText: "Correct Answer")),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            for (var q in questionControllers) {
                              await FirebaseFirestore.instance
                                  .collection('courses')
                                  .doc(courseId)
                                  .collection('quizzes')
                                  .add({
                                'question': q['question']!.text,
                                'options': [
                                  q['option1']!.text,
                                  q['option2']!.text,
                                  q['option3']!.text,
                                  q['option4']!.text,
                                ],
                                'correctAnswer': q['correctAnswer']!.text,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                            }

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("✅ Quiz added for $courseName"),
                              backgroundColor: Colors.green,
                            ));
                          },
                          child: Text("Publish"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}