import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shaheen_home/website_model.dart';
import 'web_view_page.dart';

class HomePage extends StatefulWidget {
  static const route = "/";
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<LinkItem> whitelistItems = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchWhitelistedSites();
  }

  Future<void> fetchWhitelistedSites() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      // Query the whitelist collection and filter by active status
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('whitelist')
          .where('status', isEqualTo: true)
          .get();

      List<LinkItem> items = [];

      for (var doc in snapshot.docs) {
        items.add(LinkItem(
          name: doc['name'],
          url: doc['url'],
          icon: doc['icon'],
          status: doc['status'] ?? true,
          docId: doc.id,
        ));
      }

      setState(() {
        whitelistItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading websites: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Shaheen',
            style: TextStyle(fontSize: 24),
          ),
          backgroundColor: const Color.fromARGB(255, 241, 243, 245),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
                ? Center(child: Text(error))
                : whitelistItems.isEmpty
                    ? const Center(child: Text('No active websites found'))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final cols = constraints.maxWidth > 600 ? 4 : 2;
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                childAspectRatio: 0.9,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: whitelistItems.length,
                              itemBuilder: (ctx, i) {
                                final item = whitelistItems[i];
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(PageRouteBuilder(
                                      pageBuilder: (ctx, anim, secAnim) =>
                                          WebViewPage(
                                        url: item.url,
                                        title: item.name,
                                      ),

                                      // 300ms for both push & pop:
                                      transitionDuration:
                                          const Duration(milliseconds: 300),
                                      reverseTransitionDuration:
                                          const Duration(milliseconds: 300),

                                      transitionsBuilder: (ctx, animation,
                                          secondaryAnimation, child) {
                                        // tween from right → center
                                        final tween = Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).chain(CurveTween(curve: Curves.ease));

                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ));
                                  },
                                  child: Card(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: CircleAvatar(
                                            radius: 40,
                                            backgroundColor: Colors.transparent,
                                            child: ClipOval(
                                              child: Image.network(
                                                item.icon,
                                                fit: BoxFit.cover,
                                                width: 80,
                                                height: 80,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              (loadingProgress
                                                                      .expectedTotalBytes ??
                                                                  1)
                                                          : null,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(
                                                      Icons.broken_image,
                                                      size: 80);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 25,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item.name,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              Text(item.url,
                                                  style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
