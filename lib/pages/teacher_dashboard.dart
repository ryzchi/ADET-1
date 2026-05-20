import 'package:flutter/material.dart';
import 'upload_material_page.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String selectedSubject = 'All';
  final List<String> subjects = ['All', 'Math', 'Physics', 'Biology', 'History', 'English'];

  void _uploadSpecificType(String type, String subjectHint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadMaterialPage(
          preselectedSubject: subjectHint,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Quick Upload', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Upload PDF'),
              onTap: () => _uploadSpecificType('PDF', 'General'),
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.blue),
              title: const Text('Upload DOCX'),
              onTap: () => _uploadSpecificType('DOCX', 'General'),
            ),
            ListTile(
              leading: const Icon(Icons.slideshow, color: Colors.orange),
              title: const Text('Upload PPT'),
              onTap: () => _uploadSpecificType('PPT', 'General'),
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.purple),
              title: const Text('Upload Video'),
              onTap: () => _uploadSpecificType('Video', 'General'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: FilterChip(
                    label: Text(subject),
                    selected: selectedSubject == subject,
                    onSelected: (selected) {
                      setState(() {
                        selectedSubject = subject;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildUploadCard('Upload PDF', Icons.picture_as_pdf, Colors.red, 'PDF'),
                _buildUploadCard('Upload DOCX', Icons.description, Colors.blue, 'DOCX'),
                _buildUploadCard('Upload PPT', Icons.slideshow, Colors.orange, 'PPT'),
                _buildUploadCard('Upload Video', Icons.video_library, Colors.purple, 'Video'),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.cloud_upload, color: Colors.green),
                    title: const Text('Advanced Upload (any type)'),
                    subtitle: const Text('PDF, DOCX, PPT, MP4, MOV, AVI, MKV'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UploadMaterialPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadMaterialPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Upload'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildUploadCard(String label, IconData icon, Color color, String typeHint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.cloud_upload),
        onTap: () => _uploadSpecificType(typeHint, 'General'),
      ),
    );
  }
}