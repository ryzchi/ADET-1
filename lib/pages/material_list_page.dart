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
  List<UploadedMaterial> filteredMaterials = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredMaterials = uploadedMaterials;
  }

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
        filteredMaterials = uploadedMaterials;
      });
    }
  }

  void searchMaterials(String query) {
    final results = uploadedMaterials.where((material) {
      return material.title.toLowerCase().contains(query.toLowerCase()) ||
          material.subject.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredMaterials = results;
    });
  }

  void deleteMaterial(UploadedMaterial material) {
    setState(() {
      uploadedMaterials.remove(material);
      filteredMaterials = uploadedMaterials;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Materials'),
      ),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search learning materials...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: searchMaterials,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: filteredMaterials.isEmpty
                ? const Center(
                    child: Text(
                      'No materials found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredMaterials.length,
                    itemBuilder: (context, index) {
                      final material = filteredMaterials[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(material.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Subject: ${material.subject}'),
                              Text(
                                'File: ${material.fileName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),

                          // FIX: SAFE ACTIONS (NO ROLE CHANGE, SAME STRUCTURE)
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () {
                                  // optional download/open
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  deleteMaterial(material);
                                },
                              ),
                            ],
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