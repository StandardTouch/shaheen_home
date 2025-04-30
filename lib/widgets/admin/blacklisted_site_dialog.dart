import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

Future<void> showBlacklistedSiteDialog(
    BuildContext context, Function fetchData) async {
  TextEditingController domainController = TextEditingController();
  bool isActive = true;

  // Define a regex pattern for a valid domain
  RegExp domainRegex = RegExp(r'^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Blacklisted Site'),
        content: Container(
          width: 500,
          height: 300,
          child: Column(
            children: [
              TextField(
                controller: domainController,
                decoration: InputDecoration(
                  labelText: 'Domain',
                  hintText: 'e.g. example.com', // Placeholder example domain
                  errorText: domainController.text.isNotEmpty &&
                          !domainRegex.hasMatch(domainController.text)
                      ? 'Please enter a valid domain'
                      : null,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\.-]'))
                ],
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
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String url = domainController.text;

              // Check if the domain is valid
              if (domainRegex.hasMatch(url)) {
                // Use add() to let Firestore generate a document ID
                await FirebaseFirestore.instance.collection('blacklist').add({
                  'url': url,
                  'status': isActive,
                });
                fetchData();
                Navigator.pop(context);
              } else {
                // Show an error message if the domain is invalid
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid domain.')),
                );
              }
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
