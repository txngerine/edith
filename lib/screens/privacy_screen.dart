import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/common_widgets.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _ghostMode = true;
  bool _readReceipts = false;
  bool _typingIndicators = false;
  bool _screenshotDetection = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ghostMode = prefs.getBool('ghost_mode') ?? true;
      _readReceipts = prefs.getBool('read_receipts') ?? false;
      _typingIndicators = prefs.getBool('typing_indicators') ?? false;
      _screenshotDetection = prefs.getBool('screenshot_detection') ?? true;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ghost_mode', _ghostMode);
    await prefs.setBool('read_receipts', _readReceipts);
    await prefs.setBool('typing_indicators', _typingIndicators);
    await prefs.setBool('screenshot_detection', _screenshotDetection);
  }

  @override
  Widget build(BuildContext context) {
    return EdithScaffold(
      title: 'Privacy',
      body: ListView(
        children: [
          ToggleRow(
            icon: Icons.visibility_off_outlined,
            title: 'Ghost Mode',
            subtitle: 'Hide your activity',
            value: _ghostMode,
            onChanged: (v) {
              setState(() => _ghostMode = v);
              _savePrefs();
            },
          ),
          ToggleRow(
            icon: Icons.done_all_outlined,
            title: 'Read Receipts',
            subtitle: 'Let others see you read',
            value: _readReceipts,
            onChanged: (v) {
              setState(() => _readReceipts = v);
              _savePrefs();
            },
          ),
          ToggleRow(
            icon: Icons.keyboard_outlined,
            title: 'Typing Indicators',
            subtitle: 'Show when typing',
            value: _typingIndicators,
            onChanged: (v) {
              setState(() => _typingIndicators = v);
              _savePrefs();
            },
          ),
          ToggleRow(
            icon: Icons.screenshot_monitor_outlined,
            title: 'Screenshot Detection',
            subtitle: 'Get notified of screenshots',
            value: _screenshotDetection,
            onChanged: (v) {
              setState(() => _screenshotDetection = v);
              _savePrefs();
            },
          ),
          const SectionHeader('Auto-Actions'),
          NavRow(
            icon: Icons.timer_outlined,
            title: 'Auto Destruction',
            subtitle: 'Messages disappear',
            trailing: 'On >',
            onTap: () {},
          ),
          NavRow(
            icon: Icons.rotate_right_outlined,
            title: 'Identity Rotation',
            subtitle: 'Daily at 00:00',
            trailing: 'On >',
            onTap: () {},
          ),
          NavRow(
            icon: Icons.devices_outlined,
            title: 'Device Sessions',
            subtitle: 'Manage active sessions',
            trailing: '>',
            onTap: () {},
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
