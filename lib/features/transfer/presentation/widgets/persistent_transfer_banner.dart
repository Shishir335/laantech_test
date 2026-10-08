import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/transfer_notifier.dart';
import 'transfer_progress_card.dart';

void showTransferManagerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalContext) {
      return const TransferManagerSheetContent();
    },
  );
}

class TransferManagerSheetContent extends ConsumerWidget {
  const TransferManagerSheetContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferState = ref.watch(transferNotifierProvider);
    final notifier = ref.read(transferNotifierProvider.notifier);
    final activeTasks = transferState.activeTasks;
    final allTasks = transferState.allTasksList;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Transfers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${activeTasks.length} in progress • ${formatSpeed(transferState.totalActiveSpeed)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (transferState.completedTasks.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear Done'),
                  onPressed: notifier.clearCompleted,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: allTasks.isEmpty
                ? const Center(
                    child: Text(
                      'No active or recent transfers',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: allTasks.length,
                    itemBuilder: (ctx, idx) {
                      final task = allTasks[idx];
                      return TransferProgressCard(
                        task: task,
                        onPause: () => notifier.pauseTransfer(task.id),
                        onResume: () => notifier.resumeTransfer(task.id),
                        onCancel: () => notifier.cancelTransfer(task.id),
                        onRetry: () => notifier.retryTransfer(task.id),
                        onDelete: () => notifier.deleteTask(task.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class PersistentTransferBanner extends ConsumerWidget {
  const PersistentTransferBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferState = ref.watch(transferNotifierProvider);
    final activeTasks = transferState.activeTasks;

    if (activeTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalActive = activeTasks.length;
    final speed = transferState.totalActiveSpeed;
    final primaryTask = activeTasks.first;

    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: () => showTransferManagerSheet(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sync,
                  color: AppColors.primaryLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$totalActive Transfer${totalActive > 1 ? 's' : ''} Running',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          formatSpeed(speed),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.statusProgress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      primaryTask.fileName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_up,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
