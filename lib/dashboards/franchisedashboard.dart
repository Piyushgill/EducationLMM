import 'package:flutter/material.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/login_screen.dart';
import 'package:thenew/dashboards/super_admin_dashboard.dart';
import 'package:thenew/Screens/EducationHomeScreen.dart';
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
    _FranchiseSchoolsTab(),
    _FranchiseOrdersTab(),
    _FranchiseProfileTab(),
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

class _FranchiseDrawer extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onNavigate;

  const _FranchiseDrawer({required this.currentIndex, required this.onNavigate});

  @override
  State<_FranchiseDrawer> createState() => _FranchiseDrawerState();
}

class _FranchiseDrawerState extends State<_FranchiseDrawer> {
  String _name = "Franchise Owner";
  String _email = "";
  int _centresCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDrawerData();
  }

  Future<void> _loadDrawerData() async {
    final session = await SessionManager.getSession();
    if (session != null) {
      setState(() {
        _name = session['name'] ?? "Franchise Owner";
        _email = session['email'] ?? "";
      });
      final userId = session['id'];
      try {
        final res = await http.post(
          Uri.parse("https://apps.kofalt.in/api/franchise/get_schools.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"franchise_id": userId}),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == 'success' && data['data'] != null) {
            setState(() {
              _centresCount = (data['data'] as List).length;
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching drawer school count: $e");
      }
    }
  }

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
                  child: Text(
                    _name.isNotEmpty ? _name[0].toUpperCase() : "F",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _email.isNotEmpty ? _email : "franchise@example.com",
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
                  child: Text(
                    "$_centresCount Centres Active",
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
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
                    final isActive = widget.currentIndex == item['index'] as int;
                    return _DrawerItem(
                      icon: item['icon'] as IconData,
                      label: item['label'] as String,
                      isActive: isActive,
                      onTap: () => widget.onNavigate(item['index'] as int),
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
                    onTap: () {
                      Navigator.pop(context); // close drawer
                      Widget target;
                      switch (item['label']) {
                        case 'Centre Details':
                          target = const CentreDetailsScreen();
                          break;
                        case 'Student Enrollment':
                          target = const StudentEnrollmentScreen();
                          break;
                        case 'Batch Management':
                          target = const BatchManagementScreen();
                          break;
                        case 'Fee Collection':
                          target = const FeeCollectionScreen();
                          break;
                        case 'Kit Ordering':
                          target = const FranchiseKitOrderScreen();
                          break;
                        default:
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${item['label']} feature coming soon.")),
                          );
                          return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => target),
                      );
                    },
                  )),

                  const Divider(height: 28, indent: 20, endIndent: 20),

                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    label: "Logout",
                    isActive: false,
                    isLogout: true,
                    onTap: () {
                      Navigator.pop(context); // drawer close
                      _confirmAndLogout(context);
                    },
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

class _FranchiseHomeTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _FranchiseHomeTab({required this.scaffoldKey});

  @override
  State<_FranchiseHomeTab> createState() => _FranchiseHomeTabState();
}

class _FranchiseHomeTabState extends State<_FranchiseHomeTab> {
  bool _isLoadingStats = false;
  int _networkSize = 0;
  int _activeSchools = 0;
  int _totalStudents = 0;
  double _totalCommission = 0.0;
  String _userName = "Franchise Partner";

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoadingStats = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        setState(() {
          _userName = session['name'] ?? "Franchise Partner";
        });
        final userId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_user_network.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": userId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              _networkSize = data['network_size'] ?? 0;
              _activeSchools = data['active_schools'] ?? 0;
              _totalStudents = data['total_students'] ?? 0;
              _totalCommission = (data['total_commission'] ?? 0).toDouble();
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading stats: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final int estimatedBatches = _totalStudents ~/ 15 + 1;
    final String estimatedFees = "₹${(_totalCommission * 2.5).toStringAsFixed(0)}";

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
                        onTap: () => widget.scaffoldKey.currentState?.openDrawer(),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _userName,
                      style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
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
                      _hStat("Centres", "$_networkSize"),
                      _vDivider(),
                      _hStat("Batches", "$estimatedBatches"),
                      _vDivider(),
                      _hStat("Students", "$_totalStudents"),
                      _vDivider(),
                      _hStat("Fee Pending", estimatedFees),
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
                          value: "$_networkSize",
                          icon: Icons.store_mall_directory_outlined,
                          iconColor: const Color(0xff7C3AED),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CentreDetailsScreen())),
                        ),
                        FDashboardCard(
                          title: "Student Enrollment",
                          value: "$_totalStudents",
                          icon: Icons.how_to_reg_outlined,
                          iconColor: const Color(0xffDB2777),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentEnrollmentScreen())),
                        ),
                        FDashboardCard(
                          title: "Batch Management",
                          value: "$estimatedBatches",
                          icon: Icons.groups_2_outlined,
                          iconColor: const Color(0xff2563EB),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BatchManagementScreen())),
                        ),
                        FDashboardCard(
                          title: "Fee Collection",
                          value: estimatedFees,
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

void _confirmAndLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Logout"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            final nav = Navigator.of(context);
            Navigator.pop(ctx); // close dialog
            final session = await SessionManager.getSession();
            if (session != null && session['is_impersonating'] == true) {
              await SessionManager.saveSession(
                id: 1,
                name: "Super Admin",
                email: "admin@educationlmm.com",
                phone: "9999999999",
                role: "Super Admin",
                kycStatus: "Approved",
              );
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SuperAdminDashboard()),
                (route) => false,
              );
            } else {
              await SessionManager.clearSession();
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          child: const Text("Logout", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
class _FranchiseSchoolsTab extends StatefulWidget {
  const _FranchiseSchoolsTab();

  @override
  State<_FranchiseSchoolsTab> createState() => _FranchiseSchoolsTabState();
}

class _FranchiseSchoolsTabState extends State<_FranchiseSchoolsTab> {
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "Active", "Suspended"];
  bool _isLoading = false;
  List<dynamic> _schools = [];

  Future<void> _fetchSchools() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final franchiseId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/franchise/get_schools.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"franchise_id": franchiseId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              _schools = data['data'] ?? [];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching schools: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addSchool({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String principal,
    required String board,
    required String regNum,
    required String city,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff7C3AED))),
    );

    try {
      final session = await SessionManager.getSession();
      if (session == null) return;
      final franchiseId = session['id'];

      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/franchise/add_school.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "franchise_id": franchiseId,
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "principal_name": principal,
          "board_type": board,
          "reg_number": regNum,
          "school_city": city,
        }),
      );

      Navigator.pop(context); // Close loader

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("School registered successfully under you!")),
        );
        _fetchSchools();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to add school"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddSchoolSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final principalCtrl = TextEditingController();
    final boardCtrl = TextEditingController();
    final regCtrl = TextEditingController();
    final cityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Register New School", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "School Name")),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email Address")),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number")),
              TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Login Password")),
              TextField(controller: principalCtrl, decoration: const InputDecoration(labelText: "Principal Name")),
              TextField(controller: boardCtrl, decoration: const InputDecoration(labelText: "Board Type (e.g. CBSE)")),
              TextField(controller: regCtrl, decoration: const InputDecoration(labelText: "Registration Number")),
              TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: "School City")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final email = emailCtrl.text.trim();
              final phone = phoneCtrl.text.trim();
              final password = passCtrl.text.trim();
              if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill out all required fields"), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx);
              _addSchool(
                name: name,
                email: email,
                phone: phone,
                password: password,
                principal: principalCtrl.text.trim(),
                board: boardCtrl.text.trim(),
                regNum: regCtrl.text.trim(),
                city: cityCtrl.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff7C3AED)),
            child: const Text("Add School", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<dynamic> get _filtered {
    if (_selectedFilter == "All") return _schools;
    return _schools.where((s) => s['status'] == _selectedFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  @override
  Widget build(BuildContext context) {
    int totalStudents = 0;
    int totalBatches = 0;
    for (final s in _schools) {
      totalStudents += (s['students'] as int? ?? 0);
      totalBatches += (s['batches'] as int? ?? 0);
    }
    int activeCount = _schools.where((s) => s['status'] == 'Active').length;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
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
                  const Text("Schools", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Manage your franchise centres", style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 14)),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _summaryChip(Icons.school_rounded, "$activeCount Active", Colors.white),
                      _summaryChip(Icons.people_alt_outlined, "$totalStudents Students", Colors.white),
                      _summaryChip(Icons.layers_outlined, "$totalBatches Batches", Colors.white),
                    ],
                  )
                ],
              ),
            ),

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

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xff7C3AED)))
                  : _filtered.isEmpty
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
                            return _SchoolCard(school: s, onRefresh: _fetchSchools);
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
}

class _SchoolCard extends StatelessWidget {
  final Map<String, dynamic> school;
  final VoidCallback onRefresh;
  const _SchoolCard({required this.school, required this.onRefresh});

  Color get _statusColor {
    return school['status'] == 'Active' ? const Color(0xff16C74A) : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final initials = school['name'] != null && school['name'].toString().isNotEmpty ? school['name'][0].toUpperCase() : "?";

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
                  backgroundColor: const Color(0xff7C3AED).withOpacity(.12),
                  child: Text(
                    initials,
                    style: const TextStyle(color: Color(0xff7C3AED), fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(school['name'] as String? ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1E1E1E))),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 3),
                          Text(school['school_city'] as String? ?? "No City Specified", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
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
                    school['status'] as String? ?? "Active",
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
                _statChip(Icons.currency_rupee, "₹${(school['students'] ?? 0) * 150}", const Color(0xff16C74A)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(school['principal_name'] as String? ?? "No Principal Specified", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const Spacer(),
                Icon(Icons.badge_outlined, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text("Reg: ${school['reg_number'] ?? 'N/A'}", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
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
      initialChildSize: .65,
      maxChildSize: .85,
      minChildSize: .4,
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xff7C3AED).withOpacity(.12),
                  child: Text(
                    school['name'] != null && school['name'].toString().isNotEmpty ? school['name'][0].toUpperCase() : "?",
                    style: const TextStyle(color: Color(0xff7C3AED), fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(school['name'] ?? "", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
                      Text("Registered School Details", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 40),
            const Text("Contact Information", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
            const SizedBox(height: 12),
            _infoDetailRow("Email", school['email'] ?? "N/A", Icons.email_outlined),
            _infoDetailRow("Phone", school['phone'] ?? "N/A", Icons.phone_outlined),
            const Divider(height: 32),
            const Text("Registration & Board details", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
            const SizedBox(height: 12),
            _infoDetailRow("Principal Name", school['principal_name'] ?? "N/A", Icons.person_outline),
            _infoDetailRow("Board Type", school['board_type'] ?? "N/A", Icons.domain_outlined),
            _infoDetailRow("Registration No.", school['reg_number'] ?? "N/A", Icons.badge_outlined),
            _infoDetailRow("City Location", school['school_city'] ?? "N/A", Icons.location_on_outlined),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoDetailRow(String label, String value, IconData icon) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 14),
            SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(color: Color(0xff1E1E1E), fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
}

class _FranchiseOrdersTab extends StatefulWidget {
  const _FranchiseOrdersTab();

  @override
  State<_FranchiseOrdersTab> createState() => _FranchiseOrdersTabState();
}

class _FranchiseOrdersTabState extends State<_FranchiseOrdersTab> {
  String _selectedStatus = "All";
  final List<String> _statuses = ["All", "Pending", "Shipped", "Delivered", "Cancelled"];
  bool _isLoading = false;
  List<dynamic> _orders = [];

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final buyerId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/franchise/get_my_orders.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"buyer_id": buyerId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              _orders = data['data'] ?? [];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading my orders: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> get _filtered {
    if (_selectedStatus == "All") return _orders;
    return _orders.where((o) => o['delivery_status'] == _selectedStatus).toList();
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

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final delivered  = _orders.where((o) => o['delivery_status'] == 'Delivered').length;
    final pending    = _orders.where((o) => o['delivery_status'] == 'Pending').length;
    final shipped    = _orders.where((o) => o['delivery_status'] == 'Shipped').length;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
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
                  const Text("Kit Orders", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Track & manage all kit orders", style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 14)),
                  const SizedBox(height: 18),
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xffDB2777)))
                  : _filtered.isEmpty
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
                              statusColor: _statusColor(order['delivery_status'] as String? ?? 'Pending'),
                              statusIcon: _statusIcon(order['delivery_status'] as String? ?? 'Pending'),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FranchiseKitOrderScreen()),
          );
          _fetchOrders();
        },
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
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color statusColor;
  final IconData statusIcon;

  const _OrderCard({required this.order, required this.statusColor, required this.statusIcon});

  @override
  Widget build(BuildContext context) {
    final orderId = order['order_id'] ?? 0;
    final kitLevel = order['kit_level'] ?? 0;
    final qty = order['quantity'] ?? 0;
    final totalAmount = order['total_amount'] ?? 0.0;
    final deliveryStatus = order['delivery_status'] ?? 'Pending';
    final date = order['created_at'] ?? "";

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
                      Text("Level $kitLevel Kit", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1E1E1E))),
                      Text("Order #$orderId", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
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
                      Text(deliveryStatus, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11)),
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
                _infoTag(Icons.format_list_numbered_rounded, "Qty: $qty", const Color(0xff7C3AED)),
                const SizedBox(width: 12),
                _infoTag(Icons.payments_outlined, "₹$totalAmount", const Color(0xff16C74A)),
                const Spacer(),
                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(date.toString().split(' ')[0], style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
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
    final orderId = order['order_id'] ?? 0;
    final kitLevel = order['kit_level'] ?? 0;
    final qty = order['quantity'] ?? 0;
    final totalAmount = order['total_amount'] ?? 0.0;
    final deliveryStatus = order['delivery_status'] ?? 'Pending';
    final date = order['created_at'] ?? "";

    return DraggableScrollableSheet(
      initialChildSize: .5,
      maxChildSize: .75,
      minChildSize: .35,
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
                Text("Order #$orderId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xff1E1E1E))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 5),
                      Text(deliveryStatus, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _row("Kit Name", "Level $kitLevel Kit", Icons.inventory_2_outlined),
            _row("Quantity Placed", "$qty units", Icons.format_list_numbered_rounded),
            _row("Total Amount Paid", "₹$totalAmount", Icons.payments_outlined),
            _row("Order Date & Time", date.toString(), Icons.calendar_today_outlined),
            const SizedBox(height: 24),
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
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff1E1E1E))),
              ],
            ),
          ],
        ),
      );
}

class _FranchiseProfileTab extends StatefulWidget {
  const _FranchiseProfileTab();

  @override
  State<_FranchiseProfileTab> createState() => _FranchiseProfileTabState();
}

class _FranchiseProfileTabState extends State<_FranchiseProfileTab> {
  String _name = "Franchise Partner";
  String _email = "";
  String _phone = "";
  String _kycStatus = "Pending";

  Future<void> _loadProfile() async {
    final session = await SessionManager.getSession();
    if (session != null) {
      setState(() {
        _name = session['name'] ?? "Franchise Partner";
        _email = session['email'] ?? "";
        _phone = session['phone'] ?? "";
        _kycStatus = session['kyc_status'] ?? "Pending";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.orange;
    if (_kycStatus == 'Approved') statusColor = Colors.green;
    if (_kycStatus == 'Rejected') statusColor = Colors.red;

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
                gradient: LinearGradient(colors: [Color(0xff7C3AED), Color(0xffDB2777)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withOpacity(.2),
                        child: Text(
                          _name.isNotEmpty ? _name[0].toUpperCase() : "?",
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(_email, style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          _profileRow("Phone Number", _phone, Icons.phone_outlined),
                          const Divider(height: 24),
                          _profileRow("Account Role", "Franchise Partner", Icons.badge_outlined),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.verified_user_outlined, color: Colors.grey, size: 20),
                              const SizedBox(width: 12),
                              const Text("KYC Status", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: statusColor.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
                                child: Text(_kycStatus, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _confirmAndLogout(context),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Logout from Account", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
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