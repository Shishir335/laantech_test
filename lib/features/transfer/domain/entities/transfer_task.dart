enum TransferType { upload, download }

enum TransferStatus {
  queued,
  inProgress,
  paused,
  completed,
  failed,
  cancelled,
}

class TransferTask {
  final String id;
  final String fileName;
  final String? filePath;
  final String? remoteUrl;
  final int totalBytes;
  final int transferredBytes;
  final double speedBytesPerSec;
  final TransferType type;
  final TransferStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransferTask({
    required this.id,
    required this.fileName,
    this.filePath,
    this.remoteUrl,
    required this.totalBytes,
    this.transferredBytes = 0,
    this.speedBytesPerSec = 0.0,
    required this.type,
    this.status = TransferStatus.queued,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progress {
    if (totalBytes <= 0) return 0.0;
    return (transferredBytes / totalBytes).clamp(0.0, 1.0);
  }

  int get percentage => (progress * 100).round();

  bool get isActive => status == TransferStatus.inProgress;
  bool get isPaused => status == TransferStatus.paused;
  bool get isCompleted => status == TransferStatus.completed;
  bool get isFailed => status == TransferStatus.failed;

  TransferTask copyWith({
    String? id,
    String? fileName,
    String? filePath,
    String? remoteUrl,
    int? totalBytes,
    int? transferredBytes,
    double? speedBytesPerSec,
    TransferType? type,
    TransferStatus? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransferTask(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      totalBytes: totalBytes ?? this.totalBytes,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
      type: type ?? this.type,
      status: status ?? this.status,
      errorMessage: errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
