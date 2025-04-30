import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shaheen_home/website_model.dart';
import 'package:shaheen_home/widgets/admin/blacklisted_site_dialog.dart';
import 'package:shaheen_home/widgets/admin/white_listed_site_dialog.dart';

class AdminWebsitesTab extends StatefulWidget {
  const AdminWebsitesTab({super.key});

  @override
  _AdminWebsitesTabState createState() => _AdminWebsitesTabState();
}

class _AdminWebsitesTabState extends State<AdminWebsitesTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<LinkItem> whitelistItems = [];
  List<String> blacklistItems = [];
  List<LinkItem> filteredWhitelistItems = [];
  List<String> filteredBlacklistItems = [];
  Map<String, bool> blacklistStatus = {};
  Map<String, String> blacklistDocIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchData();
  }

  Future<void> fetchData() async {
    QuerySnapshot whitelistSnapshot =
        await FirebaseFirestore.instance.collection('whitelist').get();
    List<LinkItem> tempWhitelistItems = [];
    for (var doc in whitelistSnapshot.docs) {
      tempWhitelistItems.add(LinkItem(
        name: doc['name'],
        url: doc['url'],
        icon: doc['icon'],
        status: doc['status'] ?? true,
        docId: doc.id,
      ));
    }

    QuerySnapshot blacklistSnapshot =
        await FirebaseFirestore.instance.collection('blacklist').get();
    List<String> tempBlacklistItems = [];
    Map<String, bool> tempBlacklistStatus = {};
    Map<String, String> tempBlacklistDocIds = {};

    for (var doc in blacklistSnapshot.docs) {
      String url = doc['url'];
      tempBlacklistItems.add(url);
      tempBlacklistStatus[url] = doc['status'] ?? true;
      tempBlacklistDocIds[url] = doc.id;
    }

    setState(() {
      whitelistItems = tempWhitelistItems;
      filteredWhitelistItems = tempWhitelistItems;
      blacklistItems = tempBlacklistItems;
      filteredBlacklistItems = tempBlacklistItems;
      blacklistStatus = tempBlacklistStatus;
      blacklistDocIds = tempBlacklistDocIds;
    });
  }

  void filterList(String query) {
    final filteredWhitelist = whitelistItems.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.url.toLowerCase().contains(query.toLowerCase());
    }).toList();

    final filteredBlacklist = blacklistItems.where((url) {
      return url.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredWhitelistItems = filteredWhitelist;
      filteredBlacklistItems = filteredBlacklist;
    });
  }

  void deleteItem(String url) async {
    final item = filteredWhitelistItems.firstWhere((item) => item.url == url);

    await FirebaseFirestore.instance
        .collection('whitelist')
        .doc(item.docId)
        .delete();

    setState(() {
      filteredWhitelistItems.removeWhere((item) => item.url == url);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item deleted')),
    );
  }

  void toggleActiveStatus(String url, bool status) async {
    final item =
        filteredWhitelistItems.firstWhere((element) => element.url == url);

    await FirebaseFirestore.instance
        .collection('whitelist')
        .doc(item.docId)
        .update({'status': status});

    setState(() {
      item.status = status;
    });
  }

  void toggleBlacklistStatus(String url, bool status) async {
    String docId = blacklistDocIds[url]!;

    await FirebaseFirestore.instance
        .collection('blacklist')
        .doc(docId)
        .update({'status': status});

    setState(() {
      blacklistStatus[url] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Websites'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Whitelisted Sites'),
            Tab(text: 'Blacklisted Sites'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: filterList,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Whitelisted Sites
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          showWhitelistedSiteDialog(context, fetchData),
                      child: const Text('Add Whitelisted Site'),
                    ),
                    Expanded(
                      child: filteredWhitelistItems.isEmpty
                          ? const Center(child: Text('No results found'))
                          : ListView.builder(
                              itemCount: filteredWhitelistItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredWhitelistItems[index];
                                return ListTile(
                                  leading: Image.network(item.icon),
                                  title: Text(item.name),
                                  subtitle: Text(item.url),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          item.status
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: item.status
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        onPressed: () {
                                          toggleActiveStatus(
                                              item.url, !item.status);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          deleteItem(item.url);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                // Blacklisted Sites
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          showBlacklistedSiteDialog(context, fetchData),
                      child: const Text('Add Blacklisted Site'),
                    ),
                    Expanded(
                      child: filteredBlacklistItems.isEmpty
                          ? const Center(child: Text('No results found'))
                          : ListView.builder(
                              itemCount: filteredBlacklistItems.length,
                              itemBuilder: (context, index) {
                                final url = filteredBlacklistItems[index];
                                final isActive = blacklistStatus[url] ?? true;
                                return ListTile(
                                  title: Text(url),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isActive
                                              ? Icons.block
                                              : Icons.block_flipped,
                                          color: isActive
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          toggleBlacklistStatus(url, !isActive);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          String docId = blacklistDocIds[url]!;

                                          await FirebaseFirestore.instance
                                              .collection('blacklist')
                                              .doc(docId)
                                              .delete();

                                          setState(() {
                                            filteredBlacklistItems
                                                .removeAt(index);
                                            blacklistStatus.remove(url);
                                            blacklistDocIds.remove(url);
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text('$url deleted'),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
