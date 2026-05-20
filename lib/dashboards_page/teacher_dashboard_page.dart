import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../pages/upload_material_page.dart';
import '../pages/uploaded_material.dart';
import '/security_service/auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load students
    final studentsJson = prefs.getString('teacher_students');
    if (studentsJson != null) {
      _students = List<Map<String, dynamic>>.from(jsonDecode(studentsJson));
    } else {
      
      // Default data from your original code
      _students = [
        {
          'name': 'Juan Dela Cruz',
          'id': '2024-0001',
          'grade': 'Grade 10-A',
          'avg': '92%',
          'attendance': '95%',
        },
        {
          'name': 'Maria Santos',
          'id': '2024-0002',
          'grade': 'Grade 10-A',
          'avg': '95%',
          'attendance': '98%',
        },
        {
          'name': 'Pedro Reyes',
          'id': '2024-0003',
          'grade': 'Grade 10-A',
          'avg': '78%',
          'attendance': '85%',
        },
        {
          'name': 'Ana Garcia',
          'id': '2024-0004',
          'grade': 'Grade 10-A',
          'avg': '88%',
          'attendance': '92%',
        },
        {
          'name': 'Jose Lim',
          'id': '2024-0005',
          'grade': 'Grade 10-A',
          'avg': '85%',
          'attendance': '90%',
        },
        {
          'name': 'Carmen Tan',
          'id': '2024-0006',
          'grade': 'Grade 10-A',
          'avg': '91%',
          'attendance': '96%',
        },
        {
          'name': 'Miguel Cruz',
          'id': '2024-0007',
          'grade': 'Grade 10-A',
          'avg': '73%',
          'attendance': '80%',
        },
        {
          'name': 'Sofia Reyes',
          'id': '2024-0008',
          'grade': 'Grade 10-A',
          'avg': '96%',
          'attendance': '100%',
        },
      ];
      _saveStudents();
    }

    // Load announcements
    final announcementsJson = prefs.getString('teacher_announcements');
    if (announcementsJson != null) {
      _announcements = List<Map<String, dynamic>>.from(
        jsonDecode(announcementsJson),
      );
    } else {
      _announcements = [
        {
          'title': 'Midterm Exam Schedule',
          'content':
              'The midterm examination will be held on November 15-20, 2024. All students must bring their school ID and examination permit. Please review the schedule posted on the bulletin board.',
          'date': 'Oct 25, 2024',
          'color': 'blue',
          'isNew': true,
          'views': 42,
        },
        {
          'title': 'Science Fair 2024',
          'content':
              'Join us for the annual Science Fair on November 10, 2024. Students are encouraged to showcase their innovative projects. Registration deadline is November 5.',
          'date': 'Oct 24, 2024',
          'color': 'green',
          'isNew': true,
          'views': 38,
        },
        {
          'title': 'Semestral Break Notice',
          'content':
              'Classes will be suspended from October 28 to November 3 for the semestral break. Classes will resume on November 4, 2024.',
          'date': 'Oct 20, 2024',
          'color': 'orange',
          'isNew': false,
          'views': 42,
        },
      ];
      _saveAnnouncements();
    }

    // Load materials
    final materialsJson = prefs.getString('teacher_materials');
    if (materialsJson != null) {
      _materials = List<Map<String, dynamic>>.from(jsonDecode(materialsJson));
    } else {
      _materials = [
        {
          'id': '1',
          'title': 'Quadratic Equations',
          'subject': 'Mathematics',
          'grade': 'Grade 10',
          'date': 'Oct 25, 2024',
          'format': 'PDF',
          'color': 'blue',
        },
        {
          'id': '2',
          'title': 'Cell Division',
          'subject': 'Science',
          'grade': 'Grade 10',
          'date': 'Oct 28, 2024',
          'format': 'PDF',
          'color': 'green',
        },
        {
          'id': '3',
          'title': 'Philippine Literature',
          'subject': 'Filipino',
          'grade': 'Grade 10',
          'date': 'Nov 2, 2024',
          'format': 'DOCX',
          'color': 'orange',
        },
      ];
      _saveMaterials();
    }

    // Load assignments
    final assignmentsJson = prefs.getString('teacher_assignments');
    if (assignmentsJson != null) {
      _assignments = List<Map<String, dynamic>>.from(jsonDecode(assignmentsJson));
    } else {
      _assignments = [
        {
          'id': '1',
          'title': 'Chapter 5 Exercises',
          'description': 'Complete all exercises from page 120 to 130',
          'deadline': 'Nov 1, 2024',
          'subject': 'Mathematics',
          'status': 'Active',
        },
        {
          'id': '2',
          'title': 'Research Project',
          'description': 'Write a 5-page research paper on photosynthesis',
          'deadline': 'Nov 5, 2024',
          'subject': 'Science',
          'status': 'Active',
        },
      ];
      _saveAssignments();
    }
  }

  Future<void> _saveMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacher_materials', jsonEncode(_materials));
  }

  Future<void> _saveAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacher_assignments', jsonEncode(_assignments));
  }

  Future<void> _saveStudents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacher_students', jsonEncode(_students));
  }

  Future<void> _saveAnnouncements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacher_announcements', jsonEncode(_announcements));
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

  // ===== FUNCTION 1: ADD STUDENT =====
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
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Juan Dela Cruz',
                labelText: 'Full Name',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                hintText: '2024-0009',
                labelText: 'Student ID',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  idController.text.isNotEmpty) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student added successfully!')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ===== FUNCTION 2: DELETE STUDENT =====
  void _deleteStudent(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(
          'Are you sure you want to delete ${_students[index]['name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _students.removeAt(index);
              });
              _saveStudents();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Student deleted!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ===== FUNCTION 3: ADD ANNOUNCEMENT =====
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
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Announcement Title',
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                hintText: 'Enter announcement details...',
                labelText: 'Content',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Announcement posted!')),
                );
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  // ===== FUNCTION 4: DELETE ANNOUNCEMENT =====
  void _deleteAnnouncement(int index) {
    setState(() {
      _announcements.removeAt(index);
    });
    _saveAnnouncements();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Announcement deleted!')));
  }

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

  // ... (REST OF YOUR ORIGINAL CODE - SAME LANG, HINDI KO BINAGO) ...

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0d2b5c),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/capstonelogo.png', width: 32, height: 32),
          const SizedBox(width: 12),
          const Text(
            'Teacher Portal',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
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
                  Text(
                    _authService.currentUserName ?? 'Teacher',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _authService.currentUserEmail ?? '',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'change_password',
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 18),
                  SizedBox(width: 8),
                  Text('Change Password'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
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
            child: Row(
              children: [
                Image.asset('assets/capstonelogo.png', width: 40, height: 40),
                const SizedBox(width: 12),
                const Text(
                  'Teacher Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
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
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade600,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      tileColor: isSelected ? const Color(0xFF0d2b5c).withOpacity(0.08) : null,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset('assets/capstonelogo.png', width: 40, height: 40),
                const SizedBox(width: 12),
                const Text(
                  'Teacher Portal',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1a2b4a),
                  ),
                ),
              ],
            ),
          ),
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
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            onTap: _logout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade600,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      tileColor: isSelected ? const Color(0xFF0d2b5c).withOpacity(0.08) : null,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildStudentList();
      case 2:
        return _buildLessonPlans();
      case 3:
        return _buildWorksheets();
      case 4:
        return _buildAssignments();
      case 5:
        return _buildGrades();
      case 6:
        return _buildAttendance();
      case 7:
        return _buildAnnouncements();
      default:
        return _buildOverview();
    }
  }

  // ==================== OVERVIEW PANEL (SPRINT 2) ====================
  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0d2b5c), Color(0xFF1a5276)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${_authService.currentUserName ?? 'Teacher'}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your classes and track student progress.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid - Responsive
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _statCard(
                    'Total Students',
                    '${_students.length}',
                    'Grade 10-A',
                    Colors.blue,
                    Icons.people,
                  ),
                  _statCard(
                    'Lesson Plans',
                    '8',
                    'This week',
                    Colors.green,
                    Icons.book,
                  ),
                  _statCard(
                    'Worksheets',
                    '12',
                    'Generated',
                    Colors.orange,
                    Icons.description,
                  ),
                  _statCard(
                    'Pending Grades',
                    '5',
                    'To review',
                    Colors.red,
                    Icons.grade,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Two Column Layout - Responsive
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return Column(
                  children: [
                    _buildClassOverview(),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                    const SizedBox(height: 16),
                    _buildAttendanceSummary(),
                    const SizedBox(height: 16),
                    _buildAnnouncementsPreview(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildClassOverview()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRecentActivity()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return const SizedBox.shrink();
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildAttendanceSummary()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAnnouncementsPreview()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a2b4a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildClassOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Class Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a2b4a),
            ),
          ),
          const SizedBox(height: 16),
          _classStat('Average Grade', '84%', Colors.blue, 0.84),
          const SizedBox(height: 12),
          _classStat('Attendance Rate', '92%', Colors.green, 0.92),
          const SizedBox(height: 12),
          _classStat('Assignment Completion', '78%', Colors.orange, 0.78),
          const SizedBox(height: 12),
          _classStat('Quiz Average', '81%', Colors.purple, 0.81),
        ],
      ),
    );
  }

  Widget _classStat(String label, String value, Color color, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1a2b4a)),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a2b4a),
            ),
          ),
          const SizedBox(height: 12),
          _activityItem(
            'Graded Math Quiz',
            '35 students',
            '2 hours ago',
            Colors.blue,
          ),
          const Divider(),
          _activityItem(
            'Uploaded Lesson Plan',
            'Science - Cell Biology',
            '5 hours ago',
            Colors.green,
          ),
          const Divider(),
          _activityItem(
            'Generated Worksheet',
            'English - Grammar',
            'Yesterday',
            Colors.orange,
          ),
          const Divider(),
          _activityItem(
            'Updated Attendance',
            'Oct 25, 2024',
            'Yesterday',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _activityItem(String action, String detail, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1a2b4a),
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Attendance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a2b4a),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _attendanceStat('38', 'Present', Colors.green)),
              Expanded(child: _attendanceStat('3', 'Late', Colors.orange)),
              Expanded(child: _attendanceStat('1', 'Absent', Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _selectedIndex = 5),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0d2b5c),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Take Attendance',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Announcements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a2b4a),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 6),
                child: const Text(
                  'Manage',
                  style: TextStyle(color: Color(0xFF007bff), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._announcements
              .take(3)
              .map(
                (a) => _announcementPreviewItem(
                  a['title'],
                  a['date'],
                  a['isNew'] == true,
                ),
              ),
        ],
      ),
    );
  }

  Widget _announcementPreviewItem(String title, String date, bool isNew) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (isNew)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1a2b4a),
              ),
            ),
          ),
          Text(
            date,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ==================== FUNCTIONAL STUDENTS PAGE ====================
  Widget _buildStudentList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Student List',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a2b4a),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddStudentDialog, // ✅ FUNCTIONAL
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Student'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d2b5c),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Student Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'ID',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (!_isMobile)
                        Expanded(
                          child: Text(
                            'Attendance',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          'Average',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 60),
                    ],
                  ),
                ),
                ...List.generate(
                  _students.length,
                  (index) => _studentRow(index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentRow(int index) {
    final student = _students[index];
    final avg = int.parse(student['avg']!.replaceAll('%', ''));
    final color = avg >= 90
        ? Colors.green
        : avg >= 80
        ? Colors.blue
        : avg >= 75
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF0d2b5c).withOpacity(0.1),
                  child: Text(
                    student['name']![0],
                    style: const TextStyle(
                      color: Color(0xFF0d2b5c),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  student['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a2b4a),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              student['id']!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          if (!_isMobile)
            Expanded(
              child: Text(
                student['attendance']!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                student['avg']!,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: IconButton(
              icon: const Icon(
                Icons.delete,
                size: 18,
                color: Colors.red,
              ), // ✅ FUNCTIONAL DELETE
              onPressed: () => _deleteStudent(index),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== LESSON PLANS PAGE ====================
  Widget _buildLessonPlans() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(_isMobile ? 16 : 24, 0, _isMobile ? 16 : 24, _isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _isMobile ? 16 : 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lesson Plans',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a2b4a),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UploadMaterialPage(),
                    ),
                  ).then((uploadedMaterial) {
                    if (uploadedMaterial is UploadedMaterial) {
                      _addUploadedMaterial(uploadedMaterial);
                    }
                  });
                },
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Upload File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d2b5c),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ..._materials.map((material) => _lessonPlanCard(
                material['id'],
                material['title'],
                material['subject'],
                material['grade'],
                material['date'],
                material['format'],
                Color(int.parse('0xFF${_getColorHex(material['color'])}')),
              )),
            ],
          ),
        ],
      ),
    );
  }

  String _getColorHex(String colorName) {
    switch (colorName) {
      case 'green':
        return '4CAF50';
      case 'orange':
        return 'FF9800';
      case 'red':
        return 'F44336';
      case 'teal':
        return '009688';
      default:
        return '2196F3'; // blue
    }
  }

  Widget _lessonPlanCard(
    String id,
    String title,
    String subject,
    String grade,
    String date,
    String format,
    Color color,
  ) {
    return Container(
      width: _isMobile ? double.infinity : 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  format,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
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
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'download', child: Text('Download')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1a2b4a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subject,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(width: 16),
              Icon(Icons.grade, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                grade,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showMaterialDetails(title, subject, date, id),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0d2b5c),
                    side: const BorderSide(color: Color(0xFF0d2b5c)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _downloadMaterial(id, title),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditMaterialDialog(String id, String title, String subject, String format) {
    final titleController = TextEditingController(text: title);
    final subjectController = TextEditingController(text: subject);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Learning Material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Material updated successfully!')),
              );
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _materials.removeWhere((m) => m['id'] == id);
              });
              _saveMaterials();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Material deleted successfully!')),
              );
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: $title', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Subject: $subject'),
            const SizedBox(height: 8),
            Text('Date: $date'),
            const SizedBox(height: 8),
            Text('ID: $id', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addUploadedMaterial(UploadedMaterial uploadedMaterial) {
    final fileExtension = uploadedMaterial.fileName
        .split('.')
        .last
        .toUpperCase();
    
    final colorMap = {
      'PDF': 'blue',
      'DOCX': 'green',
      'DOC': 'green',
      'PPTX': 'orange',
      'PPT': 'orange',
      'MP4': 'red',
      'AVI': 'red',
      'MOV': 'red',
    };

    setState(() {
      _materials.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': uploadedMaterial.title,
        'subject': uploadedMaterial.subject,
        'grade': 'Grade 10',
        'date': DateTime.now().toString().split(' ')[0],
        'format': fileExtension,
        'color': colorMap[fileExtension] ?? 'blue',
        'fileName': uploadedMaterial.fileName,
      });
    });
    
    _saveMaterials();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${uploadedMaterial.title} added to Lesson Plans!')),
      );
    }
  }

  // ==================== ASSIGNMENTS PAGE ====================
  Widget _buildAssignments() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assignments',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a2b4a),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateAssignmentDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Assignment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d2b5c),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ..._assignments.map((assignment) => _assignmentCard(assignment)),
        ],
      ),
    );
  }

  Widget _assignmentCard(Map<String, dynamic> assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a2b4a),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignment['subject'],
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  assignment['status'],
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            assignment['description'],
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Deadline: ${assignment['deadline']}',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showEditAssignmentDialog(assignment),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0d2b5c),
                  side: const BorderSide(color: Color(0xFF0d2b5c)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _deleteAssignment(assignment['id']),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                  hintText: 'e.g., Chapter 5 Exercises',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g., Mathematics',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter assignment details...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deadlineController,
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  hintText: 'e.g., Nov 1, 2024',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  deadlineController.text.isNotEmpty &&
                  subjectController.text.isNotEmpty) {
                setState(() {
                  _assignments.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'deadline': deadlineController.text,
                    'subject': subjectController.text,
                    'status': 'Active',
                  });
                });
                _saveAssignments();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assignment created successfully!'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditAssignmentDialog(Map<String, dynamic> assignment) {
    final titleController = TextEditingController(text: assignment['title']);
    final descriptionController =
        TextEditingController(text: assignment['description']);
    final deadlineController = TextEditingController(text: assignment['deadline']);
    final subjectController = TextEditingController(text: assignment['subject']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Assignment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Assignment Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deadlineController,
                decoration: const InputDecoration(labelText: 'Deadline'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = _assignments.indexWhere(
                  (a) => a['id'] == assignment['id'],
                );
                if (index != -1) {
                  _assignments[index]['title'] = titleController.text;
                  _assignments[index]['description'] = descriptionController.text;
                  _assignments[index]['deadline'] = deadlineController.text;
                  _assignments[index]['subject'] = subjectController.text;
                }
              });
              _saveAssignments();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assignment updated successfully!')),
              );
            },
            child: const Text('Update'),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _assignments.removeWhere((a) => a['id'] == id);
              });
              _saveAssignments();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assignment deleted successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ==================== WORKSHEETS PAGE ====================
  Widget _buildWorksheets() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Generated Worksheets',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a2b4a),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Generate New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d2b5c),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0d2b5c).withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Generate New Worksheet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a2b4a),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _dropdownField('Subject', [
                      'Mathematics',
                      'Science',
                      'English',
                      'Filipino',
                      'History',
                    ]),
                    _dropdownField('Grade Level', [
                      'Grade 7',
                      'Grade 8',
                      'Grade 9',
                      'Grade 10',
                    ]),
                    _dropdownField('Topic', [
                      'Algebra',
                      'Geometry',
                      'Statistics',
                      'Calculus',
                    ]),
                    _dropdownField('Difficulty', ['Easy', 'Medium', 'Hard']),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Number of items',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Generate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0d2b5c),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Worksheets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a2b4a),
            ),
          ),
          const SizedBox(height: 16),
          _worksheetCard(
            'Algebra Practice Set A',
            'Mathematics',
            'Grade 10',
            '20 items',
            'Oct 24, 2024',
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _worksheetCard(
            'Cell Biology Review',
            'Science',
            'Grade 10',
            '15 items',
            'Oct 22, 2024',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _worksheetCard(
            'Verb Tenses Exercise',
            'English',
            'Grade 10',
            '25 items',
            'Oct 20, 2024',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _dropdownField(String label, List<String> items) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: Text(
                  'Select $label',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
                isExpanded: true,
                items: items
                    .map(
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text(i, style: const TextStyle(fontSize: 13)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _worksheetCard(
    String title,
    String subject,
    String grade,
    String items,
    String date,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a2b4a),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      subject,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('•', style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(width: 12),
                    Text(
                      grade,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('•', style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(width: 12),
                    Text(
                      items,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(
              Icons.download,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.print, size: 18, color: Color(0xFF94A3B8)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ==================== GRADES PAGE ====================
  Widget _buildGrades() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grades & Scores',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a2b4a),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text(
                          'Select Subject',
                          style: TextStyle(fontSize: 13),
                        ),
                        items:
                            [
                                  'Mathematics',
                                  'Science',
                                  'English',
                                  'Filipino',
                                  'History',
                                ]
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Grade'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0d2b5c),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Student',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Quiz 1',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Quiz 2',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Exam',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Project',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Average',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                _gradeRow('Juan Dela Cruz', '85', '90', '88', '92', '88.75'),
                _gradeRow('Maria Santos', '95', '92', '96', '94', '94.25'),
                _gradeRow('Pedro Reyes', '72', '75', '78', '80', '76.25'),
                _gradeRow('Ana Garcia', '88', '85', '90', '87', '87.50'),
                _gradeRow('Jose Lim', '80', '82', '85', '88', '83.75'),
                _gradeRow('Carmen Tan', '92', '94', '91', '95', '93.00'),
                _gradeRow('Miguel Cruz', '68', '70', '72', '75', '71.25'),
                _gradeRow('Sofia Reyes', '98', '96', '97', '99', '97.50'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Class Performance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a2b4a),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _performanceBar('A (90-100)', 3, Colors.green),
                      const SizedBox(height: 8),
                      _performanceBar('B (80-89)', 3, Colors.blue),
                      const SizedBox(height: 8),
                      _performanceBar('C (75-79)', 2, Colors.orange),
                      const SizedBox(height: 8),
                      _performanceBar('D (Below 75)', 1, Colors.red),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Grade Entry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a2b4a),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Student Name or ID',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Score',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8F9FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Total',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8F9FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0d2b5c),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Submit Grade'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradeRow(
    String name,
    String q1,
    String q2,
    String exam,
    String proj,
    String avg,
  ) {
    final average = double.parse(avg);
    final color = average >= 90
        ? Colors.green
        : average >= 80
        ? Colors.blue
        : average >= 75
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1a2b4a),
              ),
            ),
          ),
          Expanded(
            child: Text(q1, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(q2, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(exam, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(proj, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                avg,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Color(0xFF94A3B8)),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _performanceBar(String label, int count, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: count / 8,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ==================== ATTENDANCE PAGE ====================
  Widget _buildAttendance() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a2b4a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track and manage student attendance',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _attendanceBigStat('38', 'Present', Colors.green),
                    _attendanceBigStat('3', 'Late', Colors.orange),
                    _attendanceBigStat('1', 'Absent', Colors.red),
                    _attendanceBigStat('90%', 'Rate', const Color(0xFF0d2b5c)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today\'s Attendance - Oct 25, 2024',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a2b4a),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0d2b5c),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _attendanceStudentRow(
                  'Juan Dela Cruz',
                  '2024-0001',
                  true,
                  false,
                  false,
                ),
                _attendanceStudentRow(
                  'Maria Santos',
                  '2024-0002',
                  true,
                  false,
                  false,
                ),
                _attendanceStudentRow(
                  'Pedro Reyes',
                  '2024-0003',
                  false,
                  true,
                  false,
                ),
                _attendanceStudentRow(
                  'Ana Garcia',
                  '2024-0004',
                  true,
                  false,
                  false,
                ),
                _attendanceStudentRow(
                  'Jose Lim',
                  '2024-0005',
                  true,
                  false,
                  false,
                ),
                _attendanceStudentRow(
                  'Carmen Tan',
                  '2024-0006',
                  true,
                  false,
                  false,
                ),
                _attendanceStudentRow(
                  'Miguel Cruz',
                  '2024-0007',
                  false,
                  false,
                  true,
                ),
                _attendanceStudentRow(
                  'Sofia Reyes',
                  '2024-0008',
                  true,
                  false,
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceBigStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _attendanceStudentRow(
    String name,
    String id,
    bool present,
    bool late,
    bool absent,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF0d2b5c).withOpacity(0.1),
                  child: Text(
                    name[0],
                    style: const TextStyle(
                      color: Color(0xFF0d2b5c),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      id,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _attendanceToggle('Present', present, Colors.green),
          _attendanceToggle('Late', late, Colors.orange),
          _attendanceToggle('Absent', absent, Colors.red),
        ],
      ),
    );
  }

  Widget _attendanceToggle(String label, bool isSelected, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== FUNCTIONAL ANNOUNCEMENTS PAGE ====================
  Widget _buildAnnouncements() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Announcements',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a2b4a),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddAnnouncementDialog, // ✅ FUNCTIONAL
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Announcement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d2b5c),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Create and manage class announcements',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            _announcements.length,
            (index) => _teacherAnnouncementCard(index),
          ),
        ],
      ),
    );
  }

  Widget _teacherAnnouncementCard(int index) {
    final announcement = _announcements[index];
    final color = announcement['color'] == 'blue'
        ? Colors.blue
        : announcement['color'] == 'green'
        ? Colors.green
        : Colors.orange;
    final isActive = announcement['isNew'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.announcement, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1a2b4a),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      announcement['date'],
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.visibility, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    '${announcement['views']}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteAnnouncement(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement['content'],
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
