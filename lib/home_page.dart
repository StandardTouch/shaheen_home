import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shaheen_home/website_model.dart';

/// simple data holder

class HomePage extends StatefulWidget {
  const HomePage({ super.key });
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<LinkItem> _items = [];

  // form fields & image holder
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _url = '';
  File? _pickedLogo;

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedLogo = File(picked.path));
    }
  }

  void _showAddDialog() {
    // reset form state
    _formKey.currentState?.reset();
    _pickedLogo = null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Link'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // name
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  onSaved: (v) => _name = v!.trim(),
                ),
                // url
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Website URL'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final uri = Uri.tryParse(v.trim());
                    if (uri == null || !uri.hasAbsolutePath) return 'Invalid URL';
                    return null;
                  },
                  onSaved: (v) => _url = v!.trim(),
                ),
                const SizedBox(height: 12),
                // image picker
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Pick Logo'),
                      onPressed: _pickLogo,
                    ),
                    const SizedBox(width: 8),
                    if (_pickedLogo != null)
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.file(_pickedLogo!, fit: BoxFit.cover),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState!.save();
                setState(() {
                  _items.add(LinkItem(name: _name, url: _url, logo: _pickedLogo));
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
@override
Widget build(BuildContext context) {
  return SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Shaheen'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final item = _items[i];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: item.logo != null
                            ? Image.file(item.logo!, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported, size: 48),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(item.url,
                                style: TextStyle(color: Colors.grey[700])),
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
