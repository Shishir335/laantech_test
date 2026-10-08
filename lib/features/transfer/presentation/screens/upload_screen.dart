import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/file_catalog_provider.dart';
import '../providers/transfer_notifier.dart';
import '../widgets/transfer_progress_card.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends ConsumerState<UploadScreen> {
  String? selectedFilePath;
  String? selectedFileName;
  int selectedFileSize = 0;
  bool isGeneratingSample = false;
  double sampleGenProgress = 0.0;
  String? activeTaskId;

  Future<void> handlePickFile() async {
    final pickedFile = await FilePicker.pickFile(
      type: FileType.any,
    );

    if (pickedFile != null && pickedFile.path != null) {
      final file = File(pickedFile.path!);
      final size = await file.length();
      setState(() {
        selectedFilePath = file.path;
        selectedFileName = pickedFile.name;
        selectedFileSize = size;
      });
    }
  }

  Future<void> handleGenerateSample() async {
    setState(() {
      isGeneratingSample = true;
      sampleGenProgress = 0.0;
    });

    final file = await generateSampleLargeCsvFile(
      fileName: 'pos_catalog_50mb.csv',
      sizeInMb: 50,
      onProgress: (p) {
        if (mounted) setState(() => sampleGenProgress = p);
      },
    );

    final size = await file.length();
    if (mounted) {
      setState(() {
        selectedFilePath = file.path;
        selectedFileName = 'pos_catalog_50mb.csv';
        selectedFileSize = size;
        isGeneratingSample = false;
      });
    }
  }

  Future<void> handleStartUpload() async {
    if (selectedFilePath == null) return;
    final notifier = ref.read(transferNotifierProvider.notifier);
    final taskId = await notifier.startUpload(selectedFilePath!);
    setState(() {
      activeTaskId = taskId;
    });
    ref.read(fileCatalogProvider.notifier).fetchFiles();
  }

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferNotifierProvider);
    final notifier = ref.read(transferNotifierProvider.notifier);
    final activeTask = activeTaskId != null ? transferState.tasks[activeTaskId] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.cloud_upload_outlined,
                          color: AppColors.primaryLight, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'POS Catalog & Report Uploader',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Multipart upload with background persistence',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 420;
                    final pickButton = OutlinedButton.icon(
                      icon: const Icon(Icons.file_open_outlined, size: 18),
                      label: const Text('Pick Large File (>50MB)'),
                      onPressed: isGeneratingSample ? null : handlePickFile,
                    );
                    final generateButton = ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceElevated,
                        foregroundColor: AppColors.secondary,
                      ),
                      icon: isGeneratingSample
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        isGeneratingSample
                            ? 'Generating (${(sampleGenProgress * 100).round()}%)'
                            : 'Generate 50MB CSV',
                      ),
                      onPressed: isGeneratingSample ? null : handleGenerateSample,
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          pickButton,
                          const SizedBox(height: 10),
                          generateButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: pickButton),
                        const SizedBox(width: 12),
                        Expanded(child: generateButton),
                      ],
                    );
                  },
                ),
                if (selectedFilePath != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedFileName ?? 'Selected File',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${formatBytes(selectedFileSize)} ${selectedFileSize >= AppConstants.largeFileThresholdBytes ? "• Meets >50MB requirement" : ""}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: selectedFileSize >=
                                          AppConstants.largeFileThresholdBytes
                                      ? AppColors.statusCompleted
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload, size: 16),
                          label: const Text('Upload'),
                          onPressed: handleStartUpload,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (activeTask != null) ...[
            const Text(
              'Current Upload Status',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TransferProgressCard(
              task: activeTask,
              onPause: () => notifier.pauseTransfer(activeTask.id),
              onResume: () => notifier.resumeTransfer(activeTask.id),
              onCancel: () => notifier.cancelTransfer(activeTask.id),
              onRetry: () => notifier.retryTransfer(activeTask.id),
            ),
          ],
        ],
      ),
    );
  }
}
