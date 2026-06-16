import 'package:flutter/material.dart';
import 'package:thenew/Screens/splash_screen.dart';
import 'package:thenew/routes/routes.dart';
import 'package:thenew/routes/routes_name.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Education LLM',
      debugShowCheckedModeBanner: false,
      initialRoute: RoutesName.educationHomeScreen,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}

