import 'package:flutter/material.dart';
import 'package:thenew/Screens/ourprogram.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  ourprogramsScreen(),
            ),
          );
        }
      },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff2563EB),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: "Company",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: "Programs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_rounded),
            activeIcon: Icon(Icons.star),
            label: "Reviews",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================

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
                      "Distributor",
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
                      "Welcome back!",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= GRID =================

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: .95,
                  children: const [
                    DashboardCard(
                      title: "Network Size",
                      value: "250",
                      icon: Icons.groups_2_outlined,
                      iconColor: Color(0xff2563EB),
                    ),

                    DashboardCard(
                      title: "Active Schools",
                      value: "45",
                      icon: Icons.school_outlined,
                      iconColor: Color(0xff16C74A),
                    ),

                    DashboardCard(
                      title: "Total Students",
                      value: "1,250",
                      icon: Icons.groups_outlined,
                      iconColor: Color(0xffA020F0),
                    ),

                    DashboardCard(
                      title: "Revenue",
                      value: "₹12.5L",
                      icon: Icons.currency_rupee_rounded,
                      iconColor: Color(0xffFF6B00),
                    ),

                    DashboardCard(
                      title: "Commission",
                      value: "₹1.87L",
                      icon: Icons.trending_up_rounded,
                      iconColor: Color(0xffFF1493),
                    ),

                    DashboardCard(
                      title: "Visitors",
                      value: "3,450",
                      icon: Icons.remove_red_eye_outlined,
                      iconColor: Color(0xff5B5BF6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CARD =================

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  iconColor,
                  iconColor.withOpacity(.8),
                ],
              ),
            ),

            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),

          const Spacer(),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1E1E),
            ),
          ),
        ],
      ),
    );
  }
}
