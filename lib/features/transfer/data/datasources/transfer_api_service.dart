import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/file_item_model.dart';
import '../models/upload_response_model.dart';

part 'transfer_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class TransferApiService {
  factory TransferApiService(Dio dio, {String baseUrl}) = _TransferApiService;

  @GET(ApiConstants.getFilesEndpoint)
  Future<FileListResponseModel> getFiles();

  @DELETE(ApiConstants.deleteEndpoint)
  Future<DeleteResponseModel> deleteFile(
    @Query('file') String fileName,
  );
}
