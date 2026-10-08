import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/transfer_notifier.dart';
import '../providers/transfer_state.dart';
import '../widgets/transfer_progress_card.dart';
import '../widgets/transfer_stat_card.dart';

class TransferDashboardScreen extends ConsumerWidget {
  const TransferDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferState = ref.watch(transferNotifierProvider);
    final notifier = ref.read(transferNotifierProvider.notifier);
    final filteredTasks = transferState.filteredTasks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 600;
              final statCards = [
                TransferStatCard(
                  title: 'Active Transfers',
                  value: '${transferState.activeTasks.length}',
                  icon: Icons.sync,
                  iconColor: AppColors.statusProgress,
                  subtitle: transferState.hasOngoingTransfers
                      ? formatSpeed(transferState.totalActiveSpeed)
                      : 'Idle',
                ),
                TransferStatCard(
                  title: 'Completed',
                  value: '${transferState.completedTasks.length}',
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.statusCompleted,
                  subtitle: 'Transfers finished',
                ),
                TransferStatCard(
                  title: 'Paused',
                  value: '${transferState.pausedTasks.length}',
                  icon: Icons.pause_circle_outline,
                  iconColor: AppColors.statusPaused,
                  subtitle: 'Can be resumed',
                ),
                TransferStatCard(
                  title: 'Failed',
                  value: '${transferState.failedTasks.length}',
                  icon: Icons.error_outline,
                  iconColor: AppColors.statusFailed,
                  subtitle: 'Needs retry',
                ),
              ];

              if (isWide) {
                return GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: statCards,
                );
              } else {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: statCards,
                );
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transfer Queue & History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (transferState.completedTasks.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear Completed'),
                  onPressed: notifier.clearCompleted,
                ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TransferFilter.values.map((f) {
                final isSelected = transferState.filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      f.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    checkmarkColor: Colors.white,
                    onSelected: (_) => notifier.setFilter(f),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (filteredTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.history_outlined, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No ${transferState.filter != TransferFilter.all ? transferState.filter.name : ''} transfers found',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Transfers initiated from Upload or Download will appear here.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ...filteredTasks.map((task) {
              return TransferProgressCard(
                task: task,
                onPause: () => notifier.pauseTransfer(task.id),
                onResume: () => notifier.resumeTransfer(task.id),
                onCancel: () => notifier.cancelTransfer(task.id),
                onRetry: () => notifier.retryTransfer(task.id),
                onDelete: () => notifier.deleteTask(task.id),
              );
            }),
        ],
      ),
    );
  }
}
