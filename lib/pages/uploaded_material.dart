import 'dart:io';

class UploadedMaterial {
  final String title;
  final String subject;
  final String fileName;
  final File? file;
  final List<int>? fileBytes;

  UploadedMaterial({
    required this.title,
    required this.subject,
    required this.fileName,
    this.file,
    this.fileBytes,
  });
}