import '../../domain/entities/file_item.dart';

class FileItemModel {
  final int id;
  final String name;
  final String originalName;
  final int size;
  final String type;
  final String uploadedAt;
  final String url;

  FileItemModel({
    required this.id,
    required this.name,
    required this.originalName,
    required this.size,
    required this.type,
    required this.uploadedAt,
    required this.url,
  });

  factory FileItemModel.fromJson(Map<String, dynamic> json) {
    return FileItemModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      originalName: json['original_name'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      type: json['type'] as String? ?? 'application/octet-stream',
      uploadedAt: json['uploaded_at'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'original_name': originalName,
        'size': size,
        'type': type,
        'uploaded_at': uploadedAt,
        'url': url,
      };

  FileItem toEntity() => FileItem(
        id: id,
        name: name,
        originalName: originalName,
        size: size,
        type: type,
        uploadedAt: uploadedAt,
        url: url,
      );
}

class FileListResponseModel {
  final bool success;
  final String? user;
  final int count;
  final List<FileItemModel> files;
  final String? error;

  FileListResponseModel({
    required this.success,
    this.user,
    required this.count,
    required this.files,
    this.error,
  });

  factory FileListResponseModel.fromJson(Map<String, dynamic> json) {
    final rawFiles = json['files'] as List<dynamic>? ?? [];
    return FileListResponseModel(
      success: json['success'] as bool? ?? false,
      user: json['user'] as String?,
      count: json['count'] as int? ?? 0,
      files: rawFiles
          .map((f) => FileItemModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
    );
  }
}
