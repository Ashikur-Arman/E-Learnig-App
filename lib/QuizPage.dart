import 'dart:async';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _quizStarted = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _selectedOption = -1;
  int _secondsRemaining = 300; // 5 minutes = 300 seconds
  Timer? _timer;

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "What is the SI unit of force?",
      "options": ["Joule", "Pascal", "Newton", "Watt"],
      "answerIndex": 2,
    },
    {
      "question": "Who discovered gravity?",
      "options": ["Einstein", "Newton", "Galileo", "Bohr"],
      "answerIndex": 1,
    },
    {
      "question": "Speed of light is?",
      "options": ["300 km/s", "3x10^8 m/s", "150 km/h", "3x10^5 km/s"],
      "answerIndex": 1,
    },
    {
      "question": "Which is not a vector quantity?",
      "options": ["Velocity", "Acceleration", "Speed", "Force"],
      "answerIndex": 2,
    },
    {
      "question": "Which law is F = ma?",
      "options": ["1st law", "2nd law", "3rd law", "None"],
      "answerIndex": 1,
    },
    {
      "question": "Energy stored in a spring is called?",
      "options": ["Kinetic", "Potential", "Elastic potential", "Mechanical"],
      "answerIndex": 2,
    },
    {
      "question": "Power is defined as?",
      "options": ["Work/time", "Force/distance", "Mass x Acceleration", "None"],
      "answerIndex": 0,
    },
    {
      "question": "Sound cannot travel through?",
      "options": ["Water", "Air", "Steel", "Vacuum"],
      "answerIndex": 3,
    },
    {
      "question": "Which has more inertia?",
      "options": ["Car", "Bike", "Truck", "Cycle"],
      "answerIndex": 2,
    },
    {
      "question": "Unit of pressure is?",
      "options": ["N/m", "N", "Pa", "J"],
      "answerIndex": 2,
    },
  ];

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
      _currentQuestionIndex = 0;
      _score = 0;
      _secondsRemaining = 300;
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        _finishQuiz();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _submitAnswer() {
    if (_selectedOption == _questions[_currentQuestionIndex]['answerIndex']) {
      _score++;
    }

    setState(() {
      _selectedOption = -1;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _finishQuiz();
      }
    });
  }

  void _finishQuiz() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Quiz Finished"),
        content: Text("Your Score is $_score out of ${_questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _quizStarted = false;
              });
            },
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Physics Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _quizStarted ? _buildQuizContent() : _buildStartButton(),
      ),
    );
  }

  Widget _buildStartButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _startQuiz,
        child: Text("Start Quiz"),
      ),
    );
  }

  Widget _buildQuizContent() {
    var question = _questions[_currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Time Remaining: ${_formatTime(_secondsRemaining)}", style: TextStyle(fontSize: 18, color: Colors.red)),
        SizedBox(height: 20),
        Text("Question ${_currentQuestionIndex + 1}/${_questions.length}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(question['question'], style: TextStyle(fontSize: 16)),
        SizedBox(height: 20),
        ...List.generate(question['options'].length, (index) {
          return RadioListTile(
            title: Text(question['options'][index]),
            value: index,
            groupValue: _selectedOption,
            onChanged: (val) {
              setState(() {
                _selectedOption = val as int;
              });
            },
          );
        }),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _selectedOption == -1 ? null : _submitAnswer,
          child: Text("Submit"),
        )
      ],
    );
  }
}
