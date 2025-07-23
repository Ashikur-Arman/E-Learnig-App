import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressReportPage extends StatefulWidget {
  @override
  _ProgressReportPageState createState() => _ProgressReportPageState();
}

class _ProgressReportPageState extends State<ProgressReportPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> quizResults = [];
  bool isLoading = true;

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

      List<Future<Map<String, dynamic>?>> futures = [];

      for (String courseId in enrolledCourses) {
        futures.add(fetchCourseResult(courseId, user.uid));
      }

      final results = await Future.wait(futures);

      setState(() {
        quizResults = results.whereType<Map<String, dynamic>>().toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading results: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> fetchCourseResult(String courseId, String uid) async {
    try {
      final courseDoc = await _firestore.collection('courses').doc(courseId).get();
      final resultQuery = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('results')
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get();

      if (resultQuery.docs.isNotEmpty) {
        final resultDoc = resultQuery.docs.first;
        return {
          'courseName': courseDoc.get('courseName') ?? 'Unknown',
          'score': resultDoc['score'],
          'total': resultDoc['total'],
        };
      }
    } catch (e) {
      print('Error fetching result for course $courseId: $e');
    }
    return null;
  }

  List<BarChartGroupData> generateBarGroups() {
    return List.generate(quizResults.length, (index) {
      final result = quizResults[index];
      double percentage = result['score'] / result['total'] * 100;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: percentage,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  List<String> getLowSubjects() {
    return quizResults
        .where((result) => (result['score'] / result['total']) * 100 < 60)
        .map((result) => result['courseName'].toString())
        .toList();
  }

  List<String> getPerfectSubjects() {
    return quizResults
        .where((result) => (result['score'] / result['total']) * 100 == 100)
        .map((result) => result['courseName'].toString())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Quiz Progress")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : quizResults.isEmpty
          ? Center(child: Text("No quiz results found"))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: quizResults.length,
                itemBuilder: (context, index) {
                  final result = quizResults[index];
                  double percentage = result['score'] / result['total'];

                  return Card(
                    margin: EdgeInsets.all(12),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: result['score'].toDouble(),
                                    color: Colors.green,
                                    radius: 30,
                                  ),
                                  PieChartSectionData(
                                    value: (result['total'] -
                                        result['score'])
                                        .toDouble(),
                                    color: Colors.redAccent,
                                    radius: 30,
                                  ),
                                ],
                                centerSpaceRadius: 20,
                                sectionsSpace: 0,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result['courseName'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                    "Score: ${result['score']} / ${result['total']}"),
                                SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: percentage,
                                  backgroundColor:
                                  Colors.red.withOpacity(0.2),
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                "Quiz Performance Overview",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 240,
                child: BarChart(
                  BarChartData(
                    barGroups: generateBarGroups(),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),
                    maxY: 100,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final course =
                            quizResults[value.toInt()];
                            return Transform.rotate(
                              angle: -0.5,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  course['courseName']
                                      .toString()
                                      .length >
                                      6
                                      ? course['courseName']
                                      .toString()
                                      .substring(0, 6) +
                                      '...'
                                      : course['courseName'],
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 20,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding:
                              const EdgeInsets.only(left: 4),
                              child: Text(
                                '${value.toInt()}%',
                                style: TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                          sideTitles:
                          SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                          sideTitles:
                          SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (getLowSubjects().isNotEmpty)
                Card(
                  color: Colors.red.shade50,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Areas to Improve!!!",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "You scored below 60% in the following subjects:",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 6),
                        ...getLowSubjects()
                            .map((sub) => Text("• $sub"))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              if (getPerfectSubjects().isNotEmpty)
                Card(
                  color: Colors.green.shade50,
                  elevation: 2,
                  margin: const EdgeInsets.only(top: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Congratulations!!!",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "You have scored 100% in the following subjects:",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 6),
                        ...getPerfectSubjects()
                            .map((sub) => Text("• $sub"))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
