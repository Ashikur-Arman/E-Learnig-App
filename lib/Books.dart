import 'package:flutter/material.dart';
import 'Books/BGS.dart';
import 'Books/Bangla_Bakaron.dart';
import 'Books/Bangla_Sohopath.dart';
import 'Books/Bangla_sahitto.dart';
import 'Books/Bioloy.dart';
import 'Books/Chemistry.dart';
import 'Books/English 1st.dart';
import 'Books/English 2nd.dart';
import 'Books/Higher Math.dart';
import 'Books/ICT.dart';
import 'Books/Islam.dart';
import 'Books/Krishi.dart';
import 'Books/Math.dart';
import 'Books/Physics.dart';
import 'Books/Saririk sikkah.dart';


class BookPdf extends StatefulWidget {
  const BookPdf({super.key});

  @override
  State<BookPdf> createState() => _BookPdfState();
}

class _BookPdfState extends State<BookPdf> {
  final List<Map<String, dynamic>> subjects = [
    {"title": "বাংলা সাহিত্য", "color": Colors.blue, "page": BanglaSahitto ()},
    {"title": "বাংলা সহপাঠ", "color": Colors.blue, "page": BanglaSohopat ()},
    {"title": "বাংলা ভাষার ব্যাকরণ", "color": Colors.blue, "page": BanglaBakaron()},
    {"title": "English for Today", "color": Colors.green, "page": English1()},
    {"title": "English Grammar and Composition", "color": Colors.green, "page":English2()},
    {"title": "পদার্থ বিজ্ঞান", "color": Colors.orange, "page": Physics()},
    {"title": "রসায়ন", "color": Colors.orange, "page": Chemistry ()},
    {"title": "জীব বিজ্ঞান", "color": Colors.orange, "page": Biology()},
    {"title": "সাধারণ গণিত", "color": Colors.orange, "page": Math()},
    {"title": "উচ্চতর গণিত", "color": Colors.red, "page": HigherMath()},
    {"title": "কৃষিশিক্ষা", "color": Colors.red, "page": KrishiSikkha()},
    {"title": "বাংলাদেশ ও বিশ্বপরিচয়", "color": Colors.brown, "page": BGS()},
    {"title": "ইসলাম ও নৈতিক শিক্ষা", "color": Colors.brown, "page": Islam()},
    {"title": "তথ্য ও যোগাযোগ প্রযুক্তি", "color": Colors.brown, "page": ICT()},
    {"title": "শারীরিক শিক্ষা ও স্বাস্থ্য", "color": Colors.brown, "page": SaririkSikkah()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Subject", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFFFFDD0).withOpacity(.6),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: subjects.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return buildSubjectTile(
              context,
              title: subject['title'],
              color: subject['color'],
              index: index + 1,
              page: subject['page'],
            );
          },
        ),
      ),
    );
  }

  Widget buildSubjectTile(BuildContext context, {
    required String title,
    required Color color,
    required int index,
    required Widget? page,
  }) {
    return InkWell(
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No page available for "$title"')),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.85), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                index.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}