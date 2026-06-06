import 'package:flutter/material.dart';
import 'package:thenew/Screens/EducationHomeScreen.dart';
import 'package:thenew/Screens/admin_screen.dart';
import 'package:thenew/Screens/splash_screen.dart';
import 'package:thenew/dashboardCardDetails/Batch_Management_Screen.dart';
import 'package:thenew/dashboardCardDetails/Centre_Details_Screen.dart';
import 'package:thenew/dashboardCardDetails/Expected_Commission_Screen.dart';
import 'package:thenew/dashboardCardDetails/Fee_Collection_Screen.dart';
import 'package:thenew/dashboardCardDetails/FranchiseKitOrderScreen.dart';
import 'package:thenew/dashboardCardDetails/Student_Enrollment_Screen.dart';
import 'package:thenew/dashboardCardDetails/active_schools_screen.dart';
import 'package:thenew/dashboardCardDetails/commission_screen.dart';
import 'package:thenew/dashboardCardDetails/network_size_screen.dart';
import 'package:thenew/dashboardCardDetails/revenue_screen.dart';
import 'package:thenew/dashboardCardDetails/total_students_screen.dart';
import 'package:thenew/dashboardCardDetails/visitors_screen.dart';
import 'package:thenew/dashboards/distributor_dashboard.dart';
import 'package:thenew/dashboards/franchisedashboard.dart';
import 'package:thenew/dashboards/schoolDashboard.dart';
import 'package:thenew/dashboards/studentdashboard.dart';
import 'package:thenew/services/joinus.dart';

class Routes{
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
      case '/home_screen':
        return MaterialPageRoute(builder: (context) => EducationLLMHomeScreen());

      case '/splash_screen':
        return MaterialPageRoute(builder: (context) => SplashScreen());

      case '/join_us':
        return MaterialPageRoute(builder: (context) => JoinUsScreen());

      case '/distributor_dash':
        return MaterialPageRoute(builder: (context) => DistributorDashboard());

      case '/school_dash':
        return MaterialPageRoute(builder: (context) => SchoolDashboard());

      case '/franchise_dash':
        return MaterialPageRoute(builder: (context) => FranchiseDashboard());

      case '/student_dash':
        return MaterialPageRoute(builder: (context) => StudentDashboard());

      case '/admin_screen':
        return MaterialPageRoute(builder: (context) => AdminScreen());

      case '/network_size_screen':
        return MaterialPageRoute(builder: (context) => NetworkSizeScreen());
      case '/active_school_screen':
        return MaterialPageRoute(builder: (context) => ActiveSchoolsScreen());
      case '/batch_management_screen':
        return MaterialPageRoute(builder: (context) => BatchManagementScreen());
      case '/center_detail_screen':
        return MaterialPageRoute(builder: (context) => CentreDetailsScreen());
      case '/commission_screen':
        return MaterialPageRoute(builder: (context) => CommissionScreen());
      case '/expected_commission_screen':
        return MaterialPageRoute(builder: (context) => ExpectedCommissionScreen());
      case '/fee_collection_screen':
        return MaterialPageRoute(builder: (context) => FeeCollectionScreen());
      case '/franchise_kit_order_screen':
        return MaterialPageRoute(builder: (context) => FranchiseKitOrderScreen());
      case '/revenue_screen':
        return MaterialPageRoute(builder: (context) => RevenueScreen());
      case '/student_enrollment_screen':
        return MaterialPageRoute(builder: (context) => StudentEnrollmentScreen());
      case '/total_students_screen':
        return MaterialPageRoute(builder: (context) => TotalStudentsScreen());
      case '/visitor_screen':
        return MaterialPageRoute(builder: (context) => VisitorsScreen());



      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('No Routes Defined'),
            ),
          ),
        );
    }
  }
}