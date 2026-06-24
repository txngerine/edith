import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

// ─── IMPORTANT: Replace with your Supabase project credentials ───────────────
const _supabaseUrl = 'https://kyjwgqwzaiztsfwlhvpl.supabase.co';
const _supabaseAnonKey = 'sb_publishable_QUZcjWyV3d_feG-AW1sNMw_bAy2C-6R';
const turnstileSiteKey = '0x4AAAAAADqMipXY6wltPL7ExjuH-xZGGz8';
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dark system UI overlay
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF080808),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  developer.log('[EDITH] Initializing Supabase client', name: 'EDITH');
  developer.log('[EDITH] Supabase URL: $_supabaseUrl', name: 'EDITH');
  try {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
    );
    developer.log('[EDITH] Supabase initialized successfully', name: 'EDITH');
  } catch (e) {
    developer.log('[EDITH] Supabase initialization FAILED: $e', name: 'EDITH');
    rethrow;
  }

  runApp(const EdithApp());
}

class EdithApp extends StatelessWidget {
  const EdithApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EDITH',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
