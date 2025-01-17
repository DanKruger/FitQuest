import 'package:fitquest/di.dart';
import 'package:fitquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fitquest/presentation/viewmodels/excercise_viewmodel.dart';
import 'package:fitquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:fitquest/presentation/viewmodels/social_viewmodel.dart';
import 'package:fitquest/presentation/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDi();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme lightMode = ColorScheme(
        brightness: Brightness.light,
        primary: Colors.deepOrange,
        onPrimary: Colors.white,
        secondary: Colors.deepOrange,
        onSecondary: Colors.white,
        onInverseSurface: Colors.grey[400],
        error: Colors.red,
        onError: Colors.white,
        surface: Colors.grey[300]!,
        surfaceTint: Colors.grey[350],
        onSurface: Colors.black,
        surfaceBright: Colors.white.withOpacity(0.7),
        shadow: Colors.black.withOpacity(0.2),
        surfaceDim: Colors.grey[400]);

    ColorScheme darkMode = lightMode.copyWith(
      brightness: Brightness.dark,
      surface: Colors.grey[850],
      surfaceTint: Colors.grey[850],
      surfaceDim: Colors.grey[700],
      onInverseSurface: Colors.grey[700],
      surfaceContainer: Colors.grey[850],
      surfaceBright: Colors.grey[800],
      shadow: Colors.grey[900],
      onSecondaryContainer: Colors.white,
      onSurface: Colors.white,
      onPrimary: Colors.black,
      onPrimaryContainer: Colors.black,
      onSurfaceVariant: Colors.white60,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewmodel>(
          key: const Key('Auth ViewModel'),
          create: (_) => locate<AuthViewmodel>(),
        ),
        ChangeNotifierProvider<MapViewmodel>(
          create: (_) => locate<MapViewmodel>(),
        ),
        ChangeNotifierProvider<ExcerciseViewmodel>(
          create: (_) => locate<ExcerciseViewmodel>(),
        ),
        ChangeNotifierProvider<SocialViewmodel>(
          create: (_) => locate<SocialViewmodel>(),
        )
      ],
      child: MaterialApp(
        theme: ThemeData(colorScheme: lightMode, useMaterial3: true),
        darkTheme: ThemeData(colorScheme: darkMode, useMaterial3: true),
        themeMode: ThemeMode.system,
        home: const MainView(),
      ),
    );
  }
}
