import 'package:flutter/material.dart';

import 'bangla_book.dart';
import 'english_book.dart';

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📚 Book List"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            buildBookItem("📖 Bangla Book", Colors.orange, BanglaBook()),
            buildBookItem("🔬 Science Book", Colors.green, EnglishBook()),
            buildBookItem("📘 English Book", Colors.blue, EnglishBook()),
          ],
        ),
      ),
    );
  }

  Widget buildBookItem(String title, Color color, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,     // eta string title ta
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
