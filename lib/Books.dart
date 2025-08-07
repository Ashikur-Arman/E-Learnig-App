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
  // Refined softer base colors for better UI
  final List<Color> baseColors = [
    Color(0xFF3F51B5), // Indigo Blue
    Color(0xFF009688), // Teal
    Color(0xFFFFA726), // Soft Orange
    Color(0xFFD32F2F), // Deep Red
    Color(0xFF6D4C41), // Brown
  ];

  final List<Map<String, dynamic>> subjects = [
    {"title": "বাংলা সাহিত্য", "colorIndex": 0, "page": BanglaSahitto()},
    {"title": "বাংলা সহপাঠ", "colorIndex": 0, "page": BanglaSohopat()},
    {"title": "বাংলা ভাষার ব্যাকরণ", "colorIndex": 0, "page": BanglaBakaron()},
    {"title": "English for Today", "colorIndex": 1, "page": English1()},
    {"title": "English Grammar and Composition", "colorIndex": 1, "page": English2()},
    {"title": "পদার্থ বিজ্ঞান", "colorIndex": 2, "page": Physics()},
    {"title": "রসায়ন", "colorIndex": 2, "page": Chemistry()},
    {"title": "জীব বিজ্ঞান", "colorIndex": 2, "page": Biology()},
    {"title": "সাধারণ গণিত", "colorIndex": 2, "page": Math()},
    {"title": "উচ্চতর গণিত", "colorIndex": 3, "page": HigherMath()},
    {"title": "কৃষিশিক্ষা", "colorIndex": 3, "page": KrishiSikkha()},
    {"title": "বাংলাদেশ ও বিশ্বপরিচয়", "colorIndex": 4, "page": BGS()},
    {"title": "ইসলাম ও নৈতিক শিক্ষা", "colorIndex": 4, "page": Islam()},
    {"title": "তথ্য ও যোগাযোগ প্রযুক্তি", "colorIndex": 4, "page": ICT()},
    {"title": "শারীরিক শিক্ষা ও স্বাস্থ্য", "colorIndex": 4, "page": SaririkSikkah()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose Subject",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFFDD0).withOpacity(.8),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2EBF2), // Light Cyan
              Color(0xFF4DD0E1), // Teal-ish
              Color(0xFF00838F), // Darker blue-teal
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: subjects.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final subject = subjects[index];
            final baseColor = baseColors[subject['colorIndex']];

            // Subtle gradient with softer opacity for elegant look
            final startColor = baseColor.withOpacity(0.75);
            final endColor = baseColor.withOpacity(0.95);

            return buildSubjectTile(
              context,
              title: subject['title'],
              startColor: startColor,
              endColor: endColor,
              index: index + 1,
              page: subject['page'],
            );
          },
        ),
      ),
    );
  }

  Widget buildSubjectTile(
      BuildContext context, {
        required String title,
        required Color startColor,
        required Color endColor,
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
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: endColor.withOpacity(0.3),
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
                style: TextStyle(fontWeight: FontWeight.bold, color: endColor),
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
