import '../../../../core/network/api_result.dart';
import '../repositories/transfer_repository.dart';

class DownloadFileUseCase {
  final TransferRepository repository;

  DownloadFileUseCase({required this.repository});

  Future<ApiResult<String>> execute({
    required String taskId,
    required String fileName,
    required String remoteUrl,
    required int startByteOffset,
    required void Function(
            int receivedBytes, int totalBytes, double speedBytesPerSec)
        onProgress,
  }) {
    return repository.downloadFile(
      taskId: taskId,
      fileName: fileName,
      remoteUrl: remoteUrl,
      startByteOffset: startByteOffset,
      onProgress: onProgress,
    );
  }

  void pause(String taskId) => repository.pauseTransfer(taskId);
  void cancel(String taskId) => repository.cancelTransfer(taskId);
}
