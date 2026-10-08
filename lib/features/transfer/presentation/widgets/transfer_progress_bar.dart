import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/transfer_task.dart';
import 'status_badge.dart';

class TransferProgressBar extends StatelessWidget {
  final double progress;
  final TransferStatus status;

  const TransferProgressBar({
    super.key,
    required this.progress,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(status);
    final clampedProgress = progress.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final filledWidth = totalWidth * clampedProgress;

        return Stack(
          children: [
            Container(
              height: 8,
              width: totalWidth,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              height: 8,
              width: filledWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [
                    statusColor.withValues(alpha: 0.7),
                    statusColor,
                  ],
                ),
                boxShadow: [
                  if (status == TransferStatus.inProgress)
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
