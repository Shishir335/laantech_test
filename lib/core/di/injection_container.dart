import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../routes/app_routes.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

import '../../features/auth/data/datasources/auth_api_service.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

import '../../features/transfer/data/datasources/transfer_api_service.dart';
import '../../features/transfer/data/repositories/transfer_repository_impl.dart';
import '../../features/transfer/domain/repositories/transfer_repository.dart';
import '../../features/transfer/domain/usecases/delete_file_usecase.dart';
import '../../features/transfer/domain/usecases/download_file_usecase.dart';
import '../../features/transfer/domain/usecases/get_remote_files_usecase.dart';
import '../../features/transfer/domain/usecases/upload_file_usecase.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // 1. External & Storage
  final sharedPrefs = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  serviceLocator.registerLazySingleton<StorageService>(
    () => StorageService(preferences: serviceLocator<SharedPreferences>()),
  );

  // 2. Notifications
  final notificationService = NotificationService();
  await notificationService.initialize(
    onSelectNotification: (response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        rootNavigatorKey.currentState?.pushNamed(payload);
      }
    },
  );
  serviceLocator.registerLazySingleton<NotificationService>(
    () => notificationService,
  );

  // 3. Network Dio
  serviceLocator.registerLazySingleton<Dio>(
    () => createDioClient(storageService: serviceLocator<StorageService>()),
  );

  // 4. Auth Layer
  serviceLocator.registerLazySingleton<AuthApiService>(
    () => AuthApiService(serviceLocator<Dio>()),
  );
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiService: serviceLocator<AuthApiService>(),
      storageService: serviceLocator<StorageService>(),
    ),
  );

  // 5. Transfer Layer
  serviceLocator.registerLazySingleton<TransferApiService>(
    () => TransferApiService(serviceLocator<Dio>()),
  );
  serviceLocator.registerLazySingleton<TransferRepository>(
    () => TransferRepositoryImpl(
      dio: serviceLocator<Dio>(),
      apiService: serviceLocator<TransferApiService>(),
    ),
  );

  // 6. Use Cases
  serviceLocator.registerLazySingleton<GetRemoteFilesUseCase>(
    () => GetRemoteFilesUseCase(repository: serviceLocator<TransferRepository>()),
  );
  serviceLocator.registerLazySingleton<UploadFileUseCase>(
    () => UploadFileUseCase(repository: serviceLocator<TransferRepository>()),
  );
  serviceLocator.registerLazySingleton<DownloadFileUseCase>(
    () => DownloadFileUseCase(repository: serviceLocator<TransferRepository>()),
  );
  serviceLocator.registerLazySingleton<DeleteFileUseCase>(
    () => DeleteFileUseCase(repository: serviceLocator<TransferRepository>()),
  );
}
