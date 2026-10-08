import '../../../../core/network/api_result.dart';
import '../repositories/transfer_repository.dart';

class DeleteFileUseCase {
  final TransferRepository repository;

  DeleteFileUseCase({required this.repository});

  Future<ApiResult<bool>> execute(String fileName) {
    return repository.deleteRemoteFile(fileName);
  }
}
