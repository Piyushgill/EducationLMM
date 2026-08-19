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
import 'package:thenew/widgets/notification_bell.dart';

// ── Role constant used to filter admin-managed content (Videos/Testimonials/FAQs) ──
const String _kMyRole = "Franchise Partner";

/// Returns true if this admin-managed content item (video/testimonial/faq)
/// should be visible to [role], based on its 'target_roles' field which the
/// Super Admin sets when creating the content ("All" or a specific list).
bool _visibleToRole(dynamic targetRolesField, String role) {
  List<String> roles;
  if (targetRolesField is List) {
    roles = targetRolesField.map((e) => e.toString()).toList();
  } else {
    roles = (targetRolesField?.toString().split(',') ?? const ["All"]);
  }
  return roles.contains("All") || roles.contains(role);
}

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
    _FranchisecentersTab(),
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
          BottomNavigationBarItem(icon: Icon(Icons.school_rounded),       activeIcon: Icon(Icons.school_rounded),      label: "centers"),
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
          Uri.parse("https://apps.kofalt.in/api/franchise/get_centers.php"),
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
        debugPrint("Error fetching drawer center count: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded,           'label': 'Home',          'index': 0},
      {'icon': Icons.eighteen_mp_rounded,          'label': 'centers',       'index': 1},
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

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () => _confirmAndLogout(context),
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
  int _activecenters = 0;
  int _totalStudents = 0;
  double _totalCommission = 0.0;
  String _userName = "Franchise Partner";

  // ── Admin-managed content (Videos / Testimonials / FAQs), filtered by role ──
  bool _isLoadingVideos = false;
  bool _isLoadingTestimonials = false;
  bool _isLoadingFaqs = false;
  List<dynamic> _adminVideos = [];
  List<dynamic> _adminTestimonials = [];
  List<dynamic> _adminFaqs = [];

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
              _activecenters = data['active_centers'] ?? 0;
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

  // ----------------------------------------------------------
  //  Fetch Videos / Testimonials / FAQs added by Super Admin,
  //  keeping only the ones targeted at "Franchise Partner" or "All".
  // ----------------------------------------------------------
  Future<void> _fetchAdminContent() async {
    if (!mounted) return;
    setState(() {
      _isLoadingVideos = true;
      _isLoadingTestimonials = true;
      _isLoadingFaqs = true;
    });

    try {
      final res = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_videos.php"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final all = (data['data'] as List? ?? []);
          if (mounted) {
            setState(() => _adminVideos = all.where((v) => _visibleToRole(v['target_roles'], _kMyRole)).toList());
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching videos: $e");
    } finally {
      if (mounted) setState(() => _isLoadingVideos = false);
    }

    try {
      final res = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_testimonials.php"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final all = (data['data'] as List? ?? []);
          if (mounted) {
            setState(() => _adminTestimonials = all.where((t) => _visibleToRole(t['target_roles'], _kMyRole)).toList());
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching testimonials: $e");
    } finally {
      if (mounted) setState(() => _isLoadingTestimonials = false);
    }

    try {
      final res = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_faqs.php"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final all = (data['data'] as List? ?? []);
          if (mounted) {
            setState(() => _adminFaqs = all.where((f) => _visibleToRole(f['target_roles'], _kMyRole)).toList());
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching FAQs: $e");
    } finally {
      if (mounted) setState(() => _isLoadingFaqs = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
    _fetchAdminContent();
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
                    children: [
                      GestureDetector(
                        onTap: () => widget.scaffoldKey.currentState?.openDrawer(),
                        child: Container(
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
                      ),

                      const SizedBox(width: 8),

                      Image.asset(
                        'assets/image/kmain.png',
                        height: 54,
                        width: 145,
                        fit: BoxFit.fill,  // 👈 yahi "stretch" effect deta hai
                      ),

                      const Spacer(),

                      const NotificationBell(role: "Franchise Partner"),
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
                      "Franchise",
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
                    _isLoadingVideos
                        ? SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator(color: const Color(0xff7C3AED))),
                    )
                        : _adminVideos.isEmpty
                        ? _emptyBlock("No training videos yet")
                        : SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _adminVideos.map((v) {
                          return _videoCard(
                            v['title'] ?? "",
                            (v['description'] ?? "").toString().isNotEmpty ? v['description'] : "Tap to watch",
                            const Color(0xff7C3AED),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle("Testimonials"),
                    const SizedBox(height: 12),
                    _isLoadingTestimonials
                        ? const Center(child: CircularProgressIndicator())
                        : _adminTestimonials.isEmpty
                        ? _emptyBlock("No testimonials yet")
                        : Column(
                      children: _adminTestimonials.map((t) {
                        final rating = int.tryParse(t['rating']?.toString() ?? '5') ?? 5;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _testimonialCard(t['name'] ?? "", t['message'] ?? "", rating),
                        );
                      }).toList(),
                    ),

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
                    if (_isLoadingFaqs)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_adminFaqs.isEmpty)
                      _emptyBlock("No FAQs yet")
                    else
                      ..._adminFaqs.map((f) => _faqItem(f['question'] ?? "", f['answer'] ?? "")),

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

  Widget _emptyBlock(String label) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
    child: Center(child: Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
  );

  Widget _videoCard(String title, String duration, Color color) => Container(
    width: 150, margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
    child: Row(children: [
      Icon(Icons.play_circle_filled, color: color, size: 28),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(duration, style: TextStyle(color: Colors.grey.shade500, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
    ]),
  );

  Widget _testimonialCard(String name, String text, int stars) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(backgroundColor: const Color(0xff7C3AED).withOpacity(.1), radius: 18, child: Text(name.isNotEmpty ? name[0] : "?", style: const TextStyle(color: Color(0xff7C3AED), fontWeight: FontWeight.bold))),
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
class _FranchisecentersTab extends StatefulWidget {
  const _FranchisecentersTab();

  @override
  State<_FranchisecentersTab> createState() => _FranchisecentersTabState();
}

class _FranchisecentersTabState extends State<_FranchisecentersTab> {
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "Active", "Suspended"];
  bool _isLoading = false;
  List<dynamic> _centers = [];

  Future<void> _fetchcenters() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final franchiseId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/franchise/get_centers.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"franchise_id": franchiseId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              _centers = data['data'] ?? [];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching centers: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addcenter({
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
        Uri.parse("https://apps.kofalt.in/api/franchise/add_center.php"),
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
          "center_city": city,
        }),
      );

      Navigator.pop(context); // Close loader

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("center registered successfully under you!")),
        );
        _fetchcenters();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to add center"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddcenterSheet(BuildContext context) {
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
        title: const Text("Register New center", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "center Name")),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email Address")),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number")),
              TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Login Password")),
              TextField(controller: principalCtrl, decoration: const InputDecoration(labelText: "Principal Name")),
              TextField(controller: boardCtrl, decoration: const InputDecoration(labelText: "Board Type (e.g. CBSE)")),
              TextField(controller: regCtrl, decoration: const InputDecoration(labelText: "Registration Number")),
              TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: "center City")),
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
              _addcenter(
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
            child: const Text("Add center", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<dynamic> get _filtered {
    if (_selectedFilter == "All") return _centers;
    return _centers.where((s) => s['status'] == _selectedFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchcenters();
  }

  @override
  Widget build(BuildContext context) {
    int totalStudents = 0;
    int totalBatches = 0;
    for (final s in _centers) {
      totalStudents += (s['students'] as int? ?? 0);
      totalBatches += (s['batches'] as int? ?? 0);
    }
    int activeCount = _centers.where((s) => s['status'] == 'Active').length;

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
                  const Text("centers", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
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
                    hintText: "Search centers...",
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
                    Icon(Icons.school_rounded, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text("No centers found", style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final s = _filtered[index];
                  return _centerCard(center: s, onRefresh: _fetchcenters);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddcenterSheet(context),
        backgroundColor: const Color(0xff7C3AED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add center", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

class _centerCard extends StatelessWidget {
  final Map<String, dynamic> center;
  final VoidCallback onRefresh;
  const _centerCard({required this.center, required this.onRefresh});

  Color get _statusColor {
    return center['status'] == 'Active' ? const Color(0xff16C74A) : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final initials = center['name'] != null && center['name'].toString().isNotEmpty ? center['name'][0].toUpperCase() : "?";

    return GestureDetector(
      onTap: () => _showcenterDetail(context),
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
                      Text(center['name'] as String? ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1E1E1E))),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 3),
                          Text(center['center_city'] as String? ?? "No City Specified", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
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
                    center['status'] as String? ?? "Active",
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
                _statChip(Icons.people_alt_outlined, "${center['students']} Students", const Color(0xff7C3AED)),
                const SizedBox(width: 12),
                _statChip(Icons.layers_outlined, "${center['batches']} Batches", const Color(0xff2563EB)),
                const Spacer(),
                _statChip(Icons.currency_rupee, "₹${(center['students'] ?? 0) * 150}", const Color(0xff16C74A)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(center['principal_name'] as String? ?? "No Principal Specified", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const Spacer(),
                Icon(Icons.badge_outlined, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text("Reg: ${center['reg_number'] ?? 'N/A'}", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
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

  void _showcenterDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _centerDetailSheet(center: center),
    );
  }
}

class _centerDetailSheet extends StatelessWidget {
  final Map<String, dynamic> center;
  const _centerDetailSheet({required this.center});

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
                    center['name'] != null && center['name'].toString().isNotEmpty ? center['name'][0].toUpperCase() : "?",
                    style: const TextStyle(color: Color(0xff7C3AED), fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(center['name'] ?? "", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
                      Text("Registered center Details", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 40),
            const Text("Contact Information", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
            const SizedBox(height: 12),
            _infoDetailRow("Email", center['email'] ?? "N/A", Icons.email_outlined),
            _infoDetailRow("Phone", center['phone'] ?? "N/A", Icons.phone_outlined),
            const Divider(height: 32),
            const Text("Registration & Board details", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
            const SizedBox(height: 12),
            _infoDetailRow("Principal Name", center['principal_name'] ?? "N/A", Icons.person_outline),
            _infoDetailRow("Board Type", center['board_type'] ?? "N/A", Icons.domain_outlined),
            _infoDetailRow("Registration No.", center['reg_number'] ?? "N/A", Icons.badge_outlined),
            _infoDetailRow("City Location", center['center_city'] ?? "N/A", Icons.location_on_outlined),
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
  bool _isLoading = true;

  String _id = "";
  String _name = "Franchise Partner";
  String _email = "";
  String _phone = "";
  String _role = "Franchise Partner";
  String _kycStatus = "Pending";

  int _centres = 0;
  int _students = 0;
  int _batches = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final session = await SessionManager.getSession();

      if (session != null) {
        setState(() {
          _id = session['id']?.toString() ?? "";
          _name = session['name']?.toString().trim().isNotEmpty == true
              ? session['name'].toString()
              : "Franchise Partner";

          _email = session['email']?.toString() ?? "";
          _phone = session['phone']?.toString() ?? "";
          _role = session['role']?.toString() ?? "Franchise Partner";
          _kycStatus = session['kyc_status']?.toString() ?? "Pending";
        });

        await _loadFranchiseStats(session['id']);
      }
    } catch (e) {
      debugPrint("Profile loading error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadFranchiseStats(dynamic userId) async {
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse(
          "https://apps.kofalt.in/api/get_user_network.php",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' && mounted) {
          setState(() {
            _centres = int.tryParse(
              data['network_size']?.toString() ?? "0",
            ) ??
                0;

            _students = int.tryParse(
              data['total_students']?.toString() ?? "0",
            ) ??
                0;

            // If API doesn't provide batches, estimate them.
            _batches = int.tryParse(
              data['total_batches']?.toString() ?? "0",
            ) ??
                (_students ~/ 15 + 1);
          });
        }
      }
    } catch (e) {
      debugPrint("Franchise stats error: $e");
    }
  }

  Color get _kycColor {
    switch (_kycStatus.toLowerCase()) {
      case "approved":
        return const Color(0xff16A34A);

      case "rejected":
        return const Color(0xffDC2626);

      case "pending":
      default:
        return const Color(0xffD97706);
    }
  }

  IconData get _kycIcon {
    switch (_kycStatus.toLowerCase()) {
      case "approved":
        return Icons.verified_rounded;

      case "rejected":
        return Icons.cancel_rounded;

      case "pending":
      default:
        return Icons.pending_rounded;
    }
  }

  String get _initial {
    if (_name.trim().isEmpty) return "F";

    return _name
        .trim()
        .substring(0, 1)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xff7C3AED),
          ),
        )
            : RefreshIndicator(
          color: const Color(0xff7C3AED),
          onRefresh: _loadProfile,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildProfileHeader(),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  30,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionTitle(
                      "Personal Information",
                      Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 10),

                    _buildInfoCard(
                      children: [
                        _profileInfoRow(
                          icon: Icons.person_outline_rounded,
                          label: "Full Name",
                          value: _name,
                        ),

                        _profileDivider(),

                        _profileInfoRow(
                          icon: Icons.email_outlined,
                          label: "Email Address",
                          value: _email.isNotEmpty
                              ? _email
                              : "Not available",
                        ),

                        _profileDivider(),

                        _profileInfoRow(
                          icon: Icons.phone_outlined,
                          label: "Phone Number",
                          value: _phone.isNotEmpty
                              ? _phone
                              : "Not available",
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      "Account Information",
                      Icons.manage_accounts_outlined,
                    ),

                    const SizedBox(height: 10),

                    _buildInfoCard(
                      children: [
                        _profileInfoRow(
                          icon: Icons.badge_outlined,
                          label: "Franchise ID",
                          value: _id.isNotEmpty
                              ? "#$_id"
                              : "Not available",
                        ),

                        _profileDivider(),

                        _profileInfoRow(
                          icon: Icons.admin_panel_settings_outlined,
                          label: "Account Role",
                          value: _role,
                        ),

                        _profileDivider(),

                        _buildKycRow(),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      "Franchise Overview",
                      Icons.business_outlined,
                    ),

                    const SizedBox(height: 10),

                    _buildOverviewCard(),

                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      "Account Actions",
                      Icons.settings_outlined,
                    ),

                    const SizedBox(height: 10),

                    _buildActionCard(),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        "Kofalt Global • Franchise Partner",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        24,
        22,
        28,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        gradient: LinearGradient(
          colors: [
            Color(0xff7C3AED),
            Color(0xffDB2777),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Row(
          //   children: [
          //     // const Text(
          //     //   "My Profile",
          //     //   style: TextStyle(
          //     //     color: Colors.white,
          //     //     fontSize: 26,
          //     //     fontWeight: FontWeight.bold,
          //     //   ),
          //     // ),
          //     //
          //     // const Spacer(),
          //
          //     GestureDetector(
          //       onTap: _loadProfile,
          //       child: Container(
          //         height: 42,
          //         width: 42,
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(.16),
          //           borderRadius: BorderRadius.circular(13),
          //         ),
          //         child: const Icon(
          //           Icons.refresh_rounded,
          //           color: Colors.white,
          //           size: 22,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          //
          // const SizedBox(height: 25),

          Row(
            children: [
              Container(
                height: 78,
                width: 78,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(.35),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _email.isNotEmpty
                          ? _email
                          : "No email available",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.82),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _role,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(.12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _kycIcon,
                  color: Colors.white,
                  size: 19,
                ),

                const SizedBox(width: 9),

                const Text(
                  "KYC Verification",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _kycStatus,
                    style: TextStyle(
                      color: _kycColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: const Color(0xff7C3AED).withOpacity(.09),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: const Color(0xff7C3AED),
            size: 18,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xff1E1E1E),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GENERIC CARD
  // ============================================================

  Widget _buildInfoCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ============================================================
  // PROFILE INFO ROW
  // ============================================================

  Widget _profileInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xff7C3AED).withOpacity(.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xff7C3AED),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value.isNotEmpty ? value : "Not available",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff1E1E1E),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileDivider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade100,
    );
  }

  // ============================================================
  // KYC ROW
  // ============================================================

  Widget _buildKycRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: _kycColor.withOpacity(.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _kycIcon,
              color: _kycColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              "KYC Verification",
              style: TextStyle(
                color: Color(0xff1E1E1E),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _kycColor.withOpacity(.09),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _kycStatus,
              style: TextStyle(
                color: _kycColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FRANCHISE OVERVIEW
  // ============================================================

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _overviewItem(
              icon: Icons.store_mall_directory_outlined,
              label: "Centres",
              value: "$_centres",
              color: const Color(0xff7C3AED),
            ),
          ),

          _overviewDivider(),

          Expanded(
            child: _overviewItem(
              icon: Icons.people_alt_outlined,
              label: "Students",
              value: "$_students",
              color: const Color(0xffDB2777),
            ),
          ),

          _overviewDivider(),

          Expanded(
            child: _overviewItem(
              icon: Icons.groups_2_outlined,
              label: "Batches",
              value: "$_batches",
              color: const Color(0xff2563EB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 21,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          value,
          style: const TextStyle(
            color: Color(0xff1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _overviewDivider() {
    return Container(
      height: 60,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _buildActionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _actionTile(
            icon: Icons.edit_outlined,
            title: "Edit Profile",
            subtitle: "Update your personal information",
            color: const Color(0xff7C3AED),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Edit Profile feature coming soon.",
                  ),
                ),
              );
            },
          ),

          Divider(
            height: 1,
            indent: 68,
            color: Colors.grey.shade100,
          ),

          _actionTile(
            icon: Icons.lock_outline_rounded,
            title: "Change Password",
            subtitle: "Update your account password",
            color: const Color(0xff2563EB),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Change Password feature coming soon.",
                  ),
                ),
              );
            },
          ),

          Divider(
            height: 1,
            indent: 68,
            color: Colors.grey.shade100,
          ),

          _actionTile(
            icon: Icons.logout_rounded,
            title: "Logout",
            subtitle: "Sign out from your account",
            color: Colors.red,
            onTap: () => _confirmAndLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(.09),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color == Colors.red
                          ? Colors.red.shade700
                          : const Color(0xff1E1E1E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
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