import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/sound_service.dart';
import 'state/dish_provider.dart';
import 'theme/nothing_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sound player for timer alerts
  await SoundService().init();

  // Configure system UI overlay style for Nothing OS AMOLED aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: NothingTheme.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CookieApp());
}

class CookieApp extends StatelessWidget {
  const CookieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DishProvider()),
      ],
      child: MaterialApp(
        title: 'Cookie',
        debugShowCheckedModeBanner: false,
        theme: NothingTheme.darkTheme,
        home: const DashboardScreen(),
      ),
    );
  }
}
