import '../../../../core/network/api_result.dart';
import '../entities/file_item.dart';
import '../repositories/transfer_repository.dart';

class GetRemoteFilesUseCase {
  final TransferRepository repository;

  GetRemoteFilesUseCase({required this.repository});

  Future<ApiResult<List<FileItem>>> execute() {
    return repository.getRemoteFiles();
  }
}
