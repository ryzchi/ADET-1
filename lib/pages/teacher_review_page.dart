import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TeacherReviewPage extends StatefulWidget {
  const TeacherReviewPage({super.key});

  @override
  State<TeacherReviewPage> createState() => _TeacherReviewPageState();
}

class _TeacherReviewPageState extends State<TeacherReviewPage> {
  List<Map<String, dynamic>> _submissions = [];
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String _selectedAssignment = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load assignments from SHARED key
      final assignmentsJson = prefs.getString('student_assignments');
      if (assignmentsJson != null) {
        _assignments = List<Map<String, dynamic>>.from(jsonDecode(assignmentsJson));
      } else {
        // Default assignments if none exist
        _assignments = [
          {'id': '1', 'title': 'Math Homework'},
          {'id': '2', 'title': 'Science Project'},
          {'id': '3', 'title': 'English Essay'},
          {'id': '4', 'title': 'History Timeline'},
        ];
      }
      
      // Load ALL submissions from GLOBAL key
      final submissionsJson = prefs.getString('all_submissions');
      if (submissionsJson != null) {
        _submissions = List<Map<String, dynamic>>.from(jsonDecode(submissionsJson));
        // Sort by date (newest first)
        _submissions.sort((a, b) => b['submitted_at'].compareTo(a['submitted_at']));
      } else {
        _submissions = [];
      }
      
      print('Loaded ${_submissions.length} submissions'); // Debug
      
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSubmissionStatus(String submissionId, String newStatus, String feedback) async {
    final prefs = await SharedPreferences.getInstance();
    
    final submissionsJson = prefs.getString('all_submissions');
    if (submissionsJson != null) {
      List<Map<String, dynamic>> allSubmissions = List<Map<String, dynamic>>.from(jsonDecode(submissionsJson));
      
      final index = allSubmissions.indexWhere((sub) => sub['id'] == submissionId);
      if (index != -1) {
        allSubmissions[index]['status'] = newStatus;
        allSubmissions[index]['feedback'] = feedback;
        allSubmissions[index]['reviewed_at'] = DateTime.now().toString();
        
        await prefs.setString('all_submissions', jsonEncode(allSubmissions));
        
        // Also update student-specific submissions
        final studentEmail = allSubmissions[index]['student_email'];
        if (studentEmail != null) {
          final studentSubmissionsKey = 'submissions_${studentEmail.replaceAll('.', '_')}';
          final studentSubmissionsJson = prefs.getString(studentSubmissionsKey);
          if (studentSubmissionsJson != null) {
            List<Map<String, dynamic>> studentSubmissions = List<Map<String, dynamic>>.from(jsonDecode(studentSubmissionsJson));
            final studentIndex = studentSubmissions.indexWhere((sub) => sub['id'] == submissionId);
            if (studentIndex != -1) {
              studentSubmissions[studentIndex]['status'] = newStatus;
              studentSubmissions[studentIndex]['feedback'] = feedback;
              studentSubmissions[studentIndex]['reviewed_at'] = DateTime.now().toString();
              await prefs.setString(studentSubmissionsKey, jsonEncode(studentSubmissions));
            }
          }
        }
        
        await _loadData(); // Refresh
      }
    }
  }

  String _getAssignmentTitle(String assignmentId) {
    try {
      final assignment = _assignments.firstWhere((a) => a['id'] == assignmentId);
      return assignment['title'] ?? 'Unknown';
    } catch (e) {
      return 'Unknown Assignment';
    }
  }

  List<Map<String, dynamic>> get _filteredSubmissions {
    var filtered = _submissions;
    
    if (_selectedFilter != 'All') {
      filtered = filtered.where((sub) => sub['status'] == _selectedFilter).toList();
    }
    
    if (_selectedAssignment != 'All') {
      filtered = filtered.where((sub) => sub['assignment_id'] == _selectedAssignment).toList();
    }
    
    return filtered;
  }

  int get _pendingCount => _submissions.where((s) => s['status'] == 'Pending').length;
  int get _approvedCount => _submissions.where((s) => s['status'] == 'Approved').length;
  int get _rejectedCount => _submissions.where((s) => s['status'] == 'Rejected').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Review Submissions'),
        backgroundColor: const Color(0xFF0d2b5c),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Summary
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('Total', _submissions.length, Colors.blue),
                      _statItem('Pending', _pendingCount, Colors.orange),
                      _statItem('Approved', _approvedCount, Colors.green),
                      _statItem('Rejected', _rejectedCount, Colors.red),
                    ],
                  ),
                ),
                
                // Filters
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip('All', _selectedFilter == 'All'),
                          _buildFilterChip('Pending', _selectedFilter == 'Pending'),
                          _buildFilterChip('Approved', _selectedFilter == 'Approved'),
                          _buildFilterChip('Rejected', _selectedFilter == 'Rejected'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildAssignmentFilterChip('All', _selectedAssignment == 'All'),
                          ..._assignments.map((a) => _buildAssignmentFilterChip(a['title'], _selectedAssignment == a['id'], assignmentId: a['id'])),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Submissions List
                Expanded(
                  child: _filteredSubmissions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No submissions found',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ask students to submit assignments first',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSubmissions.length,
                          itemBuilder: (context, index) {
                            final submission = _filteredSubmissions[index];
                            return _submissionCard(submission);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _statItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
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
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: const Color(0xFF0d2b5c),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildAssignmentFilterChip(String label, bool isSelected, {String? assignmentId}) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedAssignment = selected ? (assignmentId ?? label) : 'All';
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: const Color(0xFF0d2b5c),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _submissionCard(Map<String, dynamic> submission) {
    final isPending = submission['status'] == 'Pending';
    final isApproved = submission['status'] == 'Approved';
    final TextEditingController feedbackController = TextEditingController(text: submission['feedback'] ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isPending 
                ? Colors.orange.withValues(alpha: 0.1)
                : isApproved
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPending ? Icons.pending_actions : isApproved ? Icons.check_circle : Icons.cancel,
            color: isPending ? Colors.orange : isApproved ? Colors.green : Colors.red,
            size: 28,
          ),
        ),
        title: Text(
          _getAssignmentTitle(submission['assignment_id']),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${submission['student_name'] ?? submission['student_email']}'),
            Text('Submitted: ${_formatDate(submission['submitted_at'])}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPending 
                ? Colors.orange.withValues(alpha: 0.1)
                : isApproved
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            submission['status'],
            style: TextStyle(
              color: isPending ? Colors.orange : isApproved ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Comment
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.comment, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Student Comment:',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(submission['comment'] ?? 'No comment'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.insert_drive_file, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'File: ${submission['file_name']}',
                              style: TextStyle(color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (submission['file_size'] != null && submission['file_size'] > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 24),
                            Text(
                              'Size: ${_formatFileSize(submission['file_size'])}',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Existing Feedback (if any)
                if (submission['feedback'] != null && submission['feedback'].isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.feedback, size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Previous Feedback:',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(submission['feedback']),
                        if (submission['reviewed_at'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Reviewed: ${_formatDate(submission['reviewed_at'])}',
                            style: TextStyle(color: Colors.blue.shade400, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                if (submission['status'] == 'Pending') ...[
                  const Text(
                    'Review Submission',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: feedbackController,
                    decoration: InputDecoration(
                      hintText: 'Enter feedback for student...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final feedback = feedbackController.text.trim();
                            if (feedback.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please provide feedback before approving'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            await _updateSubmissionStatus(submission['id'], 'Approved', feedback);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Submission approved!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final feedback = feedbackController.text.trim();
                            if (feedback.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please provide feedback before rejecting'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            await _updateSubmissionStatus(submission['id'], 'Rejected', feedback);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Submission rejected'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Feedback'),
                                content: Text(submission['feedback'] ?? 'No feedback provided'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.feedback, size: 18),
                          label: const Text('View Feedback'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Download: ${submission['file_name']}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Download File'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString.split(' ')[0];
    }
  }

  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}