import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class LaunchCoursePage extends StatefulWidget {
  @override
  _LaunchCoursePageState createState() => _LaunchCoursePageState();
}

class _LaunchCoursePageState extends State<LaunchCoursePage> {
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false; // লোডিং স্টেট

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().substring(0, 10);
    }
  }

  void publishCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('courses').add({
          'courseName': courseNameController.text.trim(),
          'startDate': startDateController.text.trim(),
          'endDate': endDateController.text.trim(),
          'price': int.tryParse(priceController.text.trim()) ?? 0,
          'discount': int.tryParse(discountController.text.trim()) ?? 0,
          'description': descriptionController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          isLoading = false;
        });

        Get.snackbar(
          "✅ Success",
          "Course published successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        // Clear form fields
        courseNameController.clear();
        startDateController.clear();
        endDateController.clear();
        priceController.clear();
        discountController.clear();
        descriptionController.clear();

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        Get.snackbar(
          "❌ Error",
          "Failed to publish course: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Launch New Course"), backgroundColor: Colors.cyan),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: courseNameController,
                decoration: InputDecoration(labelText: "Course Name"),
                validator: (value) => value!.isEmpty ? "Enter course name" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: startDateController,
                readOnly: true,
                onTap: () => _selectDate(context, startDateController),
                decoration: InputDecoration(labelText: "Start Date (yyyy-mm-dd)"),
                validator: (value) => value!.isEmpty ? "Enter start date" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: endDateController,
                readOnly: true,
                onTap: () => _selectDate(context, endDateController),
                decoration: InputDecoration(labelText: "End Date (yyyy-mm-dd)"),
                validator: (value) => value!.isEmpty ? "Enter end date" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Main Price (৳)"),
                validator: (value) => value!.isEmpty ? "Enter course price" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Discount (৳)"),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: "Course Description"),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : publishCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  "Publish Course",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
