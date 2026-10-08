import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transfer_task.dart';
import 'status_badge.dart';
import 'transfer_action_buttons.dart';
import 'transfer_progress_bar.dart';

class TransferProgressCard extends StatelessWidget {
  final TransferTask task;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback? onDelete;

  const TransferProgressCard({
    super.key,
    required this.task,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onRetry,
    this.onDelete,
  });

  void handleOpenFile(BuildContext context) {
    if (task.filePath != null) {
      OpenFilex.open(task.filePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingBytes = task.totalBytes - task.transferredBytes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isActive
              ? AppColors.primaryLight.withValues(alpha: 0.5)
              : AppColors.border.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  task.type == TransferType.upload
                      ? Icons.upload_file_outlined
                      : Icons.download_for_offline_outlined,
                  color: task.type == TransferType.upload
                      ? AppColors.primaryLight
                      : AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.fileName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        TransferTypeBadge(type: task.type),
                        const SizedBox(width: 8),
                        StatusBadge(status: task.status),
                      ],
                    ),
                  ],
                ),
              ),
              TransferActionButtons(
                task: task,
                onPause: onPause,
                onResume: onResume,
                onCancel: onCancel,
                onRetry: onRetry,
                onOpenFile: () => handleOpenFile(context),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                  tooltip: 'Dismiss task',
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 12),
          TransferProgressBar(
            progress: task.progress,
            status: task.status,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatBytes(task.transferredBytes)} / ${formatBytes(task.totalBytes)} (${task.percentage}%)',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (task.isActive)
                Text(
                  '${formatSpeed(task.speedBytesPerSec)} • ETA ${formatEta(remainingBytes, task.speedBytesPerSec)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.statusProgress,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (task.errorMessage != null && task.status == TransferStatus.failed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.statusFailed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: AppColors.statusFailed),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      task.errorMessage!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.statusFailed,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
