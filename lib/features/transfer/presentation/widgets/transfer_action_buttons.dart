import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/transfer_task.dart';

class TransferActionButtons extends StatelessWidget {
  final TransferTask task;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback? onOpenFile;

  const TransferActionButtons({
    super.key,
    required this.task,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onRetry,
    this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (task.status == TransferStatus.inProgress) ...[
          IconButton(
            icon: const Icon(Icons.pause_circle_outline, color: AppColors.statusPaused),
            tooltip: 'Pause transfer',
            onPressed: onPause,
          ),
          IconButton(
            icon: const Icon(Icons.cancel_outlined, color: AppColors.statusFailed),
            tooltip: 'Cancel transfer',
            onPressed: onCancel,
          ),
        ] else if (task.status == TransferStatus.paused) ...[
          IconButton(
            icon: const Icon(Icons.play_circle_outline, color: AppColors.statusProgress),
            tooltip: 'Resume transfer',
            onPressed: onResume,
          ),
          IconButton(
            icon: const Icon(Icons.cancel_outlined, color: AppColors.statusFailed),
            tooltip: 'Cancel transfer',
            onPressed: onCancel,
          ),
        ] else if (task.status == TransferStatus.failed ||
            task.status == TransferStatus.cancelled) ...[
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: AppColors.primaryLight),
            tooltip: 'Retry transfer',
            onPressed: onRetry,
          ),
        ] else if (task.status == TransferStatus.completed &&
            task.filePath != null &&
            onOpenFile != null) ...[
          IconButton(
            icon: const Icon(Icons.folder_open_outlined, color: AppColors.accent),
            tooltip: 'Open downloaded file',
            onPressed: onOpenFile,
          ),
        ],
      ],
    );
  }
}
