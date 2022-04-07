// ignore_for_file: avoid_print, unnecessary_null_comparison

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String urlPDFPath = "";

  @override
  void initState() {
    super.initState();

    getFileFromUrl(
            "https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf")
        .then((f) {
      setState(() {
        urlPDFPath = f.path;
        print("urlPDFPath : $urlPDFPath");
      });
    });
  }

  Future<File> getFileFromUrl(String url) async {
    try {
      var data = await http.get(Uri.parse(url));
      print("data : ${data.body}");
      var bytes = data.bodyBytes;
      print("bytes : $bytes");
      var dir = await getApplicationDocumentsDirectory();
      print("dir : $dir");
      File file = File("${dir.path}/mypdfonline.pdf");
      print("file : $file");

      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) {
            return const RadialGradient(
              radius: 5,
              colors: [Colors.deepOrange, Colors.white],
            ).createShader(bounds);
          },
          child: const Text(
            "PDF VIEW",
            style: TextStyle(
              fontSize: 18,
              letterSpacing: 2,
              wordSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade600,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //! buttons view
            HomePageDiffrentPdfBtn(
              name: "Pdf View With Buttons",
              press: () {
                if (urlPDFPath != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewPage(path: urlPDFPath),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 30),

            //! simple view
            HomePageDiffrentPdfBtn(
              name: "Simple Pdf View",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SimpleViewPdf(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// diffrent pdf view buttons
class HomePageDiffrentPdfBtn extends StatelessWidget {
  const HomePageDiffrentPdfBtn({
    Key? key,
    required this.name,
    required this.press,
  }) : super(key: key);

  final String name;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.45),
            Colors.white.withOpacity(0.04),
          ],
        ),
      ),
      child: TextButton(
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onPressed: press),
    );
  }
}

//simple pdf view
class SimpleViewPdf extends StatefulWidget {
  const SimpleViewPdf({
    Key? key,
  }) : super(key: key);

  @override
  State<SimpleViewPdf> createState() => _SimpleViewPdfState();
}

class _SimpleViewPdfState extends State<SimpleViewPdf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Simple Pdf View",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SfPdfViewer.network(
            'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf'),
      ),
    );
  }
}

// button pdf view page
class PdfViewPage extends StatefulWidget {
  final String path;

  const PdfViewPage({Key? key, required this.path}) : super(key: key);
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  late PDFViewController _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Buttons Change Page of Pdf",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            autoSpacing: true,
            enableSwipe: false,
            pageSnap: true,
            swipeHorizontal: true,
            nightMode: false,
            onError: (e) {
              print(e);
            },
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages!;
                pdfReady = true;
              });
            },
            onViewCreated: (PDFViewController vc) {
              _pdfViewController = vc;
            },
            onPageChanged: (page, total) {
              setState(() {});
            },
            onPageError: (page, e) {},
          ),
          !pdfReady
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const Offstage()
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _currentPage > 0
              ? FloatingActionButton.extended(
                  heroTag: "1",
                  backgroundColor: Colors.deepOrange,
                  label: Text("Go to ${_currentPage - 1}"),
                  onPressed: () {
                    _currentPage -= 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                )
              : FloatingActionButton.extended(
                  heroTag: "2",
                  backgroundColor: Colors.grey,
                  label: const Text("  MIN  "),
                  onPressed: () {},
                ),
          const SizedBox(width: 10),
          _currentPage + 1 < _totalPages
              ? FloatingActionButton.extended(
                  heroTag: "3",
                  backgroundColor: Colors.deepPurple,
                  label: Text("Go to ${_currentPage + 1}"),
                  onPressed: () {
                    _currentPage += 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                )
              : FloatingActionButton.extended(
                  heroTag: "4",
                  backgroundColor: Colors.grey,
                  label: const Text("  MAX  "),
                  onPressed: () {},
                ),
        ],
      ),
    );
  }
}
