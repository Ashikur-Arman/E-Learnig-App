import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BanglaSahitto extends StatefulWidget {
  const BanglaSahitto({super.key});

  @override
  _BanglaSahittoState createState() => _BanglaSahittoState();
}

class _BanglaSahittoState extends State<BanglaSahitto> {
  PdfControllerPinch? pdfController;
  String? localPath;

  // নতুন PDF URL (Direct download লিংক ফরম্যাটে)
  final String pdfUrl = 'https://drive.google.com/uc?export=download&id=1al_Aia4Gwe8blSblDQoXcLZrmgwlOleF';

  @override
  void initState() {
    super.initState();
    downloadAndLoadPDF();
  }

  Future<void> downloadAndLoadPDF() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/BanglaSahitto.pdf");

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
        title: const Text("বাংলা সাহিত্য"),
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
