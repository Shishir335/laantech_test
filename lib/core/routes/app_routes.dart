import 'package:flutter/material.dart';

import '../../features/transfer/presentation/screens/download_screen.dart';
import '../../features/transfer/presentation/screens/main_pos_layout_screen.dart';
import '../../features/transfer/presentation/screens/transfer_dashboard_screen.dart';
import '../../features/transfer/presentation/screens/upload_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const String home = '/';
  static const String upload = '/upload';
  static const String download = '/download';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const MainPosLayoutScreen(),
        upload: (context) => const UploadScreen(),
        download: (context) => const DownloadScreen(),
        dashboard: (context) => const TransferDashboardScreen(),
      };
}
