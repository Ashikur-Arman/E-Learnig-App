import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressReportPage extends StatefulWidget {
  @override
  _ProgressReportPageState createState() => _ProgressReportPageState();
}

class _ProgressReportPageState extends State<ProgressReportPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<FlSpot> scorePoints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserQuizResults();
  }

  Future<void> _fetchUserQuizResults() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Firebase থেকে ইউজারের সব quiz result collection নিয়ে আসা
    final resultsSnapshot = await _firestore
        .collectionGroup('results') // সকল কোর্সের রেজাল্টস
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp')
        .get();

    List<FlSpot> loadedPoints = [];

    int index = 0;
    for (var doc in resultsSnapshot.docs) {
      final data = doc.data();
      final score = (data['score'] ?? 0).toDouble();
      final total = (data['total'] ?? 1).toDouble();
      final percentage = total > 0 ? (score / total) * 100 : 0.0;

      loadedPoints.add(FlSpot(index.toDouble(), percentage));
      index++;
    }

    setState(() {
      scorePoints = loadedPoints;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Progress Report"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : scorePoints.isEmpty
          ? Center(child: Text("No quiz data available"))
          : Padding(
        padding: EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 100,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Q${value.toInt() + 1}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
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
                    return Text('${value.toInt()}%', style: TextStyle(fontSize: 12));
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: true, horizontalInterval: 20),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: scorePoints,
                isCurved: true,
                barWidth: 3,
                color: Colors.blue,
                dotData: FlDotData(show: true),
              )
            ],
          ),
        ),
      ),
    );
  }
}
