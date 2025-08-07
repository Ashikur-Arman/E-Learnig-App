import 'package:flutter/material.dart';
import 'Books.dart';
import 'Home_Page/HomePage.dart';
import 'quiz/view_courses_page.dart';
import 'Progress_Pages/1_ProgressPage_Individual.dart';

class BottomNavBarAssigment extends StatefulWidget {
  const BottomNavBarAssigment({super.key});
  @override
  State<BottomNavBarAssigment> createState() => _BottomNavBarAssigmentState();
}

class _BottomNavBarAssigmentState extends State<BottomNavBarAssigment> {
  final List<Widget> pages = [
    Homepage(),
    BookPdf(),
    ViewCoursesPage(),
    ProgressReportPage(),
  ];

  int _selectedPage = 0;

  final Color creamColor = Color(0xFFFFF8E1); // Cream Color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: pages[_selectedPage],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PhysicalModel(
          color: creamColor,
          elevation: 8,
          shadowColor: Colors.black45,
          borderRadius: BorderRadius.circular(30),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              color: creamColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.red[800],
              unselectedItemColor: Colors.grey[700],
              currentIndex: _selectedPage,
              onTap: (index) {
                setState(() {
                  _selectedPage = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/images/Home_icon.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.home),
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book),
                  label: 'Books',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/images/quiz.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.quiz),
                  ),
                  label: 'Quiz',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Progress',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
