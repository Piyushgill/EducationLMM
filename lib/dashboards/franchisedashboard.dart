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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _pages = [
    _FranchiseHomeTab(scaffoldKey: _scaffoldKey),
    const _FranchiseSchoolsTab(),
    const _FranchiseOrdersTab(),
    const _FranchiseProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _FranchiseDrawer(
        currentIndex: _currentIndex,
        onNavigate: (i) {
          setState(() => _currentIndex = i);
          Navigator.pop(context);
        },
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),        activeIcon: Icon(Icons.home),        label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined),       activeIcon: Icon(Icons.school),      label: "Schools"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag),label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),        activeIcon: Icon(Icons.person),      label: "Profile"),
        ],
      ),
    );
  }
}

// ============================================================
//  DRAWER
// ============================================================

class _FranchiseDrawer extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onNavigate;

  const _FranchiseDrawer({required this.currentIndex, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded,           'label': 'Home',          'index': 0},
      {'icon': Icons.school_rounded,          'label': 'Schools',       'index': 1},
      {'icon': Icons.shopping_bag_rounded,    'label': 'Orders',        'index': 2},
      {'icon': Icons.person_rounded,          'label': 'Profile',       'index': 3},
    ];

    final extras = [
      {'icon': Icons.store_mall_directory_outlined, 'label': 'Centre Details'},
      {'icon': Icons.how_to_reg_outlined,           'label': 'Student Enrollment'},
      {'icon': Icons.groups_2_outlined,             'label': 'Batch Management'},
      {'icon': Icons.payments_outlined,             'label': 'Fee Collection'},
      {'icon': Icons.inventory_2_outlined,          'label': 'Kit Ordering'},
      {'icon': Icons.bar_chart_rounded,             'label': 'Reports'},
      {'icon': Icons.support_agent_rounded,         'label': 'Support'},
      {'icon': Icons.settings_outlined,             'label': 'Settings'},
    ];

    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 24, right: 24, top: 52, bottom: 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff7C3AED), Color(0xffDB2777)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(.2),
                  child: const Text(
                    "F",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Franchise Owner",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "franchise@example.com",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "3 Centres Active",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main nav
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 6, top: 4),
                    child: Text(
                      "MAIN MENU",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...items.map((item) {
                    final isActive = currentIndex == item['index'] as int;
                    return _DrawerItem(
                      icon: item['icon'] as IconData,
                      label: item['label'] as String,
                      isActive: isActive,
                      onTap: () => onNavigate(item['index'] as int),
                    );
                  }),

                  const Divider(height: 28, indent: 20, endIndent: 20),

                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 6),
                    child: Text(
                      "MANAGEMENT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...extras.map((item) => _DrawerItem(
                    icon: item['icon'] as IconData,
                    label: item['label'] as String,
                    isActive: false,
                    onTap: () => Navigator.pop(context),
                  )),

                  const Divider(height: 28, indent: 20, endIndent: 20),

                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    label: "Logout",
                    isActive: false,
                    isLogout: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isLogout;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLogout
        ? Colors.red
        : isActive
        ? const Color(0xff7C3AED)
        : Colors.grey.shade700;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xff7C3AED).withOpacity(.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (isActive) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xff7C3AED),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
//  HOME TAB
// ============================================================

class _FranchiseHomeTab extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _FranchiseHomeTab({required this.scaffoldKey});

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
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff7C3AED), Color(0xffDB2777)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => scaffoldKey.currentState?.openDrawer(),
                        child: Container(
                          height: 48, width: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
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
                      "Franchise",
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
                  const SizedBox(height: 16),
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    _sectionTitle("Testimonials"),
                    const SizedBox(height: 12),
                    _testimonialCard("Ramesh Verma",  "Running 3 centres with this system is now so easy!", 5),
                    const SizedBox(height: 10),
                    _testimonialCard("Sneha Kapoor", "Fee tracking and batch management saves hours daily.", 4),

                    const SizedBox(height: 24),
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
//  SCHOOLS TAB — Fully Static Functional
// ============================================================

class _FranchiseSchoolsTab extends StatefulWidget {
  const _FranchiseSchoolsTab();

  @override
  State<_FranchiseSchoolsTab> createState() => _FranchiseSchoolsTabState();
}

class _FranchiseSchoolsTabState extends State<_FranchiseSchoolsTab> {
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "Active", "Inactive", "New"];

  final List<Map<String, dynamic>> _schools = [
    {
      'name': 'Sunrise Public School',
      'location': 'Laxmi Nagar, Delhi',
      'principal': 'Mr. Anil Sharma',
      'students': 128,
      'batches': 5,
      'status': 'Active',
      'joined': 'Jan 2023',
      'revenue': '₹38,400',
      'color': const Color(0xff7C3AED),
      'initials': 'SP',
    },
    {
      'name': 'Greenfield Academy',
      'location': 'Rohini, Delhi',
      'principal': 'Mrs. Priya Singh',
      'students': 96,
      'batches': 4,
      'status': 'Active',
      'joined': 'Mar 2023',
      'revenue': '₹28,800',
      'color': const Color(0xff16C74A),
      'initials': 'GA',
    },
    {
      'name': 'Bright Future School',
      'location': 'Dwarka, Delhi',
      'principal': 'Mr. Ramesh Gupta',
      'students': 116,
      'batches': 3,
      'status': 'Active',
      'joined': 'Jun 2023',
      'revenue': '₹34,800',
      'color': const Color(0xff2563EB),
      'initials': 'BF',
    },
    {
      'name': 'Excel High School',
      'location': 'Janakpuri, Delhi',
      'principal': 'Ms. Kavita Mehta',
      'students': 0,
      'batches': 0,
      'status': 'Inactive',
      'joined': 'Sep 2022',
      'revenue': '₹0',
      'color': Colors.grey,
      'initials': 'EH',
    },
    {
      'name': 'New Horizon School',
      'location': 'Pitampura, Delhi',
      'principal': 'Mr. Vivek Nair',
      'students': 44,
      'batches': 2,
      'status': 'New',
      'joined': 'Nov 2024',
      'revenue': '₹13,200',
      'color': const Color(0xffDB2777),
      'initials': 'NH',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == "All") return _schools;
    return _schools.where((s) => s['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalStudents = _schools.fold<int>(0, (sum, s) => sum + (s['students'] as int));
    final totalBatches  = _schools.fold<int>(0, (sum, s) => sum + (s['batches']  as int));
    final activeCount   = _schools.where((s) => s['status'] == 'Active').length;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                gradient: LinearGradient(
                  colors: [Color(0xff7C3AED), Color(0xffDB2777)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Schools",
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manage your franchise centres",
                    style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  // Summary chips
                  Row(
                    children: [
                      _summaryChip(Icons.school_rounded, "$activeCount Active", Colors.white),
                      const SizedBox(width: 10),
                      _summaryChip(Icons.people_alt_outlined, "$totalStudents Students", Colors.white),
                      const SizedBox(width: 10),
                      _summaryChip(Icons.layers_outlined, "$totalBatches Batches", Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search schools...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // FILTER CHIPS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final isActive = _selectedFilter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xff7C3AED) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 6)],
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey.shade700,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // SCHOOL LIST
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text("No schools found", style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final s = _filtered[index];
                  return _SchoolCard(school: s);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSchoolSheet(context),
        backgroundColor: const Color(0xff7C3AED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add School", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.18),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    ),
  );

  void _showAddSchoolSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddSchoolSheet(),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final Map<String, dynamic> school;
  const _SchoolCard({required this.school});

  Color get _statusColor {
    switch (school['status']) {
      case 'Active':   return const Color(0xff16C74A);
      case 'Inactive': return Colors.grey;
      case 'New':      return const Color(0xffDB2777);
      default:         return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSchoolDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: (school['color'] as Color).withOpacity(.12),
                  child: Text(
                    school['initials'] as String,
                    style: TextStyle(color: school['color'] as Color, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(school['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1E1E1E))),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 3),
                          Text(school['location'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    school['status'] as String,
                    style: TextStyle(color: _statusColor, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _statChip(Icons.people_alt_outlined, "${school['students']} Students", const Color(0xff7C3AED)),
                const SizedBox(width: 12),
                _statChip(Icons.layers_outlined, "${school['batches']} Batches", const Color(0xff2563EB)),
                const Spacer(),
                _statChip(Icons.currency_rupee, school['revenue'] as String, const Color(0xff16C74A)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(school['principal'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const Spacer(),
                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text("Since ${school['joined']}", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
    ],
  );

  void _showSchoolDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SchoolDetailSheet(school: school),
    );
  }
}

class _SchoolDetailSheet extends StatelessWidget {
  final Map<String, dynamic> school;
  const _SchoolDetailSheet({required this.school});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .75,
      maxChildSize: .92,
      minChildSize: .5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: (school['color'] as Color).withOpacity(.12),
                  child: Text(school['initials'] as String, style: TextStyle(color: school['color'] as Color, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(school['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(school['location'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _detailRow("Principal",  school['principal'] as String, Icons.person_outline),
            _detailRow("Students",   "${school['students']}", Icons.people_alt_outlined),
            _detailRow("Batches",    "${school['batches']}", Icons.layers_outlined),
            _detailRow("Revenue",    school['revenue'] as String, Icons.payments_outlined),
            _detailRow("Status",     school['status'] as String, Icons.circle_notifications_outlined),
            _detailRow("Member Since", school['joined'] as String, Icons.calendar_today_outlined),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call_outlined, size: 18),
                    label: const Text("Call"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff7C3AED),
                      side: const BorderSide(color: Color(0xff7C3AED)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text("Edit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xff7C3AED).withOpacity(.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xff7C3AED)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            Text(value,  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff1E1E1E))),
          ],
        ),
      ],
    ),
  );
}

class _AddSchoolSheet extends StatelessWidget {
  const _AddSchoolSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Add New School", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
            const SizedBox(height: 20),
            _sheetField("School Name", Icons.school_outlined),
            const SizedBox(height: 14),
            _sheetField("Location", Icons.location_on_outlined),
            const SizedBox(height: 14),
            _sheetField("Principal Name", Icons.person_outline),
            const SizedBox(height: 14),
            _sheetField("Phone Number", Icons.call_outlined),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Add School", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _sheetField(String hint, IconData icon) => Container(
    decoration: BoxDecoration(
      color: const Color(0xffF5F5F5),
      borderRadius: BorderRadius.circular(14),
    ),
    child: TextField(
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );
}

// ============================================================
//  ORDERS TAB — Fully Static Functional
// ============================================================

class _FranchiseOrdersTab extends StatefulWidget {
  const _FranchiseOrdersTab();

  @override
  State<_FranchiseOrdersTab> createState() => _FranchiseOrdersTabState();
}

class _FranchiseOrdersTabState extends State<_FranchiseOrdersTab> {
  String _selectedStatus = "All";
  final List<String> _statuses = ["All", "Pending", "Shipped", "Delivered", "Cancelled"];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#ORD-2401',
      'kit': 'Level 3 Kit',
      'school': 'Sunrise Public School',
      'qty': 25,
      'amount': '₹12,500',
      'date': '14 Jun 2025',
      'status': 'Delivered',
      'items': ['Workbook x25', 'Flashcards x25', 'Practice Sheets x50'],
    },
    {
      'id': '#ORD-2402',
      'kit': 'Level 5 Kit',
      'school': 'Greenfield Academy',
      'qty': 18,
      'amount': '₹9,900',
      'date': '11 Jun 2025',
      'status': 'Shipped',
      'items': ['Workbook x18', 'Abacus Frame x18', 'Practice Sheets x36'],
    },
    {
      'id': '#ORD-2403',
      'kit': 'Level 2 Kit',
      'school': 'Bright Future School',
      'qty': 30,
      'amount': '₹13,500',
      'date': '9 Jun 2025',
      'status': 'Pending',
      'items': ['Starter Workbook x30', 'Number Cards x30'],
    },
    {
      'id': '#ORD-2404',
      'kit': 'Level 7 Kit',
      'school': 'New Horizon School',
      'qty': 10,
      'amount': '₹6,500',
      'date': '5 Jun 2025',
      'status': 'Delivered',
      'items': ['Advanced Workbook x10', 'Speed Drills x10', 'Answer Keys x10'],
    },
    {
      'id': '#ORD-2405',
      'kit': 'Level 4 Kit',
      'school': 'Excel High School',
      'qty': 20,
      'amount': '₹11,000',
      'date': '2 Jun 2025',
      'status': 'Cancelled',
      'items': ['Workbook x20', 'Abacus Frame x20'],
    },
    {
      'id': '#ORD-2406',
      'kit': 'Level 6 Kit',
      'school': 'Greenfield Academy',
      'qty': 15,
      'amount': '₹8,250',
      'date': '28 May 2025',
      'status': 'Delivered',
      'items': ['Advanced Workbook x15', 'Practice Sheets x30', 'Flashcards x15'],
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedStatus == "All") return _orders;
    return _orders.where((o) => o['status'] == _selectedStatus).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':  return const Color(0xff16C74A);
      case 'Shipped':    return const Color(0xff2563EB);
      case 'Pending':    return const Color(0xffFFB800);
      case 'Cancelled':  return Colors.red;
      default:           return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Delivered':  return Icons.check_circle_outlined;
      case 'Shipped':    return Icons.local_shipping_outlined;
      case 'Pending':    return Icons.hourglass_empty_rounded;
      case 'Cancelled':  return Icons.cancel_outlined;
      default:           return Icons.help_outline;
    }
  }

  int get _totalAmount {
    return _orders
        .where((o) => o['status'] != 'Cancelled')
        .fold(0, (sum, o) {
      final raw = (o['amount'] as String).replaceAll(RegExp(r'[₹,]'), '');
      return sum + (int.tryParse(raw) ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final delivered  = _orders.where((o) => o['status'] == 'Delivered').length;
    final pending    = _orders.where((o) => o['status'] == 'Pending').length;
    final shipped    = _orders.where((o) => o['status'] == 'Shipped').length;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                gradient: LinearGradient(
                  colors: [Color(0xffDB2777), Color(0xff7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kit Orders",
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Track & manage all kit orders",
                    style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  // Summary row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        _ordStat("Total Orders", "${_orders.length}", Icons.shopping_bag_outlined),
                        _vDivider(),
                        _ordStat("Delivered", "$delivered", Icons.check_circle_outline),
                        _vDivider(),
                        _ordStat("Pending", "$pending", Icons.hourglass_empty_rounded),
                        _vDivider(),
                        _ordStat("Shipped", "$shipped", Icons.local_shipping_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // FILTER CHIPS
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statuses.map((s) {
                    final isActive = _selectedStatus == s;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStatus = s),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xffDB2777) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 6)],
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey.shade700,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ORDERS LIST
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text("No orders found", style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final order = _filtered[index];
                  return _OrderCard(
                    order: order,
                    statusColor: _statusColor(order['status'] as String),
                    statusIcon:  _statusIcon(order['status'] as String),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewOrderSheet(context),
        backgroundColor: const Color(0xffDB2777),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _ordStat(String label, String value, IconData icon) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    ),
  );

  Widget _vDivider() => Container(height: 40, width: 1, color: Colors.white.withOpacity(.25));

  void _showNewOrderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewOrderSheet(),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color statusColor;
  final IconData statusIcon;

  const _OrderCard({required this.order, required this.statusColor, required this.statusIcon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOrderDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xffDB2777).withOpacity(.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: Color(0xffDB2777), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order['kit'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1E1E1E))),
                      Text(order['id'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(order['status'] as String, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.school_outlined, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 5),
                Expanded(child: Text(order['school'] as String, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _infoTag(Icons.format_list_numbered_rounded, "Qty: ${order['qty']}", const Color(0xff7C3AED)),
                const SizedBox(width: 12),
                _infoTag(Icons.payments_outlined, order['amount'] as String, const Color(0xff16C74A)),
                const Spacer(),
                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(order['date'] as String, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTag(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
    ],
  );

  void _showOrderDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderDetailSheet(order: order, statusColor: statusColor, statusIcon: statusIcon),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color statusColor;
  final IconData statusIcon;
  const _OrderDetailSheet({required this.order, required this.statusColor, required this.statusIcon});

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List<String>;
    return DraggableScrollableSheet(
      initialChildSize: .65,
      maxChildSize: .9,
      minChildSize: .45,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(order['id'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xff1E1E1E))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 5),
                      Text(order['status'] as String, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _row("Kit", order['kit'] as String, Icons.inventory_2_outlined),
            _row("School", order['school'] as String, Icons.school_outlined),
            _row("Quantity", "${order['qty']} units", Icons.format_list_numbered_rounded),
            _row("Amount", order['amount'] as String, Icons.payments_outlined),
            _row("Order Date", order['date'] as String, Icons.calendar_today_outlined),
            const SizedBox(height: 16),
            const Text("Items Included", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1E1E1E))),
            const SizedBox(height: 10),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: const Color(0xff16C74A)),
                  const SizedBox(width: 8),
                  Text(item, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                ],
              ),
            )),
            const SizedBox(height: 24),
            if (order['status'] != 'Delivered' && order['status'] != 'Cancelled')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffDB2777),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Track Order", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xffDB2777).withOpacity(.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: const Color(0xffDB2777)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            Text(value,  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff1E1E1E))),
          ],
        ),
      ],
    ),
  );
}

class _NewOrderSheet extends StatelessWidget {
  const _NewOrderSheet();

  @override
  Widget build(BuildContext context) {
    final levels = ['Level 2', 'Level 3', 'Level 4', 'Level 5', 'Level 6', 'Level 7', 'Level 8'];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 20),
            const Text("New Kit Order", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
            const SizedBox(height: 20),
            const Text("Select Level", style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: levels.map((l) => GestureDetector(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xffDB2777).withOpacity(.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xffDB2777).withOpacity(.3)),
                  ),
                  child: Text(l, style: const TextStyle(color: Color(0xffDB2777), fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            _sheetField("Select School", Icons.school_outlined),
            const SizedBox(height: 12),
            _sheetField("Quantity", Icons.format_list_numbered_rounded),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffDB2777),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Place Order", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetField(String hint, IconData icon) => Container(
    decoration: BoxDecoration(color: const Color(0xffF5F5F5), borderRadius: BorderRadius.circular(14)),
    child: TextField(
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );
}

// ============================================================
//  PROFILE TAB (stub)
// ============================================================

class _FranchiseProfileTab extends StatelessWidget {
  const _FranchiseProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                gradient: LinearGradient(colors: [Color(0xff7C3AED), Color(0xff7C3AED)]),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text("Profile", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Expanded(child: Center(child: Text("Coming Soon", style: TextStyle(color: Colors.grey, fontSize: 16)))),
          ],
        ),
      ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
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
//  DETAIL HEADER HELPER
// ============================================================

Widget detailHeader({required String title, required String subtitle, required List<Color> colors, required VoidCallback onBack, List<Widget>? extra}) {
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
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      if (subtitle.isNotEmpty) ...[const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13))],
      if (extra != null) ...[const SizedBox(height: 14), ...extra],
    ]),
  );
}

// ============================================================
//  SHARED HELPERS
// ============================================================

Widget hStatWhite(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
  Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
]);

Widget infoChip(IconData icon, String text, Color color) => Row(children: [
  Icon(icon, size: 15, color: color),
  const SizedBox(width: 5),
  Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
]);