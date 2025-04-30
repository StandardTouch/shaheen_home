import 'package:flutter/material.dart';
import 'package:shaheen_home/dummy_data.dart';
import 'web_view_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        body: LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth > 600 ? 4 : 2;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: dummyItems.length,
                itemBuilder: (ctx, i) {
                  final item = dummyItems[i];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (ctx, anim, secAnim) => WebViewPage(
                          url: item.url,
                          title: item.name,
                        ),

                        // 300ms for both push & pop:
                        transitionDuration: const Duration(milliseconds: 300),
                        reverseTransitionDuration:
                            const Duration(milliseconds: 300),

                        transitionsBuilder:
                            (ctx, animation, secondaryAnimation, child) {
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(item.logoAsset),
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: Image.asset(
                                  item.logoAsset,
                                  fit: BoxFit
                                      .cover, // Ensures the image fills the circle and maintains aspect ratio
                                  width:
                                      80, // The width and height control the size inside the avatar
                                  height: 80,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(item.url,
                                    style: TextStyle(
                                        color: Colors.grey[700], fontSize: 12)),
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
