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

  String _currentDomain = ''; // Track current domain
String _currentUrl = '';
  @override
  void initState() {
    super.initState();
    // Initially set current domain to empty to ensure first check runs
    _currentDomain = '';
    print("current domain initially set to empty");
    _initialBlacklistCheck();
  }

  // Initial check before showing any content
  Future<void> _initialBlacklistCheck() async {
    print("Starting initial blacklist check for ${widget.url}");
    // Force check regardless of domain
    final domain = _extractDomain(widget.url);
    print("Extracted initial domain: $domain");

    // Fetch blacklisted domains from Firestore
    print("Fetching blacklist from Firestore for initial check");
    final snapshot =
        await FirebaseFirestore.instance.collection('blacklist').get();

    print("Found ${snapshot.docs.length} blacklist entries for initial check");

    bool isBlacklisted = false;
    for (var doc in snapshot.docs) {
      final blacklistedUrl = doc['url'];
      final blacklistedDomain = _extractDomain(blacklistedUrl);
      print("Initial check - blacklisted domain: $blacklistedDomain");
      final status = doc['status'] ?? false;
      print("Initial check - blacklisted status: $status");

      final isMatch = blacklistedDomain == domain;
      print(
          "Initial check - Domain match: $isMatch (comparing $blacklistedDomain with $domain)");

      if (isMatch && status == true) {
        print(
            "INITIAL CHECK - BLACKLISTED! Domain: $domain is in blacklist with status: $status");
        isBlacklisted = true;
        break;
      }
    }

    setState(() {
      _isBlacklisted = isBlacklisted;
      _currentDomain = domain;
      _isLoading = false;
      print(
          "Initial check completed, isBlacklisted: $_isBlacklisted, currentDomain: $_currentDomain");
    });
  }

// Function to check if the URL is in the whitelist
  Future<void> _checkIfUrlIsBlacklisted(String url) async {
    final domain = _extractDomain(url);
    print("Checking domain: $domain");

    // Skip the check if the domain is the same as the current one
    if (_currentDomain == domain && _currentDomain.isNotEmpty) {
      print("Skipping check - same domain");
      return;
    }

    // Fetch whitelisted domains from Firestore
    print("Fetching whitelist from Firestore");
    final snapshot =
        await FirebaseFirestore.instance.collection('whitelist').get();

    print("Found ${snapshot.docs.length} whitelist entries");

    bool isWhitelisted = false;
    for (var doc in snapshot.docs) {
      final whitelistedUrl = doc['url'];
      final whitelistedDomain = _extractDomain(whitelistedUrl);
      print("whitelisted domain: $whitelistedDomain");
      final status = doc['status'] ?? false; // Ensure 'status' is present
      print("whitelisted status: $status");

      // Check if the domain matches and the status is true
      final isMatch = whitelistedDomain == domain;
      print(
          "Domain match: $isMatch (comparing $whitelistedDomain with $domain)");

      if (isMatch && status == true) {
        print(
            "WHITELISTED! Domain: $domain is in whitelist with status: $status");
        isWhitelisted = true;
        break;
      }
    }

    if (isWhitelisted) {
      print("Domain is whitelisted, updating current domain.");
      setState(() {
        _isBlacklisted = false; // Not blacklisted if in whitelist
        _currentDomain = domain; // Update the current domain
        print(
            "Updated state: _isBlacklisted=$_isBlacklisted, _currentDomain=$_currentDomain");
      });
    } else {
      print("BLACKLISTED! Domain: $domain is not in whitelist");
      setState(() {
        _isBlacklisted = true; // Mark as blacklisted if not in whitelist
        _currentDomain = domain; // Update the current domain
        print(
            "Updated state: _isBlacklisted=$_isBlacklisted, _currentDomain=$_currentDomain");
      });
    }
  }

  // Function to extract domain from URL
  String _extractDomain(String url) {
    try {
      // If URL doesn't start with http/https, add it
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final Uri uri = Uri.parse(url);
      // Remove 'www.' if present for consistent comparison
      String domain = uri.host;
      if (domain.startsWith('www.')) {
        domain = domain.substring(4);
      }
      print("Extracted domain: $domain from $url");
      return domain; // Extracts the domain from the URL
    } catch (e) {
      print("Error extracting domain from $url: $e");
      return '';
    }
  }

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
    // Show loading indicator while checking blacklist
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isBlacklisted) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(_currentDomain),
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final webUri = WebUri(widget.url);

    // Use PopScope to handle back button press

    // Use WillPopScope to handle device back button and WebView back navigation
    return WillPopScope(
        onWillPop: () async {
          // Check if WebView can go back
          bool canGoBack = await _controller.canGoBack();
          if (canGoBack) {
            // Go back within the WebView's history (device back button will only navigate back inside the WebView)
            _controller.goBack();
            return false; // Prevent closing the page
          } else {
            // If no history, close the WebView page
            Navigator.of(context).pop();
            return true; // Allow closing the page
          }
        },
        // Check if WebView can go back
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
                onLoadStart: (controller, url) {
                  if (url != null) {
                    _checkIfUrlIsBlacklisted(url.toString());
                   setState(() {
                     _currentUrl = url.toString();
                   });
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
        ));
  }
}
