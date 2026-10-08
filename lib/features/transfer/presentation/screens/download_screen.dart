import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/entities/transfer_task.dart';
import '../providers/file_catalog_provider.dart';
import '../providers/transfer_notifier.dart';
import '../widgets/file_item_tile.dart';
import '../widgets/transfer_progress_card.dart';

class DownloadScreen extends ConsumerWidget {
  const DownloadScreen({super.key});

  void handleStartDownload(WidgetRef ref, FileItem file) {
    ref.read(transferNotifierProvider.notifier).startDownload(file);
  }

  void handleDeleteFile(BuildContext context, WidgetRef ref, FileItem file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete File?'),
        content: Text('Are you sure you want to delete "${file.name}" from the cloud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusFailed),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(fileCatalogProvider.notifier).deleteFile(file.name);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogState = ref.watch(fileCatalogProvider);
    final transferState = ref.watch(transferNotifierProvider);
    final notifier = ref.read(transferNotifierProvider.notifier);

    final activeDownloads = transferState.allTasksList
        .where((t) => t.type == TransferType.download)
        .toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(fileCatalogProvider.notifier).fetchFiles(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloud Storage & Downloads',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Select previously uploaded files to download locally',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primaryLight),
                  onPressed: () => ref.read(fileCatalogProvider.notifier).fetchFiles(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activeDownloads.isNotEmpty) ...[
              const Text(
                'Recent & Active Downloads',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ...activeDownloads.take(3).map((task) {
                return TransferProgressCard(
                  task: task,
                  onPause: () => notifier.pauseTransfer(task.id),
                  onResume: () => notifier.resumeTransfer(task.id),
                  onCancel: () => notifier.cancelTransfer(task.id),
                  onRetry: () => notifier.retryTransfer(task.id),
                  onDelete: () => notifier.deleteTask(task.id),
                );
              }),
              const SizedBox(height: 20),
            ],
            const Text(
              'Available Files On Server',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (catalogState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (catalogState.files.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text(
                      'No files uploaded yet',
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Upload catalogs or reports first from the Upload tab.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...catalogState.files.map((file) {
                final isDownloading = transferState.activeTasks.any(
                  (t) => t.type == TransferType.download && t.fileName == file.name,
                );
                return FileItemTile(
                  fileItem: file,
                  isDownloading: isDownloading,
                  onDownload: () => handleStartDownload(ref, file),
                  onDelete: () => handleDeleteFile(context, ref, file),
                );
              }),
          ],
        ),
      ),
    );
  }
}
