// import 'package:flutter/material.dart';
// import 'package:thenew/Screens/ourprogramsmain.dart';
// import 'package:thenew/Screens/profilescreen.dart';
// import 'package:thenew/dashboardCardDetails/active_schools_screen.dart';
// import 'package:thenew/dashboardCardDetails/commission_screen.dart';
// import 'package:thenew/dashboardCardDetails/network_size_screen.dart';
// import 'package:thenew/dashboardCardDetails/revenue_screen.dart';
// import 'package:thenew/dashboardCardDetails/total_students_screen.dart';
// import 'package:thenew/dashboardCardDetails/visitors_screen.dart';
// // import your screens here:
// // import 'network_size_screen.dart';
// // import 'active_schools_screen.dart';
// // import 'total_students_screen.dart';
// // import 'revenue_screen.dart';
// // import 'commission_screen.dart';
// // import 'visitors_screen.dart';
// // import 'ourprogramsmain.dart';
// // import 'profilescreen.dart';
//
// class MainDashboardScreen extends StatelessWidget {
//   const MainDashboardScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xff2563EB), Color(0xffA020F0)],
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     backgroundColor: Colors.white,
//                     radius: 30,
//                     child: Icon(Icons.person, size: 35, color: Color(0xff2563EB)),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     "Distributor Name",
//                     style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.dashboard_outlined),
//               title: const Text('Dashboard'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings_outlined),
//               title: const Text('Settings'),
//               onTap: () {},
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: const Color(0xffF5F5F5),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 0,
//         onTap: (index) {
//           if (index == 1) {
//             Navigator.push(context, MaterialPageRoute(builder: (_) => ourprogramsmainScreen()));
//           }
//           if (index == 2) {
//             Navigator.push(context, MaterialPageRoute(builder: (_) => Profilescreen()));
//           }
//         },
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: const Color(0xff2563EB),
//         unselectedItemColor: Colors.grey,
//         backgroundColor: Colors.white,
//         selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: "Programs"),
//           BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // ================= HEADER =================
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
//               decoration: const BoxDecoration(
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(28),
//                   bottomRight: Radius.circular(28),
//                 ),
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [Color(0xff2563EB), Color(0xffA020F0)],
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Builder(
//                         builder: (context) => GestureDetector(
//                           onTap: () => Scaffold.of(context).openDrawer(),
//                           child: Container(
//                             height: 48, width: 48,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(.18),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
//                           ),
//                         ),
//                       ),
//                       Stack(
//                         children: [
//                           Container(
//                             height: 48, width: 48,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(.18),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
//                           ),
//                           Positioned(
//                             right: 10, top: 10,
//                             child: Container(height: 10, width: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 26),
//                   const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text("Distributor", style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
//                   ),
//                   const SizedBox(height: 6),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text("Welcome back!", style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 18, fontWeight: FontWeight.w400)),
//                   ),
//                 ],
//               ),
//             ),
//
//             // ================= GRID =================
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(18),
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 18,
//                   crossAxisSpacing: 18,
//                   childAspectRatio: .95,
//                   children: [
//                     DashboardCard(
//                       title: "Network Size",
//                       value: "250",
//                       icon: Icons.groups_2_outlined,
//                       iconColor: const Color(0xff2563EB),
//                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NetworkSizeScreen())),
//                     ),
//                     DashboardCard(
//                       title: "Active Schools",
//                       value: "45",
//                       icon: Icons.school_outlined,
//                       iconColor: const Color(0xff16C74A),
//                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveSchoolsScreen())),
//                     ),
//                     DashboardCard(
//                       title: "Total Students",
//                       value: "1,250",
//                       icon: Icons.groups_outlined,
//                       iconColor: const Color(0xffA020F0),
//                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TotalStudentsScreen())),
//                     ),
//                     DashboardCard(
//                       title: "Revenue",
//                       value: "₹12.5L",
//                       icon: Icons.currency_rupee_rounded,
//                       iconColor: const Color(0xffFF6B00),
//                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen())),
//                     ),
//                     DashboardCard(
//                       title: "Commission",
//                       value: "₹1.87L",
//                       icon: Icons.trending_up_rounded,
//                       iconColor: const Color(0xffFF1493),
//                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommissionScreen())),
//                     ),
//                     DashboardCard(
//                       title: "Visitors",
//                       value: "3,450",
//                       icon: Icons.remove_red_eye_outlined,
//                       iconColor: const Color(0xff5B5BF6),
//                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitorsScreen())),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ================= CARD =================
//
// class DashboardCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color iconColor;
//   final VoidCallback onTap; // <-- Added
//
//   const DashboardCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.iconColor,
//     required this.onTap, // <-- Added
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap, // <-- Tappable now
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(22),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0, 4)),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 48, width: 48,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(14),
//                 gradient: LinearGradient(colors: [iconColor, iconColor.withOpacity(.8)]),
//               ),
//               child: Icon(icon, color: Colors.white, size: 26),
//             ),
//             const Spacer(),
//             Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 15, fontWeight: FontWeight.w500)),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
//                 Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }