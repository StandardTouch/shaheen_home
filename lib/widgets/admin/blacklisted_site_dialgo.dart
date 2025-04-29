// blacklisted_site_dialog.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> showBlacklistedSiteDialog(
    BuildContext context, Function fetchData) async {
  TextEditingController domainController = TextEditingController();
  bool isActive = true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Blacklisted Site'),
        content: Column(
          children: [
            TextField(
              controller: domainController,
              decoration: InputDecoration(labelText: 'Domain'),
            ),
            SwitchListTile(
              title: Text('Active'),
              value: isActive,
              onChanged: (bool value) {
                isActive = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String url = domainController.text;

              // Use add() to let Firestore generate a document ID
              await FirebaseFirestore.instance.collection('blacklist').add({
                'url': url,
                'status': isActive,
              });
              fetchData();
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}
