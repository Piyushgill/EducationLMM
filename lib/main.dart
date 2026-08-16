import 'package:flutter/material.dart';
import 'package:thenew/Screens/EducationHomeScreen.dart';
import 'package:thenew/dashboards/distributor_dashboard.dart';
import 'package:thenew/dashboards/franchisedashboard.dart';
import 'package:thenew/dashboards/schoolDashboard.dart';
import 'package:thenew/dashboards/studentdashboard.dart';
import 'package:thenew/dashboards/super_admin_dashboard.dart';
import 'package:thenew/dashboards/agent_dashboard.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:thenew/services/kyc_status_screen.dart';
import 'package:thenew/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = await SessionManager.getSession();
  runApp(MyApp(initialSession: session));
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic>? initialSession;
  const MyApp({super.key, this.initialSession});

  Widget _getInitialScreen() {
    if (initialSession == null) {
      return const EducationLLMHomeScreen();
    }
    
    final role = initialSession!['role'];
    if (role == 'Super Admin') {
      return SuperAdminDashboard();
    }

    final status = initialSession!['kyc_status'];
    if (status == 'Approved') {
      switch (role) {
        case "Distributor":
          return const DistributorDashboard();
        case "Franchise Partner":
          return const FranchiseDashboard();
        case "School":
          return const SchoolDashboard();
        case "Student":
          return const StudentDashboard();
        case "Agent":
          return const AgentDashboard();
        default:
          return const DistributorDashboard();
      }
    } else {
      return KycStatusScreen(userSession: initialSession!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Education LLM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.compact,
      ),
      home: _getInitialScreen(),
      onGenerateRoute: Routes.generateRoute,
    );
  }
}

