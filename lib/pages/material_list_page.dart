import 'package:flutter/material.dart';
import 'upload_material_page.dart';
import 'uploaded_material.dart';

class LessonPlanPage extends StatefulWidget {
  const LessonPlanPage({super.key});

  @override
  State<LessonPlanPage> createState() => LessonPlanPageState();
}

class LessonPlanPageState extends State<LessonPlanPage> {
  List<UploadedMaterial> uploadedMaterials = [];

  Future<void> navigateToUpload() async {
    final result = await Navigator.push<UploadedMaterial>(
      context,
      MaterialPageRoute(
        builder: (context) => const UploadMaterialPage(
          preselectedSubject: 'Mathematics',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        uploadedMaterials.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson Plan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: navigateToUpload,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Material'),
            ),
          ),

          Expanded(
            child: uploadedMaterials.isEmpty
                ? const Center(
                    child: Text(
                      'No materials uploaded yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: uploadedMaterials.length,
                    itemBuilder: (context, index) {
                      final material = uploadedMaterials[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(material.title),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subject: ${material.subject}',
                              ),
                              Text(
                                'File: ${material.fileName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                uploadedMaterials.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}