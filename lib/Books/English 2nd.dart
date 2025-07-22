import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class English2 extends StatefulWidget {
  const English2({super.key});

  @override
  _English2State createState() => _English2State();
}

class _English2State extends State<English2> {
  PdfControllerPinch? pdfController;
  String? localPath;

  final String pdfUrl = 'https://drive.google.com/uc?export=download&id=1I2k47nlS5g8sWOY9H7pH2_g2kKoHGlsA';

  @override
  void initState() {
    super.initState();
    downloadAndLoadPDF();
  }

  Future<void> downloadAndLoadPDF() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/English2.pdf");

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
        title: const Text("English Grammar and Composition"),
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
