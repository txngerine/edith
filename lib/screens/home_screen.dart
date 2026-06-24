import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/common_widgets.dart';
import '../controllers/home_controller.dart';
import 'messages_list_screen.dart';
import 'vault_screen.dart';
import 'settings_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _screens = [
    MessagesListScreen(),
    ScanScreen(),
    VaultScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Obx(() => Scaffold(
          body: _screens[controller.navIndex.value],
          bottomNavigationBar: EdithBottomNav(
            currentIndex: controller.navIndex.value,
            onTap: controller.setTab,
          ),
        ));
  }
}
