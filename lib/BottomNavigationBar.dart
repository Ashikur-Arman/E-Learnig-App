import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Books.dart';
import 'HomePage.dart';
import 'LivePage.dart';
import 'ProfilePage.dart';
import 'ProgressPage.dart';

class BottomNavBarAssigment extends StatefulWidget {
  const BottomNavBarAssigment({super.key});
  @override
  State<BottomNavBarAssigment> createState() => _BottomNavBarAssigmentState();
}

class _BottomNavBarAssigmentState extends State<BottomNavBarAssigment> {
  List<Widget> pages = [Homepage(), BookPdf(),Livepage(),ProgressPage(),ProfilePage()];
  int _selectedPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedPage],
      bottomNavigationBar: BottomNavigationBar(
        //backgroundColor: Colors.brown.withOpacity(.8),
        items: [
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 24.0,  // Set the desired width
              height: 24.0, // Set the desired height
              child: Image.asset('assets/images/Home_icon.png'),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv),
            label: 'Live',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedPage,
        onTap: (index){
          setState(() {
            _selectedPage=index;
          });
        },
      ),

    );
  }
}

