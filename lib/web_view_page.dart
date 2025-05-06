import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isBlacklisted = false;
  bool _isLoading = true; // Add loading state
  String _currentUrl = ''; // Track the current URL

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url; // Initialize with the starting URL
    _loadInitialUrl();
  }

  // Initialize WebView with URL
  _loadInitialUrl() {
    setState(() {
      _isLoading = false;
    });
  }
  void _reload() {
  setState(() {
    _hasError = false;   // Reset error state
    _errorMsg = '';      // Clear any previous error message
    _progress = 0;       // Reset progress bar
  });

  // Reload using the current URL being tracked
  _controller.loadUrl(
    urlRequest: URLRequest(url: WebUri(_currentUrl)),  // Use _currentUrl instead of widget.url
  );
}


  // Function to extract domain from URL
  String _extractDomain(String url) {
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final Uri uri = Uri.parse(url);
      String domain = uri.host;
      if (domain.startsWith('www.')) domain = domain.substring(4);
      return domain;
    } catch (e) {
      return '';
    }
  }

  // Handle URL loading to check for blacklist
  Future<void> _checkIfUrlIsBlacklisted(String url) async {
    final domain = _extractDomain(url);
    print("Checking domain: $domain");

    // Skip the check if the domain is the same as the current one
    if (_currentUrl == url && _currentUrl.isNotEmpty) return;

    final snapshot = await FirebaseFirestore.instance.collection('blacklist').get();

    bool isBlacklisted = false;
    for (var doc in snapshot.docs) {
      final blacklistedUrl = doc['url'];
      final blacklistedDomain = _extractDomain(blacklistedUrl);
      final status = doc['status'] ?? false;

      if (blacklistedDomain == domain && status == true) {
        isBlacklisted = true;
        break;
      }
    }

    setState(() {
      _isBlacklisted = isBlacklisted;
      _currentUrl = url; // Update the current URL
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking the URL domain
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isBlacklisted) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(_extractDomain(_currentUrl)),  // Show the URL that was attempted and is blacklisted
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.red.shade50,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                color: Colors.red,
                size: 100,
              ),
              SizedBox(height: 20),
              Text(
                'You are not allowed to open this URL  \n $_currentUrl \n Contact your administrator for more info',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: ()  {
                  Navigator.of(context).pop();
                },
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        bool canGoBack = await _controller.canGoBack();
        if (canGoBack) {
          _controller.goBack();
          return false; // Prevent closing the page
        } else {
          Navigator.of(context).pop();
          return true; // Allow closing the page
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: LinearProgressIndicator(value: _progress),
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              onWebViewCreated: (InAppWebViewController ctrl) {
                _controller = ctrl;
              },
              onProgressChanged: (ctrl, progress) {
                setState(() => _progress = progress / 100);
              },
              onLoadStart: (controller, url) {
                if (url != null) {
                  _checkIfUrlIsBlacklisted(url.toString());
                }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url?.toString();
                if (url != null) {
                  await _checkIfUrlIsBlacklisted(url);
                  if (_isBlacklisted) {
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                return NavigationActionPolicy.ALLOW;
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
      ),
    );
  }
}
