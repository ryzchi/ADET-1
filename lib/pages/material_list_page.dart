import 'package:flutter/material.dart';
import 'upload_material_page.dart';
import 'uploaded_material.dart';

class LessonPlanPage extends StatefulWidget {
  const LessonPlanPage({super.key});

  @override
  State<LessonPlanPage> createState() => _LessonPlanPageState();
}

class _LessonPlanPageState extends State<LessonPlanPage> {
  List<UploadedMaterial> uploadedMaterials = [];

  List<UploadedMaterial> filteredMaterials = [];

  final TextEditingController searchController =
      TextEditingController();

  String selectedSubject = 'All';

  final List<String> subjects = [
    'All',
    'Mathematics',
    'Science',
    'English',
    'Filipino',
    'MAPEH',
    'ICT',
  ];

  @override
  void initState() {
    super.initState();

    // DEMO DATA
    uploadedMaterials = [
      UploadedMaterial(
        title: 'Quadratic Equations',
        subject: 'Mathematics',
        fileName: 'quadratic_equations.pdf',
      ),
      UploadedMaterial(
        title: 'Cell Division',
        subject: 'Science',
        fileName: 'cell_division.pdf',
      ),
      UploadedMaterial(
        title: 'Philippine Literature',
        subject: 'Filipino',
        fileName: 'philippine_literature.docx',
      ),
    ];

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

        applyFilters();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.title} uploaded successfully',
          ),
        ),
      );
    }
  }

  void applyFilters() {
    final query = searchController.text.toLowerCase();

    final results = uploadedMaterials.where((material) {
      final matchesSearch =
          material.title.toLowerCase().contains(query) ||
              material.subject.toLowerCase().contains(query) ||
              material.fileName.toLowerCase().contains(query);

      final matchesSubject =
          selectedSubject == 'All' ||
              material.subject == selectedSubject;

      return matchesSearch && matchesSubject;
    }).toList();

    setState(() {
      filteredMaterials = results;
    });
  }

  void deleteMaterial(UploadedMaterial material) {
    setState(() {
      uploadedMaterials.remove(material);

      applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${material.title} deleted',
        ),
      ),
    );
  }

  Widget buildSubjectChip(String label) {
    final bool isSelected = selectedSubject == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSubject = label;

          applyFilters();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0d2b5c)
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0d2b5c)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildMaterialCard(UploadedMaterial material) {
    String fileType = material.fileName
        .split('.')
        .last
        .toUpperCase();

    Color subjectColor = const Color(0xFF2563EB);

    if (material.subject == 'Science') {
      subjectColor = Colors.green;
    } else if (material.subject == 'Filipino') {
      subjectColor = Colors.orange;
    } else if (material.subject == 'English') {
      subjectColor = Colors.purple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: subjectColor.withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Text(
                  fileType,
                  style: TextStyle(
                    color: subjectColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade500,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Delete'),
                    onTap: () {
                      Future.delayed(
                        Duration.zero,
                            () {
                          deleteMaterial(material);
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            material.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a2b4a),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            material.subject,
            style: TextStyle(
              color: subjectColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                size: 18,
                color: Colors.grey.shade500,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  material.fileName,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Viewing ${material.title}',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.visibility,
                    size: 18,
                  ),
                  label: const Text('View'),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF0d2b5c),
                    foregroundColor:
                    Colors.white,
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Downloading ${material.fileName}',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.download,
                    size: 18,
                  ),
                  label: const Text(
                    'Download',
                  ),
                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                    Colors.grey.shade700,
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Lesson Plans',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: navigateToUpload,
        backgroundColor:
        const Color(0xFF0d2b5c),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload File'),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Lesson Plans',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight:
                          FontWeight.bold,
                          color:
                          Color(0xFF1a2b4a),
                        ),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: navigateToUpload,
                      icon: const Icon(
                        Icons.upload_file,
                      ),
                      label:
                      const Text('Upload File'),
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(
                            0xFF0d2b5c),
                        foregroundColor:
                        Colors.white,
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 22,
                          vertical: 18,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                              12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText:
                    'Search lesson plans...',
                    prefixIcon:
                    const Icon(Icons.search),
                    filled: true,
                    fillColor:
                    const Color(0xFFF5F7FB),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    applyFilters();
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 46,
                  child: ListView(
                    scrollDirection:
                    Axis.horizontal,
                    children: subjects
                        .map(
                          (subject) =>
                          buildSubjectChip(
                            subject,
                          ),
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredMaterials.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 90,
                    color:
                    Colors.grey.shade300,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'No learning materials found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors
                          .grey.shade600,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding:
              const EdgeInsets.all(24),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.15,
              ),
              itemCount:
              filteredMaterials.length,
              itemBuilder:
                  (context, index) {
                final material =
                filteredMaterials[index];

                return buildMaterialCard(
                  material,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}