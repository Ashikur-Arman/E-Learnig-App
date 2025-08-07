import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnrolledStudentsPage extends StatefulWidget {
  const EnrolledStudentsPage({super.key});

  @override
  State<EnrolledStudentsPage> createState() => _EnrolledStudentsPageState();
}

class _EnrolledStudentsPageState extends State<EnrolledStudentsPage> {
  List<Map<String, dynamic>> allEnrollments = [];
  List<Map<String, dynamic>> filteredEnrollments = [];
  bool isLoading = true;

  String selectedSearchOption = 'Course Name';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final courseSnapshot = await FirebaseFirestore.instance.collection('courses').get();
      final courses = courseSnapshot.docs;

      List<Map<String, dynamic>> result = [];

      // Parallel fetch all enrolledUsers and results per course
      await Future.wait(courses.map((course) async {
        final courseId = course.id;
        final courseName = course['courseName'] ?? 'Unnamed Course';
        final startDate = course['startDate'] ?? 'Unknown Date';

        // Fetch enrolledUsers & results in parallel for this course
        final enrolledFuture = FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('enrolledUsers')
            .get();

        final resultsFuture = FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('results')
            .get();

        final enrolledSnapshot = await enrolledFuture;
        final resultsSnapshot = await resultsFuture;

        // Map userId -> result data for fast lookup
        Map<String, dynamic> resultsMap = {};
        for (var resDoc in resultsSnapshot.docs) {
          resultsMap[resDoc.id] = resDoc.data();
        }

        // Build student list with result info
        final students = enrolledSnapshot.docs.map((doc) {
          final studentData = doc.data();
          final userId = studentData['userId'];
          final resultData = resultsMap[userId];

          studentData['score'] = resultData != null ? resultData['score'] : null;
          studentData['total'] = resultData != null ? resultData['total'] : null;

          return studentData;
        }).toList();

        result.add({
          'courseId': courseId,
          'courseName': courseName,
          'startDate': startDate,
          'students': students,
        });
      }));

      setState(() {
        allEnrollments = result;
        filteredEnrollments = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading enrollments: $e');
    }
  }

  void _performSearch(String query) {
    query = query.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        filteredEnrollments = allEnrollments;
      });
      return;
    }

    List<Map<String, dynamic>> results = [];

    if (selectedSearchOption == 'Course Name') {
      results = allEnrollments.where((course) {
        final name = course['courseName']?.toString().toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    } else if (selectedSearchOption == 'Start Date') {
      results = allEnrollments.where((course) {
        final date = course['startDate']?.toString().toLowerCase() ?? '';
        return date.contains(query);
      }).toList();
    }

    setState(() {
      filteredEnrollments = results;
    });
  }

  void _showSearchDialog() {
    searchController.clear();
    selectedSearchOption = 'Course Name';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text("Search Enrolled Students"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedSearchOption,
                  isExpanded: true,
                  items: ['Course Name', 'Start Date'].map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedSearchOption = val;
                      });
                      setStateDialog(() {});
                    }
                  },
                ),
                if (selectedSearchOption == 'Course Name') ...[
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(labelText: 'Enter course name'),
                    onSubmitted: (_) {
                      Navigator.pop(context);
                      _performSearch(searchController.text);
                    },
                  ),
                ] else ...[
                  TextField(
                    controller: searchController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Pick course start date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2022),
                        lastDate: DateTime(2030),
                      );

                      if (pickedDate != null) {
                        String formatted = DateFormat('yyyy-MM-dd').format(pickedDate);
                        searchController.text = formatted;
                      }
                    },
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    filteredEnrollments = allEnrollments;
                  });
                },
                child: Text("Clear"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performSearch(searchController.text);
                },
                child: Text("Search"),
              ),
            ],
          );
        },
      ),
    );
  }

  // MCQ Dialog Code Same (no change)
  void showMCQDialog(BuildContext context, String courseId, String courseName) {
    int questionCount = 2;
    final List<Map<String, dynamic>> questionControllers = [];

    void initializeControllers(int count) {
      questionControllers.clear();
      for (int i = 0; i < count; i++) {
        questionControllers.add({
          'question': TextEditingController(),
          'option1': TextEditingController(),
          'option2': TextEditingController(),
          'option3': TextEditingController(),
          'option4': TextEditingController(),
          'correctAnswerIndex': 0,
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
                                  SizedBox(height: 8),
                                  Text("Select Correct Answer:"),
                                  Row(
                                    children: List.generate(4, (optionIndex) {
                                      return Expanded(
                                        child: RadioListTile<int>(
                                          title: Text("Option ${optionIndex + 1}"),
                                          value: optionIndex,
                                          groupValue: controllers['correctAnswerIndex'],
                                          onChanged: (val) {
                                            setState(() {
                                              controllers['correctAnswerIndex'] = val!;
                                            });
                                          },
                                        ),
                                      );
                                    }),
                                  ),
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
                        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                        ElevatedButton(
                          onPressed: () async {
                            bool valid = true;
                            for (var q in questionControllers) {
                              if (q['question']!.text.trim().isEmpty ||
                                  q['option1']!.text.trim().isEmpty ||
                                  q['option2']!.text.trim().isEmpty ||
                                  q['option3']!.text.trim().isEmpty ||
                                  q['option4']!.text.trim().isEmpty) {
                                valid = false;
                                break;
                              }
                            }

                            if (!valid) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please fill all question fields."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            for (var q in questionControllers) {
                              await FirebaseFirestore.instance
                                  .collection('courses')
                                  .doc(courseId)
                                  .collection('quizzes')
                                  .add({
                                'question': q['question']!.text.trim(),
                                'options': [
                                  q['option1']!.text.trim(),
                                  q['option2']!.text.trim(),
                                  q['option3']!.text.trim(),
                                  q['option4']!.text.trim(),
                                ],
                                'correctAnswerIndex': q['correctAnswerIndex'],
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                            }

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("✅ Quiz added for $courseName"),
                                backgroundColor: Colors.green,
                              ),
                            );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enrolled Students"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredEnrollments.isEmpty
          ? Center(child: Text("Sorry, no enrolled students found.", style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
        itemCount: filteredEnrollments.length,
        itemBuilder: (context, index) {
          final course = filteredEnrollments[index];
          final courseName = course['courseName'];
          final startDate = course['startDate'];
          final courseId = course['courseId'];
          final students = course['students'];

          return ExpansionTile(
            title: Text(
              "$courseName (Starts: $startDate)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: students.isEmpty
                ? [Padding(padding: EdgeInsets.all(8), child: Text("No students enrolled in this course."))]
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
      ),
    );
  }
}
