import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class EnglishBook extends StatefulWidget {
  @override
  _EnglishBookState createState() => _EnglishBookState();
}

class _EnglishBookState extends State<EnglishBook> {
  PdfControllerPinch? pdfController;
  String? localPath;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    try {
      // Assets থেকে PDF লোড করা
      final ByteData bytes = await rootBundle.load("assets/pdf/class_one_english.pdf");
      final Uint8List list = bytes.buffer.asUint8List();

      // টেম্প ফোল্ডারে PDF সংরক্ষণ করা
      final tempDir = await getTemporaryDirectory();
      final file = await File("${tempDir.path}/class_one_english.pdf").create();
      await file.writeAsBytes(list);

      setState(() {
        localPath = file.path;
        pdfController = PdfControllerPinch(document: PdfDocument.openFile(localPath!));
      });
    } catch (e) {
      print("Error loading PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Read")),
      body: localPath == null
          ? Center(child: CircularProgressIndicator()) // লোডিং ইন্ডিকেটর
          : PdfViewPinch(controller: pdfController!),
    );
  }
}
