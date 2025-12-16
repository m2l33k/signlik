import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sign.dart';

class QuizScreen extends StatefulWidget {
  final List<Sign> allSigns;
  final int questionCount;
  final String title;

  const QuizScreen({
    super.key,
    required this.allSigns,
    this.questionCount = 5,
    this.title = "Quiz",
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    if (widget.allSigns.length < 4) {
      // Not enough signs for a quiz
      return;
    }

    final random = Random();
    final List<Sign> pool = List.from(widget.allSigns)..shuffle(random);
    final count = min(widget.questionCount, pool.length);

    for (int i = 0; i < count; i++) {
      final correct = pool[i];
      // Pick 3 distractors
      final distractors = List<Sign>.from(widget.allSigns)
        ..removeWhere((s) => s.id == correct.id)
        ..shuffle(random);
      
      final options = (distractors.take(3).toList()..add(correct))..shuffle(random);
      
      _questions.add(Question(correctSign: correct, options: options));
    }
  }

  void _submitAnswer(Sign selected) {
    if (_answered) return;

    setState(() {
      _answered = true;
      if (selected.id == _questions[_currentIndex].correctSign.id) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Quiz Completed!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You scored $_score / ${_questions.length}"),
            const SizedBox(height: 10),
            if (_score == _questions.length)
              const Text("Perfect! 🎉", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _answered = false;
                _questions.clear();
                _generateQuestions();
              });
            },
            child: const Text("Retake"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text("Done"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text("Not enough signs for a quiz.")),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title} (${_currentIndex + 1}/${_questions.length})"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video/Image Area
            Expanded(
              flex: 4,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  color: Colors.grey[100],
                  child: Center(
                    child: question.correctSign.thumbnailUrl != null
                        ? Image.network(question.correctSign.thumbnailUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.videocam, size: 64, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "What does this sign mean?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Options
            Expanded(
              flex: 6,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: question.options.map((opt) {
                  Color btnColor = Colors.blue.shade50;
                  Color txtColor = Colors.blue.shade900;
                  
                  if (_answered) {
                    if (opt.id == question.correctSign.id) {
                      btnColor = Colors.green.shade100;
                      txtColor = Colors.green.shade900;
                    } else if (opt.word == question.correctSign.word) { 
                       // Duplicate word case handling? Unlikely with IDs
                    } 
                    // Highlight selected wrong answer?
                    // We don't track which one was tapped in state easily without extra field, 
                    // but we can just show correct answer.
                  }

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      foregroundColor: txtColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _answered ? null : () => _submitAnswer(opt),
                    child: Text(opt.word, textAlign: TextAlign.center),
                  );
                }).toList(),
              ),
            ),
            if (_answered)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1 ? "Next Question" : "Finish Quiz",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final Sign correctSign;
  final List<Sign> options;

  Question({required this.correctSign, required this.options});
}
