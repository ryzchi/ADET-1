import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'uploaded_material.dart';

class UploadMaterialPage extends StatefulWidget {
  final String? preselectedSubject;
  const UploadMaterialPage({super.key, this.preselectedSubject});

  @override
  State<UploadMaterialPage> createState() => _UploadMaterialPageState();
}

class _UploadMaterialPageState extends State<UploadMaterialPage> {
  File? selectedFile;
  String? selectedFileName;
  List<int>? selectedFileBytes;

  late TextEditingController _titleController;
  late TextEditingController _subjectController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subjectController = TextEditingController(text: widget.preselectedSubject ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      final picked = result.files.first;
      setState(() {
        selectedFileName = picked.name;
        selectedFileBytes = picked.bytes;
        selectedFile = picked.path != null ? File(picked.path!) : null;
      });
    }
  }

  Future<void> upload() async {
    if (selectedFileName == null) {
      setState(() => _errorMessage = 'Please select a file.');
      return;
    }
    if (_titleController.text.trim().isEmpty || _subjectController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Enter title and subject.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate network delay (optional)
    await Future.delayed(const Duration(seconds: 1));

    // Extract file extension for "type" field
    final extension = selectedFileName!.contains('.')
        ? selectedFileName!.split('.').last.toUpperCase()
        : 'FILE';

    final uploadedMaterial = UploadedMaterial(
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      fileName: selectedFileName!,
      filePath: selectedFile?.path ?? '',
      fileUrl: null,                     // No remote URL yet
      type: extension,                   // e.g., PDF, DOCX, etc.
      fileId: null,
      fileBytes: selectedFileBytes,      // Raw bytes of the file
      fileContent: null,                 // Not used
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploaded successfully!')),
    );
    Navigator.pop(context, uploadedMaterial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload File')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(controller: _subjectController, decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: pickFile, child: const Text('Select File')),
            const SizedBox(height: 8),
            Text(selectedFileName ?? 'No file selected'),
            const SizedBox(height: 20),
            if (_errorMessage != null) Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : upload,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}