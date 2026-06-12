import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuizTakePage extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final String studentEmail;

  const QuizTakePage({
    super.key,
    required this.quiz,
    required this.studentEmail,
  });

  @override
  State<QuizTakePage> createState() => _QuizTakePageState();
}

class _QuizTakePageState extends State<QuizTakePage> {
  late final List<Map<String, dynamic>> _questions;
  final Map<int, String> _mcSelections = {};
  final Map<int, String> _identificationAnswers = {};
  final Map<int, String> _essayAnswers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final questionsRaw = widget.quiz['questions'];
    if (questionsRaw is List) {
      _questions = List<Map<String, dynamic>>.from(questionsRaw);
    } else {
      _questions = [];
    }
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final email = widget.studentEmail.trim();
      if (email.isEmpty) {
        throw Exception('Student email is empty. Cannot save quiz result.');
      }

      int correct = 0;
      int total = _questions.length;

      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        final type = q['type']?.toString() ?? '';

        if (type == 'Multiple Choice') {
          final expected = (q['correctAnswer']?.toString() ?? '').trim().toUpperCase();
          final got = (_mcSelections[i] ?? '').trim().toUpperCase();
          if (expected.isNotEmpty && got == expected) correct++;
        } else if (type == 'Identification') {
          final expected = (q['answer']?.toString() ?? '').trim().toUpperCase();
          final got = (_identificationAnswers[i] ?? '').trim().toUpperCase();
          if (expected.isNotEmpty && got == expected) correct++;
        }
      }

      final percent = total > 0 ? (correct / total) * 100.0 : 0.0;

      // Convert integer keys to strings for JSON
      final mcAnswers = Map.fromEntries(
        _mcSelections.entries.map((e) => MapEntry(e.key.toString(), e.value))
      );
      final idAnswers = Map.fromEntries(
        _identificationAnswers.entries.map((e) => MapEntry(e.key.toString(), e.value))
      );
      final essayAnswers = Map.fromEntries(
        _essayAnswers.entries.map((e) => MapEntry(e.key.toString(), e.value))
      );

      final submission = {
        'quiz_id': widget.quiz['id']?.toString() ?? '',
        'quiz_title': widget.quiz['title']?.toString() ?? 'Untitled Quiz',
        'student_email': email,
        'submitted_at': DateTime.now().toIso8601String(),
        'score_correct': correct,
        'score_total': total,
        'score_percent': percent,
        'answers': {
          'multiple_choice': mcAnswers,
          'identification': idAnswers,
          'essay': essayAnswers,
        },
      };

      final prefs = await SharedPreferences.getInstance();
      final studentKey = email.replaceAll('.', '_');
      final attemptsKey = 'quiz_attempts_$studentKey';
      final attemptsJson = prefs.getString(attemptsKey);
      final List<Map<String, dynamic>> attempts = attemptsJson == null
          ? []
          : List<Map<String, dynamic>>.from(jsonDecode(attemptsJson));

      attempts.removeWhere((a) => a['quiz_id']?.toString() == submission['quiz_id']?.toString());
      attempts.add(submission);
      await prefs.setString(attemptsKey, jsonEncode(attempts));

      if (mounted) {
        // Show raw score in snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Quiz submitted! Score: $correct/$total (${percent.toStringAsFixed(0)}%)')),
        );
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Quiz error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Submission Error'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Something went wrong while saving your quiz.'),
                  const SizedBox(height: 12),
                  Text('Error: ${e.toString()}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  Text('Stack trace: ${stackTrace.toString().split('\n').first}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz['title']?.toString() ?? 'Quiz')),
        body: const Center(child: Text('No questions found for this quiz.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz['title']?.toString() ?? 'Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if ((widget.quiz['description']?.toString() ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.quiz['description'].toString(),
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  final type = q['type']?.toString() ?? '';
                  final text = q['text']?.toString() ?? '';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${index + 1}. $text', style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          if (type == 'Multiple Choice')
                            _buildMultipleChoice(index, q)
                          else if (type == 'Identification')
                            _buildIdentification(index)
                          else
                            _buildEssay(index),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitQuiz,
                icon: _isSubmitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: const Text('Submit Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoice(int index, Map<String, dynamic> q) {
    final choices = List<String>.from(q['choices'] ?? []);
    final selected = _mcSelections[index];
    return Column(
      children: List.generate(choices.length, (i) {
        final label = String.fromCharCode(65 + i);
        return RadioListTile<String>(
          value: label,
          groupValue: selected,
          title: Text('${label}. ${choices[i]}'),
          dense: true,
          onChanged: (val) => setState(() => _mcSelections[index] = val ?? ''),
        );
      }),
    );
  }

  Widget _buildIdentification(int index) {
    return TextField(
      decoration: const InputDecoration(labelText: 'Your answer', border: OutlineInputBorder()),
      onChanged: (val) => _identificationAnswers[index] = val,
    );
  }

  Widget _buildEssay(int index) {
    return TextField(
      maxLines: 5,
      decoration: const InputDecoration(labelText: 'Your answer', border: OutlineInputBorder()),
      onChanged: (val) => _essayAnswers[index] = val,
    );
  }
}