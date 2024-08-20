import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webinapp/pdf_screen.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Professional WebView Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const WebViewScreen(),
      );
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final InAppWebViewController _webViewController;
  final String _initialUrl = "https://his.honghunghospital.com.vn/GeneratePDF";

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Professional WebView Demo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _webViewController.loadUrl(
                urlRequest: URLRequest(url: WebUri(_initialUrl)),
              ),
            ),
          ],
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(_initialUrl)),
          initialSettings: _webViewSettings,
          onWebViewCreated: _onWebViewCreated,
          shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
          onLoadStart: _onLoadStart,
          onLoadStop: _onLoadStop,
          onProgressChanged: _onProgressChanged,
          onConsoleMessage: _onConsoleMessage,
        ),
      );

  InAppWebViewSettings get _webViewSettings => InAppWebViewSettings(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        javaScriptEnabled: true,
        domStorageEnabled: true,
        useOnLoadResource: true,
        supportMultipleWindows: true,
        useHybridComposition: true,
        javaScriptCanOpenWindowsAutomatically: true,
      );

  void _onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
    _setupJavaScriptHandler(controller);
  }

  void _setupJavaScriptHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: "flutterHandler",
      callback: (args) async {
        final base64String = args[0] as String;
        await _processPdfData(base64String);
      },
    );
  }

  Future<void> _processPdfData(String base64String) async {
    try {
      final pdfBytes = base64Decode(base64String.split(',').last);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp.pdf');
      await file.writeAsBytes(pdfBytes);

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFViewerScreen(filePath: file.path)),
      );
    } catch (e) {
      _showErrorSnackBar('Error processing PDF: $e');
    }
  }

  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
          InAppWebViewController controller,
          NavigationAction navigationAction) async =>
      NavigationActionPolicy.ALLOW;

  void _onLoadStart(InAppWebViewController controller, WebUri? url) {
    debugPrint("Page load started: $url");
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? url) {
    debugPrint("Page load finished: $url");
  }

  void _onProgressChanged(InAppWebViewController controller, int progress) {
    debugPrint('WebView loading (progress: $progress%)');
  }

  void _onConsoleMessage(
      InAppWebViewController controller, ConsoleMessage consoleMessage) {
    debugPrint('Console message: ${consoleMessage.message}');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
