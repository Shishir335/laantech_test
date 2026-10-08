import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/transfer_task.dart';

Color getStatusColor(TransferStatus status) {
  switch (status) {
    case TransferStatus.inProgress:
      return AppColors.statusProgress;
    case TransferStatus.completed:
      return AppColors.statusCompleted;
    case TransferStatus.paused:
      return AppColors.statusPaused;
    case TransferStatus.failed:
      return AppColors.statusFailed;
    case TransferStatus.cancelled:
      return AppColors.statusCancelled;
    case TransferStatus.queued:
      return AppColors.statusQueued;
  }
}

String getStatusLabel(TransferStatus status) {
  switch (status) {
    case TransferStatus.inProgress:
      return 'TRANSFERRING';
    case TransferStatus.completed:
      return 'COMPLETED';
    case TransferStatus.paused:
      return 'PAUSED';
    case TransferStatus.failed:
      return 'FAILED';
    case TransferStatus.cancelled:
      return 'CANCELLED';
    case TransferStatus.queued:
      return 'QUEUED';
  }
}

class StatusBadge extends StatelessWidget {
  final TransferStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status);
    final label = getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class TransferTypeBadge extends StatelessWidget {
  final TransferType type;

  const TransferTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isUpload = type == TransferType.upload;
    final color = isUpload ? AppColors.primaryLight : AppColors.secondary;
    final icon = isUpload ? Icons.cloud_upload_outlined : Icons.cloud_download_outlined;
    final label = isUpload ? 'UPLOAD' : 'DOWNLOAD';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
