import 'package:flutter/material.dart';
import 'package:shaheen_home/dummy_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({ super.key });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Shaheen')),
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
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // circular logo
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(item.logoAsset),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        // name & url
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(item.url,
                                  style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
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
