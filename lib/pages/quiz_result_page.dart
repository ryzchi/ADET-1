import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final Map<String, dynamic> quiz;
  final Map<String, dynamic> attempt;

  const QuizResultPage({
    super.key,
    required this.quiz,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    final questions = List<Map<String, dynamic>>.from(quiz['questions'] ?? []);
    final answers = attempt['answers'] ?? {};
    final mcAnswers = Map<String, String>.from(answers['multiple_choice'] ?? {});
    final idAnswers = Map<String, String>.from(answers['identification'] ?? {});
    final essayAnswers = Map<String, String>.from(answers['essay'] ?? {});

    final scoreCorrect = attempt['score_correct'] ?? 0;
    final scoreTotal = attempt['score_total'] ?? questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz['title'] ?? 'Quiz Results'),
        backgroundColor: const Color(0xFF0d2b5c),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.quiz, size: 32, color: Color(0xFF0d2b5c)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Score', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    Text('$scoreCorrect / $scoreTotal',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0d2b5c))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final type = q['type']?.toString() ?? '';
                final questionText = q['text']?.toString() ?? '';
                final userAnswer = _getUserAnswer(
                  index: index,
                  type: type,
                  mcAnswers: mcAnswers,
                  idAnswers: idAnswers,
                  essayAnswers: essayAnswers,
                );
                final isCorrect = _isAnswerCorrect(q, type, userAnswer);
                final correctAnswer = _getCorrectAnswer(q, type);

                // Convert choices to List<String> safely
                final dynamic choicesRaw = q['choices'];
                final List<String> choices = (choicesRaw is List)
                    ? choicesRaw.map((e) => e?.toString() ?? '').toList()
                    : [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${index + 1}. $questionText',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 12),
                        if (type == 'Multiple Choice')
                          _buildMultipleChoiceResult(
                            choices: choices,
                            userChoice: userAnswer,
                            correctChoiceLetter: q['correctAnswer']?.toString() ?? '',
                          )
                        else if (type == 'Identification')
                          _buildIdentificationResult(
                            userAnswer: userAnswer,
                            correctAnswer: correctAnswer,
                            isCorrect: isCorrect,
                          )
                        else
                          _buildEssayResult(
                            userAnswer: userAnswer,
                            sampleAnswer: correctAnswer,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceResult({
    required List<String> choices,
    required String userChoice,
    required String correctChoiceLetter,
  }) {
    final selectedLetter = userChoice.trim().toUpperCase();
    final correctLetter = correctChoiceLetter.trim().toUpperCase();

    return Column(
      children: List.generate(choices.length, (i) {
        final letter = String.fromCharCode(65 + i);
        final choiceText = choices[i];
        final isSelected = letter == selectedLetter;
        final isCorrectChoice = letter == correctLetter;

        Color? backgroundColor;
        Color? textColor;
        Widget? trailingIcon;

        if (isSelected) {
          if (isCorrectChoice) {
            backgroundColor = Colors.green.shade100;
            textColor = Colors.green.shade900;
            trailingIcon = const Icon(Icons.check_circle, color: Colors.green, size: 20);
          } else {
            backgroundColor = Colors.red.shade100;
            textColor = Colors.red.shade900;
            trailingIcon = const Icon(Icons.cancel, color: Colors.red, size: 20);
          }
        } else if (isCorrectChoice) {
          backgroundColor = Colors.green.shade50;
          textColor = Colors.green.shade800;
          trailingIcon = const Icon(Icons.check, color: Colors.green, size: 18);
        } else {
          backgroundColor = Colors.grey.shade50;
          textColor = Colors.grey.shade800;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected && !isCorrectChoice
                  ? Colors.red.shade300
                  : isCorrectChoice
                      ? Colors.green.shade300
                      : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$letter. $choiceText',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ),
              if (trailingIcon != null) trailingIcon,
            ],
          ),
        );
      }),
    );
  }

  Widget _buildIdentificationResult({
    required String userAnswer,
    required String correctAnswer,
    required bool isCorrect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isCorrect ? Colors.green.shade300 : Colors.red.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your answer:',
                        style: TextStyle(
                            fontSize: 12,
                            color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(userAnswer.isNotEmpty ? userAnswer : '(blank)',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isCorrect ? Colors.green.shade900 : Colors.red.shade900)),
                  ],
                ),
              ),
              Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red),
            ],
          ),
        ),
        if (!isCorrect) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Correct answer:',
                          style: TextStyle(
                              fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(correctAnswer,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.green.shade900)),
                    ],
                  ),
                ),
                const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEssayResult({
    required String userAnswer,
    required String sampleAnswer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your answer:',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(userAnswer.isNotEmpty ? userAnswer : '(blank)', style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
        if (sampleAnswer.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sample answer / rubric:',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(sampleAnswer, style: TextStyle(fontSize: 15, color: Colors.blue.shade900)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getUserAnswer({
    required int index,
    required String type,
    required Map<String, String> mcAnswers,
    required Map<String, String> idAnswers,
    required Map<String, String> essayAnswers,
  }) {
    final idxStr = index.toString();
    if (type == 'Multiple Choice') {
      return mcAnswers[idxStr] ?? '';
    } else if (type == 'Identification') {
      return idAnswers[idxStr] ?? '';
    } else {
      return essayAnswers[idxStr] ?? '';
    }
  }

  String _getCorrectAnswer(Map<String, dynamic> q, String type) {
    if (type == 'Multiple Choice') {
      final correctLetter = q['correctAnswer']?.toString() ?? '';
      final dynamic choicesRaw = q['choices'];
      final List<String> choices = (choicesRaw is List)
          ? choicesRaw.map((e) => e?.toString() ?? '').toList()
          : [];
      final choiceIndex = correctLetter.toUpperCase().codeUnitAt(0) - 65;
      if (choiceIndex >= 0 && choiceIndex < choices.length) {
        return '${correctLetter.toUpperCase()}. ${choices[choiceIndex]}';
      }
      return correctLetter;
    } else if (type == 'Identification') {
      return q['answer']?.toString() ?? 'No answer key';
    } else {
      return q['sampleAnswer']?.toString() ?? '';
    }
  }

  bool _isAnswerCorrect(Map<String, dynamic> q, String type, String userAnswer) {
    if (type == 'Multiple Choice') {
      final expectedLetter = q['correctAnswer']?.toString().trim().toUpperCase() ?? '';
      return userAnswer.trim().toUpperCase() == expectedLetter;
    } else if (type == 'Identification') {
      final expected = q['answer']?.toString().trim().toUpperCase() ?? '';
      return userAnswer.trim().toUpperCase() == expected;
    }
    return false;
  }
}