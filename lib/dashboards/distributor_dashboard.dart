import 'package:flutter/material.dart';
import 'package:thenew/Screens/ourprogramsmain.dart';
import 'package:thenew/Screens/profilescreen.dart';
import 'package:thenew/dashboardCardDetails/Expected_Commission_Screen.dart';
import 'package:thenew/dashboardCardDetails/active_schools_screen.dart';
import 'package:thenew/dashboardCardDetails/commission_screen.dart';
import 'package:thenew/dashboardCardDetails/network_size_screen.dart';
import 'package:thenew/dashboardCardDetails/revenue_screen.dart';
import 'package:thenew/dashboardCardDetails/total_students_screen.dart';
import 'package:thenew/dashboardCardDetails/visitors_screen.dart';

class DistributorDashboard extends StatefulWidget {
  const DistributorDashboard({super.key});

  @override
  State<DistributorDashboard> createState() => _DistributorDashboardState();
}

class _DistributorDashboardState extends State<DistributorDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    ourprogramsmainScreen(),
    const Profilescreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff2563EB),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: "Programs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  HOME TAB — merged MainDashboard + DistributorDashboard
// ============================================================

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff2563EB), Color(0xffA020F0)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: Container(
                            height: 48, width: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 48, width: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                          ),
                          Positioned(
                            right: 10, top: 10,
                            child: Container(
                              height: 10, width: 10,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Distributor",
                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Welcome back!",
                      style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // SCROLLABLE BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ---- DASHBOARD CARDS GRID ----
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: .95,
                      children: [
                        DashboardCard(
                          title: "Network Size",
                          value: "250",
                          icon: Icons.groups_2_outlined,
                          iconColor: const Color(0xff2563EB),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NetworkSizeScreen())),
                        ),
                        DashboardCard(
                          title: "Active Schools",
                          value: "45",
                          icon: Icons.school_outlined,
                          iconColor: const Color(0xff16C74A),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveSchoolsScreen())),
                        ),
                        DashboardCard(
                          title: "Total Students",
                          value: "1,250",
                          icon: Icons.groups_outlined,
                          iconColor: const Color(0xffA020F0),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TotalStudentsScreen())),
                        ),
                        DashboardCard(
                          title: "Revenue",
                          value: "₹12.5L",
                          icon: Icons.currency_rupee_rounded,
                          iconColor: const Color(0xffFF6B00),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen())),
                        ),
                        DashboardCard(
                          title: "Commission",
                          value: "₹1.87L",
                          icon: Icons.trending_up_rounded,
                          iconColor: const Color(0xffFF1493),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommissionScreen())),
                        ),
                        DashboardCard(
                          title: "Expected Commission",
                          value: "₹2.5L",
                          icon: Icons.account_balance_wallet_outlined,
                          iconColor: const Color(0xff16C74A),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const ExpectedCommissionScreen(),
                              ),
                            );
                          },
                        ),
                        DashboardCard(
                          title: "Visitors",
                          value: "3,450",
                          icon: Icons.remove_red_eye_outlined,
                          iconColor: const Color(0xff5B5BF6),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitorsScreen())),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ---- EXPECTED COMMISSION ----
                    // _sectionTitle("Expected Commission"),
                    // const SizedBox(height: 12),
                    // Container(
                    //   padding: const EdgeInsets.all(18),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(20),
                    //     boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)],
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           const Text("This Month Target", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    //           const Text("₹2.5L", style: TextStyle(color: Color(0xff2563EB), fontWeight: FontWeight.bold, fontSize: 16)),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 12),
                    //       ClipRRect(
                    //         borderRadius: BorderRadius.circular(10),
                    //         child: LinearProgressIndicator(
                    //           value: 0.748,
                    //           backgroundColor: const Color(0xff2563EB).withOpacity(.1),
                    //           valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff2563EB)),
                    //           minHeight: 10,
                    //         ),
                    //       ),
                    //       const SizedBox(height: 8),
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Text("Earned: ₹1.87L", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    //           const Text("74.8% Achieved", style: TextStyle(color: Color(0xff16C74A), fontWeight: FontWeight.w600, fontSize: 13)),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    //
                    // const SizedBox(height: 24),

                    // ---- TRAINING VIDEOS ----
                    _sectionTitle("Training Videos"),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 130,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _videoCard("Sales Techniques",        "12 min", const Color(0xff2563EB)),
                          _videoCard("How to Approach Schools", "18 min", const Color(0xffA020F0)),
                          _videoCard("Objection Handling",      "25 min", const Color(0xffFF6B00)),
                          _videoCard("Closing Deals",           "15 min", const Color(0xff16C74A)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---- TESTIMONIALS ----
                    _sectionTitle("Testimonials"),
                    const SizedBox(height: 12),
                    _testimonialCard("Rajesh Kumar", "This program has helped me grow my network tremendously.", 5),
                    const SizedBox(height: 10),
                    _testimonialCard("Priya Sharma", "Excellent training support and commission structure.", 4),

                    const SizedBox(height: 24),

                    // ---- FAQ ----
                    _sectionTitle("FAQ"),
                    const SizedBox(height: 12),
                    _faqItem("How is commission calculated?",
                        "Commission is calculated based on total revenue generated from your network at applicable rates."),
                    _faqItem("When is commission paid?",
                        "Commission is credited to your account on the 7th of every month for the previous month."),
                    _faqItem("How to add a new school?",
                        "Contact the company support team or use the New Lead section to register a school."),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- HELPER WIDGETS ----

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E)),
    );
  }

  Widget _videoCard(String title, String duration, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.play_circle_filled, color: color, size: 34),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(duration, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _testimonialCard(String name, String text, int stars) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xff2563EB).withOpacity(.1),
                radius: 18,
                child: Text(name[0], style: const TextStyle(color: Color(0xff2563EB), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              Row(children: List.generate(stars, (_) => const Icon(Icons.star, color: Color(0xffFFB800), size: 14))),
            ],
          ),
          const SizedBox(height: 10),
          Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _faqItem(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        iconColor: const Color(0xff2563EB),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(a, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ---- DRAWER ----

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xff2563EB), Color(0xffA020F0)]),
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
                Text("Distributor Name", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Distributor Account", style: TextStyle(color: Colors.white70, fontSize: 13)),
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
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  DASHBOARD CARD WIDGET
// ============================================================

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48, width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: [iconColor, iconColor.withOpacity(.8)]),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const Spacer(),
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}