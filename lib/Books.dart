import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Books/class_1/bangla_book.dart';
import 'Books/class_1/pdf.dart';


class BookPdf extends StatefulWidget {
  const BookPdf({super.key});

  @override
  State<BookPdf> createState() => _BookPdfState();
}

class _BookPdfState extends State<BookPdf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Class"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildClassTile(context, "Class 1", Colors.blue, Icons.looks_one,  BookList()),
            buildClassTile(context, "Class 2", Colors.green, Icons.looks_two, null),
            buildClassTile(context, "Class 3", Colors.orange, Icons.looks_3, null),
            buildClassTile(context, "Class 4", Colors.purple, Icons.looks_4, null),
            buildClassTile(context, "Class 5", Colors.red, Icons.looks_5, null),
          ],
        ),
      ),
    );
  }

  Widget buildClassTile(BuildContext context, String title, Color color, IconData icon, Widget? page) {
    return InkWell(
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No page available for $title')),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(2, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
