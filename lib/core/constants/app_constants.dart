class AppConstants {
  static const String appName = 'LAAN POS Transfer Hub';
  static const String appVersion = '1.0.0';

  static const String tokenStorageKey = 'auth_token_key';
  static const String usernameStorageKey = 'auth_username_key';

  static const String notificationChannelId = 'file_transfers_channel';
  static const String notificationChannelName = 'File Transfers';
  static const String notificationChannelDesc = 'Notifications for file uploads and downloads';

  static const int largeFileThresholdBytes = 50 * 1024 * 1024; // 50 MB
}
