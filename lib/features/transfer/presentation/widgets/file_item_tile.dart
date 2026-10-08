import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/file_item.dart';

IconData getFileIcon(String fileName) {
  final ext = fileName.split('.').last.toLowerCase();
  switch (ext) {
    case 'csv':
    case 'xlsx':
    case 'xls':
      return Icons.table_chart_outlined;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'webp':
      return Icons.image_outlined;
    case 'mp4':
    case 'mkv':
    case 'mov':
      return Icons.video_file_outlined;
    case 'pdf':
      return Icons.picture_as_pdf_outlined;
    default:
      return Icons.insert_drive_file_outlined;
  }
}

class FileItemTile extends StatelessWidget {
  final FileItem fileItem;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final bool isDownloading;

  const FileItemTile({
    super.key,
    required this.fileItem,
    required this.onDownload,
    required this.onDelete,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              getFileIcon(fileItem.name),
              color: AppColors.secondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileItem.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formatBytes(fileItem.size),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileItem.uploadedAt.split('T').first,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded, color: AppColors.primaryLight),
            tooltip: 'Download file',
            onPressed: isDownloading ? null : onDownload,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.statusFailed, size: 20),
            tooltip: 'Delete from server',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
