import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ManageCoursesPage extends StatefulWidget {
  const ManageCoursesPage({super.key});

  @override
  State<ManageCoursesPage> createState() => _ManageCoursesPageState();
}

class _ManageCoursesPageState extends State<ManageCoursesPage> {
  List<QueryDocumentSnapshot> filteredCourses = [];

  Future<void> deleteCourse(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('courses').doc(docId).delete();
      Get.snackbar(
        "✅ Deleted",
        "Course has been removed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        "❌ Error",
        "Failed to delete: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showDescriptionDialog(BuildContext context, String courseName, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(courseName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        content: Text(description.isNotEmpty ? description : "No description available."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close")),
        ],
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Are you sure?"),
        content: Text("Do you really want to delete this course?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              deleteCourse(docId);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void showEditCourseDialog(BuildContext context, String docId, Map<String, dynamic> currentData) {
    final _formKey = GlobalKey<FormState>();

    // Controllers pre-filled with existing data
    final courseNameController = TextEditingController(text: currentData['courseName'] ?? '');
    final chapterNumberController = TextEditingController(text: currentData['chapterNumber']?.toString() ?? '');
    final difficultyLevelController = TextEditingController(text: currentData['difficultyLevel'] ?? '');
    final startDateController = TextEditingController(text: currentData['startDate'] ?? '');
    final endDateController = TextEditingController(text: currentData['endDate'] ?? '');
    final descriptionController = TextEditingController(text: currentData['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Course", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Course Name
                TextFormField(
                  controller: courseNameController,
                  decoration: InputDecoration(labelText: "Course Name"),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                // Chapter Number
                TextFormField(
                  controller: chapterNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Chapter Number"),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    if (int.tryParse(val) == null) return 'Must be a number';
                    return null;
                  },
                ),
                // Difficulty Level
                TextFormField(
                  controller: difficultyLevelController,
                  decoration: InputDecoration(labelText: "Difficulty Level"),
                ),
                // Start Date
                TextFormField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: "Start Date (yyyy-MM-dd)",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(startDateController.text) ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                        }
                      },
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    // Basic date format validation
                    try {
                      DateFormat('yyyy-MM-dd').parseStrict(val);
                    } catch (_) {
                      return 'Invalid date format';
                    }
                    return null;
                  },
                ),
                // End Date
                TextFormField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: "End Date (yyyy-MM-dd)",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(endDateController.text) ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                        }
                      },
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    try {
                      DateFormat('yyyy-MM-dd').parseStrict(val);
                    } catch (_) {
                      return 'Invalid date format';
                    }
                    return null;
                  },
                ),
                // Description
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: "Description"),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  // Update firestore doc with new data
                  await FirebaseFirestore.instance.collection('courses').doc(docId).set({
                    'courseName': courseNameController.text.trim(),
                    'chapterNumber': int.parse(chapterNumberController.text.trim()),
                    'difficultyLevel': difficultyLevelController.text.trim(),
                    'startDate': startDateController.text.trim(),
                    'endDate': endDateController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'timestamp': FieldValue.serverTimestamp(), // update timestamp
                  }, SetOptions(merge: true));

                  Get.snackbar(
                    "✅ Updated",
                    "Course data updated successfully",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                  Navigator.pop(context); // close dialog
                } catch (e) {
                  Get.snackbar(
                    "❌ Error",
                    "Failed to update: $e",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(List<QueryDocumentSnapshot> allCourses) {
    String selectedOption = 'Course Name';
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Search Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedOption,
                isExpanded: true,
                items: ['Course Name', 'Start Date'].map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  setModalState(() {
                    selectedOption = value!;
                    searchController.clear();
                  });
                },
              ),
              SizedBox(height: 10),
              if (selectedOption == 'Course Name')
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(labelText: 'Enter course name'),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      String formatted = DateFormat('yyyy-MM-dd').format(picked);
                      setModalState(() {
                        searchController.text = formatted;
                      });
                    }
                  },
                  child: Text(searchController.text.isEmpty ? "Pick Start Date" : searchController.text),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String query = searchController.text.trim().toLowerCase();

                List<QueryDocumentSnapshot> results = allCourses.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  if (selectedOption == 'Course Name') {
                    String name = (data['courseName'] ?? '').toString().toLowerCase();
                    return name.contains(query);
                  } else {
                    dynamic startDate = data['startDate'];
                    String formattedStartDate = '';

                    if (startDate is Timestamp) {
                      formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate.toDate());
                    } else if (startDate is String) {
                      formattedStartDate = startDate.trim();
                    }

                    return formattedStartDate == query;
                  }
                }).toList();

                Navigator.pop(context);

                if (results.isEmpty) {
                  Get.snackbar('Course not found', '', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                } else {
                  setState(() {
                    filteredCourses = results;
                  });
                }
              },
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Courses"),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final snapshot = await FirebaseFirestore.instance.collection('courses').orderBy('timestamp', descending: true).get();
              _showSearchDialog(snapshot.docs);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

          final allCourses = snapshot.data!.docs;
          final coursesToDisplay = filteredCourses.isNotEmpty ? filteredCourses : allCourses;

          if (coursesToDisplay.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("No courses available yet!", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text("Please launch a course to see it here.", style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: coursesToDisplay.map((doc) {
              final course = doc.data() as Map<String, dynamic>;
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(course['courseName'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Chapter: ${course['chapterNumber'] ?? 'N/A'} | Level: ${course['difficultyLevel'] ?? 'N/A'}"),
                      SizedBox(height: 4),
                      Text("Start: ${course['startDate']} | End: ${course['endDate']}"),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showEditCourseDialog(context, doc.id, course);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDeleteConfirmationDialog(context, doc.id);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    showDescriptionDialog(context, course['courseName'] ?? 'No Name', course['description'] ?? '');
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
