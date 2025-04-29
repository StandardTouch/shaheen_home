import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  final String title;
  final String url;
const WebViewPage({super.key, required this.title, required this.url});
  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late InAppWebViewController _controller;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    // Convert the string URL into a WebUri:
    final webUri = WebUri(widget.url);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: BackButton(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(value: _progress),
        ),
      ),
      
      body: InAppWebView(
        // Use WebUri here:
        initialUrlRequest: URLRequest(url: webUri),
        onWebViewCreated: (ctrl) => _controller = ctrl,
        onProgressChanged: (ctrl, progress) {
          setState(() => _progress = progress / 100);
        },
      ),
    );
  }
}
