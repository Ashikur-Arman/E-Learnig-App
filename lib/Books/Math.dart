import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Math extends StatefulWidget {
  const Math({super.key});

  @override
  _MathState createState() => _MathState();
}

class _MathState extends State<Math> {
  PdfControllerPinch? pdfController;
  String? localPath;

  final String pdfUrl = 'https://drive.google.com/uc?export=download&id=1Re27pwMKH-Qg2xCADzPRXnyb_1f43Sm4';

  @override
  void initState() {
    super.initState();
    downloadAndLoadPDF();
  }

  Future<void> downloadAndLoadPDF() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/math.pdf");

      if (await file.exists()) {
        print('✅ Loading PDF from cache...');
      } else {
        print('⬇️ Downloading PDF...');
        final response = await http.get(Uri.parse(pdfUrl));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          print('✅ Download complete and saved locally.');
        } else {
          print("❌ Failed to download PDF: ${response.statusCode}");
          return;
        }
      }

      setState(() {
        localPath = file.path;
        pdfController = PdfControllerPinch(
          document: PdfDocument.openFile(localPath!),
        );
      });
    } catch (e) {
      print("❌ Error loading PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("সাধারণ গণিত"),
        backgroundColor: Colors.deepPurple,
      ),
      body: localPath == null
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(controller: pdfController!),
    );
  }

  @override
  void dispose() {
    pdfController?.dispose();
    super.dispose();
  }
}
