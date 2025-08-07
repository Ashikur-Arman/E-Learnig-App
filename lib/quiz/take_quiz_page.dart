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
  Map<int, int> selectedAnswers = {};
  bool isSubmitted = false;
  int score = 0;
  bool showAnswers = false;
  bool isDisqualified = false;

  Timer? _timer;
  late int timeLeft;

  @override
  void initState() {
    super.initState();
    timeLeft = widget.quizQuestions.length * 30; // 30 seconds per question
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft <= 0) {
        timer.cancel();
        submitQuiz();
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  Future<void> submitQuiz() async {
    _timer?.cancel();

    int tempScore = 0;
    for (int i = 0; i < widget.quizQuestions.length; i++) {
      final question = widget.quizQuestions[i];
      final correctIndex = question['correctAnswerIndex'] ?? 0;

      if (selectedAnswers[i] == correctIndex) {
        tempScore++;
      }
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('results')
          .doc(user.uid)
          .set({
        'score': tempScore,
        'total': widget.quizQuestions.length,
        'userId': user.uid,
        'submittedAt': FieldValue.serverTimestamp(),
        'disqualified': false,
      });
    }

    setState(() {
      isSubmitted = true;
      score = tempScore;
    });
  }

  Future<void> disqualifyUser() async {
    if (isDisqualified) return; // Prevent multiple calls
    isDisqualified = true;

    _timer?.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('results')
          .doc(user.uid)
          .set({
        'score': 0,
        'total': widget.quizQuestions.length,
        'userId': user.uid,
        'submittedAt': FieldValue.serverTimestamp(),
        'disqualified': true,
      });
    }
  }

  @override
  void dispose() {
    if (!isSubmitted && !isDisqualified) {
      disqualifyUser();
    }
    _timer?.cancel();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final question = widget.quizQuestions[currentIndex];
    final options = List<String>.from(question['options'] ?? []);
    final questionText = question['question'] ?? '';

    return WillPopScope(
      onWillPop: () async {
        if (!isSubmitted) {
          await disqualifyUser();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Quiz for ${widget.courseName}"),
          centerTitle: true,
          backgroundColor: Colors.teal,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "$timeLeft s",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: timeLeft <= 5 ? Colors.redAccent : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: isSubmitted
              ? (showAnswers ? buildAnswerReview() : buildResultView())
              : buildQuizView(questionText, options),
        ),
      ),
    );
  }

  Widget buildResultView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 90, color: Colors.teal.shade700),
          const SizedBox(height: 20),
          const Text(
            "Quiz Completed!",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "You scored $score out of ${widget.quizQuestions.length}",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                showAnswers = true;
              });
            },
            icon: const Icon(Icons.visibility),
            label: const Text("Show Answers"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuizView(String questionText, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Question ${currentIndex + 1} of ${widget.quizQuestions.length}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        Card(
          elevation: 3,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              questionText,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, i) {
              return RadioListTile<int>(
                value: i,
                groupValue: selectedAnswers[currentIndex],
                onChanged: (val) {
                  setState(() {
                    selectedAnswers[currentIndex] = val!;
                  });
                },
                title: Text(
                  options[i],
                  style: const TextStyle(fontSize: 16),
                ),
                activeColor: Colors.teal,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: currentIndex > 0 ? prevQuestion : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text("Previous"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                disabledBackgroundColor: Colors.grey.shade400,
              ),
            ),
            currentIndex == widget.quizQuestions.length - 1
                ? ElevatedButton.icon(
              onPressed:
              selectedAnswers.length == widget.quizQuestions.length
                  ? submitQuiz
                  : null,
              icon: const Icon(Icons.check),
              label: const Text("Submit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                disabledBackgroundColor: Colors.grey.shade400,
              ),
            )
                : ElevatedButton.icon(
              onPressed: selectedAnswers.containsKey(currentIndex)
                  ? nextQuestion
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Next"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                disabledBackgroundColor: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildAnswerReview() {
    return ListView.builder(
      itemCount: widget.quizQuestions.length,
      itemBuilder: (context, index) {
        final question = widget.quizQuestions[index];
        final options = List<String>.from(question['options'] ?? []);
        final correctIndex = question['correctAnswerIndex'] ?? 0;
        final selectedIndex = selectedAnswers[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Q${index + 1}: ${question['question']}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                ...List.generate(options.length, (i) {
                  Color? bgColor;
                  Icon? icon;

                  if (i == correctIndex) {
                    bgColor = Colors.green.shade100;
                    icon = const Icon(Icons.check_circle, color: Colors.green);
                  } else if (i == selectedIndex) {
                    bgColor = Colors.red.shade100;
                    icon = const Icon(Icons.cancel, color: Colors.red);
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: bgColor != null
                            ? (bgColor == Colors.green.shade100
                            ? Colors.green
                            : Colors.red)
                            : Colors.grey.shade300,
                        width: 1.3,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (icon != null) icon,
                        if (icon != null) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            options[i],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: i == correctIndex
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
