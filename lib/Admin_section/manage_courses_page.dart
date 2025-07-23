import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageCoursesPage extends StatelessWidget {
  const ManageCoursesPage({super.key});

  // 🔴 Delete course from Firebase
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
        title: Text(
          courseName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Text(description.isNotEmpty ? description : "No description available."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Courses"),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    "No courses available yet!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please launch a course to see it here.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: snapshot.data!.docs.map((doc) {
              final course = doc.data() as Map<String, dynamic>;
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(course['courseName'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Chapter: ${course['chapterNumber'] ?? 'N/A'} | Level: ${course['difficultyLevel'] ?? 'N/A'}",
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Start: ${course['startDate']} | End: ${course['endDate']}",
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteCourse(doc.id);
                    },
                  ),
                  onTap: () {
                    showDescriptionDialog(
                      context,
                      course['courseName'] ?? 'No Name',
                      course['description'] ?? '',
                    );
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
