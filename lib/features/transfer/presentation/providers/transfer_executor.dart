import 'dart:io';
import '../../../../core/network/api_result.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/usecases/download_file_usecase.dart';
import '../../domain/usecases/upload_file_usecase.dart';

class TransferExecutor {
  final UploadFileUseCase uploadUseCase;
  final DownloadFileUseCase downloadUseCase;
  final NotificationService notificationService;

  TransferExecutor({
    required this.uploadUseCase,
    required this.downloadUseCase,
    required this.notificationService,
  });

  Future<ApiResult<FileItem>> executeUpload({
    required String taskId,
    required String filePath,
    required void Function(int sent, int total, double speed) onProgress,
  }) async {
    final notificationId = taskId.hashCode.abs();
    final fileName = filePath.split(Platform.pathSeparator).last;

    notificationService.showProgressNotification(
      id: notificationId,
      title: 'Uploading $fileName',
      body: '0%',
      progress: 0,
      maxProgress: 100,
    );

    return uploadUseCase.execute(
      taskId: taskId,
      filePath: filePath,
      onProgress: (sent, total, speed) {
        final pct = total > 0 ? (sent / total * 100).round() : 0;
        notificationService.showProgressNotification(
          id: notificationId,
          title: 'Uploading $fileName',
          body: '$pct%',
          progress: pct,
          maxProgress: 100,
        );
        onProgress(sent, total, speed);
      },
    );
  }

  Future<ApiResult<String>> executeDownload({
    required String taskId,
    required String fileName,
    required String remoteUrl,
    required int startByteOffset,
    required int expectedTotalBytes,
    required void Function(int received, int total, double speed) onProgress,
  }) async {
    final notificationId = taskId.hashCode.abs();

    notificationService.showProgressNotification(
      id: notificationId,
      title: 'Downloading $fileName',
      body: 'Connecting...',
      progress: 0,
      maxProgress: 100,
    );

    return downloadUseCase.execute(
      taskId: taskId,
      fileName: fileName,
      remoteUrl: remoteUrl,
      startByteOffset: startByteOffset,
      onProgress: (received, total, speed) {
        final actualTotal = total > 0 ? total : expectedTotalBytes;
        final pct = actualTotal > 0 ? (received / actualTotal * 100).round() : 0;

        notificationService.showProgressNotification(
          id: notificationId,
          title: 'Downloading $fileName',
          body: '$pct%',
          progress: pct,
          maxProgress: 100,
        );
        onProgress(received, actualTotal, speed);
      },
    );
  }
}
