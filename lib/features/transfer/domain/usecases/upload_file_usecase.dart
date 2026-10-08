import '../../../../core/network/api_result.dart';
import '../entities/file_item.dart';
import '../repositories/transfer_repository.dart';

class UploadFileUseCase {
  final TransferRepository repository;

  UploadFileUseCase({required this.repository});

  Future<ApiResult<FileItem>> execute({
    required String taskId,
    required String filePath,
    required void Function(int sentBytes, int totalBytes, double speedBytesPerSec)
        onProgress,
  }) {
    return repository.uploadFile(
      taskId: taskId,
      filePath: filePath,
      onProgress: onProgress,
    );
  }

  void pause(String taskId) => repository.pauseTransfer(taskId);
  void cancel(String taskId) => repository.cancelTransfer(taskId);
}
