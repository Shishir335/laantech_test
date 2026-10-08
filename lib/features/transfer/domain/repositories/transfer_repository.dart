import '../../../../core/network/api_result.dart';
import '../entities/file_item.dart';

abstract class TransferRepository {
  Future<ApiResult<List<FileItem>>> getRemoteFiles();

  Future<ApiResult<bool>> deleteRemoteFile(String fileName);

  Future<ApiResult<FileItem>> uploadFile({
    required String taskId,
    required String filePath,
    required void Function(int sentBytes, int totalBytes, double speedBytesPerSec)
        onProgress,
  });

  Future<ApiResult<String>> downloadFile({
    required String taskId,
    required String fileName,
    required String remoteUrl,
    required int startByteOffset,
    required void Function(
            int receivedBytes, int totalBytes, double speedBytesPerSec)
        onProgress,
  });

  void pauseTransfer(String taskId);

  void cancelTransfer(String taskId);
}
