import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TakeQuizPage extends StatefulWidget {
  final String courseId;
  final String courseName;
  final List<Map<String, dynamic>> quizQuestions;

  const TakeQuizPage({
    Key? key,
    required this.courseId,
    required this.courseName,
    required this.quizQuestions,
  }) : super(key: key);

  @override
  _TakeQuizPageState createState() => _TakeQuizPageState();
}

class _TakeQuizPageState extends State<TakeQuizPage> {
  int currentIndex = 0;
  Map<int, int> selectedAnswers = {}; // questionIndex -> selectedOptionIndex
  bool isSubmitted = false;
  int score = 0;

  Timer? _timer;
  int timeLeft = 30;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    setState(() {
      timeLeft = 30;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft == 0) {
        timer.cancel();
        moveToNextOrSubmit();
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  void moveToNextOrSubmit() {
    if (currentIndex == widget.quizQuestions.length - 1) {
      submitQuiz();
    } else {
      setState(() {
        currentIndex++;
      });
      startTimer();
    }
  }

  void nextQuestion() {
    if (currentIndex < widget.quizQuestions.length - 1) {
      setState(() {
        currentIndex++;
      });
      startTimer();
    }
  }

  void prevQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      startTimer();
    }
  }

  void submitQuiz() async {
    _timer?.cancel();

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
              Navigator.pop(context); // Back to previous page
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quizQuestions[currentIndex];
    final options = List<String>.from(question['options'] ?? []);
    final questionText = question['question'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                "Quiz for ${widget.courseName}",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 10),
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: timeLeft <= 5 ? Colors.red.shade300 : Colors.green.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$timeLeft s",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
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
            SizedBox(height: 8),
            Text(
              questionText,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
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
                  onPressed: selectedAnswers.length ==
                      widget.quizQuestions.length
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
