import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BanglaBakaron extends StatefulWidget {
  const BanglaBakaron({super.key});

  @override
  _BanglaBakaronState createState() => _BanglaBakaronState();
}

class _BanglaBakaronState extends State<BanglaBakaron> {
  PdfControllerPinch? pdfController;
  String? localPath;

  final String pdfUrl = 'https://drive.google.com/uc?export=download&id=1Gt_lvDSEexZBAP1TOizDcyxR0I2JZt1i';

  @override
  void initState() {
    super.initState();
    downloadAndLoadPDF();
  }

  Future<void> downloadAndLoadPDF() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/BanglaBakaron.pdf");

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
        title: const Text("বাংলা ভাষার ব্যাকরণ"),
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
