import 'package:flutter/material.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/splash_screen.dart';

void main() {
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KAEL',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
    );
  }
}