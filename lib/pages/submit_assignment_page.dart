import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../assignment_service.dart';
import '../security_service/auth_service.dart';

class SubmitAssignmentPage extends StatefulWidget {
  final String assignmentId;

  const SubmitAssignmentPage({
    super.key,
    required this.assignmentId,
  });

  @override
  State<SubmitAssignmentPage> createState() =>
      _SubmitAssignmentPageState();
}

class _SubmitAssignmentPageState
    extends State<SubmitAssignmentPage> {
  File? file;

  bool loading = false;

  final AssignmentService _assignmentService =
      AssignmentService();

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadSubmission() async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file first'),
        ),
      );
      return;
    }

    final studentEmail = AuthService().currentUserEmail;

    if (studentEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student email not found'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final result = await _assignmentService.submitAssignment(
      assignmentId: widget.assignmentId,
      filePath: file!.path,
      studentEmail: studentEmail,
    );

    setState(() {
      loading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment submitted successfully'),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Submission failed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Pick File'),
            ),

            const SizedBox(height: 15),

            Text(
              file != null
                  ? file!.path.split('/').last
                  : 'No file selected',
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: loading ? null : uploadSubmission,
              child: Text(
                loading
                    ? 'Uploading...'
                    : 'Submit Assignment',
              ),
            ),
          ],
        ),
      ),
    );
  }
}