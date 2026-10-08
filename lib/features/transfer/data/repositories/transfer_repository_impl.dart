import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/utils/file_utils.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_api_service.dart';
import '../models/upload_response_model.dart';

class TransferRepositoryImpl implements TransferRepository {
  final Dio dio;
  final TransferApiService apiService;
  final Map<String, CancelToken> activeCancelTokens = {};

  TransferRepositoryImpl({
    required this.dio,
    required this.apiService,
  });

  @override
  Future<ApiResult<List<FileItem>>> getRemoteFiles() async {
    try {
      final response = await apiService.getFiles();
      if (response.success) {
        final items = response.files.map((m) => m.toEntity()).toList();
        return ApiSuccess(items);
      }
      return ApiFailure(
        ServerException(message: response.error ?? 'Failed to fetch files'),
      );
    } on DioException catch (e) {
      return ApiFailure(
        ServerException(
          message: e.response?.data is Map
              ? e.response?.data['error']?.toString() ?? e.message ?? 'Network error'
              : e.message ?? 'Network error',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return ApiFailure(AppException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<bool>> deleteRemoteFile(String fileName) async {
    try {
      final response = await apiService.deleteFile(fileName);
      if (response.success) {
        return const ApiSuccess(true);
      }
      return ApiFailure(
        ServerException(message: response.error ?? 'Failed to delete file'),
      );
    } on DioException catch (e) {
      return ApiFailure(ServerException(message: e.message ?? 'Network error'));
    } catch (e) {
      return ApiFailure(AppException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<FileItem>> uploadFile({
    required String taskId,
    required String filePath,
    required void Function(int sentBytes, int totalBytes, double speedBytesPerSec)
        onProgress,
  }) async {
    final cancelToken = CancelToken();
    activeCancelTokens[taskId] = cancelToken;

    int lastSent = 0;
    int lastTime = DateTime.now().millisecondsSinceEpoch;

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ApiFailure(AppException(message: 'File does not exist at $filePath'));
      }

      final fileName = file.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        ApiConstants.uploadEndpoint,
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: (sent, total) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final timeDiff = (now - lastTime) / 1000.0;
          double speed = 0.0;
          if (timeDiff > 0.3) {
            speed = (sent - lastSent) / timeDiff;
            lastSent = sent;
            lastTime = now;
          }
          onProgress(sent, total, speed);
        },
      );

      final uploadResult = UploadResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (uploadResult.success && uploadResult.file != null) {
        return ApiSuccess(uploadResult.file!.toEntity());
      }
      return ApiFailure(
        ServerException(message: uploadResult.error ?? 'Upload failed on server'),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return ApiFailure(CancelledException(message: 'Upload paused or cancelled'));
      }
      return ApiFailure(
        ServerException(
          message: e.response?.data is Map
              ? e.response?.data['error']?.toString() ?? e.message ?? 'Upload failed'
              : e.message ?? 'Upload failed',
        ),
      );
    } catch (e) {
      return ApiFailure(AppException(message: e.toString()));
    } finally {
      activeCancelTokens.remove(taskId);
    }
  }

  @override
  Future<ApiResult<String>> downloadFile({
    required String taskId,
    required String fileName,
    required String remoteUrl,
    required int startByteOffset,
    required void Function(
            int receivedBytes, int totalBytes, double speedBytesPerSec)
        onProgress,
  }) async {
    final cancelToken = CancelToken();
    activeCancelTokens[taskId] = cancelToken;

    int lastReceived = startByteOffset;
    int lastTime = DateTime.now().millisecondsSinceEpoch;

    try {
      final saveDir = await getSensibleDownloadDirectoryPath();
      final destinationPath = '$saveDir/$fileName';
      final targetFile = File(destinationPath);

      final headers = <String, dynamic>{};
      FileMode fileMode = FileMode.write;

      if (startByteOffset > 0 && await targetFile.exists()) {
        headers['Range'] = 'bytes=$startByteOffset-';
        fileMode = FileMode.append;
      }

      final response = await dio.get<ResponseBody>(
        remoteUrl,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
        ),
        cancelToken: cancelToken,
      );

      final contentRange = response.headers.value('content-range');
      int totalBytes = -1;
      if (contentRange != null && contentRange.contains('/')) {
        final parts = contentRange.split('/');
        if (parts.length > 1) {
          totalBytes = int.tryParse(parts[1]) ?? -1;
        }
      }
      if (totalBytes <= 0) {
        final lengthHeader = response.headers.value('content-length');
        if (lengthHeader != null) {
          final streamLen = int.tryParse(lengthHeader) ?? -1;
          totalBytes = streamLen > 0 ? startByteOffset + streamLen : -1;
        }
      }

      final sink = targetFile.openWrite(mode: fileMode);
      int currentReceived = startByteOffset;

      await for (final chunk in response.data!.stream) {
        sink.add(chunk);
        currentReceived += chunk.length;

        final now = DateTime.now().millisecondsSinceEpoch;
        final timeDiff = (now - lastTime) / 1000.0;
        double speed = 0.0;
        if (timeDiff > 0.3) {
          speed = (currentReceived - lastReceived) / timeDiff;
          lastReceived = currentReceived;
          lastTime = now;
        }
        onProgress(currentReceived, totalBytes, speed);
      }

      await sink.flush();
      await sink.close();

      return ApiSuccess(destinationPath);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return ApiFailure(
            CancelledException(message: 'Download paused or cancelled'));
      }
      return ApiFailure(ServerException(message: e.message ?? 'Download failed'));
    } catch (e) {
      return ApiFailure(AppException(message: e.toString()));
    } finally {
      activeCancelTokens.remove(taskId);
    }
  }

  @override
  void pauseTransfer(String taskId) {
    final token = activeCancelTokens[taskId];
    if (token != null && !token.isCancelled) {
      token.cancel('Paused by user');
    }
  }

  @override
  void cancelTransfer(String taskId) {
    final token = activeCancelTokens[taskId];
    if (token != null && !token.isCancelled) {
      token.cancel('Cancelled by user');
    }
  }
}
