import 'file_item_model.dart';

class UploadResponseModel {
  final bool success;
  final String? message;
  final FileItemModel? file;
  final String? error;

  UploadResponseModel({
    required this.success,
    this.message,
    this.file,
    this.error,
  });

  factory UploadResponseModel.fromJson(Map<String, dynamic> json) {
    return UploadResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      file: json['file'] != null
          ? FileItemModel.fromJson(json['file'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
    );
  }
}

class DeleteResponseModel {
  final bool success;
  final String? message;
  final String? file;
  final String? error;

  DeleteResponseModel({
    required this.success,
    this.message,
    this.file,
    this.error,
  });

  factory DeleteResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      file: json['file'] as String?,
      error: json['error'] as String?,
    );
  }
}
