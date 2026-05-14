import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Transparent status bar so gradients show through
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await StorageService.init();

  runApp(const ProviderScope(child: PawPalApp()));
}

class PawPalApp extends StatelessWidget {
  const PawPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawPal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: Routes.onboarding,
      routes: Routes.all,
    );
  }
}
