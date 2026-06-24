import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import 'messages_list_screen.dart';
import 'vault_screen.dart';
import 'settings_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final _screens = const [
    MessagesListScreen(),
    ScanScreen(),
    VaultScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_navIndex],
      bottomNavigationBar: EdithBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}
