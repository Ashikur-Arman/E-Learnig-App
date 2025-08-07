import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProgressReportPage2 extends StatefulWidget {
  @override
  _ProgressReportPageState createState() => _ProgressReportPageState();
}

class _ProgressReportPageState extends State<ProgressReportPage2> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> quizResults = [];
  bool isLoading = true;
  List<String> weekLabels = [];

  @override
  void initState() {
    super.initState();
    loadQuizResults();
  }

  Future<void> loadQuizResults() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final enrolledCourses = userDoc.get('enrolledCourses') ?? [];

      List<Future<List<Map<String, dynamic>>?>> futures = [];

      for (String courseId in enrolledCourses) {
        futures.add(fetchCourseResult(courseId, user.uid));
      }

      final results = await Future.wait(futures);
      final mergedResults = results.whereType<List<Map<String, dynamic>>>().expand((e) => e).toList();

      setState(() {
        quizResults = mergedResults;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading results: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>?> fetchCourseResult(String courseId, String uid) async {
    try {
      final courseDoc = await _firestore.collection('courses').doc(courseId).get();
      final resultQuery = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('results')
          .where('userId', isEqualTo: uid)
          .get();

      if (resultQuery.docs.isNotEmpty) {
        return resultQuery.docs.map((doc) => {
          'courseName': courseDoc.get('courseName') ?? 'Unknown',
          'score': (doc['score'] as num).toDouble(),
          'total': (doc['total'] as num).toDouble(),
          'timestamp': doc['submittedAt'],
        }).toList();
      }
    } catch (e) {
      print('Error fetching result for course $courseId: $e');
    }
    return null;
  }

  List<double?> getWeeklyAverages(List<Map<String, dynamic>> results) {
    if (results.isEmpty) return [];

    results.sort((a, b) => (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));

    DateTime firstDate = (results.first['timestamp'] as Timestamp).toDate();
    DateTime startOfWeek = firstDate.subtract(Duration(days: firstDate.weekday - 1));
    DateTime today = DateTime.now();
    DateTime endOfWeek = today.add(Duration(days: DateTime.daysPerWeek - today.weekday));

    int totalWeeks = endOfWeek.difference(startOfWeek).inDays ~/ 7 + 1;
    weekLabels = List.generate(totalWeeks, (i) {
      DateTime weekStart = startOfWeek.add(Duration(days: i * 7));
      DateTime weekEnd = weekStart.add(Duration(days: 6));
      return "Week ${i + 1} (${weekStart.day}/${weekStart.month}-${weekEnd.day}/${weekEnd.month})";
    });

    List<double?> averages = [];

    for (int i = 0; i < totalWeeks; i++) {
      DateTime weekStart = startOfWeek.add(Duration(days: i * 7));
      DateTime weekEnd = weekStart.add(Duration(days: 7));

      var weeklyResults = results.where((result) {
        DateTime time = (result['timestamp'] as Timestamp).toDate();
        return !time.isBefore(weekStart) && time.isBefore(weekEnd);
      }).toList();

      if (weeklyResults.isEmpty) {
        averages.add(null);
      } else {
        double sumOfPercentages = 0;
        int validAttempts = 0;

        for (var result in weeklyResults) {
          double score = result['score'];
          double total = result['total'];
          if (total > 0) {
            sumOfPercentages += (score / total) * 100;
            validAttempts++;
          }
        }

        averages.add(validAttempts > 0 ? sumOfPercentages / validAttempts : 0);
      }
    }

    return averages;
  }

  Widget buildProgressGraph(List<double?> averages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Weekly Progress",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 24),
        ...List.generate(averages.length, (index) {
          final progress = averages[index];
          final label = weekLabels.isNotEmpty ? weekLabels[index] : "Week ${index + 1}";

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress != null ? progress / 100 : 0,
                    minHeight: 14,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == null
                          ? Colors.transparent
                          : progress >= 80
                          ? Colors.green.shade600
                          : progress >= 50
                          ? Colors.orange.shade600
                          : Colors.red.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    progress != null ? "${progress.toStringAsFixed(1)}%" : "--",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: progress == null
                          ? Colors.grey
                          : progress >= 80
                          ? Colors.green
                          : progress >= 50
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                  if (index > 0 && averages[index - 1] != null && progress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        progress > averages[index - 1]!
                            ? "Improved from last week. Keep it up!"
                            : progress < averages[index - 1]!
                            ? "Dropped from last week. Focus more."
                            : "Same as last week.",
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: progress > averages[index - 1]!
                              ? Colors.green
                              : progress < averages[index - 1]!
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ),
                  if (progress != null && progress < 60)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        "Improvement needed in this week.",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Progress Report"),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : quizResults.isEmpty
          ? Center(
        child: Text(
          "No quiz results found",
          style: TextStyle(fontSize: 18),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            buildProgressGraph(getWeeklyAverages(quizResults)),
            SizedBox(height: 20),
            Text(
              "Total Attempts: ${quizResults.length}",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}