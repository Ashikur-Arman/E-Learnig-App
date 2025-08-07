import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool loading = true;
  String? errorMessage;
  List<Map<String, dynamic>> leaderboard = [];

  @override
  void initState() {
    super.initState();
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('valid', isEqualTo: true)
          .get();

      if (usersSnapshot.docs.isEmpty) {
        setState(() {
          loading = false;
          leaderboard = [];
        });
        return;
      }

      List<Map<String, dynamic>> tempList = [];

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();

        final name = userData['name'] ?? 'No Name';
        final email = userData['email'] ?? '';
        final enrolledCourses = List<String>.from(userData['enrolledCourses'] ?? []);

        double totalScore = 0;
        double totalMarks = 0;

        for (var courseId in enrolledCourses) {
          final resultsSnapshot = await FirebaseFirestore.instance
              .collection('courses')
              .doc(courseId)
              .collection('results')
              .where('userId', isEqualTo: userId)
              .get();

          for (var resDoc in resultsSnapshot.docs) {
            final data = resDoc.data();
            if (data == null) continue;

            bool disqualified = data['disqualified'] == true;
            if (disqualified) continue;

            if (data['score'] is num && data['total'] is num) {
              totalScore += (data['score'] as num).toDouble();
              totalMarks += (data['total'] as num).toDouble();
            }
          }
        }

        if (totalMarks > 0) {
          double percentage = (totalScore / totalMarks) * 100;
          tempList.add({
            'name': name,
            'email': email,
            'percentage': percentage,
          });
        }
      }

      tempList.sort((a, b) => b['percentage'].compareTo(a['percentage']));

      setState(() {
        leaderboard = tempList;
        loading = false;
      });
    } catch (e) {
      print("Error loading leaderboard: $e");
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Leaderboard")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text("Error: $errorMessage"))
          : leaderboard.isEmpty
          ? Center(child: Text("No leaderboard data found."))
          : ListView.builder(
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final user = leaderboard[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(user['name']),
            subtitle: Text(user['email']),
            trailing: Text('${user['percentage'].toStringAsFixed(1)}%'),
          );
        },
      ),
    );
  }
}
