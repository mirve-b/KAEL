import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataModel()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: const KaelApp(),
    ),
  );
}

class KaelApp extends StatelessWidget {
  const KaelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectData, child) {
        final theme = KaelTheme.of(projectData.isLightMode);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'KAEL',
          theme: ThemeData(
            brightness: projectData.isLightMode ? Brightness.light : Brightness.dark,
            scaffoldBackgroundColor: Colors.transparent,
            useMaterial3: true,
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red.shade900,
              brightness: projectData.isLightMode ? Brightness.light : Brightness.dark,
            ),
          ),
          builder: (context, screenWidget) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: theme.canvasBackground,
              child: screenWidget,
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
