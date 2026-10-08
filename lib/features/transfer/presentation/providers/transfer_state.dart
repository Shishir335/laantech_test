import '../../domain/entities/transfer_task.dart';

enum TransferFilter { all, active, completed, paused, failed }

class TransferState {
  final Map<String, TransferTask> tasks;
  final TransferFilter filter;
  final bool isNetworkOnline;

  const TransferState({
    this.tasks = const {},
    this.filter = TransferFilter.all,
    this.isNetworkOnline = true,
  });

  List<TransferTask> get allTasksList => tasks.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<TransferTask> get activeTasks =>
      allTasksList.where((t) => t.status == TransferStatus.inProgress).toList();

  List<TransferTask> get completedTasks =>
      allTasksList.where((t) => t.status == TransferStatus.completed).toList();

  List<TransferTask> get pausedTasks =>
      allTasksList.where((t) => t.status == TransferStatus.paused).toList();

  List<TransferTask> get failedTasks =>
      allTasksList.where((t) => t.status == TransferStatus.failed).toList();

  List<TransferTask> get filteredTasks {
    switch (filter) {
      case TransferFilter.active:
        return activeTasks;
      case TransferFilter.completed:
        return completedTasks;
      case TransferFilter.paused:
        return pausedTasks;
      case TransferFilter.failed:
        return failedTasks;
      case TransferFilter.all:
        return allTasksList;
    }
  }

  double get totalActiveSpeed =>
      activeTasks.fold(0.0, (sum, t) => sum + t.speedBytesPerSec);

  bool get hasOngoingTransfers => activeTasks.isNotEmpty;

  TransferState copyWith({
    Map<String, TransferTask>? tasks,
    TransferFilter? filter,
    bool? isNetworkOnline,
  }) {
    return TransferState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      isNetworkOnline: isNetworkOnline ?? this.isNetworkOnline,
    );
  }
}
