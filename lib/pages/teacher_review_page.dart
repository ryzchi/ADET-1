import 'package:flutter/material.dart';
import '../assignment_service.dart';

class TeacherReviewPage extends StatefulWidget {
  const TeacherReviewPage({super.key});

  @override
  State<TeacherReviewPage> createState() =>
      _TeacherReviewPageState();
}

class _TeacherReviewPageState
    extends State<TeacherReviewPage> {
  final AssignmentService _assignmentService =
      AssignmentService();

  List<Map<String, dynamic>> submissions = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSubmissions();
  }

  Future<void> loadSubmissions() async {
    final data = await _assignmentService.fetchSubmissions();

    setState(() {
      submissions = data;
      loading = false;
    });
  }

  Future<void> reviewSubmission({
    required String submissionId,
    required String status,
    required String feedback,
  }) async {
    await _assignmentService.reviewSubmission(
      submissionId: submissionId,
      status: status,
      feedback: feedback,
    );

    loadSubmissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Submissions'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final submission = submissions[index];

                final TextEditingController
                    feedbackController =
                    TextEditingController();

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          submission['assignment_title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Student: ${submission['student_email']}',
                        ),

                        Text(
                          'Current Status: ${submission['status']}',
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: feedbackController,
                          decoration: const InputDecoration(
                            labelText: 'Teacher Feedback',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await reviewSubmission(
                                    submissionId:
                                        submission['id']
                                            .toString(),
                                    status: 'Approved',
                                    feedback:
                                        feedbackController.text,
                                  );
                                },
                                child: const Text('Approve'),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await reviewSubmission(
                                    submissionId:
                                        submission['id']
                                            .toString(),
                                    status: 'Rejected',
                                    feedback:
                                        feedbackController.text,
                                  );
                                },
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}