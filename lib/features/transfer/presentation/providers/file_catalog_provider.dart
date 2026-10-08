import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/usecases/delete_file_usecase.dart';
import '../../domain/usecases/get_remote_files_usecase.dart';

class FileCatalogState {
  final bool isLoading;
  final List<FileItem> files;
  final String? errorMessage;

  const FileCatalogState({
    this.isLoading = false,
    this.files = const [],
    this.errorMessage,
  });

  FileCatalogState copyWith({
    bool? isLoading,
    List<FileItem>? files,
    String? errorMessage,
  }) {
    return FileCatalogState(
      isLoading: isLoading ?? this.isLoading,
      files: files ?? this.files,
      errorMessage: errorMessage,
    );
  }
}

class FileCatalogNotifier extends StateNotifier<FileCatalogState> {
  final GetRemoteFilesUseCase getFilesUseCase;
  final DeleteFileUseCase deleteFileUseCase;

  FileCatalogNotifier({
    required this.getFilesUseCase,
    required this.deleteFileUseCase,
  }) : super(const FileCatalogState()) {
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await getFilesUseCase.execute();

    switch (result) {
      case ApiSuccess(data: final files):
        state = state.copyWith(isLoading: false, files: files);
      case ApiFailure(exception: final err):
        state = state.copyWith(
          isLoading: false,
          errorMessage: err.message,
        );
    }
  }

  Future<bool> deleteFile(String fileName) async {
    final result = await deleteFileUseCase.execute(fileName);
    switch (result) {
      case ApiSuccess():
        await fetchFiles();
        return true;
      case ApiFailure(exception: final err):
        state = state.copyWith(errorMessage: err.message);
        return false;
    }
  }
}

final fileCatalogProvider =
    StateNotifierProvider<FileCatalogNotifier, FileCatalogState>((ref) {
  return FileCatalogNotifier(
    getFilesUseCase: serviceLocator<GetRemoteFilesUseCase>(),
    deleteFileUseCase: serviceLocator<DeleteFileUseCase>(),
  );
});
