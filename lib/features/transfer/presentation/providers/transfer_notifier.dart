import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/entities/transfer_task.dart';
import '../../domain/usecases/download_file_usecase.dart';
import '../../domain/usecases/upload_file_usecase.dart';
import 'transfer_executor.dart';
import 'transfer_state.dart';

class TransferNotifier extends StateNotifier<TransferState> {
  final UploadFileUseCase uploadUseCase;
  final DownloadFileUseCase downloadUseCase;
  final NotificationService notificationService;
  late final TransferExecutor executor;
  final Uuid uuid = const Uuid();

  TransferNotifier({
    required this.uploadUseCase,
    required this.downloadUseCase,
    required this.notificationService,
  }) : super(const TransferState()) {
    executor = TransferExecutor(
      uploadUseCase: uploadUseCase,
      downloadUseCase: downloadUseCase,
      notificationService: notificationService,
    );
  }

  void setFilter(TransferFilter filter) => state = state.copyWith(filter: filter);

  void updateTaskInState(TransferTask updatedTask) {
    final updatedMap = Map<String, TransferTask>.from(state.tasks);
    updatedMap[updatedTask.id] = updatedTask;
    state = state.copyWith(tasks: updatedMap);
  }

  Future<String?> startUpload(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    final taskId = uuid.v4();
    final fileName = file.path.split(Platform.pathSeparator).last;
    final totalBytes = await file.length();

    final task = TransferTask(
      id: taskId,
      fileName: fileName,
      filePath: filePath,
      totalBytes: totalBytes,
      type: TransferType.upload,
      status: TransferStatus.inProgress,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    updateTaskInState(task);

    final result = await executor.executeUpload(
      taskId: taskId,
      filePath: filePath,
      onProgress: (sent, total, speed) {
        final current = state.tasks[taskId];
        if (current == null || current.status != TransferStatus.inProgress) return;
        updateTaskInState(current.copyWith(
          transferredBytes: sent,
          totalBytes: total,
          speedBytesPerSec: speed,
          updatedAt: DateTime.now(),
        ));
      },
    );

    final currentTask = state.tasks[taskId];
    if (currentTask == null) return taskId;
    final notifId = taskId.hashCode.abs();

    if (currentTask.status == TransferStatus.paused ||
        currentTask.status == TransferStatus.cancelled) {
      notificationService.cancelNotification(notifId);
      return taskId;
    }

    switch (result) {
      case ApiSuccess(data: final uploadedItem):
        updateTaskInState(currentTask.copyWith(
          status: TransferStatus.completed,
          remoteUrl: uploadedItem.url,
          transferredBytes: currentTask.totalBytes,
          speedBytesPerSec: 0.0,
          updatedAt: DateTime.now(),
        ));
        notificationService.showCompletionNotification(
          id: notifId,
          title: 'Upload Completed',
          body: '$fileName uploaded successfully.',
          payload: AppRoutes.dashboard,
        );
      case ApiFailure(exception: final err):
        updateTaskInState(currentTask.copyWith(
          status: TransferStatus.failed,
          errorMessage: err.message,
          speedBytesPerSec: 0.0,
          updatedAt: DateTime.now(),
        ));
        notificationService.showCompletionNotification(
          id: notifId,
          title: 'Upload Failed',
          body: '$fileName: ${err.message}',
          payload: AppRoutes.dashboard,
        );
    }
    return taskId;
  }

  Future<String?> startDownload(FileItem fileItem) async {
    final taskId = uuid.v4();
    final task = TransferTask(
      id: taskId,
      fileName: fileItem.name,
      remoteUrl: fileItem.url,
      totalBytes: fileItem.size,
      type: TransferType.download,
      status: TransferStatus.inProgress,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    updateTaskInState(task);
    return runDownloadTask(taskId: taskId, startByteOffset: 0);
  }

  Future<String?> runDownloadTask({
    required String taskId,
    required int startByteOffset,
  }) async {
    final currentTask = state.tasks[taskId];
    if (currentTask == null) return null;

    final result = await executor.executeDownload(
      taskId: taskId,
      fileName: currentTask.fileName,
      remoteUrl: currentTask.remoteUrl!,
      startByteOffset: startByteOffset,
      expectedTotalBytes: currentTask.totalBytes,
      onProgress: (received, total, speed) {
        final current = state.tasks[taskId];
        if (current == null || current.status != TransferStatus.inProgress) return;
        updateTaskInState(current.copyWith(
          transferredBytes: received,
          totalBytes: total,
          speedBytesPerSec: speed,
          updatedAt: DateTime.now(),
        ));
      },
    );

    final postTask = state.tasks[taskId];
    if (postTask == null) return taskId;
    final notifId = taskId.hashCode.abs();

    if (postTask.status == TransferStatus.paused ||
        postTask.status == TransferStatus.cancelled) {
      notificationService.cancelNotification(notifId);
      return taskId;
    }

    switch (result) {
      case ApiSuccess(data: final savedPath):
        updateTaskInState(postTask.copyWith(
          status: TransferStatus.completed,
          filePath: savedPath,
          transferredBytes: postTask.totalBytes,
          speedBytesPerSec: 0.0,
          updatedAt: DateTime.now(),
        ));
        notificationService.showCompletionNotification(
          id: notifId,
          title: 'Download Completed',
          body: '${postTask.fileName} downloaded successfully.',
          payload: AppRoutes.download,
        );
      case ApiFailure(exception: final err):
        updateTaskInState(postTask.copyWith(
          status: TransferStatus.failed,
          errorMessage: err.message,
          speedBytesPerSec: 0.0,
          updatedAt: DateTime.now(),
        ));
        notificationService.showCompletionNotification(
          id: notifId,
          title: 'Download Failed',
          body: '${postTask.fileName}: ${err.message}',
          payload: AppRoutes.download,
        );
    }
    return taskId;
  }

  void pauseTransfer(String taskId) {
    final task = state.tasks[taskId];
    if (task == null || task.status != TransferStatus.inProgress) return;
    if (task.type == TransferType.upload) {
      uploadUseCase.pause(taskId);
    } else {
      downloadUseCase.pause(taskId);
    }
    updateTaskInState(task.copyWith(
      status: TransferStatus.paused,
      speedBytesPerSec: 0.0,
      updatedAt: DateTime.now(),
    ));
    notificationService.cancelNotification(taskId.hashCode.abs());
  }

  Future<void> resumeTransfer(String taskId) async {
    final task = state.tasks[taskId];
    if (task == null) return;
    updateTaskInState(task.copyWith(
      status: TransferStatus.inProgress,
      errorMessage: null,
      updatedAt: DateTime.now(),
    ));
    if (task.type == TransferType.upload) {
      if (task.filePath != null) await startUpload(task.filePath!);
    } else {
      await runDownloadTask(taskId: taskId, startByteOffset: task.transferredBytes);
    }
  }

  void cancelTransfer(String taskId) {
    final task = state.tasks[taskId];
    if (task == null) return;
    if (task.type == TransferType.upload) {
      uploadUseCase.cancel(taskId);
    } else {
      downloadUseCase.cancel(taskId);
    }
    updateTaskInState(task.copyWith(
      status: TransferStatus.cancelled,
      speedBytesPerSec: 0.0,
      updatedAt: DateTime.now(),
    ));
    notificationService.cancelNotification(taskId.hashCode.abs());
  }

  void retryTransfer(String taskId) {
    final task = state.tasks[taskId];
    if (task == null) return;
    if (task.type == TransferType.upload && task.filePath != null) {
      startUpload(task.filePath!);
    } else if (task.type == TransferType.download && task.remoteUrl != null) {
      updateTaskInState(task.copyWith(
        status: TransferStatus.inProgress,
        errorMessage: null,
        transferredBytes: 0,
      ));
      runDownloadTask(taskId: taskId, startByteOffset: 0);
    }
  }

  void deleteTask(String taskId) {
    final updatedMap = Map<String, TransferTask>.from(state.tasks);
    updatedMap.remove(taskId);
    state = state.copyWith(tasks: updatedMap);
    notificationService.cancelNotification(taskId.hashCode.abs());
  }

  void clearCompleted() {
    final updatedMap = Map<String, TransferTask>.from(state.tasks);
    updatedMap.removeWhere((_, t) => t.status == TransferStatus.completed);
    state = state.copyWith(tasks: updatedMap);
  }
}

final transferNotifierProvider =
    StateNotifierProvider<TransferNotifier, TransferState>((ref) {
  return TransferNotifier(
    uploadUseCase: serviceLocator<UploadFileUseCase>(),
    downloadUseCase: serviceLocator<DownloadFileUseCase>(),
    notificationService: serviceLocator<NotificationService>(),
  );
});
