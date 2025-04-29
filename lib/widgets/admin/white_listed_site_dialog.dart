import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';

Future<void> showWhitelistedSiteDialog(
    BuildContext context, Function fetchData) async {
  TextEditingController nameController = TextEditingController();
  TextEditingController domainController = TextEditingController();
  bool isActive = true;
  String selectedPrefix = 'https://';
  String iconUrl = '';
  dynamic pickedFile;

  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add Whitelisted Site'),
            content: SingleChildScrollView(
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Site Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the site name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: domainController,
                        decoration: InputDecoration(
                          labelText: 'Domain',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the domain';
                          }
                          final url = Uri.tryParse(value);
                          if (url == null ||
                              !url.hasScheme ||
                              !url.hasAuthority) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      SwitchListTile(
                        title: Text('Active'),
                        value: isActive,
                        onChanged: (bool value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (result != null) {
                            PlatformFile file = result.files.first;
                            setState(() {
                              iconUrl = 'data:image/png;base64,' +
                                  base64Encode(file.bytes!);
                            });

                            FirebaseStorage storage = FirebaseStorage.instance;
                            String fileName = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            Reference ref =
                                storage.ref().child('icons/$fileName');
                            await ref.putData(file.bytes!);
                            iconUrl = await ref.getDownloadURL();
                          }
                        },
                        child: iconUrl.isEmpty
                            ? Icon(Icons.add_a_photo, size: 50)
                            : Image.memory(
                                base64Decode(iconUrl.split(',').last),
                                width: 100,
                                height: 100),
                      ),
                      if (iconUrl.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Please upload an icon.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (iconUrl.isNotEmpty) {
                      String fullUrl = selectedPrefix + domainController.text;

                      // Use add() to let Firestore generate a document ID
                      await FirebaseFirestore.instance
                          .collection('whitelist')
                          .add({
                        'name': nameController.text,
                        'url': fullUrl,
                        'icon': iconUrl,
                        'status': isActive,
                      });
                      fetchData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please upload an icon.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    Navigator.pop(context);
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
    },
  );
}
