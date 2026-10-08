class FileItem {
  final int id;
  final String name;
  final String originalName;
  final int size;
  final String type;
  final String uploadedAt;
  final String url;

  const FileItem({
    required this.id,
    required this.name,
    required this.originalName,
    required this.size,
    required this.type,
    required this.uploadedAt,
    required this.url,
  });
}
