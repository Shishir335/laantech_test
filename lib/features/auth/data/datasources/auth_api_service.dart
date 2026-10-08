import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';

part 'auth_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST(ApiConstants.tokenEndpoint)
  @FormUrlEncoded()
  Future<AuthResponseModel> login(
    @Field('username') String username,
    @Field('password') String password,
  );

  @POST(ApiConstants.registerEndpoint)
  @FormUrlEncoded()
  Future<AuthResponseModel> register(
    @Field('username') String username,
    @Field('password') String password,
  );
}
