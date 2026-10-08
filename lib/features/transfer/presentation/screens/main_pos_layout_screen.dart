import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/persistent_transfer_banner.dart';
import '../widgets/pos_app_bar.dart';
import 'download_screen.dart';
import 'transfer_dashboard_screen.dart';
import 'upload_screen.dart';

class MainPosLayoutScreen extends ConsumerStatefulWidget {
  const MainPosLayoutScreen({super.key});

  @override
  ConsumerState<MainPosLayoutScreen> createState() => MainPosLayoutScreenState();
}

class MainPosLayoutScreenState extends ConsumerState<MainPosLayoutScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    UploadScreen(),
    DownloadScreen(),
    TransferDashboardScreen(),
  ];

  final List<String> screenTitles = const [
    'POS File Uploader',
    'POS File Catalog & Downloads',
    'Transfer Center & Queue',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 720;

        if (isWideScreen) {
          return Scaffold(
            appBar: PosAppBar(title: screenTitles[selectedIndex]),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  backgroundColor: AppColors.surface,
                  indicatorColor: AppColors.primary,
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                  unselectedIconTheme:
                      const IconThemeData(color: AppColors.textSecondary),
                  selectedLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  onDestinationSelected: (idx) {
                    setState(() => selectedIndex = idx);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.cloud_upload_outlined),
                      selectedIcon: Icon(Icons.cloud_upload),
                      label: Text('Upload'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.cloud_download_outlined),
                      selectedIcon: Icon(Icons.cloud_download),
                      label: Text('Download'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
                Expanded(
                  child: Stack(
                    children: [
                      screens[selectedIndex],
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: PersistentTransferBanner(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: PosAppBar(title: screenTitles[selectedIndex]),
          body: Stack(
            children: [
              screens[selectedIndex],
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PersistentTransferBanner(),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primary,
            onDestinationSelected: (idx) {
              setState(() => selectedIndex = idx);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.cloud_upload_outlined),
                selectedIcon: Icon(Icons.cloud_upload, color: Colors.white),
                label: 'Upload',
              ),
              NavigationDestination(
                icon: Icon(Icons.cloud_download_outlined),
                selectedIcon: Icon(Icons.cloud_download, color: Colors.white),
                label: 'Download',
              ),
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: Colors.white),
                label: 'Dashboard',
              ),
            ],
          ),
        );
      },
    );
  }
}
