import 'package:flutter/material.dart';
import 'package:thenew/dashboardCardDetails/Batch_Management_Screen.dart';
import 'package:thenew/dashboardCardDetails/Centre_Details_Screen.dart';
import 'package:thenew/dashboardCardDetails/Fee_Collection_Screen.dart';
import 'package:thenew/dashboardCardDetails/FranchiseKitOrderScreen.dart';
import 'package:thenew/dashboardCardDetails/Student_Enrollment_Screen.dart';

// ============================================================
//  FRANCHISE DASHBOARD — Main Entry
// ============================================================

class FranchiseDashboard extends StatefulWidget {
  const FranchiseDashboard({super.key});

  @override
  State<FranchiseDashboard> createState() => _FranchiseDashboardState();
}

class _FranchiseDashboardState extends State<FranchiseDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const _FranchiseHomeTab(),
    const _FranchiseSchoolsTab(),
    const _FranchiseOrdersTab(),
    const _FranchiseProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff7C3AED),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),         activeIcon: Icon(Icons.home),          label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined),        activeIcon: Icon(Icons.school),        label: "Schools"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined),  activeIcon: Icon(Icons.shopping_bag),  label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),         activeIcon: Icon(Icons.person),        label: "Profile"),
        ],
      ),
    );
  }
}

// ============================================================
//  HOME TAB
// ============================================================

class _FranchiseHomeTab extends StatelessWidget {
  const _FranchiseHomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xff7C3AED), Color(0xffDB2777)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 48, width: 48,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                      ),
                      Stack(children: [
                        Container(
                          height: 48, width: 48,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                        ),
                        Positioned(right: 10, top: 10, child: Container(height: 10, width: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Align(alignment: Alignment.centerLeft, child: Text("Franchise", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 4),
                  Align(alignment: Alignment.centerLeft, child: Text("Welcome back!", style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 16))),
                  const SizedBox(height: 16),
                  // Quick stats
                  Row(
                    children: [
                      _hStat("Centres", "3"),
                      _vDivider(),
                      _hStat("Batches", "12"),
                      _vDivider(),
                      _hStat("Students", "340"),
                      _vDivider(),
                      _hStat("Fee Pending", "₹45K"),
                    ],
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
                    // DASHBOARD CARDS
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: .95,
                      children: [
                        FDashboardCard(
                          title: "Centre Details",
                          value: "3",
                          icon: Icons.store_mall_directory_outlined,
                          iconColor: const Color(0xff7C3AED),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CentreDetailsScreen())),
                        ),
                        FDashboardCard(
                          title: "Student Enrollment",
                          value: "340",
                          icon: Icons.how_to_reg_outlined,
                          iconColor: const Color(0xffDB2777),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentEnrollmentScreen())),
                        ),
                        FDashboardCard(
                          title: "Batch Management",
                          value: "12",
                          icon: Icons.groups_2_outlined,
                          iconColor: const Color(0xff2563EB),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BatchManagementScreen())),
                        ),
                        FDashboardCard(
                          title: "Fee Collection",
                          value: "₹1.2L",
                          icon: Icons.payments_outlined,
                          iconColor: const Color(0xff16C74A),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeCollectionScreen())),
                        ),
                        FDashboardCard(
                          title: "Kit Ordering",
                          value: "Order",
                          icon: Icons.inventory_2_outlined,
                          iconColor: const Color(0xffFF6B00),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FranchiseKitOrderScreen())),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // TRAINING VIDEOS
                    _sectionTitle("Training Videos"),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _videoCard("Batch Management",    "10 min", const Color(0xff7C3AED)),
                          _videoCard("Fee Collection Tips", "14 min", const Color(0xffDB2777)),
                          _videoCard("Student Engagement",  "20 min", const Color(0xff2563EB)),
                          _videoCard("Centre Growth Tips",  "18 min", const Color(0xff16C74A)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TESTIMONIALS
                    _sectionTitle("Testimonials"),
                    const SizedBox(height: 12),
                    _testimonialCard("Ramesh Verma",  "Running 3 centres with this system is now so easy!", 5),
                    const SizedBox(height: 10),
                    _testimonialCard("Sneha Kapoor", "Fee tracking and batch management saves hours daily.", 4),

                    const SizedBox(height: 24),

                    // GALLERY
                    _sectionTitle("Gallery"),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(6, (i) => Container(
                          width: 90, height: 90,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xff7C3AED).withOpacity(.1 + i * 0.04),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.image_outlined, color: const Color(0xff7C3AED).withOpacity(.6), size: 30),
                        )),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // FAQ
                    _sectionTitle("FAQ"),
                    const SizedBox(height: 12),
                    _faqItem("How to add a new batch?",   "Go to Batch Management and tap 'Add Batch'. Fill in the details and assign students."),
                    _faqItem("How is fee tracked?",       "Fee collection is updated when a payment is marked against a student's account."),
                    _faqItem("How to order level kits?",  "Go to Kit Ordering, select level (2-8) and place your order directly."),

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

  Widget _hStat(String label, String value) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
  ]));
  Widget _vDivider() => Container(height: 28, width: 1, color: Colors.white.withOpacity(.3));
  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E)));

  Widget _videoCard(String title, String duration, Color color) => Container(
    width: 150, margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
    child: Row(children: [
      Icon(Icons.play_circle_filled, color: color, size: 28),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 2),
        const SizedBox(height: 3),
        Text(duration, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      ])),
    ]),
  );

  Widget _testimonialCard(String name, String text, int stars) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(backgroundColor: const Color(0xff7C3AED).withOpacity(.1), radius: 18, child: Text(name[0], style: const TextStyle(color: Color(0xff7C3AED), fontWeight: FontWeight.bold))),
        const SizedBox(width: 10),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const Spacer(),
        Row(children: List.generate(stars, (_) => const Icon(Icons.star, color: Color(0xffFFB800), size: 14))),
      ]),
      const SizedBox(height: 10),
      Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
    ]),
  );

  Widget _faqItem(String q, String a) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)]),
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      iconColor: const Color(0xff7C3AED),
      children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 14), child: Text(a, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)))],
    ),
  );
}

// ============================================================
//  STUB TABS (Schools, Orders, Profile)
// ============================================================

class _FranchiseSchoolsTab extends StatelessWidget {
  const _FranchiseSchoolsTab();
  @override
  Widget build(BuildContext context) => _SimpleTab(title: "Schools", color: const Color(0xff7C3AED));
}

class _FranchiseOrdersTab extends StatelessWidget {
  const _FranchiseOrdersTab();
  @override
  Widget build(BuildContext context) => _SimpleTab(title: "Orders", color: const Color(0xffDB2777));
}

class _FranchiseProfileTab extends StatelessWidget {
  const _FranchiseProfileTab();
  @override
  Widget build(BuildContext context) => _SimpleTab(title: "Profile", color: const Color(0xff7C3AED));
}

class _SimpleTab extends StatelessWidget {
  final String title;
  final Color color;
  const _SimpleTab({required this.title, required this.color});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            gradient: LinearGradient(colors: [color, color.withOpacity(.7)]),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          ]),
        ),
        const Expanded(child: Center(child: Text("Coming Soon", style: TextStyle(color: Colors.grey, fontSize: 16)))),
      ])),
    );
  }
}

// ============================================================
//  FRANCHISE DASHBOARD CARD
// ============================================================

class FDashboardCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const FDashboardCard({super.key, required this.title, required this.value, required this.icon, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ]),
        ]),
      ),
    );
  }
}

// ============================================================
//  DETAIL SCREENS — shared header widget
// ============================================================

Widget _detailHeader({required String title, required String subtitle, required List<Color> colors, required VoidCallback onBack, List<Widget>? extra}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.only(left: 24, right: 24, top: 52, bottom: 24),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: onBack,
        child: Container(height: 40, width: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
      ),
      const SizedBox(height: 16),
      Text(title,    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      if (subtitle.isNotEmpty) ...[const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13))],
      if (extra != null) ...[const SizedBox(height: 14), ...extra],
    ]),
  );
}

// ============================================================
//  1. CENTRE DETAILS SCREEN
// ============================================================


// ============================================================
//  2. STUDENT ENROLLMENT SCREEN
// ============================================================



// ============================================================
//  3. BATCH MANAGEMENT SCREEN
// ============================================================



// ============================================================
//  4. FEE COLLECTION SCREEN
// ============================================================


// ============================================================
//  5. KIT ORDER SCREEN (Franchise)
// ============================================================





// ============================================================
//  SHARED SMALL HELPERS
// ============================================================

Widget _hStatWhite(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
  Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
]);

Widget _infoChip(IconData icon, String text, Color color) => Row(children: [
  Icon(icon, size: 15, color: color),
  const SizedBox(width: 5),
  Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
]);