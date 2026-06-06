import 'package:flutter/material.dart';
import 'package:thenew/Screens/EducationHomeScreen.dart';
import 'package:thenew/dashboards/distributor_dashboard.dart';
import 'package:thenew/Screens/maindashboardsccreen.dart';
import 'package:thenew/Screens/ourprogramsmain.dart';
import 'package:thenew/Screens/profilescreen.dart';
import 'package:thenew/dashboards/franchisedashboard.dart';
import 'package:thenew/dashboards/schoolDashboard.dart';
import 'package:thenew/dashboards/studentdashboard.dart';
import 'package:thenew/services/joinus.dart';



void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Education LLM',
      home: EducationLLMHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

