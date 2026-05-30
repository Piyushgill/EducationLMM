import 'package:flutter/material.dart';
import 'package:thenew/Screens/dashboard.dart';
import 'package:thenew/Screens/maindashboardsccreen.dart';
import 'package:thenew/Screens/ourprogramsmain.dart';
import 'package:thenew/Screens/profilescreen.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book sells',
      home:  MainDashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

