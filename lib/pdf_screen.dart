import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerScreen extends StatelessWidget {
  final String filePath;

  const PDFViewerScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePDF(context),
          ),
        ],
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        fitPolicy: FitPolicy.BOTH,
        onRender: (pages) => _onPdfRender(context, pages),
        onError: (error) => _onPdfError(context, error),
        onPageError: (page, error) => _onPdfPageError(context, page, error),
        onViewCreated: (PDFViewController pdfViewController) {
          // You can store the controller and use it for operations like
          // jumping to a specific page, getting the current page, etc.
        },
      ),
    );
  }

  void _sharePDF(BuildContext context) {
    // Implement PDF sharing functionality
    // This could use a plugin like share_plus to share the PDF file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF sharing not implemented')),
    );
  }

  void _onPdfRender(BuildContext context, int? pages) {
    if (pages != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF rendered, total pages: $pages')),
      );
    }
  }

  void _onPdfError(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading PDF: $error')),
    );
  }

  void _onPdfPageError(BuildContext context, int? page, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error on page ${page ?? 'unknown'}: $error')),
    );
  }
}
