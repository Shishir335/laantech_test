import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> getSensibleDownloadDirectoryPath() async {
  if (Platform.isAndroid) {
    final downloadsDir = await getExternalStorageDirectory();
    if (downloadsDir != null) {
      return downloadsDir.path;
    }
  }
  final docsDir = await getApplicationDocumentsDirectory();
  return docsDir.path;
}

Future<File> generateSampleLargeCsvFile({
  required String fileName,
  required int sizeInMb,
  void Function(double progress)? onProgress,
}) async {
  final tempDir = await getTemporaryDirectory();
  final targetFile = File('${tempDir.path}/$fileName');
  if (await targetFile.exists()) {
    await targetFile.delete();
  }

  final sink = targetFile.openWrite(mode: FileMode.write);
  sink.writeln('id,sku,product_name,category,inventory_count,unit_price,updated_at');

  const rowTemplate = '10001,SKU-PROD-99881,Commercial POS High-Speed Thermal Receipt Printer,Hardware,450,189.99,2026-10-05T12:00:00Z\n';
  final targetBytes = sizeInMb * 1024 * 1024;
  int writtenBytes = 0;

  final batchSize = 1000;
  final batchString = List.filled(batchSize, rowTemplate).join();
  final batchBytes = batchString.length;

  while (writtenBytes < targetBytes) {
    sink.write(batchString);
    writtenBytes += batchBytes;
    if (onProgress != null) {
      final progress = (writtenBytes / targetBytes).clamp(0.0, 1.0);
      onProgress(progress);
    }
  }

  await sink.flush();
  await sink.close();
  return targetFile;
}
