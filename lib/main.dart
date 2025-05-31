// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'screens/home_screens.dart';
import 'screens/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => Login(context),
        '/home': (context) => const HomeScreens(accessToken: ''),
      },
    );
  }
}
