  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'dart:convert';
  import 'dart:math';
  import '../pages/upload_material_page.dart';
  import '../pages/uploaded_material.dart';
  import '/security_service/auth_service.dart';
  import '/pages/teacher_review_page.dart';

  class TeacherDashboardPage extends StatefulWidget {
    const TeacherDashboardPage({super.key});

    @override
    State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
  }

  class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
    final _authService = AuthService();
    int _selectedIndex = 0;
    bool _isMobile = false;

    List<Map<String, dynamic>> _students = [];
    List<Map<String, dynamic>> _announcements = [];
    List<Map<String, dynamic>> _materials = [];
    List<Map<String, dynamic>> _assignments = [];
    List<Map<String, dynamic>> _submissions = [];
    
    // NEW: Attendance records
    List<Map<String, dynamic>> _attendanceRecords = [];

    @override
    void initState() {
      super.initState();
      _loadData();
    }

    Future<void> _loadData() async {
      final prefs = await SharedPreferences.getInstance();

      final studentsJson = prefs.getString('teacher_students');
      if (studentsJson != null) {
        _students = List<Map<String, dynamic>>.from(jsonDecode(studentsJson));
      } else {
        _students = [
          {'name': 'Juan Dela Cruz', 'id': '2024-0001', 'grade': 'Grade 10-A', 'avg': '92%', 'attendance': '95%'},
          {'name': 'Maria Santos', 'id': '2024-0002', 'grade': 'Grade 10-A', 'avg': '95%', 'attendance': '98%'},
          {'name': 'Pedro Reyes', 'id': '2024-0003', 'grade': 'Grade 10-A', 'avg': '78%', 'attendance': '85%'},
          {'name': 'Ana Garcia', 'id': '2024-0004', 'grade': 'Grade 10-A', 'avg': '88%', 'attendance': '92%'},
          {'name': 'Jose Lim', 'id': '2024-0005', 'grade': 'Grade 10-A', 'avg': '85%', 'attendance': '90%'},
          {'name': 'Carmen Tan', 'id': '2024-0006', 'grade': 'Grade 10-A', 'avg': '91%', 'attendance': '96%'},
          {'name': 'Miguel Cruz', 'id': '2024-0007', 'grade': 'Grade 10-A', 'avg': '73%', 'attendance': '80%'},
          {'name': 'Sofia Reyes', 'id': '2024-0008', 'grade': 'Grade 10-A', 'avg': '96%', 'attendance': '100%'},
        ];
        await _saveStudents();
      }

      final announcementsJson = prefs.getString('teacher_announcements');
      if (announcementsJson != null) {
        _announcements = List<Map<String, dynamic>>.from(jsonDecode(announcementsJson));
      } else {
        _announcements = [
          {'title': 'Midterm Exam Schedule', 'content': 'The midterm examination will be held on November 15-20, 2024.', 'date': 'Oct 25, 2024', 'color': 'blue', 'isNew': true, 'views': 42},
          {'title': 'Science Fair 2024', 'content': 'Join us for the annual Science Fair on November 10, 2024.', 'date': 'Oct 24, 2024', 'color': 'green', 'isNew': true, 'views': 38},
          {'title': 'Semestral Break Notice', 'content': 'Classes will be suspended from October 28 to November 3.', 'date': 'Oct 20, 2024', 'color': 'orange', 'isNew': false, 'views': 42},
        ];
        await _saveAnnouncements();
      }

      final materialsJson = prefs.getString('teacher_materials');
      if (materialsJson != null) {
        _materials = List<Map<String, dynamic>>.from(jsonDecode(materialsJson));
      } else {
        _materials = [
          {'id': '1', 'title': 'Quadratic Equations', 'subject': 'Mathematics', 'grade': 'Grade 10', 'date': 'Oct 25, 2024', 'format': 'PDF'},
          {'id': '2', 'title': 'Cell Division', 'subject': 'Science', 'grade': 'Grade 10', 'date': 'Oct 28, 2024', 'format': 'PDF'},
          {'id': '3', 'title': 'Philippine Literature', 'subject': 'Filipino', 'grade': 'Grade 10', 'date': 'Nov 2, 2024', 'format': 'DOCX'},
        ];
        await _saveMaterials();
      }

      final assignmentsJson = prefs.getString('student_assignments');
      if (assignmentsJson != null) {
        _assignments = List<Map<String, dynamic>>.from(jsonDecode(assignmentsJson));
      } else {
        _assignments = [
          {'id': '1', 'title': 'Math Homework', 'description': 'Complete problems 1-20 on page 42.', 'deadline': 'May 30, 2026', 'subject': 'Mathematics', 'status': 'Active'},
          {'id': '2', 'title': 'Science Project', 'description': 'Build a simple volcano model and write a short report.', 'deadline': 'June 2, 2026', 'subject': 'Science', 'status': 'Active'},
          {'id': '3', 'title': 'English Essay', 'description': 'Write a 300-word essay on your favorite book.', 'deadline': 'June 5, 2026', 'subject': 'English', 'status': 'Active'},
          {'id': '4', 'title': 'History Timeline', 'description': 'Create a timeline of World War II events.', 'deadline': 'June 8, 2026', 'subject': 'History', 'status': 'Active'},
        ];
        await _saveAssignments();
      }

      final submissionsJson = prefs.getString('all_submissions');
      if (submissionsJson != null) {
        _submissions = List<Map<String, dynamic>>.from(jsonDecode(submissionsJson));
      } else {
        _submissions = [];
      }

      // Load attendance records
      final attendanceJson = prefs.getString('attendance_records');
      if (attendanceJson != null) {
        _attendanceRecords = List<Map<String, dynamic>>.from(jsonDecode(attendanceJson));
      } else {
        _attendanceRecords = [];
      }
    }

    Future<void> _saveMaterials() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teacher_materials', jsonEncode(_materials));
    }

    Future<void> _saveAssignments() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('student_assignments', jsonEncode(_assignments));
    }

    Future<void> _saveStudents() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teacher_students', jsonEncode(_students));
    }

    Future<void> _saveAnnouncements() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teacher_announcements', jsonEncode(_announcements));
    }

    Future<void> _saveAttendanceRecords() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('attendance_records', jsonEncode(_attendanceRecords));
    }

    Future<void> _logout() async {
      try {
        await _authService.logout();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: $e')),
          );
        }
      }
    }

    int _getPendingSubmissionsCount() {
      return _submissions.where((s) => s['status'] == 'Pending').length;
    }

    void _showAddStudentDialog() {
      final nameController = TextEditingController();
      final idController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add New Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Juan Dela Cruz', labelText: 'Full Name')),
              const SizedBox(height: 8),
              TextField(controller: idController, decoration: const InputDecoration(hintText: '2024-0009', labelText: 'Student ID')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && idController.text.isNotEmpty) {
                  setState(() {
                    _students.add({
                      'name': nameController.text,
                      'id': idController.text,
                      'grade': 'Grade 10-A',
                      'avg': '${Random().nextInt(25) + 70}%',
                      'attendance': '${Random().nextInt(20) + 80}%',
                    });
                  });
                  _saveStudents();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student added successfully!')));
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }

    void _deleteStudent(int index) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Student'),
          content: Text('Are you sure you want to delete ${_students[index]['name']}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() { _students.removeAt(index); });
                _saveStudents();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deleted!')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    void _showAddAnnouncementDialog() {
      final titleController = TextEditingController();
      final contentController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('New Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Announcement Title', labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: contentController, decoration: const InputDecoration(hintText: 'Enter announcement details...', labelText: 'Content'), maxLines: 3),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  setState(() {
                    _announcements.insert(0, {
                      'title': titleController.text,
                      'content': contentController.text,
                      'date': 'Just now',
                      'color': 'blue',
                      'isNew': true,
                      'views': 0,
                    });
                  });
                  _saveAnnouncements();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement posted!')));
                }
              },
              child: const Text('Post'),
            ),
          ],
        ),
      );
    }

    void _deleteAnnouncement(int index) {
      setState(() { _announcements.removeAt(index); });
      _saveAnnouncements();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement deleted!')));
    }

    void _showCreateAssignmentDialog() {
      final titleController = TextEditingController();
      final descriptionController = TextEditingController();
      final deadlineController = TextEditingController();
      final subjectController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Create New Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Assignment Title', hintText: 'e.g., Chapter 5 Exercises')),
                const SizedBox(height: 12),
                TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject', hintText: 'e.g., Mathematics')),
                const SizedBox(height: 12),
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description', hintText: 'Enter assignment details...'), maxLines: 3),
                const SizedBox(height: 12),
                TextField(controller: deadlineController, decoration: const InputDecoration(labelText: 'Deadline', hintText: 'e.g., Nov 1, 2024')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty && deadlineController.text.isNotEmpty && subjectController.text.isNotEmpty) {
                  final newAssignment = {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'deadline': deadlineController.text,
                    'subject': subjectController.text,
                    'status': 'Active',
                  };
                  setState(() { _assignments.add(newAssignment); });
                  await _saveAssignments();
                  if (mounted) Navigator.pop(context);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignment created successfully!')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );
    }

    void _deleteAssignment(String id) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Assignment'),
          content: const Text('Are you sure you want to delete this assignment?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() { _assignments.removeWhere((a) => a['id'] == id); });
                _saveAssignments();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignment deleted successfully!')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    void _addUploadedMaterial(UploadedMaterial uploadedMaterial) {
      final fileExtension = uploadedMaterial.fileName.split('.').last.toUpperCase();
      setState(() {
        _materials.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': uploadedMaterial.title,
          'subject': uploadedMaterial.subject,
          'grade': 'Grade 10',
          'date': DateTime.now().toString().split(' ')[0],
          'format': fileExtension,
          'fileName': uploadedMaterial.fileName,
        });
      });
      _saveMaterials();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${uploadedMaterial.title} added to Lesson Plans!')));
      }
    }

    void _showEditMaterialDialog(String id, String title, String subject, String format) {
      final titleController = TextEditingController(text: title);
      final subjectController = TextEditingController(text: subject);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Learning Material'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')), const SizedBox(height: 12), TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject'))]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final index = _materials.indexWhere((m) => m['id'] == id);
                  if (index != -1) {
                    _materials[index]['title'] = titleController.text;
                    _materials[index]['subject'] = subjectController.text;
                  }
                });
                _saveMaterials();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material updated successfully!')));
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
                setState(() { _materials.removeWhere((m) => m['id'] == id); });
                _saveMaterials();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material deleted successfully!')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    void _downloadMaterial(String id, String title) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading $title...')),
      );
    }

    void _showMaterialDetails(String title, String subject, String date, String id) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Material Details'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Title: $title', style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8), Text('Subject: $subject'), const SizedBox(height: 8), Text('Date: $date'), const SizedBox(height: 8), Text('ID: $id', style: TextStyle(color: Colors.grey.shade600, fontSize: 12))]),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      );
    }

    // ==================== NEW ATTENDANCE METHODS ====================

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
      final existingIndex = _attendanceRecords.indexWhere((r) => r['date'] == dateKey);
      if (existingIndex != -1) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance record already exists for this date')));
        return;
      }
      
      Map<String, String> statuses = {};
      for (var student in _students) {
        statuses[student['id']] = 'Present';
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
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Attendance for $dateKey', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: _students.length,
                            itemBuilder: (ctx, index) {
                              final student = _students[index];
                              final studentId = student['id'];
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
                                      backgroundColor: const Color(0xFF0d2b5c).withOpacity(0.1),
                                      child: Text(student['name'][0], style: const TextStyle(color: Color(0xFF0d2b5c), fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(student['name'], style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1a2b4a))),
                                          Text(student['id'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
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
                                        setSheetState(() {
                                          currentStatuses[studentId] = newStatus;
                                        });
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
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _attendanceRecords[recordIndex]['statuses'] = currentStatuses;
                                    });
                                    await _saveAttendanceRecords();
                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance saved!')));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0d2b5c),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Save Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Cancel'),
                              ),
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
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Attendance History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _attendanceRecords.isEmpty
                        ? const Center(child: Text('No attendance records yet. Create one!', style: TextStyle(color: Colors.grey)))
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
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1a2b4a))),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _markAttendanceForDate(record['date']);
                                              },
                                              tooltip: 'Edit',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text('Delete Record'),
                                                    content: const Text('Are you sure you want to delete this attendance record?'),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _attendanceRecords.removeAt(index);
                                                          });
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
                                              },
                                              tooltip: 'Delete',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 16,
                                      children: [
                                        Chip(
                                          avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                          label: Text('Present: $present'),
                                          backgroundColor: Colors.green.shade50,
                                        ),
                                        Chip(
                                          avatar: const Icon(Icons.access_time, size: 16, color: Colors.orange),
                                          label: Text('Late: $late'),
                                          backgroundColor: Colors.orange.shade50,
                                        ),
                                        Chip(
                                          avatar: const Icon(Icons.cancel, size: 16, color: Colors.red),
                                          label: Text('Absent: $absent'),
                                          backgroundColor: Colors.red.shade50,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _markAttendanceForDate(record['date']);
                                      },
                                      icon: const Icon(Icons.edit_note, size: 16),
                                      label: const Text('Edit details'),
                                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF0d2b5c)),
                                    ),
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

    // ==================== BUILD METHODS ====================

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
          const SizedBox(width: 16),
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
            _drawerItem(Icons.description_outlined, 'Worksheets', 3),
            _drawerItem(Icons.assignment_outlined, 'Assignments', 4),
            _drawerItem(Icons.grade_outlined, 'Grades', 5),
            _drawerItem(Icons.calendar_today_outlined, 'Attendance', 6),
            _drawerItem(Icons.announcement_outlined, 'Announcements', 7),
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
        tileColor: isSelected ? const Color(0xFF0d2b5c).withOpacity(0.08) : null,
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
            _sidebarItem(Icons.description_outlined, 'Worksheets', 3),
            _sidebarItem(Icons.assignment_outlined, 'Assignments', 4),
            _sidebarItem(Icons.grade_outlined, 'Grades', 5),
            _sidebarItem(Icons.calendar_today_outlined, 'Attendance', 6),
            _sidebarItem(Icons.announcement_outlined, 'Announcements', 7),
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
        tileColor: isSelected ? const Color(0xFF0d2b5c).withOpacity(0.08) : null,
        onTap: () => setState(() => _selectedIndex = index),
      );
    }

    Widget _buildContent() {
      switch (_selectedIndex) {
        case 0: return _buildOverview();
        case 1: return _buildStudentList();
        case 2: return _buildLessonPlans();
        case 3: return _buildWorksheets();
        case 4: return _buildAssignments();
        case 5: return _buildGrades();
        case 6: return _buildAttendance();
        case 7: return _buildAnnouncements();
        default: return _buildOverview();
      }
    }

    // ==================== ORIGINAL METHODS (unchanged) ====================

    Widget _buildOverview() {
      final pendingSubmissions = _getPendingSubmissionsCount();
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
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Welcome, ${_authService.currentUserName ?? 'Teacher'}!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 8), Text('Manage your classes and track student progress.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14))])),
                  Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 30)),
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
                  _statCard('Total Students', '${_students.length}', 'Grade 10-A', Colors.blue, Icons.people),
                  _statCard('Assignments', '${_assignments.length}', 'Total', Colors.green, Icons.assignment),
                  _statCard('Pending Review', '$pendingSubmissions', 'Submissions', Colors.orange, Icons.assignment_turned_in),
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
            Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(subtitle, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)))]),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      );
    }

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
                  ElevatedButton.icon(
                    onPressed: _createAttendanceRecord,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0d2b5c),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _viewAttendanceHistory,
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('History'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0d2b5c),
                      side: const BorderSide(color: Color(0xFF0d2b5c)),
                    ),
                  ),
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
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF0d2b5c)),
                            onPressed: () => _markAttendanceForDate(record['date']),
                          ),
                        );
                      },
                    ),
                  if (_attendanceRecords.length > 3)
                    TextButton(onPressed: _viewAttendanceHistory, child: const Text('View all records →')),
                ],
              ),
            ),
          ),
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
            _activityItem('Uploaded Lesson Plan', 'Science - Cell Biology', '5 hours ago', Colors.green),
            const Divider(),
            _activityItem('Generated Worksheet', 'English - Grammar', 'Yesterday', Colors.blue),
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
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today\'s Attendance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: _attendanceStat('38', 'Present', Colors.green)), Expanded(child: _attendanceStat('3', 'Late', Colors.orange)), Expanded(child: _attendanceStat('1', 'Absent', Colors.red))]),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() => _selectedIndex = 6), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0d2b5c), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0), child: const Text('Take Attendance', style: TextStyle(fontSize: 13)))),
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Announcements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))), TextButton(onPressed: () => setState(() => _selectedIndex = 7), child: const Text('Manage', style: TextStyle(color: Color(0xFF007bff), fontSize: 12)))]),
            const SizedBox(height: 12),
            ..._announcements.take(3).map((a) => _announcementPreviewItem(a['title'], a['date'], a['isNew'] == true)),
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

    Widget _buildStudentList() {
      return SingleChildScrollView(
        padding: EdgeInsets.all(_isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Student List', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))), ElevatedButton.icon(onPressed: _showAddStudentDialog, icon: const Icon(Icons.add, size: 18), label: const Text('Add Student'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0d2b5c), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0))]),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children: [Icon(Icons.search, color: Colors.grey.shade400, size: 20), const SizedBox(width: 12), Expanded(child: TextField(decoration: InputDecoration(hintText: 'Search students...', hintStyle: TextStyle(color: Colors.grey.shade400), border: InputBorder.none, contentPadding: EdgeInsets.zero)))])),
            const SizedBox(height: 16),
            Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))), child: Column(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))), child: Row(children: [Expanded(flex: 2, child: Text('Student Name', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade700, fontSize: 12))), Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade700, fontSize: 12))), if (!_isMobile) Expanded(child: Text('Attendance', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade700, fontSize: 12))), Expanded(child: Text('Average', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade700, fontSize: 12))), const SizedBox(width: 60)])), ...List.generate(_students.length, (index) => _studentRow(index))])),
          ],
        ),
      );
    }

    Widget _studentRow(int index) {
      final student = _students[index];
      final avg = int.parse(student['avg']!.replaceAll('%', ''));
      final color = avg >= 90 ? Colors.green : avg >= 80 ? Colors.blue : avg >= 75 ? Colors.orange : Colors.red;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
        child: Row(
          children: [
            Expanded(flex: 2, child: Row(children: [CircleAvatar(radius: 16, backgroundColor: const Color(0xFF0d2b5c).withOpacity(0.1), child: Text(student['name']![0], style: const TextStyle(color: Color(0xFF0d2b5c), fontWeight: FontWeight.w700, fontSize: 12))), const SizedBox(width: 12), Text(student['name']!, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1a2b4a)))])),
            Expanded(child: Text(student['id']!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
            if (!_isMobile) Expanded(child: Text(student['attendance']!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
            Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(student['avg']!, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)))),
            SizedBox(width: 60, child: IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deleteStudent(index))),
          ],
        ),
      );
    }

    Widget _buildAssignments() {
      final pendingCount = _getPendingSubmissionsCount();
      return SingleChildScrollView(
        padding: EdgeInsets.all(_isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Assignments', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))), const SizedBox(height: 4), Text('Create and manage assignments for students', style: TextStyle(color: Colors.grey.shade600, fontSize: 14))]), Row(children: [ElevatedButton.icon(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const TeacherReviewPage())).then((_) => _loadData()); }, icon: const Icon(Icons.assignment_turned_in, size: 18), label: pendingCount > 0 ? Text('Review ($pendingCount)') : const Text('View Submissions'), style: ElevatedButton.styleFrom(backgroundColor: pendingCount > 0 ? Colors.orange : const Color(0xFF0d2b5c), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))), const SizedBox(width: 12), ElevatedButton.icon(onPressed: _showCreateAssignmentDialog, icon: const Icon(Icons.add, size: 18), label: const Text('Create Assignment'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0d2b5c), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0))])]),
            const SizedBox(height: 24),
            ..._assignments.map((assignment) => _assignmentCard(assignment)),
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
      final submissionCount = _submissions.where((s) => s['assignment_id'] == id).length;
      final pendingForThis = _submissions.where((s) => s['assignment_id'] == id && s['status'] == 'Pending').length;
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))), const SizedBox(height: 4), Text(subject, style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600))])), Row(children: [if (submissionCount > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: pendingForThis > 0 ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text('$submissionCount submission${submissionCount != 1 ? 's' : ''}', style: TextStyle(color: pendingForThis > 0 ? Colors.orange : Colors.green, fontSize: 11, fontWeight: FontWeight.w700))), const SizedBox(width: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text('Active', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700)))])]),
            const SizedBox(height: 12),
            Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
            const SizedBox(height: 12),
            Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.orange), const SizedBox(width: 8), Text('Deadline: $deadline', style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [OutlinedButton.icon(onPressed: () => _deleteAssignment(id), icon: const Icon(Icons.delete, size: 16), label: const Text('Delete'), style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))]),
          ],
        ),
      );
    }

    // ==================== LESSON PLANS PAGE ====================
    Widget _buildLessonPlans() {
      String searchQuery = '';
      String selectedSubject = 'All';
      List<String> subjects = ['All', 'Mathematics', 'Science', 'Filipino', 'English', 'History', 'MAPEH'];
      
      List<Map<String, dynamic>> getFilteredMaterials() {
        return _materials.where((material) {
          bool matchesSearch = searchQuery.isEmpty ||
              material['title'].toLowerCase().contains(searchQuery.toLowerCase()) ||
              material['subject'].toLowerCase().contains(searchQuery.toLowerCase());
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
                          onChanged: (value) { setState(() { searchQuery = value; }); },
                          decoration: InputDecoration(
                            hintText: 'Search lesson plans...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                    onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UploadMaterialPage()),
                        ).then((uploadedMaterial) {
                          if (uploadedMaterial is UploadedMaterial) {
                            _addUploadedMaterial(uploadedMaterial);
                            setState(() {});
                          }
                        });
                      },
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('Upload File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0d2b5c),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
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
                          onSelected: (selected) { setState(() { selectedSubject = subject; }); },
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
                    ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 60), child: Column(children: [Icon(Icons.folder_open, size: 64, color: Colors.grey.shade300), const SizedBox(height: 16), Text('No materials found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16))])))
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
      final String grade = material['grade'] ?? 'Grade 10';
      final String date = material['date'] ?? DateTime.now().toString().split(' ')[0];
      final String format = material['format'] ?? 'PDF';
      
      Color getFormatColor(String format) {
        switch (format.toUpperCase()) {
          case 'PDF': return Colors.red;
          case 'DOCX': return Colors.blue;
          case 'PPTX': return Colors.orange;
          default: return Colors.grey;
        }
      }
      
      return Container(
        width: _isMobile ? double.infinity : 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: getFormatColor(format).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(format.toUpperCase(), style: TextStyle(color: getFormatColor(format), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF64748B)),
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
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1a2b4a))),
            const SizedBox(height: 6),
            Text(subject, style: TextStyle(color: getFormatColor(format), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(date, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.grade, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(grade, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showMaterialDetails(title, subject, date, id),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0d2b5c),
                      side: const BorderSide(color: Color(0xFF0d2b5c)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadMaterial(id, title),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Download', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget _buildWorksheets() {
      return SingleChildScrollView(
        padding: EdgeInsets.all(_isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Worksheets', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Worksheets feature coming soon...', style: TextStyle(color: Colors.grey)))),
          ],
        ),
      );
    }

    Widget _buildGrades() {
      return SingleChildScrollView(
        padding: EdgeInsets.all(_isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grades', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))),
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Grades feature coming soon...', style: TextStyle(color: Colors.grey)))),
          ],
        ),
      );
    }

    // The old _buildAttendance is replaced by the new one above (already provided).
    // This is the new _buildAttendance that we already wrote.
    // (Keep only one _buildAttendance, the one with the attendance UI.)

    Widget _buildAnnouncements() {
      return SingleChildScrollView(
        padding: EdgeInsets.all(_isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Announcements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a2b4a))), ElevatedButton.icon(onPressed: _showAddAnnouncementDialog, icon: const Icon(Icons.add, size: 18), label: const Text('New Announcement'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0d2b5c), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0))]),
            const SizedBox(height: 24),
            ...List.generate(_announcements.length, (index) => _teacherAnnouncementCard(index)),
          ],
        ),
      );
    }

    Widget _teacherAnnouncementCard(int index) {
      final announcement = _announcements[index];
      final color = announcement['color'] == 'blue' ? Colors.blue : announcement['color'] == 'green' ? Colors.green : Colors.orange;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.announcement, color: color, size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(announcement['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1a2b4a))), const SizedBox(height: 4), Text(announcement['date'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12))])), PopupMenuButton<String>(icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF94A3B8)), onSelected: (value) { if (value == 'delete') { _deleteAnnouncement(index); } }, itemBuilder: (context) => [const PopupMenuItem(value: 'edit', child: Text('Edit')), const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red)))])]),
            const SizedBox(height: 12),
            Text(announcement['content'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5)),
          ],
        ),
      );
    }
  }