import 'dart:math';

String formatBytes(int bytes, {int decimals = 1}) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  int i = (log(bytes) / log(1024)).floor();
  if (i >= suffixes.length) i = suffixes.length - 1;
  double num = bytes / pow(1024, i);
  return '${num.toStringAsFixed(decimals)} ${suffixes[i]}';
}

String formatSpeed(double bytesPerSecond) {
  if (bytesPerSecond <= 0) return '0 KB/s';
  if (bytesPerSecond < 1024 * 1024) {
    return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
  }
  return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
}

String formatEta(int remainingBytes, double bytesPerSecond) {
  if (bytesPerSecond <= 0 || remainingBytes <= 0) return '--';
  int seconds = (remainingBytes / bytesPerSecond).round();
  if (seconds < 60) return '${seconds}s';
  int minutes = seconds ~/ 60;
  int remainingSecs = seconds % 60;
  return '${minutes}m ${remainingSecs}s';
}
