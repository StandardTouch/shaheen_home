class LinkItem {
  final String name;
  final String url;
  final String icon; // path to your asset image
  bool status; // Enabled or Disabled
  final String docId; // Firestore document ID

  LinkItem({
    required this.name,
    required this.url,
    required this.icon,
    this.status = true, // Default status is true (enabled)
    required this.docId,
  });
}
