import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Livepage extends StatefulWidget {
  const Livepage({super.key});

  @override
  State<Livepage> createState() => _LivepageState();
}

class _LivepageState extends State<Livepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live......"),
      ),
      body: Center(
        child: Text("No data available"),
      ),
    );
  }
}
