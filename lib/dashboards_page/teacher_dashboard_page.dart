import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../pages/upload_material_page.dart';
import '../pages/uploaded_material.dart';
import '/security_service/auth_service.dart';
import '/pages/teacher_review_page.dart';
import '/services/api_client.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  final _authService = AuthService();
  final ApiClient _api = ApiClient();
  int _selectedIndex = 0;
  bool _isMobile = false;

  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _materials = [];
  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _submissions = [];
  List<Map<String, dynamic>> _attendanceRecords = [];
  List<Map<String, dynamic>> _quizzes = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _loadQuizzes();
  }

  // ========== API LOADERS ==========
  Future<void> _loadAllData() async {
    await Future.wait([
      _loadStudents(),
      _loadAnnouncements(),
      _loadMaterials(),
      _loadAssignments(),
      _loadSubmissions(),
      _loadAttendance(),
    ]);
    setState(() {});
  }

  Future<void> _loadStudents() async {
    try {
      final response = await _api.get('students.php');
      if (response['success'] == true) {
        setState(() => _students = List<Map<String, dynamic>>.from(response['students'] ?? []));
      } else {
        _students = [];
      }
    } catch (e) {
      _students = [];
    }
  }

  Future<void> _loadAnnouncements() async {
    try {
      final response = await _api.get('announcements.php');
      if (response['success'] == true) {
        setState(() => _announcements = List<Map<String, dynamic>>.from(response['announcements'] ?? []));
      } else {
        _announcements = [];
      }
    } catch (e) {
      _announcements = [];
    }
  }

  Future<void> _loadMaterials() async {
    try {
      final response = await _api.get('materials.php');
      if (response['success'] == true) {
        setState(() => _materials = List<Map<String, dynamic>>.from(response['materials'] ?? []));
      } else {
        _materials = [];
      }
    } catch (e) {
      _materials = [];
    }
  }

  Future<void> _loadAssignments() async {
    try {
      final response = await _api.get('assignments.php');
      if (response['success'] == true) {
        setState(() => _assignments = List<Map<String, dynamic>>.from(response['assignments'] ?? []));
      } else {
        _assignments = [];
      }
    } catch (e) {
      _assignments = [];
    }
  }

  Future<void> _loadSubmissions() async {
    try {
      final response = await _api.get('submissions.php');
      if (response['success'] == true) {
        setState(() => _submissions = List<Map<String, dynamic>>.from(response['submissions'] ?? []));
      } else {
        _submissions = [];
      }
    } catch (e) {
      _submissions = [];
    }
  }

  Future<void> _loadAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getString('attendance_records');
    setState(() {
      _attendanceRecords = attendanceJson != null
          ? List<Map<String, dynamic>>.from(jsonDecode(attendanceJson))
          : [];
    });
  }

  // ========== QUIZZES ==========
  Future<void> _loadQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    final quizzesJson = prefs.getString('teacher_quizzes');
    setState(() {
      _quizzes = quizzesJson != null
          ? List<Map<String, dynamic>>.from(jsonDecode(quizzesJson))
          : [];
    });
  }

  Future<void> _saveQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacher_quizzes', jsonEncode(_quizzes));
  }

  Future<void> _createQuiz() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Quiz Title')),
            const SizedBox(height: 12),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final newQuiz = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'questions': <Map<String, dynamic>>[],
                };
                setState(() => _quizzes.add(newQuiz));
                _saveQuizzes();
                Navigator.pop(context);
                _editQuizQuestions(newQuiz);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _editQuizQuestions(Map<String, dynamic> quiz) async {
    final List<Map<String, dynamic>> questions = List.from(quiz['questions']);
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Edit Quiz: ${quiz['title']}'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _addQuestionDialog(quiz, questions, setStateDialog, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Question'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: questions.length,
                      itemBuilder: (context, idx) {
                        final q = questions[idx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('${idx+1}. ${q['text']}', maxLines: 2),
                            subtitle: Text('Type: ${q['type']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editSingleQuestionDialog(quiz, questions, setStateDialog, idx),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    questions.removeAt(idx);
                                    setStateDialog(() {});
                                    _saveQuizQuestions(quiz, questions);
                                  },
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
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _saveQuizQuestions(quiz, questions);
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveQuizQuestions(Map<String, dynamic> quiz, List<Map<String, dynamic>> questions) {
    final index = _quizzes.indexWhere((q) => q['id'] == quiz['id']);
    if (index != -1) {
      setState(() => _quizzes[index]['questions'] = questions);
      _saveQuizzes();
    }
  }

  Future<void> _addQuestionDialog(Map<String, dynamic> quiz, List<Map<String, dynamic>> questions, StateSetter setStateDialog, int? editIndex) async {
    if (editIndex != null) {
      await _editSingleQuestionDialog(quiz, questions, setStateDialog, editIndex);
      return;
    }

    String questionType = 'Multiple Choice';
    final questionTextController = TextEditingController();
    final correctAnswerController = TextEditingController();
    final identificationAnswerController = TextEditingController();
    final essayAnswerController = TextEditingController();
    List<TextEditingController> choiceControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateInner) {
          return AlertDialog(
            title: const Text('Add Question (Keep Adding)'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: questionType,
                      items: const [
                        DropdownMenuItem(value: 'Multiple Choice', child: Text('Multiple Choice')),
                        DropdownMenuItem(value: 'Identification', child: Text('Identification')),
                        DropdownMenuItem(value: 'Essay', child: Text('Essay')),
                      ],
                      onChanged: (val) {
                        questionType = val!;
                        setStateInner(() {});
                      },
                      decoration: const InputDecoration(labelText: 'Question Type'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: questionTextController,
                      decoration: const InputDecoration(labelText: 'Question Text'),
                    ),
                    if (questionType == 'Multiple Choice') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Choices', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.blue),
                            onPressed: () {
                              setStateInner(() {
                                choiceControllers.add(TextEditingController());
                              });
                            },
                            tooltip: 'Add choice',
                          ),
                        ],
                      ),
                      ...List.generate(choiceControllers.length, (i) {
                        final char = String.fromCharCode(65 + i);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: choiceControllers[i],
                                  decoration: InputDecoration(labelText: 'Choice $char'),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete choice',
                                onPressed: () {
                                  setStateInner(() {
                                    if (choiceControllers.length <= 2) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('At least 2 choices are recommended.')),
                                      );
                                      return;
                                    }
                                    choiceControllers[i].dispose();
                                    choiceControllers.removeAt(i);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      TextField(
                        controller: correctAnswerController,
                        decoration: const InputDecoration(labelText: 'Correct Answer (e.g., A, B, C, D)'),
                        onChanged: (val) => correctAnswerController.text = val.toUpperCase(),
                      ),
                    ],
                    if (questionType == 'Identification') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: identificationAnswerController,
                        decoration: const InputDecoration(labelText: 'Correct Answer'),
                      ),
                    ],
                    if (questionType == 'Essay') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: essayAnswerController,
                        decoration: const InputDecoration(labelText: 'Sample Answer / Rubric'),
                        maxLines: 3,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  questionTextController.dispose();
                  correctAnswerController.dispose();
                  identificationAnswerController.dispose();
                  essayAnswerController.dispose();
                  for (var controller in choiceControllers) {
                    controller.dispose();
                  }
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (questionTextController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter question text')));
                    return;
                  }
                  final Map<String, dynamic> newQuestion = {
                    'text': questionTextController.text,
                    'type': questionType,
                  };

                  if (questionType == 'Multiple Choice') {
                    newQuestion['choices'] = choiceControllers.map((c) => c.text).toList();
                    newQuestion['correctAnswer'] = correctAnswerController.text.toUpperCase();
                  } else if (questionType == 'Identification') {
                    newQuestion['answer'] = identificationAnswerController.text;
                  } else {
                    newQuestion['sampleAnswer'] = essayAnswerController.text;
                  }

                  questions.add(newQuestion);
                  setStateDialog(() {});
                  _saveQuizQuestions(quiz, questions);
                  questionTextController.clear();
                  correctAnswerController.clear();
                  identificationAnswerController.clear();
                  essayAnswerController.clear();
                  for (var controller in choiceControllers) {
                    controller.dispose();
                  }
                  choiceControllers = [
                    TextEditingController(),
                    TextEditingController(),
                    TextEditingController(),
                    TextEditingController(),
                  ];
                  setStateInner(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question added!'), duration: Duration(seconds: 1)),
                  );
                },
                child: const Text('Add Another'),
              ),
              ElevatedButton(
                onPressed: () {
                  questionTextController.dispose();
                  correctAnswerController.dispose();
                  identificationAnswerController.dispose();
                  essayAnswerController.dispose();
                  for (var controller in choiceControllers) {
                    controller.dispose();
                  }
                  _saveQuizQuestions(quiz, questions);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editSingleQuestionDialog(Map<String, dynamic> quiz, List<Map<String, dynamic>> questions, StateSetter setStateDialog, int editIndex) async {
    final q = questions[editIndex];
    String questionType = q['type'];
    String questionText = q['text'];
    List<String> choices = q['type'] == 'Multiple Choice' ? List.from(q['choices']) : ['', '', '', ''];
    String correctAnswer = q['type'] == 'Multiple Choice' ? q['correctAnswer'] : '';
    String identificationAnswer = q['type'] == 'Identification' ? q['answer'] : '';
    String essayAnswer = q['type'] == 'Essay' ? q['sampleAnswer'] : '';
    int choiceCount = choices.length;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateInner) {
          return AlertDialog(
            title: const Text('Edit Question'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: questionType,
                      items: const [
                        DropdownMenuItem(value: 'Multiple Choice', child: Text('Multiple Choice')),
                        DropdownMenuItem(value: 'Identification', child: Text('Identification')),
                        DropdownMenuItem(value: 'Essay', child: Text('Essay')),
                      ],
                      onChanged: (val) {
                        questionType = val!;
                        setStateInner(() {});
                      },
                      decoration: const InputDecoration(labelText: 'Question Type'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Question Text'),
                      controller: TextEditingController(text: questionText),
                      onChanged: (val) => questionText = val,
                    ),
                    if (questionType == 'Multiple Choice') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Choices', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.blue),
                            onPressed: () {
                              setStateInner(() {
                                choices.add('');
                                choiceCount++;
                              });
                            },
                          ),
                        ],
                      ),
                      ...List.generate(choiceCount, (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: TextField(
                          decoration: InputDecoration(labelText: 'Choice ${String.fromCharCode(65 + i)}'),
                          controller: TextEditingController(text: choices[i]),
                          onChanged: (val) => choices[i] = val,
                        ),
                      )),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Correct Answer (e.g., A, B, C, D)'),
                        controller: TextEditingController(text: correctAnswer),
                        onChanged: (val) => correctAnswer = val.toUpperCase(),
                      ),
                    ],
                    if (questionType == 'Identification') ...[
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Correct Answer'),
                        controller: TextEditingController(text: identificationAnswer),
                        onChanged: (val) => identificationAnswer = val,
                      ),
                    ],
                    if (questionType == 'Essay') ...[
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Sample Answer / Rubric'),
                        maxLines: 3,
                        controller: TextEditingController(text: essayAnswer),
                        onChanged: (val) => essayAnswer = val,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (questionText.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter question text')));
                    return;
                  }
                  Map<String, dynamic> updatedQuestion = {
                    'text': questionText,
                    'type': questionType,
                  };
                  if (questionType == 'Multiple Choice') {
                    updatedQuestion['choices'] = choices;
                    updatedQuestion['correctAnswer'] = correctAnswer;
                  } else if (questionType == 'Identification') {
                    updatedQuestion['answer'] = identificationAnswer;
                  } else {
                    updatedQuestion['sampleAnswer'] = essayAnswer;
                  }
                  questions[editIndex] = updatedQuestion;
                  setStateDialog(() {});
                  _saveQuizQuestions(quiz, questions);
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ========== ATTENDANCE ==========
  Future<void> _saveAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_records', jsonEncode(_attendanceRecords));
  }

  Future<void> _createAttendanceRecord() async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    selectedDate = picked;
    final dateKey = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
    if (_attendanceRecords.any((r) => r['date'] == dateKey)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance already exists for this date')));
      return;
    }
    Map<String, String> statuses = {};
    for (var student in _students) {
      statuses[student['id'].toString()] = 'Present';
    }
    setState(() {
      _attendanceRecords.add({
        'date': dateKey,
        'displayDate': "${selectedDate.toLocal()}".split(' ')[0],
        'statuses': statuses,
      });
    });
    await _saveAttendanceRecords();
    _markAttendanceForDate(dateKey);
  }

  void _markAttendanceForDate(String dateKey) {
    final recordIndex = _attendanceRecords.indexWhere((r) => r['date'] == dateKey);
    if (recordIndex == -1) return;
    Map<String, String> currentStatuses = Map.from(_attendanceRecords[recordIndex]['statuses']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.9,
                maxChildSize: 0.9,
                minChildSize: 0.5,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Attendance for $dateKey', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
                            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _students.length,
                          itemBuilder: (ctx, index) {
                            final student = _students[index];
                            final studentId = student['id'].toString();
                            String status = currentStatuses[studentId] ?? 'Present';
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFF0d2b5c).withValues(alpha: 0.1),
                                    child: Text(student['name'][0], style: const TextStyle(color: Color(0xFF0d2b5c), fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(student['name'], style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1a2b4a))),
                                        Text(student['email'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  SegmentedButton<String>(
                                    segments: const [
                                      ButtonSegment(value: 'Present', label: Text('Present'), icon: Icon(Icons.check_circle, size: 16)),
                                      ButtonSegment(value: 'Late', label: Text('Late'), icon: Icon(Icons.access_time, size: 16)),
                                      ButtonSegment(value: 'Absent', label: Text('Absent'), icon: Icon(Icons.cancel, size: 16)),
                                    ],
                                    selected: {status},
                                    onSelectionChanged: (Set<String> newSelection) {
                                      final newStatus = newSelection.first;
                                      setSheetState(() => currentStatuses[studentId] = newStatus);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(WidgetState.selected)) {
                                          if (status == 'Present') return Colors.green.shade50;
                                          if (status == 'Late') return Colors.orange.shade50;
                                          if (status == 'Absent') return Colors.red.shade50;
                                        }
                                        return Colors.grey.shade50;
                                      }),
                                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(WidgetState.selected)) {
                                          if (status == 'Present') return Colors.green;
                                          if (status == 'Late') return Colors.orange;
                                          if (status == 'Absent') return Colors.red;
                                        }
                                        return Colors.grey.shade700;
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() => _attendanceRecords[recordIndex]['statuses'] = currentStatuses);
                                  await _saveAttendanceRecords();
                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance saved!')));
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0d2b5c), foregroundColor: Colors.white),
                                child: const Text('Save Attendance'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _viewAttendanceHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Attendance History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                Expanded(
                  child: _attendanceRecords.isEmpty
                      ? const Center(child: Text('No attendance records yet.'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _attendanceRecords.length,
                          itemBuilder: (context, index) {
                            final record = _attendanceRecords[index];
                            final date = record['displayDate'] ?? record['date'];
                            final statuses = Map<String, String>.from(record['statuses']);
                            int present = statuses.values.where((s) => s == 'Present').length;
                            int late = statuses.values.where((s) => s == 'Late').length;
                            int absent = statuses.values.where((s) => s == 'Absent').length;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () { Navigator.pop(context); _markAttendanceForDate(record['date']); }),
                                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Delete Record'),
                                                content: const Text('Are you sure you want to delete this attendance record?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() => _attendanceRecords.removeAt(index));
                                                      _saveAttendanceRecords();
                                                      Navigator.pop(ctx);
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance record deleted')));
                                                    },
                                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 16,
                                    children: [
                                      Chip(avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green), label: Text('Present: $present'), backgroundColor: Colors.green.shade50),
                                      Chip(avatar: const Icon(Icons.access_time, size: 16, color: Colors.orange), label: Text('Late: $late'), backgroundColor: Colors.orange.shade50),
                                      Chip(avatar: const Icon(Icons.cancel, size: 16, color: Colors.red), label: Text('Absent: $absent'), backgroundColor: Colors.red.shade50),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(onPressed: () { Navigator.pop(context); _markAttendanceForDate(record['date']); }, icon: const Icon(Icons.edit_note), label: const Text('Edit details')),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _generateAttendanceSummary() {
    if (_attendanceRecords.isEmpty) {
      showDialog(context: context, builder: (context) => AlertDialog(title: const Text('No Data'), content: const Text('No attendance records found.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
      return;
    }
    int totalPresent = 0, totalLate = 0, totalAbsent = 0;
    int totalDays = _attendanceRecords.length;
    Map<String, Map<String, dynamic>> studentSummary = {};
    for (var student in _students) {
      studentSummary[student['id'].toString()] = {'name': student['name'], 'present': 0, 'late': 0, 'absent': 0};
    }
    for (var record in _attendanceRecords) {
      Map<String, String> statuses = Map.from(record['statuses']);
      for (var entry in statuses.entries) {
        String studentId = entry.key;
        String status = entry.value;
        var summary = studentSummary[studentId];
        if (summary != null) {
          if (status == 'Present') { summary['present'] = (summary['present'] ?? 0) + 1; totalPresent++; }
          else if (status == 'Late') { summary['late'] = (summary['late'] ?? 0) + 1; totalLate++; }
          else if (status == 'Absent') { summary['absent'] = (summary['absent'] ?? 0) + 1; totalAbsent++; }
        }
      }
    }
    int totalEvents = totalPresent + totalLate + totalAbsent;
    double overallPresentPercent = totalEvents > 0 ? (totalPresent / totalEvents) * 100 : 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Attendance Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))])),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                        child: Padding(padding: const EdgeInsets.all(16), child: Column(
                          children: [
                            const Text('Overall Statistics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(child: _summaryStat('Total Days', totalDays.toString(), Colors.blue)),
                              Expanded(child: _summaryStat('Total Present', totalPresent.toString(), Colors.green)),
                              Expanded(child: _summaryStat('Total Late', totalLate.toString(), Colors.orange)),
                              Expanded(child: _summaryStat('Total Absent', totalAbsent.toString(), Colors.red)),
                            ]),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(value: totalEvents > 0 ? totalPresent / totalEvents : 0, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(Colors.green), minHeight: 8),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Present: ${overallPresentPercent.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.green))]),
                          ],
                        )),
                      ),
                      const SizedBox(height: 16),
                      Card(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                        child: Padding(padding: const EdgeInsets.all(16), child: Column(
                          children: [
                            const Text('Student-wise Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 16,
                                columns: const [DataColumn(label: Text('Student')), DataColumn(label: Text('Present')), DataColumn(label: Text('Late')), DataColumn(label: Text('Absent')), DataColumn(label: Text('Rate'))],
                                rows: studentSummary.values.map((data) {
                                  int present = data['present'], late = data['late'], absent = data['absent'], total = present + late + absent;
                                  double rate = total > 0 ? (present / total) * 100 : 0;
                                  return DataRow(cells: [
                                    DataCell(Text(data['name'], style: const TextStyle(fontWeight: FontWeight.w500))),
                                    DataCell(Text(present.toString(), style: const TextStyle(color: Colors.green))),
                                    DataCell(Text(late.toString(), style: const TextStyle(color: Colors.orange))),
                                    DataCell(Text(absent.toString(), style: const TextStyle(color: Colors.red))),
                                    DataCell(Text('${rate.toStringAsFixed(1)}%', style: TextStyle(color: rate >= 85 ? Colors.green : rate >= 75 ? Colors.orange : Colors.red, fontWeight: FontWeight.w600))),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _summaryStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  // ========== FILE VIEW & DOWNLOAD ==========
  Future<void> _viewMaterial(String filePath, String title) async {
    if (filePath.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No file associated.')));
      return;
    }
    final file = File(filePath);
    if (!await file.exists()) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File not found.')));
      return;
    }
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open file: ${result.message}')));
    }
  }

  Future<void> _downloadMaterialToDevice(String sourcePath, String fileName) async {
    if (sourcePath.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No file to download.')));
      return;
    }
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Storage permission required.')));
        return;
      }
    }
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Source file not found.')));
      return;
    }
    Directory destDir;
    if (Platform.isAndroid) {
      destDir = Directory('/storage/emulated/0/Download');
      if (!await destDir.exists()) destDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    } else {
      destDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    }
    final destFile = File('${destDir.path}/$fileName');
    try {
      await sourceFile.copy(destFile.path);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded to ${destFile.path}')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  void _downloadMaterial(String id, String title) {
    final material = _materials.firstWhere((m) => m['id'].toString() == id);
    final filePath = material['file_url'] ?? '';
    final fileName = material['title'] ?? 'document';
    _downloadMaterialToDevice(filePath, fileName);
  }

  void _showMaterialDetails(String title, String subject, String date, String id) {
    final material = _materials.firstWhere((m) => m['id'].toString() == id);
    final filePath = material['file_url'] ?? '';
    _viewMaterial(filePath, title);
  }

  void _showEditMaterialDialog(String id, String title, String subject, String format) {
    final titleController = TextEditingController(text: title);
    final subjectController = TextEditingController(text: subject);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Learning Material'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit not yet implemented via API')));
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteMaterial(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Learning Material'),
        content: const Text('Are you sure you want to delete this material?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete not yet implemented via API')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ========== ANNOUNCEMENTS API ==========
  Future<void> _createAnnouncement(String title, String content, String color) async {
    try {
      final response = await _api.post('announcements.php', {
        'action': 'create',
        'title': title,
        'content': content,
        'color': color,
        'author_id': _authService.currentUserId ?? 0,
      });
      if (response['success'] == true) {
        await _loadAnnouncements();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement posted!')));
        }
      } else {
        throw Exception(response['message'] ?? 'Failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteAnnouncementById(int id) async {
    try {
      final response = await _api.post('announcements.php', {
        'action': 'delete',
        'id': id,
      });
      if (response['success'] == true) {
        await _loadAnnouncements();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement deleted!')));
        }
      } else {
        throw Exception(response['message'] ?? 'Failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAddAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedColor = 'blue';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: 3),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedColor,
                decoration: const InputDecoration(labelText: 'Color Category'),
                items: const [
                  DropdownMenuItem(value: 'blue', child: Text('Blue - General')),
                  DropdownMenuItem(value: 'green', child: Text('Green - Success')),
                  DropdownMenuItem(value: 'orange', child: Text('Orange - Important')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedColor = value ?? 'blue';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  Navigator.pop(context);
                  await _createAnnouncement(titleController.text, contentController.text, selectedColor);
                }
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== MATERIALS API ==========
  Future<void> _addUploadedMaterial(UploadedMaterial uploadedMaterial) async {
    final fileExtension = uploadedMaterial.fileName.split('.').last.toUpperCase();
    String? localPath;

    if (!kIsWeb && uploadedMaterial.fileBytes != null && uploadedMaterial.fileBytes!.isNotEmpty) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${uploadedMaterial.fileName}');
        await file.writeAsBytes(uploadedMaterial.fileBytes!);
        localPath = file.path;
      } catch (e) {
        print('Error saving file: $e');
      }
    } else if (uploadedMaterial.fileUrl != null && uploadedMaterial.fileUrl!.isNotEmpty) {
      localPath = uploadedMaterial.fileUrl;
    }

    final newMaterial = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': uploadedMaterial.title,
      'subject': uploadedMaterial.subject,
      'date': DateTime.now().toString().split(' ')[0],
      'format': fileExtension,
      'filePath': localPath ?? '',
      'fileUrl': uploadedMaterial.fileUrl,
    };
    setState(() {
      _materials.insert(0, newMaterial);
    });

    try {
      final response = await _api.post('materials.php', {
        'action': 'create',
        'title': uploadedMaterial.title,
        'subject': uploadedMaterial.subject,
        'type': fileExtension,
        'file_url': localPath ?? '',
        'uploaded_by': _authService.currentUserId ?? 0,
      });
      if (response['success'] != true) {
        print('API save failed: ${response['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Database save failed: ${response['message']}'), backgroundColor: Colors.red),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${uploadedMaterial.title} added to Lesson Plans!')),
          );
        }
      }
    } catch (e) {
      print('API error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ========== ASSIGNMENTS API ==========
  Future<void> _createAssignment(String title, String description, String deadline, String subject) async {
    try {
      final response = await _api.post('assignments.php', {
        'title': title,
        'description': description,
        'deadline': deadline,
        'subject': subject,
      });
      if (response['success'] == true) {
        await _loadAssignments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignment created!')));
        }
      } else {
        throw Exception(response['message'] ?? 'Creation failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteAssignmentById(int id) async {
    try {
      final response = await _api.post('assignments.php', {
        'action': 'delete',
        'id': id,
      });
      if (response['success'] == true) {
        await _loadAssignments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignment deleted!')));
        }
      } else {
        throw Exception(response['message'] ?? 'Delete failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showCreateAssignmentDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDateTime;

    final List<String> subjects = [
      'Mathematics',
      'Science',
      'English',
      'Filipino',
      'AP',
      'ESP',
      'TLE',
      'MAPEH'
    ];
    String selectedSubject = 'Mathematics';

    Future<void> selectDateTime() async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030),
      );
      if (pickedDate != null) {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 23, minute: 59),
        );
        if (pickedTime != null) {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Create New Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Assignment Title', hintText: 'e.g., Chapter 5 Exercises'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedSubject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: subjects.map((subject) => DropdownMenuItem(value: subject, child: Text(subject))).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedSubject = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', hintText: 'Enter assignment details...'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Deadline'),
                  subtitle: Text(selectedDateTime == null ? 'Not set' : selectedDateTime!.toLocal().toString()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    await selectDateTime();
                    setStateDialog(() {});
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && selectedDateTime != null) {
                  Navigator.pop(context);
                  await _createAssignment(
                    titleController.text,
                    descriptionController.text,
                    selectedDateTime!.toIso8601String(),
                    selectedSubject,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in title and deadline')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== LOGOUT ==========
  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    }
  }

  int _getPendingSubmissionsCount() {
    return _submissions.where((s) => s['status'] == 'Pending').length;
  }

  String _getDisplayDate(Map<String, dynamic> material) {
    String rawDate = material['created_at']?.toString() ?? material['date']?.toString() ?? '';
    if (rawDate.isEmpty) return 'No date';
    if (rawDate.contains(' ')) return rawDate.split(' ')[0];
    if (rawDate.contains('T')) return rawDate.split('T')[0];
    return rawDate;
  }

  // ========== BUILD UI ==========
  @override
  Widget build(BuildContext context) {
    _isMobile = MediaQuery.of(context).size.width < 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _isMobile ? _buildMobileAppBar() : null,
      drawer: _isMobile ? _buildDrawer() : null,
      body: Row(
        children: [
          if (!_isMobile) _buildSidebar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0d2b5c),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/capstonelogo.png', width: 32, height: 32),
          const SizedBox(width: 12),
          const Text('Teacher Portal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle, size: 28),
          onSelected: (value) {
            if (value == 'change_password') {
              Navigator.pushNamed(context, '/change-password');
            } else if (value == 'logout') {
              _logout();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_authService.currentUserName ?? 'Teacher', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(_authService.currentUserEmail ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'change_password', child: Row(children: [Icon(Icons.lock_outline, size: 18), SizedBox(width: 8), Text('Change Password')])),
            const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, size: 18, color: Colors.red), SizedBox(width: 8), Text('Logout', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0d2b5c)),
            child: Row(children: [Image.asset('assets/capstonelogo.png', width: 40, height: 40), const SizedBox(width: 12), const Text('Teacher Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18))]),
          ),
          _drawerItem(Icons.dashboard_outlined, 'Overview', 0),
          _drawerItem(Icons.people_outline, 'Students', 1),
          _drawerItem(Icons.upload_file_outlined, 'Lesson Plans', 2),
          _drawerItem(Icons.assignment_outlined, 'Assignments', 3),
          _drawerItem(Icons.calendar_today_outlined, 'Attendance', 4),
          _drawerItem(Icons.announcement_outlined, 'Announcements', 5),
          _drawerItem(Icons.quiz_outlined, 'Quizzes', 6),
          const Spacer(),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)), onTap: _logout),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade600),
      title: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
      tileColor: isSelected ? const Color(0xFF0d2b5c).withValues(alpha: 0.08) : null,
      onTap: () { setState(() => _selectedIndex = index); Navigator.pop(context); },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Image.asset('assets/capstonelogo.png', width: 40, height: 40), const SizedBox(width: 12), const Text('Teacher Portal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1a2b4a)))])),
          const SizedBox(height: 24),
          _sidebarItem(Icons.dashboard_outlined, 'Overview', 0),
          _sidebarItem(Icons.people_outline, 'Students', 1),
          _sidebarItem(Icons.upload_file_outlined, 'Lesson Plans', 2),
          _sidebarItem(Icons.assignment_outlined, 'Assignments', 3),
          _sidebarItem(Icons.calendar_today_outlined, 'Attendance', 4),
          _sidebarItem(Icons.announcement_outlined, 'Announcements', 5),
          _sidebarItem(Icons.quiz_outlined, 'Quizzes', 6),
          const Spacer(),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)), onTap: _logout),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade600),
      title: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
      tileColor: isSelected ? const Color(0xFF0d2b5c).withValues(alpha: 0.08) : null,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return _buildOverview();
      case 1: return _buildStudentList();
      case 2: return _buildLessonPlans();
      case 3: return _buildAssignments();
      case 4: return _buildAttendance();
      case 5: return _buildAnnouncements();
      case 6: return _buildQuizzes();
      default: return _buildOverview();
    }
  }

  // ==================== OVERVIEW ====================
  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0d2b5c), Color(0xFF1a5276)]), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Welcome, ${_authService.currentUserName ?? 'Teacher'}!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 8), Text('Manage your classes and track student progress.', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14))])),
                Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 30)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _statCard('Total Students', '${_students.length}', 'Enrolled', Colors.blue, Icons.people),
                _statCard('Assignments', '${_assignments.length}', 'Created', Colors.green, Icons.assignment),
                _statCard('Pending Review', '${_getPendingSubmissionsCount()}', 'Submissions', Colors.orange, Icons.assignment_turned_in),
                _statCard('Lesson Plans', '${_materials.length}', 'Uploaded', const Color(0xFF0d2b5c), Icons.book),
              ],
            );
          }),
          const SizedBox(height: 24),
          Row(children: [Expanded(child: _buildClassOverview()), const SizedBox(width: 16), Expanded(child: _buildRecentActivity())]),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: _buildAttendanceSummary()), const SizedBox(width: 16), Expanded(child: _buildAnnouncementsPreview())]),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(subtitle, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)))]),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildClassOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Class Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
          const SizedBox(height: 16),
          _classStat('Average Grade', '84%', Colors.blue, 0.84),
          const SizedBox(height: 12),
          _classStat('Attendance Rate', '92%', Colors.green, 0.92),
          const SizedBox(height: 12),
          _classStat('Assignment Completion', '78%', Colors.orange, 0.78),
        ],
      ),
    );
  }

  Widget _classStat(String label, String value, Color color, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF1a2b4a))), Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color))]),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(color), borderRadius: BorderRadius.circular(4), minHeight: 6),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
          const SizedBox(height: 12),
          _activityItem('Pending Submissions', '${_getPendingSubmissionsCount()} to review', 'Now', Colors.orange),
          const Divider(),
          _activityItem('Uploaded Lesson Plan', _materials.isNotEmpty ? _materials.first['title'] : 'None', 'Recently', Colors.green),
          const Divider(),
          _activityItem('Created Assignment', _assignments.isNotEmpty ? _assignments.first['title'] : 'None', 'Recently', Colors.blue),
        ],
      ),
    );
  }

  Widget _activityItem(String action, String detail, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(action, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1a2b4a))), Text(detail, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))])),
          Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    final todayKey = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    Map<String, String> todayStatuses = {};
    final todayRecord = _attendanceRecords.firstWhere((r) => r['date'] == todayKey, orElse: () => {});
    if (todayRecord.isNotEmpty) {
      todayStatuses = Map<String, String>.from(todayRecord['statuses'] ?? {});
    }
    int present = todayStatuses.values.where((s) => s == 'Present').length;
    int late = todayStatuses.values.where((s) => s == 'Late').length;
    int absent = todayStatuses.values.where((s) => s == 'Absent').length;
    int total = present + late + absent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today\'s Attendance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: _attendanceStat(present.toString(), 'Present', Colors.green)), Expanded(child: _attendanceStat(late.toString(), 'Late', Colors.orange)), Expanded(child: _attendanceStat(absent.toString(), 'Absent', Colors.red))]),
          const SizedBox(height: 12),
          if (total > 0)
            Text('${((present / total) * 100).toStringAsFixed(1)}% attendance rate', style: TextStyle(color: Colors.grey.shade600, fontSize: 12))
          else
            Text('No attendance marked yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() => _selectedIndex = 5), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0d2b5c), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0), child: const Text('Take Attendance', style: TextStyle(fontSize: 13)))),
        ],
      ),
    );
  }

  Widget _attendanceStat(String value, String label, Color color) {
    return Column(children: [Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)), Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))]);
  }

  Widget _buildAnnouncementsPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Announcements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))), TextButton(onPressed: () => setState(() => _selectedIndex = 6), child: const Text('Manage', style: TextStyle(color: Color(0xFF007bff), fontSize: 12)))]),
          const SizedBox(height: 12),
          ..._announcements.take(3).map((a) => _announcementPreviewItem(a['title'], a['created_at']?.toString().split(' ')[0] ?? 'Recently', false)),
        ],
      ),
    );
  }

  Widget _announcementPreviewItem(String title, String date, bool isNew) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (isNew) Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 8), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)) else const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1a2b4a)))),
          Text(date, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }

  // ==================== STUDENT LIST ====================
  Widget _buildStudentList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student List', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children: [Icon(Icons.search, color: Colors.grey.shade400, size: 20), const SizedBox(width: 12), const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Search students...', border: InputBorder.none)))])),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: _students.isEmpty
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No students found')))
                : Column(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))), child: Row(children: [Expanded(flex: 2, child: Text('Student Name', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade700))), Expanded(child: Text('Email', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade700)))])),
                    ..._students.map((student) => _studentRow(student)),
                  ]),
          ),
        ],
      ),
    );
  }

  Widget _studentRow(Map<String, dynamic> student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Row(children: [CircleAvatar(radius: 16, backgroundColor: const Color(0xFF0d2b5c).withValues(alpha: 0.1), child: Text(student['name'][0], style: const TextStyle(color: Color(0xFF0d2b5c), fontWeight: FontWeight.w700, fontSize: 12))), const SizedBox(width: 12), Text(student['name'], style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1a2b4a)))])),
          Expanded(child: Text(student['email'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
        ],
      ),
    );
  }

  // ==================== ASSIGNMENTS ====================
Widget _buildAssignments() {
  final pendingCount = _getPendingSubmissionsCount();
  return SingleChildScrollView(
    padding: EdgeInsets.all(_isMobile ? 16 : 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Assignments', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Create and manage assignments for students', style: TextStyle(color: Colors.grey.shade600)),
          ]),
          Row(children: [
            // ✅ Changed to OutlinedButton – matches Attendance "History" button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TeacherReviewPage()))
                    .then((_) => _loadSubmissions());
              },
              icon: const Icon(Icons.assignment_turned_in, size: 18),
              label: pendingCount > 0 ? Text('Review ($pendingCount)') : const Text('View Submissions'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0d2b5c),
                side: const BorderSide(color: Color(0xFF0d2b5c)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            // ✅ Solid button – same as Attendance "Create Record"
            ElevatedButton.icon(
              onPressed: _showCreateAssignmentDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Assignment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0d2b5c),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ]),
        ]),
        const SizedBox(height: 24),
        if (_assignments.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No assignments created yet')))
        else
          for (var a in _assignments) _assignmentCard(a),
      ],
    ),
  );
}

  Widget _assignmentCard(Map<String, dynamic> assignment) {
    final String id = assignment['id']?.toString() ?? '';
    final String title = assignment['title'] ?? 'Untitled';
    final String subject = assignment['subject'] ?? 'No Subject';
    final String description = assignment['description'] ?? 'No description';
    final String deadline = assignment['deadline'] ?? 'No deadline';
    final submissionCount = _submissions.where((s) => s['assignment_id'].toString() == id).length;
    final pendingForThis = _submissions.where((s) => s['assignment_id'].toString() == id && s['status'] == 'Pending').length;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))), const SizedBox(height: 4), Text(subject, style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600))])),
            Row(children: [
              if (submissionCount > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: pendingForThis > 0 ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text('$submissionCount submission${submissionCount != 1 ? 's' : ''}', style: TextStyle(color: pendingForThis > 0 ? Colors.orange : Colors.green, fontSize: 11, fontWeight: FontWeight.w700))),
              const SizedBox(width: 12),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700))),
            ]),
          ]),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.orange), const SizedBox(width: 8), Text('Deadline: $deadline', style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [OutlinedButton.icon(onPressed: () => _deleteAssignmentById(int.parse(id)), icon: const Icon(Icons.delete, size: 16), label: const Text('Delete'), style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))]),
        ],
      ),
    );
  }

  // ==================== LESSON PLANS ====================
  Widget _buildLessonPlans() {
    String searchQuery = '';
    String selectedSubject = 'All';
    List<String> subjects = ['All', 'AP', 'ESP', 'TLE', 'Mathematics', 'Science', 'Filipino', 'English', 'MAPEH'];
    List<Map<String, dynamic>> getFilteredMaterials() {
      return _materials.where((material) {
        bool matchesSearch = searchQuery.isEmpty || material['title'].toLowerCase().contains(searchQuery.toLowerCase()) || material['subject'].toLowerCase().contains(searchQuery.toLowerCase());
        bool matchesSubject = selectedSubject == 'All' || material['subject'] == selectedSubject;
        return matchesSearch && matchesSubject;
      }).toList();
    }
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(_isMobile ? 16 : 24, 0, _isMobile ? 16 : 24, _isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: _isMobile ? 16 : 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: TextField(
                        onChanged: (value) => setState(() => searchQuery = value),
                        decoration: InputDecoration(hintText: 'Search lesson plans...', hintStyle: TextStyle(color: Colors.grey.shade400), prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadMaterialPage())).then((uploadedMaterial) {
                        if (uploadedMaterial is UploadedMaterial) _addUploadedMaterial(uploadedMaterial);
                      });
                    },
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Upload File'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0d2b5c), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: subjects.map((subject) {
                    final bool isSelected = selectedSubject == subject;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(subject),
                        selected: isSelected,
                        onSelected: (_) => setState(() => selectedSubject = subject),
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF0d2b5c),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                        side: BorderSide(color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade300),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Text('${getFilteredMaterials().length} materials found', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 16),
              getFilteredMaterials().isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Column(children: [Icon(Icons.folder_open, size: 64, color: Colors.grey), SizedBox(height: 16), Text('No materials found')])))
                  : Wrap(spacing: 16, runSpacing: 16, children: getFilteredMaterials().map((material) => _lessonPlanCard(material)).toList()),
            ],
          ),
        );
      },
    );
  }

  Widget _lessonPlanCard(Map<String, dynamic> material) {
    final String id = material['id']?.toString() ?? '';
    final String title = material['title'] ?? 'Untitled';
    final String subject = material['subject'] ?? 'No Subject';
    final String format = material['type'] ?? 'PDF';
    final String filePath = material['file_url'] ?? '';
    final String displayDate = _getDisplayDate(material);

    Color getFormatColor(String f) {
      switch (f.toUpperCase()) {
        case 'PDF': return Colors.red;
        case 'DOCX': return Colors.blue;
        case 'PPTX': return Colors.orange;
        default: return Colors.grey;
      }
    }

    return Container(
      width: _isMobile ? double.infinity : 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: getFormatColor(format).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text(format.toUpperCase(), style: TextStyle(color: getFormatColor(format), fontSize: 11, fontWeight: FontWeight.bold))),
            const Spacer(),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditMaterialDialog(id, title, subject, format);
                } else if (value == 'delete') {
                  _deleteMaterial(id);
                } else if (value == 'download') {
                  _downloadMaterial(id, title);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem(value: 'download', child: Row(children: [Icon(Icons.download, size: 18), SizedBox(width: 8), Text('Download')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ]),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1a2b4a))),
          const SizedBox(height: 6),
          Text(subject, style: TextStyle(color: getFormatColor(format), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500), const SizedBox(width: 6), Text(displayDate, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _showMaterialDetails(title, subject, displayDate, id), icon: const Icon(Icons.visibility, size: 16), label: const Text('View', style: TextStyle(fontSize: 13)), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0d2b5c), side: const BorderSide(color: Color(0xFF0d2b5c)), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(onPressed: () => _downloadMaterial(id, title), icon: const Icon(Icons.download, size: 16), label: const Text('Download', style: TextStyle(fontSize: 13)), style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade700, side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
          ]),
        ],
      ),
    );
  }

  // ==================== ATTENDANCE UI ====================
  Widget _buildAttendance() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Attendance Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
              Row(
                children: [
                  ElevatedButton.icon(onPressed: _createAttendanceRecord, icon: const Icon(Icons.add, size: 18), label: const Text('Create Record'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0d2b5c), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(onPressed: _viewAttendanceHistory, icon: const Icon(Icons.history, size: 18), label: const Text('History'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0d2b5c), side: const BorderSide(color: Color(0xFF0d2b5c)))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Mark Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final todayKey = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
                        final exists = _attendanceRecords.any((r) => r['date'] == todayKey);
                        if (!exists) {
                          await _createAttendanceRecord();
                        } else {
                          _markAttendanceForDate(todayKey);
                        }
                      },
                      icon: const Icon(Icons.edit_calendar),
                      label: Text(_attendanceRecords.any((r) => r['date'] == "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}") ? 'Edit Today\'s Attendance' : 'Mark Today\'s Attendance'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0d2b5c), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Recent Records', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  if (_attendanceRecords.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text('No attendance records yet')))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _attendanceRecords.length > 3 ? 3 : _attendanceRecords.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final record = _attendanceRecords.reversed.toList()[index];
                        final date = record['displayDate'] ?? record['date'];
                        final statuses = Map<String, String>.from(record['statuses']);
                        int present = statuses.values.where((s) => s == 'Present').length;
                        int late = statuses.values.where((s) => s == 'Late').length;
                        int absent = statuses.values.where((s) => s == 'Absent').length;
                        return ListTile(
                          leading: const Icon(Icons.calendar_today, color: Color(0xFF0d2b5c)),
                          title: Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('P: $present  L: $late  A: $absent'),
                          trailing: IconButton(icon: const Icon(Icons.edit, color: Color(0xFF0d2b5c)), onPressed: () => _markAttendanceForDate(record['date'])),
                        );
                      },
                    ),
                  if (_attendanceRecords.length > 3) TextButton(onPressed: _viewAttendanceHistory, child: const Text('View all records →')),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(onPressed: _generateAttendanceSummary, icon: const Icon(Icons.summarize), label: const Text('Generate Attendance Summary'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0d2b5c), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ANNOUNCEMENTS ====================
  Widget _buildAnnouncements() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Announcements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _showAddAnnouncementDialog,
               icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Assignment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d2b5c),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
          ]),
          const SizedBox(height: 24),
          if (_announcements.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('No announcements yet. Create one to get started!', style: TextStyle(color: Colors.grey))),
            )
          else
            for (var announcement in _announcements) _teacherAnnouncementCard(announcement),
        ],
      ),
    );
  }

  Widget _teacherAnnouncementCard(Map<String, dynamic> announcement) {
    final id = announcement['id'];
    final title = announcement['title'];
    final content = announcement['content'];
    final date = announcement['created_at']?.toString().split(' ')[0] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.announcement, color: Colors.blue, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1a2b4a))),
                    const SizedBox(height: 4),
                    Text(date, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF94A3B8)),
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteAnnouncementById(id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  // ==================== QUIZZES ====================
  Widget _buildQuizzes() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Quizzes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
              ElevatedButton.icon(onPressed: _createQuiz, icon: const Icon(Icons.add), label: const Text('Create Quiz'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0d2b5c), foregroundColor: Colors.white)),
            ],
          ),
          const SizedBox(height: 24),
          if (_quizzes.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('No quizzes created yet.')),
            )
          else
            for (var quiz in _quizzes)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(quiz['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${quiz['questions'].length} questions'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(quiz['description'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
                          const SizedBox(height: 12),
                          ...List.generate(quiz['questions'].length, (idx) {
                            final q = quiz['questions'][idx];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${idx+1}. ${q['text']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  if (q['type'] == 'Multiple Choice')
                                    ...List.generate(q['choices'].length, (i) => Text('   ${String.fromCharCode(65 + i)}. ${q['choices'][i]}')),
                                  if (q['type'] == 'Identification')
                                    Text('Answer: ${q['answer']}', style: TextStyle(color: Colors.green.shade700)),
                                  if (q['type'] == 'Essay')
                                    Text('Sample: ${q['sampleAnswer']}', style: TextStyle(color: Colors.blue.shade700)),
                                  const Divider(),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(onPressed: () => _editQuizQuestions(quiz), icon: const Icon(Icons.edit), label: const Text('Edit Questions')),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Quiz'),
                                    content: Text('Are you sure you want to delete "${quiz['title']}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() => _quizzes.removeWhere((q) => q['id'] == quiz['id']));
                                          _saveQuizzes();
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz deleted')));
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ),
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text('Delete Quiz', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}