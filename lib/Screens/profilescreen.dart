import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thenew/Screens/maindashboardsccreen.dart';
import 'package:thenew/Screens/ourprogram.dart';
import 'package:thenew/Screens/ourprogramsmain.dart';

class Profilescreen extends StatelessWidget{
  const Profilescreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
        drawer: Drawer(
            child: ListView(
                padding: EdgeInsets.zero,
                children: [
                    const DrawerHeader(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Color(0xff2563EB), Color(0xffA020F0)],
                            ),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 30,
                                    child: Icon(Icons.person, size: 35, color: Color(0xff2563EB)),
                                ),
                                SizedBox(height: 10),
                                Text(
                                    "Distributor Name",
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                            ],
                        ),
                    ),
                    ListTile(
                        leading: const Icon(Icons.dashboard_outlined),
                        title: const Text('Dashboard'),
                        onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Settings'),
                        onTap: () {
                            // Handle settings navigation
                        },
                    ),
                ],
            ),
        ),
    backgroundColor: Colors.white,
//     bottomNavigationBar: BottomNavigationBar(
//     currentIndex: 2,
//     onTap: (index){
//       if(index == 0){
//         Navigator.push(context,
//           MaterialPageRoute(builder: (context)=> MainDashboardScreen(),
//           ),
//         );
//       }
//       if(index == 1){
//         Navigator.push(context,
//         MaterialPageRoute(builder: (context)=> ourprogramsmainScreen(),
//         ),
//         );
//       }
//       if(index == 2){
//         Navigator.push(context,
//           MaterialPageRoute(builder: (context)=> Profilescreen(),
//           ),
//         );
//       }
//     },
// backgroundColor: Colors.white,
//     type: BottomNavigationBarType.fixed,
//     selectedItemColor: const Color(0xff2563EB),
//     unselectedItemColor: Colors.grey,
//
//     items: const [
//     BottomNavigationBarItem(
//     icon: Icon(Icons.home_outlined),
//     activeIcon: Icon(Icons.home),
//     label: "Home",
//     ),
//
//     // BottomNavigationBarItem(
//     // icon: Icon(Icons.groups_outlined),
//     // activeIcon: Icon(Icons.groups),
//     // label: "Company",
//     // ),
//
//     BottomNavigationBarItem(
//     icon: Icon(Icons.menu_book_outlined),
//     activeIcon: Icon(Icons.menu_book),
//     label: "Programs",
//     ),
//
//     // BottomNavigationBarItem(
//     // icon: Icon(Icons.star_border_rounded),
//     // activeIcon: Icon(Icons.star),
//     // label: "Reviews",
//     // ),
//
//     BottomNavigationBarItem(
//     icon: Icon(Icons.person_outline),
//     activeIcon: Icon(Icons.person),
//     label: "Profile",
//     ),
//     ],
//     ),

    body: SafeArea(
    child: SingleChildScrollView(
    child: Column(
    children: [

    Container(
    width: double.infinity,
    padding: const EdgeInsets.only(
    left: 24,
    right: 24,
    top: 24,
    bottom: 28,
    ),
    decoration: const BoxDecoration(
    borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(28),
    bottomRight: Radius.circular(28),
    ),
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
    Color(0xff2563EB),
    Color(0xffA020F0),
    ],
    ),
    ),

    child: Column(
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Container(
    height: 48,
    width: 48,
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(.18),
    borderRadius: BorderRadius.circular(16),
    ),
    child: const Icon(
    Icons.menu_rounded,
    color: Colors.white,
    size: 28,
    ),
    ),

    Stack(
    children: [
    Container(
    height: 48,
    width: 48,
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(.18),
    borderRadius: BorderRadius.circular(16),
    ),
    child: const Icon(
    Icons.notifications_none_rounded,
    color: Colors.white,
    size: 28,
    ),
    ),

    Positioned(
    right: 10,
    top: 10,
    child: Container(
    height: 10,
    width: 10,
    decoration: const BoxDecoration(
    color: Colors.red,
    shape: BoxShape.circle,
    ),
    ),
    ),
    ],
    ),
    ],
    ),

    const SizedBox(height: 26),

    const Align(
    alignment: Alignment.centerLeft,
    child: Text(
    "Profile",
    style: TextStyle(
    color: Colors.white,
    fontSize: 34,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),

    const SizedBox(height: 6),

    Align(
    alignment: Alignment.centerLeft,
    child: Text(
    "Manage your account",
    style: TextStyle(
    color: Colors.white.withOpacity(.9),
    fontSize: 18,
    ),
    ),
    ),
    ],
    ),
    ),

    const SizedBox(height: 24),

    // ================= PROFILE CARD =================

    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
    vertical: 32,
    horizontal: 24,
    ),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(26),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(.05),
    blurRadius: 12,
    offset: const Offset(0, 4),
    ),
    ],
    ),

    child: Column(
    children: [
    Container(
    height: 100,
    width: 100,
    decoration: const BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
    colors: [
    Color(0xff2563EB),
    Color(0xffA020F0),
    ],
    ),
    ),
    child: const Center(
    child: Text(
    "JS",
    style: TextStyle(
    color: Colors.white,
    fontSize: 34,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    ),

    const SizedBox(height: 22),

    const Text(
    "John Smith",
    style: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Color(0xff1E1E1E),
    ),
    ),

    const SizedBox(height: 6),

    Text(
    "Distributor",
    style: TextStyle(
    color: Colors.grey.shade600,
    fontSize: 18,
    ),
    ),
    ],
    ),
    ),
    ),

    const SizedBox(height: 20),

    // ================= ACCOUNT DETAILS =================

    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(26),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(.05),
    blurRadius: 12,
    offset: const Offset(0, 4),
    ),
    ],
    ),

    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    "Account Details",
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),

    const SizedBox(height: 26),

    Row(
    children: [
    _iconBox(Icons.email_outlined),
    const SizedBox(width: 16),

    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    "Email",
    style: TextStyle(
    color: Colors.grey.shade600,
    fontSize: 15,
    ),
    ),

    const SizedBox(height: 4),

    const Text(
    "john@example.com",
    style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    ),
    ),
    ],
    ),
    ],
    ),

    const SizedBox(height: 26),

    Row(
    children: [
    _iconBox(Icons.phone_outlined),
    const SizedBox(width: 16),

    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    "Phone",
    style: TextStyle(
    color: Colors.grey.shade600,
    fontSize: 15,
    ),
    ),

    const SizedBox(height: 4),

    const Text(
    "+91 9876543210",
    style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    ),
    ),
    ],
    ),
    ],
    ),
    ],
    ),
    ),
    ),

    const SizedBox(height: 20),

    // ================= SETTINGS CARD =================

    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(26),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(.05),
    blurRadius: 12,
    offset: const Offset(0, 4),
    ),
    ],
    ),

    child: Column(
    children: [
    _menuTile(
    icon: Icons.settings_outlined,
    title: "Settings",
    ),

    _menuTile(
    icon: Icons.help_outline_rounded,
    title: "Help & Support",
    ),
    ],
    ),
    ),
    ),

    const SizedBox(height: 24),

    // ================= LOGOUT BUTTON =================

    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
    height: 70,
    width: double.infinity,
    decoration: BoxDecoration(
    color: const Color(0xffFFF1F2),
    borderRadius: BorderRadius.circular(22),
    ),

    child: const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.logout_rounded,
    color: Color(0xffDC2626),
    ),

    SizedBox(width: 10),

    Text(
    "Logout",
    style: TextStyle(
    color: Color(0xffDC2626),
    fontSize: 15,
    fontWeight: FontWeight.w600,
    ),
    ),
    ],
    ),
    ),
    ),

    const SizedBox(height: 20),
    ],
    ),
    ),
    ),
    );
    }

    // ================= ICON BOX =================

    Widget _iconBox(IconData icon) {
    return Container(
    height: 52,
    width: 52,
    decoration: BoxDecoration(
    color: const Color(0xffF5F5F5),
    borderRadius: BorderRadius.circular(16),
    ),
    child: Icon(
    icon,
    color: Colors.grey.shade700,
    ),
    );
    }

    // ================= MENU TILE =================

    Widget _menuTile({
    required IconData icon,
    required String title,
    }) {
    return Padding(
    padding: const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
    ),
    child: Row(
    children: [
    Icon(
    icon,
    color: Colors.grey.shade700,
    size: 20,
    ),

    const SizedBox(width: 16),

    Expanded(
    child: Text(
    title,
    style: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    ),
    ),
    ),

    Icon(
    Icons.chevron_right_rounded,
    color: Colors.grey.shade500,
    size: 20,
    ),
    ],
    ),
    );
    }
    }
