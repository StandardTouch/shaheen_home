import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  final String title;
  final String url;
  const WebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late InAppWebViewController _controller;
  double _progress = 0;

  bool _hasError = false;
  String _errorMsg = '';

  void _reload() {
    setState(() {
      _hasError = false;
      _errorMsg = '';
      _progress = 0;
    });
    _controller.loadUrl(
      urlRequest: URLRequest(url: WebUri(widget.url)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: webUri),
            onWebViewCreated: (ctrl) => _controller = ctrl,
            onProgressChanged: (ctrl, progress) {
              setState(() => _progress = progress / 100);
            },
            onLoadError: (ctrl, uri, code, message) {
              setState(() {
                _hasError = true;
                _errorMsg = 'Error $code: $message';
              });
            },
            onLoadHttpError: (ctrl, uri, statusCode, description) {
              setState(() {
                _hasError = true;
                _errorMsg = 'HTTP $statusCode: $description';
              });
            },
          ),
          if (_hasError)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _errorMsg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
