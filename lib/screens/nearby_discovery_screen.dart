import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class NearbyDiscoveryScreen extends StatefulWidget {
  const NearbyDiscoveryScreen({super.key});

  @override
  State<NearbyDiscoveryScreen> createState() => _NearbyDiscoveryScreenState();
}

class _NearbyDiscoveryScreenState extends State<NearbyDiscoveryScreen> {
  bool _isScanning = false;
  List<String> _foundDevices = [];

  void _toggleScan() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _foundDevices.clear();
        _simulateDiscovery();
      }
    });
  }

  void _simulateDiscovery() async {
    // Simulated discovery sequence
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || !_isScanning) return;
    setState(() => _foundDevices.add('Unknown Device [Signal: Strong]'));
    
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted || !_isScanning) return;
    setState(() => _foundDevices.add('Encrypted Peer [Signal: Weak]'));
  }

  void _connectToDevice(String device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Establishing secure handshake with $device...'),
        backgroundColor: EdithColors.accent,
      ),
    );
    // In a real app, this would exchange tokens via Bluetooth/BLE
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Handshake failed: Device rejected connection.'),
          backgroundColor: EdithColors.danger,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return EdithScaffold(
      title: 'Nearby Discovery',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: GestureDetector(
                onTap: _toggleScan,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isScanning ? EdithColors.accent.withOpacity(0.1) : EdithColors.surface,
                    border: Border.all(
                      color: _isScanning ? EdithColors.accent : EdithColors.border,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isScanning ? Icons.radar : Icons.bluetooth_searching,
                          color: _isScanning ? EdithColors.accent : EdithColors.textSecondary,
                          size: 48,
                        ).animate(target: _isScanning ? 1 : 0).scale(
                            duration: const Duration(milliseconds: 1000), 
                            curve: Curves.easeInOut,
                            begin: const Offset(1, 1),
                            end: const Offset(1.2, 1.2),
                        ).then().scale(
                            duration: const Duration(milliseconds: 1000), 
                            curve: Curves.easeInOut,
                            begin: const Offset(1.2, 1.2),
                            end: const Offset(1, 1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isScanning ? 'SCANNING' : 'TAP TO SCAN',
                          style: TextStyle(
                            color: _isScanning ? EdithColors.accent : EdithColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontFamily: 'SpaceMono',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'DISCOVERED PEERS',
                style: TextStyle(
                  color: EdithColors.textDim,
                  fontSize: 10,
                  letterSpacing: 3,
                  fontFamily: 'SpaceMono',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _foundDevices.isEmpty
                  ? Center(
                      child: Text(
                        _isScanning ? 'Listening for EDITH nodes...' : 'Scanner offline.',
                        style: const TextStyle(
                          color: EdithColors.textSecondary,
                          fontSize: 12,
                          fontFamily: 'SpaceMono',
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _foundDevices.length,
                      itemBuilder: (ctx, i) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: EdithColors.card,
                            border: Border.all(color: EdithColors.border),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.device_unknown, color: EdithColors.accent),
                            title: Text(
                              _foundDevices[i],
                              style: const TextStyle(
                                color: EdithColors.textPrimary,
                                fontSize: 13,
                                fontFamily: 'SpaceMono',
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: () => _connectToDevice(_foundDevices[i]),
                              child: const Text('CONNECT', style: TextStyle(color: EdithColors.accent, fontSize: 11, fontFamily: 'SpaceMono')),
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
