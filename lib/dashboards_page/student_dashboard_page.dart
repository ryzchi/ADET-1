import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '/security_service/auth_service.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  final _authService = AuthService();

  int _selectedIndex = 0;
  bool _isMobile = false;
  bool _isLoadingAssignments = false;

  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _submissions = [];
  List<Map<String, dynamic>> _attendanceRecords = []; // ATTENDANCE DATA
  List<Map<String, dynamic>> _announcements = []; // ANNOUNCEMENTS FROM TEACHER
  int _newAnnouncementCount = 0; // NOTIFICATION BADGE COUNT
  Set<int> _readAnnouncementIds = {}; // TRACK READ ANNOUNCEMENTS

  @override
  void initState() {
    super.initState();
    _loadAssignmentsWithStatus();
    _loadAttendanceData();
    _loadAnnouncementsFromTeacher();
  }

  // ==================== ATTENDANCE METHODS ====================
  Future<void> _loadAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final studentEmail = _authService.currentUserEmail ?? 'student';
    final key = 'attendance_${studentEmail.replaceAll('.', '_')}';
    final String? data = prefs.getString(key);

    if (data != null) {
      setState(() {
        _attendanceRecords = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    } else {
      // Generate sample attendance for the last 30 days
      final sample = _generateSampleAttendance();
      setState(() {
        _attendanceRecords = sample;
      });
      await prefs.setString(key, jsonEncode(sample));
    }
  }

  List<Map<String, dynamic>> _generateSampleAttendance() {
    final List<Map<String, dynamic>> records = [];
    final now = DateTime.now();
    final subjects = [
      'Mathematics',
      'Science',
      'English',
      'History',
      'PE',
      'Art',
    ];

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      // Weighted random: 70% present, 15% late, 15% absent
      final random = DateTime.now().millisecondsSinceEpoch % 100;
      String status;
      if (random < 70)
        status = 'Present';
      else if (random < 85)
        status = 'Late';
      else
        status = 'Absent';

      records.add({
        'date': date.toIso8601String().split('T')[0],
        'status': status,
        'subject': subjects[i % subjects.length],
      });
    }
    return records;
  }

  // ==================== ANNOUNCEMENT METHODS ====================
  Future<void> _loadAnnouncementsFromTeacher() async {
    final prefs = await SharedPreferences.getInstance();
    final studentEmail = _authService.currentUserEmail ?? 'student';
    final readKey = 'read_announcements_${studentEmail.replaceAll('.', '_')}';

    // Load teacher announcements
    final announcementsJson = prefs.getString('teacher_announcements');
    if (announcementsJson != null) {
      final loadedAnnouncements = List<Map<String, dynamic>>.from(
        jsonDecode(announcementsJson),
      );

      // Load previously read announcements
      final readIdsJson = prefs.getString(readKey);
      if (readIdsJson != null) {
        _readAnnouncementIds = Set<int>.from(jsonDecode(readIdsJson) as List);
      }

      setState(() {
        _announcements = loadedAnnouncements;
        // Count new announcements
        _newAnnouncementCount = _announcements
            .where(
              (a) => !_readAnnouncementIds.contains(_announcements.indexOf(a)),
            )
            .length;
      });
    }
  }

  Future<void> _markAnnouncementAsRead(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final studentEmail = _authService.currentUserEmail ?? 'student';
    final readKey = 'read_announcements_${studentEmail.replaceAll('.', '_')}';

    if (!_readAnnouncementIds.contains(index)) {
      _readAnnouncementIds.add(index);
      await prefs.setString(readKey, jsonEncode(_readAnnouncementIds.toList()));

      setState(() {
        _newAnnouncementCount = _announcements
            .where(
              (a) => !_readAnnouncementIds.contains(_announcements.indexOf(a)),
            )
            .length;
      });
    }
  }

  // Existing assignment / submission methods
  Future<void> _loadAssignmentsWithStatus() async {
    setState(() {
      _isLoadingAssignments = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final assignmentsJson = prefs.getString('student_assignments');
      if (assignmentsJson != null) {
        _assignments = List<Map<String, dynamic>>.from(
          jsonDecode(assignmentsJson),
        );
      } else {
        _assignments = [
          {
            'id': '1',
            'title': 'Math Homework',
            'subject': 'Mathematics',
            'deadline': 'May 30, 2026',
            'description': 'Complete problems 1-20 on page 42.',
          },
          {
            'id': '2',
            'title': 'Science Project',
            'subject': 'Science',
            'deadline': 'June 2, 2026',
            'description':
                'Build a simple volcano model and write a short report.',
          },
          {
            'id': '3',
            'title': 'English Essay',
            'subject': 'English',
            'deadline': 'June 5, 2026',
            'description': 'Write a 300-word essay on your favorite book.',
          },
          {
            'id': '4',
            'title': 'History Timeline',
            'subject': 'History',
            'deadline': 'June 8, 2026',
            'description': 'Create a timeline of World War II events.',
          },
        ];
        await _saveAssignments();
      }

      final studentEmail = _authService.currentUserEmail ?? 'student';
      final submissionsKey = 'submissions_${studentEmail.replaceAll('.', '_')}';
      final submissionsJson = prefs.getString(submissionsKey);

      if (submissionsJson != null) {
        _submissions = List<Map<String, dynamic>>.from(
          jsonDecode(submissionsJson),
        );
      } else {
        _submissions = [];
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoadingAssignments = false;
      });
    }
  }

  Future<void> _saveAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_assignments', jsonEncode(_assignments));
  }

  bool _isAssignmentSubmitted(String assignmentId) {
    return _submissions.any((sub) => sub['assignment_id'] == assignmentId);
  }

  Map<String, dynamic>? _getSubmission(String assignmentId) {
    try {
      return _submissions.firstWhere(
        (sub) => sub['assignment_id'] == assignmentId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitAssignment(
    String assignmentId,
    String comment,
    String fileName,
    Uint8List? fileBytes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final studentEmail = _authService.currentUserEmail ?? 'student';
    final studentName = _authService.currentUserName ?? 'Student';

    String assignmentTitle = '';
    try {
      final assignment = _assignments.firstWhere(
        (a) => a['id'] == assignmentId,
      );
      assignmentTitle = assignment['title'] ?? 'Unknown';
    } catch (e) {
      assignmentTitle = 'Unknown';
    }

    final submission = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'assignment_id': assignmentId,
      'assignment_title': assignmentTitle,
      'student_email': studentEmail,
      'student_name': studentName,
      'status': 'Pending',
      'feedback': '',
      'comment': comment,
      'file_name': fileName,
      'file_size': fileBytes?.length ?? 0,
      'submitted_at': DateTime.now().toIso8601String(),
    };

    final globalSubmissionsJson = prefs.getString('all_submissions');
    List<Map<String, dynamic>> allSubmissions = [];
    if (globalSubmissionsJson != null) {
      allSubmissions = List<Map<String, dynamic>>.from(
        jsonDecode(globalSubmissionsJson),
      );
    }
    allSubmissions.add(submission);
    await prefs.setString('all_submissions', jsonEncode(allSubmissions));

    final studentSubmissionsKey =
        'submissions_${studentEmail.replaceAll('.', '_')}';
    final studentSubmissionsJson = prefs.getString(studentSubmissionsKey);
    List<Map<String, dynamic>> studentSubmissions = [];
    if (studentSubmissionsJson != null) {
      studentSubmissions = List<Map<String, dynamic>>.from(
        jsonDecode(studentSubmissionsJson),
      );
    }
    studentSubmissions.add(submission);
    await prefs.setString(
      studentSubmissionsKey,
      jsonEncode(studentSubmissions),
    );

    setState(() {
      _submissions.add(submission);
    });
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    }
  }

  void _navigateToSubmitAssignment(String assignmentId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SubmitAssignmentPage(
          assignmentId: assignmentId,
          assignmentTitle: title,
          onSubmit: (comment, fileName, fileBytes) async {
            await _submitAssignment(assignmentId, comment, fileName, fileBytes);
          },
        ),
      ),
    ).then((_) => _loadAssignmentsWithStatus());
  }

  void _navigateToSubmissionStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SubmissionStatusPage(
          submissions: _submissions,
          assignments: _assignments,
        ),
      ),
    ).then((_) => _loadAssignmentsWithStatus());
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

  // ==================== APP BAR & DRAWER ====================
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
            'Student Portal',
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
                    _authService.currentUserName ?? 'Student',
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
                  'Student Portal',
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
          _drawerItem(Icons.assignment_outlined, 'Assignments', 1),
          _drawerItem(Icons.quiz_outlined, 'Quizzes', 2),
          _drawerItem(Icons.calendar_today_outlined, 'Attendance', 3),
          _drawerItem(Icons.announcement_outlined, 'Announcements', 4),
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
    final hasNotification = index == 4 && _newAnnouncementCount > 0;
    return ListTile(
      leading: Stack(
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade600,
          ),
          if (hasNotification)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: hasNotification
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_newAnnouncementCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
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
                  'Student Portal',
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
          _sidebarItem(Icons.assignment_outlined, 'Assignments', 1),
          _sidebarItem(Icons.quiz_outlined, 'Quizzes', 2),
          _sidebarItem(Icons.calendar_today_outlined, 'Attendance', 3),
          _sidebarItem(Icons.announcement_outlined, 'Announcements', 4),
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
    final hasNotification = index == 4 && _newAnnouncementCount > 0;
    return ListTile(
      leading: Stack(
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade600,
          ),
          if (hasNotification)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0d2b5c) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: hasNotification
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_newAnnouncementCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      tileColor: isSelected ? const Color(0xFF0d2b5c).withOpacity(0.08) : null,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildAssignments();
      case 2:
        return _buildQuizzes();
      case 3:
        return _buildAttendance(); // <-- ATTENDANCE PAGE NA MAY LISTAHAN
      case 4:
        return _buildAnnouncements();
      default:
        return _buildOverview();
    }
  }

  // ==================== OVERVIEW ====================
  Widget _buildOverview() {
    final pendingCount = _assignments
        .where((a) => !_isAssignmentSubmitted(a['id']))
        .length;
    final submittedCount = _submissions.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        'Welcome back, ${_authService.currentUserName ?? 'Student'}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your academic progress and stay updated with your classes.',
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
                    'Assignments',
                    '$pendingCount',
                    'Pending',
                    Colors.orange,
                    Icons.assignment,
                  ),
                  _statCard(
                    'Submitted',
                    '$submittedCount',
                    'Done',
                    Colors.green,
                    Icons.check_circle,
                  ),
                  _statCard(
                    'Attendance',
                    '${_getAttendancePercentage()}%',
                    'Rate',
                    Colors.blue,
                    Icons.calendar_today,
                  ),
                  _statCard(
                    'Grade Average',
                    '87%',
                    'B+',
                    const Color(0xFF0d2b5c),
                    Icons.grade,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return Column(
                  children: [
                    _buildRecentAssignments(),
                    const SizedBox(height: 16),
                    _buildUpcomingQuizzes(),
                    const SizedBox(height: 16),
                    _buildAttendanceSummary(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRecentAssignments()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildUpcomingQuizzes()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (_isMobile) _buildAttendanceSummary(),
          if (!_isMobile)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAttendanceSummary()),
                const SizedBox(width: 16),
                Expanded(child: _buildAnnouncementsPreview()),
              ],
            ),
        ],
      ),
    );
  }

  int _getAttendancePercentage() {
    if (_attendanceRecords.isEmpty) return 0;
    int present = _attendanceRecords
        .where((r) => r['status'] == 'Present')
        .length;
    return ((present / _attendanceRecords.length) * 100).round();
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

  Widget _buildRecentAssignments() {
    final recentAssignments = _assignments.take(3).toList();

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
                'Recent Assignments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a2b4a),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF007bff), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentAssignments.map((assignment) {
            final isSubmitted = _isAssignmentSubmitted(assignment['id']);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF1a2b4a),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          assignment['subject'],
                          style: TextStyle(
                            color: isSubmitted ? Colors.green : Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSubmitted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Submitted',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUpcomingQuizzes() {
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
                'Upcoming Quizzes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a2b4a),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 2),
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF007bff), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _quizPreviewItem(
            'Algebra Quiz',
            'Mathematics',
            'Oct 28, 10:00 AM',
            Colors.blue,
          ),
          const Divider(),
          _quizPreviewItem(
            'Cell Biology',
            'Science',
            'Oct 30, 1:00 PM',
            Colors.green,
          ),
          const Divider(),
          _quizPreviewItem(
            'Grammar Test',
            'English',
            'Nov 2, 9:00 AM',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _quizPreviewItem(
    String title,
    String subject,
    String schedule,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.quiz, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1a2b4a),
                  ),
                ),
                Text(
                  subject,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            schedule,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // Attendance summary card (used in Overview)
  Widget _buildAttendanceSummary() {
    int present = _attendanceRecords
        .where((r) => r['status'] == 'Present')
        .length;
    int late = _attendanceRecords.where((r) => r['status'] == 'Late').length;
    int absent = _attendanceRecords
        .where((r) => r['status'] == 'Absent')
        .length;

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
            'Attendance Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a2b4a),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _attendanceStat(
                  'Present',
                  present.toString(),
                  Colors.green,
                ),
              ),
              Expanded(
                child: _attendanceStat('Late', late.toString(), Colors.orange),
              ),
              Expanded(
                child: _attendanceStat('Absent', absent.toString(), Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attendanceStat(String label, String value, Color color) {
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
    final previewAnnouncements = _announcements.take(2).toList();
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
              if (_newAnnouncementCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_newAnnouncementCount New',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (previewAnnouncements.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No announcements',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ),
            )
          else
            ...List.generate(previewAnnouncements.length, (idx) {
              final announcement = previewAnnouncements[idx];
              final index = _announcements.indexOf(announcement);
              final isNew = !_readAnnouncementIds.contains(index);
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _markAnnouncementAsRead(index);
                      setState(() => _selectedIndex = 4);
                    },
                    child: _announcementItem(
                      announcement['title'] ?? 'Announcement',
                      announcement['content'] ?? '',
                      announcement['date'] ?? 'Recently',
                      isNew,
                    ),
                  ),
                  if (idx < previewAnnouncements.length - 1) const Divider(),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _announcementItem(
    String title,
    String content,
    String date,
    bool isNew,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNew)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, right: 8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1a2b4a),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assignments',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a2b4a),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track and manage your assignments',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _navigateToSubmissionStatus,
                icon: const Icon(Icons.history, size: 18),
                label: const Text('Submission History'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0d2b5c),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isLoadingAssignments)
            const Center(child: CircularProgressIndicator())
          else if (_assignments.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text('No assignments yet'),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _assignments.length,
              itemBuilder: (context, index) {
                final assignment = _assignments[index];
                final isSubmitted = _isAssignmentSubmitted(assignment['id']);
                final submission = _getSubmission(assignment['id']);
                final submissionStatus = submission?['status'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _assignmentCard(
                    assignment['title'] ?? 'Untitled',
                    assignment['subject'] ?? 'No Subject',
                    assignment['deadline'] ?? 'No deadline',
                    assignment['description'] ?? '',
                    isSubmitted: isSubmitted,
                    submissionStatus: submissionStatus,
                    assignmentId: assignment['id'].toString(),
                    assignmentTitle: assignment['title'].toString(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _assignmentCard(
    String title,
    String subject,
    String due,
    String description, {
    bool isSubmitted = false,
    String? submissionStatus,
    required String assignmentId,
    required String assignmentTitle,
  }) {
    Color getStatusColor() {
      if (submissionStatus == 'Approved') return Colors.green;
      if (submissionStatus == 'Rejected') return Colors.red;
      return Colors.orange;
    }

    String getStatusText() {
      if (submissionStatus == 'Approved') return 'Approved';
      if (submissionStatus == 'Rejected') return 'Rejected';
      return 'Submitted';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (isSubmitted ? Colors.green : Colors.blue).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isSubmitted ? Icons.check_circle : Icons.assignment,
                  color: isSubmitted ? Colors.green : Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1a2b4a),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subject,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSubmitted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        submissionStatus == 'Approved'
                            ? Icons.check_circle
                            : submissionStatus == 'Rejected'
                            ? Icons.cancel
                            : Icons.pending,
                        size: 14,
                        color: getStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        getStatusText(),
                        style: TextStyle(
                          color: getStatusColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                due,
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: isSubmitted
                    ? OutlinedButton.icon(
                        onPressed: _navigateToSubmissionStatus,
                        icon: const Icon(Icons.visibility, size: 20),
                        label: const Text('View Submission'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0d2b5c),
                          side: const BorderSide(color: Color(0xFF0d2b5c)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _navigateToSubmitAssignment(
                          assignmentId,
                          assignmentTitle,
                        ),
                        icon: const Icon(Icons.upload_file, size: 20),
                        label: const Text('Submit Assignment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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

  // ==================== QUIZZES PAGE ====================
  Widget _buildQuizzes() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Quizzes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a2b4a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Take quizzes to test your knowledge',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _quizCard(
            'Algebraic Expressions',
            'Mathematics',
            '15 items • 30 mins',
            'Oct 28, 2024',
            Colors.blue,
            false,
          ),
          const SizedBox(height: 12),
          _quizCard(
            'Cell Structure & Function',
            'Science',
            '20 items • 40 mins',
            'Oct 30, 2024',
            Colors.green,
            false,
          ),
          const SizedBox(height: 12),
          _quizCard(
            'Grammar & Composition',
            'English',
            '25 items • 45 mins',
            'Nov 2, 2024',
            Colors.orange,
            false,
          ),
          const SizedBox(height: 24),
          const Text(
            'Completed Quizzes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a2b4a),
            ),
          ),
          const SizedBox(height: 16),
          _quizCard(
            'Philippine Literature',
            'Filipino',
            '20 items',
            'Oct 20, 2024',
            Colors.teal,
            true,
            score: '92%',
          ),
          const SizedBox(height: 12),
          _quizCard(
            'World War II History',
            'History',
            '25 items',
            'Oct 18, 2024',
            Colors.red,
            true,
            score: '85%',
          ),
        ],
      ),
    );
  }

  Widget _quizCard(
    String title,
    String subject,
    String info,
    String date,
    Color color,
    bool isCompleted, {
    String? score,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.quiz,
              color: isCompleted ? Colors.green : color,
              size: 28,
            ),
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
                    fontSize: 15,
                    color: Color(0xFF1a2b4a),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subject,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isCompleted && score != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    score,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: isCompleted ? null : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.grey.shade300 : color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isCompleted ? 'Done' : 'Start',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== ATTENDANCE PAGE (FULL with DETAILS) ====================
  Widget _buildAttendance() {
    int present = _attendanceRecords
        .where((r) => r['status'] == 'Present')
        .length;
    int late = _attendanceRecords.where((r) => r['status'] == 'Late').length;
    int absent = _attendanceRecords
        .where((r) => r['status'] == 'Absent')
        .length;
    double rate = _attendanceRecords.isEmpty
        ? 0
        : (present / _attendanceRecords.length) * 100;

    return RefreshIndicator(
      onRefresh: _loadAttendanceData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(_isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Record',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a2b4a),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your attendance history (Present, Late, Absent)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // === SUMMARY CARDS ===
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  _attendanceBigStat(
                    present.toString(),
                    'Present',
                    Colors.green,
                  ),
                  _attendanceBigStat(late.toString(), 'Late', Colors.orange),
                  _attendanceBigStat(absent.toString(), 'Absent', Colors.red),
                  _attendanceBigStat(
                    '${rate.toStringAsFixed(1)}%',
                    'Rate',
                    const Color(0xFF0d2b5c),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // === DETAILED ATTENDANCE LOG ===
            const Text(
              'Daily Attendance Log',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a2b4a),
              ),
            ),
            const SizedBox(height: 12),

            if (_attendanceRecords.isEmpty)
              const Center(child: Text('No attendance records found.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _attendanceRecords.length,
                itemBuilder: (context, index) {
                  final record = _attendanceRecords[index];
                  Color statusColor;
                  IconData statusIcon;
                  if (record['status'] == 'Present') {
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                  } else if (record['status'] == 'Late') {
                    statusColor = Colors.orange;
                    statusIcon = Icons.access_time;
                  } else {
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(statusIcon, color: statusColor, size: 28),
                      title: Text(
                        record['subject'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(record['date']),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          record['status'],
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
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

  // ==================== ANNOUNCEMENTS PAGE ====================
  Widget _buildAnnouncements() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Announcements',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a2b4a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stay updated with school news',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),
          if (_announcements.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.announcement_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No announcements yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ...List.generate(_announcements.length, (index) {
              final announcement = _announcements[index];
              final color = announcement['color'] == 'blue'
                  ? Colors.blue
                  : announcement['color'] == 'green'
                  ? Colors.green
                  : Colors.orange;
              final isNew = !_readAnnouncementIds.contains(index);
              return Column(
                children: [
                  _announcementCard(
                    announcement['title'] ?? 'Announcement',
                    announcement['content'] ?? '',
                    announcement['date'] ?? 'Recently',
                    color,
                    isNew,
                    index,
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _announcementCard(
    String title,
    String content,
    String date,
    Color color,
    bool isNew,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _markAnnouncementAsRead(index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isNew ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isNew ? color.withOpacity(0.3) : const Color(0xFFE2E8F0),
          ),
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
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1a2b4a),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SUBMIT ASSIGNMENT PAGE ====================
class _SubmitAssignmentPage extends StatefulWidget {
  final String assignmentId;
  final String assignmentTitle;
  final Future<void> Function(
    String comment,
    String fileName,
    Uint8List? fileBytes,
  )
  onSubmit;

  const _SubmitAssignmentPage({
    required this.assignmentId,
    required this.assignmentTitle,
    required this.onSubmit,
  });

  @override
  State<_SubmitAssignmentPage> createState() => _SubmitAssignmentPageState();
}

class _SubmitAssignmentPageState extends State<_SubmitAssignmentPage> {
  final TextEditingController _commentController = TextEditingController();
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  bool _isSubmitting = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'ppt',
          'pptx',
          'txt',
          'jpg',
          'png',
          'jpeg',
        ],
        allowMultiple: false,
      );

      if (result != null) {
        final PlatformFile file = result.files.first;

        setState(() {
          _selectedFileName = file.name;
          _selectedFileBytes = file.bytes;
        });

        String fileSize = _formatFileSize(file.size);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: ${file.name} ($fileSize)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file selected'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024)
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Assignment'),
        backgroundColor: const Color(0xFF0d2b5c),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assignment',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.assignmentTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ID: ${widget.assignmentId}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Comment / Note',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'e.g., "I have attached my solution in PDF format"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            const Text(
              'File Upload',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickFile,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedFileName != null
                        ? Colors.green
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedFileName != null
                          ? Icons.check_circle
                          : Icons.cloud_upload,
                      size: 48,
                      color: _selectedFileName != null
                          ? Colors.green
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFileName ?? 'Click to browse files',
                      style: TextStyle(
                        color: _selectedFileName != null
                            ? Colors.green
                            : Colors.grey.shade600,
                        fontWeight: _selectedFileName != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: _selectedFileName != null ? 14 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedFileName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '✓ File ready for upload',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Supported: PDF, DOC, DOCX, PPT, PPTX, TXT, JPG, PNG',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (_commentController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please add a comment or note'),
                            ),
                          );
                          return;
                        }

                        if (_selectedFileName == null ||
                            _selectedFileBytes == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a file to upload'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isSubmitting = true;
                        });

                        await widget.onSubmit(
                          _commentController.text,
                          _selectedFileName!,
                          _selectedFileBytes,
                        );

                        setState(() {
                          _isSubmitting = false;
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Assignment submitted successfully!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context, true);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d2b5c),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Submit Assignment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SUBMISSION STATUS PAGE ====================
class _SubmissionStatusPage extends StatelessWidget {
  final List<Map<String, dynamic>> submissions;
  final List<Map<String, dynamic>> assignments;

  const _SubmissionStatusPage({
    required this.submissions,
    required this.assignments,
  });

  String _getAssignmentTitle(String assignmentId) {
    try {
      final assignment = assignments.firstWhere((a) => a['id'] == assignmentId);
      return assignment['title'] ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024)
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission Status'),
        backgroundColor: const Color(0xFF0d2b5c),
        foregroundColor: Colors.white,
      ),
      body: submissions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No submissions yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final submission = submissions[index];
                final isApproved = submission['status'] == 'Approved';
                final isPending = submission['status'] == 'Pending';
                final fileSize = submission['file_size'] ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _getAssignmentTitle(
                                  submission['assignment_id'],
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isApproved
                                    ? Colors.green.withOpacity(0.1)
                                    : isPending
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                submission['status'],
                                style: TextStyle(
                                  color: isApproved
                                      ? Colors.green
                                      : isPending
                                      ? Colors.orange
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'File: ${submission['file_name']} (${_formatFileSize(fileSize)})',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.comment,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Comment: ${submission['comment']}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Submitted: ${submission['submitted_at'].toString().split(' ')[0]}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (submission['feedback'].isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.feedback,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Feedback: ${submission['feedback']}',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
