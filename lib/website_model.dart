import 'dart:io';

class LinkItem {
  final String name;
  final String url;
  final File? logo;
  LinkItem({ required this.name, required this.url, this.logo });
}