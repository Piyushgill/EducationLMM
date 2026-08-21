import 'package:flutter/material.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/login_screen.dart';
import 'package:thenew/dashboards/super_admin_dashboard.dart';
import 'package:thenew/widgets/notification_bell.dart';
import 'package:thenew/widgets/dynamic_video_player.dart';
import 'package:thenew/widgets/view_all_content_screens.dart';

// ── Role constant used to filter admin-managed content (Videos/Testimonials/FAQs) ──
const String _kMyRole = "School";

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
//  SCHOOL DASHBOARD — Main Entry
// ============================================================

class SchoolDashboard extends StatefulWidget {
  const SchoolDashboard({super.key});

  @override
  State<SchoolDashboard> createState() => _SchoolDashboardState();
}

class _SchoolDashboardState extends State<SchoolDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  String _schoolName = "School Dashboard";
  String _schoolEmail = "";

  @override
  void initState() {
    super.initState();
    _loadSchoolSession();
  }

  Future<void> _loadSchoolSession() async {
    final session = await SessionManager.getSession();
    if (session != null) {
      setState(() {
        _schoolName = session['name'] ?? "School Dashboard";
        _schoolEmail = session['email'] ?? "";
      });
    }
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _goToTab(int index) {
    Navigator.pop(context); // close drawer
    setState(() => _currentIndex = index);
  }

  void _openScreen(Widget screen) {
    Navigator.pop(context); // close drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  late final List<Widget> _pages = [
    // 0 - Home
    _SchoolHomeTab(
      onMenuTap: _openDrawer,
    ),

    // 1 - Training Schedule
    const TrainingScheduleScreen(),

    // 2 - Kit Ordering
    const SchoolKitOrderScreen(),

    // 3 - Profile
    const _SchoolProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      drawer: _buildDrawer(context),

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xff0EA5E9),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,

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
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: "Training",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: "Kit Ordering",
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

  // ----------------------------------------------------------
  //  DRAWER
  // ----------------------------------------------------------
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
              decoration: const BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(51, 104, 160, 1),
                    Color.fromRGBO(2, 132, 199, 1),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 78,
                        width: 78,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(.35), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _schoolName.isNotEmpty ? _schoolName[0].toUpperCase() : "S",
                            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _schoolName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _schoolEmail.isNotEmpty ? _schoolEmail : "School Account",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withOpacity(.82), fontSize: 12),
                            ),
                            const SizedBox(height: 9),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.16),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "SCHOOL",
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: .5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 6, top: 4),
              child: Text("MAIN MENU",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade400, letterSpacing: 1.2)),
            ),

            _drawerItem(icon: Icons.home_outlined,         label: "Home",     selected: _currentIndex == 0, onTap: () => _goToTab(0)),
            _drawerItem(icon: Icons.groups_outlined,       label: "Students", onTap: () => _openScreen(const SchoolStudentDataScreen())),
            _drawerItem(icon: Icons.shopping_bag_outlined, label: "Orders",   onTap: () => _openScreen(const SchoolKitOrderScreen())),
            _drawerItem(icon: Icons.person_outline,        label: "Profile",  selected: _currentIndex == 1, onTap: () => _goToTab(1)),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Text("ACCOUNT",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade400, letterSpacing: 1.2)),
            ),

            _drawerItem(icon: Icons.notifications_none_rounded, label: "Notifications",   onTap: () => Navigator.pop(context)),
            _drawerItem(icon: Icons.help_outline_rounded,        label: "Help & Support",  onTap: () => Navigator.pop(context)),
            _drawerItem(icon: Icons.settings_outlined,           label: "Settings",        onTap: () => Navigator.pop(context)),

            const Spacer(),

            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider()),
            _drawerItem(
              icon: Icons.logout_rounded,
              label: "Logout",
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _confirmAndLogout(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
    Color? color,
  }) {
    final c = color ?? (selected ? const Color(0xff0EA5E9) : Colors.grey.shade700);
    return Material(
      color: selected ? const Color(0xffb74093).withOpacity(.08) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: c, size: 22),
        title: Text(label, style: TextStyle(color: c, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 14)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }
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
// ============================================================
//  HOME TAB
// ============================================================

class _SchoolHomeTab extends StatefulWidget {
  final VoidCallback onMenuTap;
  const _SchoolHomeTab({required this.onMenuTap});

  @override
  State<_SchoolHomeTab> createState() => _SchoolHomeTabState();
}

class _SchoolHomeTabState extends State<_SchoolHomeTab> {
  bool _isLoadingStats = false;
  int _networkSize = 0;
  int _activeSchools = 0;
  int _totalStudents = 0;
  int _activePrograms = 0;
  int _totalKitsOrdered = 0;
  double _pendingFeeAmount = 0.0;
  int _pendingFeeCount = 0;
  int _trainingCount = 0;
  int _circularsCount = 0;
  double _totalCommission = 0.0;
  String _userName = "School";

  // ── Admin-managed content (Videos / Testimonials / FAQs / Gallery / Programs), filtered by role ──
  bool _isLoadingVideos = false;
  bool _isLoadingTestimonials = false;
  bool _isLoadingFaqs = false;
  bool _isLoadingGallery = false;
  bool _isLoadingPrograms = false;
  List<dynamic> _adminVideos = [];
  List<dynamic> _adminTestimonials = [];
  List<dynamic> _adminFaqs = [];
  List<dynamic> _adminGallery = [];
  List<dynamic> _adminPrograms = [];

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoadingStats = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        setState(() {
          _userName = session['name'] ?? "School";
        });
        final userId = session['id'];

        // 1. User Network
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_user_network.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": userId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            if (mounted) {
              setState(() {
                _networkSize = data['network_size'] ?? 0;
                _activeSchools = data['active_schools'] ?? 0;
                _totalCommission = (data['total_commission'] ?? 0).toDouble();
              });
            }
          }
        }

        // 2. Class Strength (Total Students)
        final classRes = await http.post(
          Uri.parse("https://apps.kofalt.in/api/schools/get_class_strength.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"school_id": userId}),
        );
        if (classRes.statusCode == 200) {
          final cdata = jsonDecode(classRes.body);
          if (cdata['status'] == 'success') {
            if (mounted) {
              setState(() {
                _totalStudents = cdata['total_students'] ?? 0;
              });
            }
          }
        }

        // 3. Kit Orders (Programs Running & Total Kits)
        final kitRes = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_kit_orders.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"buyer_id": userId}),
        );
        if (kitRes.statusCode == 200) {
          final kdata = jsonDecode(kitRes.body);
          if (kdata['status'] == 'success') {
            final programsList = (kdata['data'] as List? ?? []);
            int totalKits = 0;
            for (var p in programsList) {
              totalKits += (p['total_quantity'] as num? ?? 0).toInt();
            }
            if (mounted) {
              setState(() {
                _activePrograms = programsList.length;
                _totalKitsOrdered = totalKits;
              });
            }
          }
        }

        // 4. Pending Payments
        final feeRes = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_pending_payments.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"school_id": userId}),
        );
        if (feeRes.statusCode == 200) {
          final fdata = jsonDecode(feeRes.body);
          if (fdata['status'] == 'success') {
            final feeList = (fdata['data'] as List? ?? []);
            double totalFee = 0.0;
            for (var f in feeList) {
              final raw = (f['amount'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.]'), '');
              totalFee += double.tryParse(raw) ?? 0.0;
            }
            if (mounted) {
              setState(() {
                _pendingFeeAmount = totalFee;
                _pendingFeeCount = feeList.length;
              });
            }
          }
        }

        // 5. Training Schedule Count
        final trainRes = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_training_schedule.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"school_id": userId}),
        );
        if (trainRes.statusCode == 200) {
          final tdata = jsonDecode(trainRes.body);
          if (tdata['status'] == 'success') {
            if (mounted) {
              setState(() {
                _trainingCount = (tdata['data'] as List? ?? []).length;
              });
            }
          }
        }

        // 6. Circulars Count
        final circRes = await http.get(Uri.parse("https://apps.kofalt.in/api/get_circulars.php?role=School"));
        if (circRes.statusCode == 200) {
          final cirData = jsonDecode(circRes.body);
          if (cirData['status'] == 'success') {
            if (mounted) {
              setState(() {
                _circularsCount = (cirData['circulars'] as List? ?? []).length;
              });
            }
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
  //  Fetch Content from Admin panel targeted at "School" or "All".
  // ----------------------------------------------------------
  Future<void> _fetchAdminContent() async {
    if (!mounted) return;
    setState(() {
      _isLoadingVideos = true;
      _isLoadingTestimonials = true;
      _isLoadingFaqs = true;
      _isLoadingGallery = true;
      _isLoadingPrograms = true;
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
      final res = await http.get(Uri.parse("https://apps.kofalt.in/api/get_programs.php?role=School"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success' && mounted) {
          setState(() => _adminPrograms = data['data'] ?? []);
        }
      }
    } catch (e) {
      debugPrint("Error fetching programs: $e");
    } finally {
      if (mounted) setState(() => _isLoadingPrograms = false);
    }

    try {
      final res = await http.get(Uri.parse("https://apps.kofalt.in/api/get_gallery.php?role=School"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success' && mounted) {
          setState(() => _adminGallery = data['data'] ?? []);
        }
      }
    } catch (e) {
      debugPrint("Error fetching gallery: $e");
    } finally {
      if (mounted) setState(() => _isLoadingGallery = false);
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
    final String pendingFeeStr = _pendingFeeAmount > 0 
        ? "₹${_pendingFeeAmount.toStringAsFixed(0)}" 
        : (_pendingFeeCount > 0 ? "$_pendingFeeCount Dues" : "₹0");

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(51, 104, 160, 1),
                  Color.fromRGBO(2, 132, 199, 1),
                ],
              ),            ),
            child: Column(children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onMenuTap,
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

                  const SizedBox(width: 12),

                  Image.asset(
                    'assets/image/kmain.png',
                    height: 54,
                    width: 145,
                    fit: BoxFit.fill,
                  ),

                  const Spacer(),

                  const NotificationBell(role: "School"),
                ],
              ),
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))),
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerLeft, child: Text("School Account", style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 16))),
              const SizedBox(height: 16),
              Row(children: [
                _hStat("Programs", "$_activePrograms"),
                _vDivider(),
                _hStat("Kit ordering", "$_totalKitsOrdered"),
                _vDivider(),
                _hStat("Pending Fee", pendingFeeStr),
                _vDivider(),
                _hStat("Students", "$_totalStudents"),
              ]),
            ]),
          ),

          // SCROLLABLE BODY
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadStats();
                await _fetchAdminContent();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // DASHBOARD CARDS
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: .95,
                    children: [
                      SDashboardCard(title: "Programs Running", value: "$_activePrograms",     icon: Icons.menu_book_outlined,      iconColor: const Color(0xff0EA5E9), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgramsRunningScreen()))),
                      SDashboardCard(title: "Student Data",     value: "$_totalStudents",   icon: Icons.groups_outlined,         iconColor: const Color(0xffA020F0), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchoolStudentDataScreen()))),
                      SDashboardCard(title: "Pending Payments", value: pendingFeeStr,  icon: Icons.payments_outlined,       iconColor: const Color(0xffFF6B00), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingPaymentsScreen()))),
                      SDashboardCard(title: "Kit Ordering",     value: "$_totalKitsOrdered Kits", icon: Icons.inventory_2_outlined,    iconColor: const Color(0xff16C74A), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchoolKitOrderScreen()))),
                      SDashboardCard(title: "Training Schedule",value: "$_trainingCount",     icon: Icons.calendar_today_outlined, iconColor: const Color(0xff2563EB), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingScheduleScreen()))),
                      SDashboardCard(title: "Circulars",        value: "$_circularsCount New", icon: Icons.announcement_outlined,   iconColor: const Color(0xffFF1493), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CircularsScreen()))),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // OUR PROGRAMS & DEMOS (live from admin)
                  if (_adminPrograms.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle("Our Programs & Demos"),
                        if (_adminPrograms.length > 3)
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllProgramsScreen(programs: _adminPrograms, themeColor: const Color(0xff0EA5E9)))),
                            child: const Text("View All", style: TextStyle(color: Color(0xff0EA5E9), fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: (_adminPrograms.length > 3 ? _adminPrograms.sublist(0, 3) : _adminPrograms).map((p) {
                        final title = p['title'] ?? "";
                        final desc = p['description'] ?? "";
                        final demoUrl = p['demo_video_url'] ?? "";
                        final fullDemoUrl = p['full_demo_video_url'] ?? "";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 38,
                                    width: 38,
                                    decoration: BoxDecoration(color: const Color(0xff0EA5E9).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.school_rounded, color: Color(0xff0EA5E9), size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),
                                ],
                              ),
                              if (desc.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (demoUrl.isNotEmpty)
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xff0EA5E9)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                        ),
                                        onPressed: () {
                                          DynamicVideoPlayerModal.show(context, title: "$title - Demo", description: desc, videoUrl: demoUrl, themeColor: const Color(0xff0EA5E9));
                                        },
                                        icon: const Icon(Icons.play_arrow_rounded, color: Color(0xff0EA5E9), size: 16),
                                        label: const Text("Watch Demo", style: TextStyle(color: Color(0xff0EA5E9), fontWeight: FontWeight.bold, fontSize: 11)),
                                      ),
                                    ),
                                  if (demoUrl.isNotEmpty && fullDemoUrl.isNotEmpty)
                                    const SizedBox(width: 8),
                                  if (fullDemoUrl.isNotEmpty)
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xff0EA5E9),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                          elevation: 0,
                                        ),
                                        onPressed: () {
                                          DynamicVideoPlayerModal.show(context, title: "$title - Full Demo", description: desc, videoUrl: fullDemoUrl, themeColor: const Color(0xff0EA5E9));
                                        },
                                        icon: const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 16),
                                        label: const Text("Full Demo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // TRAINING VIDEOS (live, from Admin panel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("Training Videos"),
                      if (_adminVideos.length > 3)
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllVideosScreen(videos: _adminVideos, themeColor: const Color(0xff0EA5E9)))),
                          child: const Text("View All", style: TextStyle(color: Color(0xff0EA5E9), fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _isLoadingVideos
                      ? SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: const Color(0xff0EA5E9))))
                      : _adminVideos.isEmpty
                      ? _emptyBlock("No training videos yet")
                      : SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: (_adminVideos.length > 3 ? _adminVideos.sublist(0, 3) : _adminVideos).map((v) {
                        return _videoCard(
                          v['title'] ?? "",
                          (v['description'] ?? "").toString().isNotEmpty ? v['description'] : "Tap to watch",
                          v['video_url'] ?? "",
                          const Color(0xff0EA5E9),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // GALLERY (live from admin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("Photo Gallery"),
                      if (_adminGallery.length > 3)
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllGalleryScreen(photos: _adminGallery, themeColor: const Color(0xff0EA5E9)))),
                          child: const Text("View All", style: TextStyle(color: Color(0xff0EA5E9), fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _isLoadingGallery
                      ? const Center(child: CircularProgressIndicator(color: Color(0xff0EA5E9)))
                      : _adminGallery.isEmpty
                      ? _emptyBlock("No gallery photos uploaded yet")
                      : SizedBox(
                    height: 96,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _adminGallery.length > 3 ? 3 : _adminGallery.length,
                      itemBuilder: (ctx, i) {
                        final photo = _adminGallery[i];
                        return Container(
                          width: 96,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              photo['image_url'] ?? "",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TESTIMONIALS (live, from Admin panel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("Testimonials"),
                      if (_adminTestimonials.length > 3)
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllTestimonialsScreen(testimonials: _adminTestimonials, themeColor: const Color(0xff0EA5E9)))),
                          child: const Text("View All", style: TextStyle(color: Color(0xff0EA5E9), fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _isLoadingTestimonials
                      ? const Center(child: CircularProgressIndicator())
                      : _adminTestimonials.isEmpty
                      ? _emptyBlock("No testimonials yet")
                      : Column(
                    children: (_adminTestimonials.length > 3 ? _adminTestimonials.sublist(0, 3) : _adminTestimonials).map((t) {
                      final rating = int.tryParse(t['rating']?.toString() ?? '5') ?? 5;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _testimonialCard(t['name'] ?? "", t['message'] ?? "", rating),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // FAQ (live, from Admin panel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("FAQ"),
                      if (_adminFaqs.length > 3)
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllFaqsScreen(faqs: _adminFaqs, themeColor: const Color(0xff0EA5E9)))),
                          child: const Text("View All", style: TextStyle(color: Color(0xff0EA5E9), fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingFaqs)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_adminFaqs.isEmpty)
                    _emptyBlock("No FAQs yet")
                  else
                    ...(_adminFaqs.length > 3 ? _adminFaqs.sublist(0, 3) : _adminFaqs).map((f) => _faqItem(f['question'] ?? "", f['answer'] ?? "")),

                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _hStat(String label, String value) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _videoCard(String title, String description, String videoUrl, Color color) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        DynamicVideoPlayerModal.show(
          context,
          title: title,
          description: description,
          videoUrl: videoUrl,
          themeColor: color,
        );
      },
      child: Container(
        width: 160, margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
        child: Row(children: [
          Icon(Icons.play_circle_filled, color: color, size: 30),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text("Watch Now", style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
        ]),
      ),
    ),
  );

  Widget _testimonialCard(String name, String text, int stars) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(backgroundColor: const Color(0xff0EA5E9).withOpacity(.1), radius: 18, child: Text(name.isNotEmpty ? name[0] : "?", style: const TextStyle(color: Color(0xff0EA5E9), fontWeight: FontWeight.bold))),
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
      iconColor: const Color(0xff0EA5E9),
      children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 14), child: Text(a, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)))],
    ),
  );
}

// ============================================================
//  PROFILE TAB
// ============================================================

// ============================================================
// SCHOOL PROFILE SCREEN
// Franchise-style profile UI
// School theme preserved
// ============================================================

class _SchoolProfileScreen extends StatefulWidget {
  const _SchoolProfileScreen();

  @override
  State<_SchoolProfileScreen> createState() =>
      _SchoolProfileScreenState();
}

class _SchoolProfileScreenState
    extends State<_SchoolProfileScreen> {

  String _schoolName = "";
  String _schoolEmail = "";
  String _schoolPhone = "";
  String _schoolRole = "";
  String _kycStatus = "";

  int _studentsCount = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // ==========================================================
  // LOAD PROFILE
  // ==========================================================

  Future<void> _loadProfileData() async {

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {

      final session =
      await SessionManager.getSession();

      if (session == null) {
        return;
      }

      if (mounted) {
        setState(() {

          _schoolName =
              (session['name'] ?? "").toString();

          _schoolEmail =
              (session['email'] ?? "").toString();

          _schoolPhone =
              (session['phone'] ?? "").toString();

          _schoolRole =
              (session['role'] ?? "School").toString();

          _kycStatus =
              (session['kyc_status'] ??
                  session['kycStatus'] ??
                  "")
                  .toString();
        });
      }

      final userId = session['id'];

      if (userId == null) {
        return;
      }

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

          final data =
          jsonDecode(response.body);

          if (data['status'] == 'success') {

            if (mounted) {
              setState(() {

                _studentsCount =
                    int.tryParse(
                      data['total_students']
                          .toString(),
                    ) ??
                        0;
              });
            }
          }
        }

      } catch (e) {

        debugPrint(
          "Profile stats error: $e",
        );
      }

    } catch (e) {

      debugPrint(
        "Profile loading error: $e",
      );

    } finally {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {

    final avatarLetter =
    _schoolName.trim().isNotEmpty
        ? _schoolName
        .trim()
        .substring(0, 1)
        .toUpperCase()
        : "S";

    return Scaffold(
      backgroundColor:
      const Color(0xffF5F5F5),

      body: SafeArea(
        child: RefreshIndicator(
          color:
          const Color(0xff0EA5E9),

          onRefresh:
          _loadProfileData,

          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            child: Column(
              children: [

                // ==================================================
                // HERO HEADER
                // ==================================================

                Container(
                  width: double.infinity,

                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    34,
                  ),

                  decoration:
                  const BoxDecoration(
                    gradient:
                    LinearGradient(
                      begin:
                      Alignment.topLeft,
                      end:
                      Alignment.bottomRight,

                      colors: [
                        Color(0xff0EA5E9),
                        Color(0xff0284C7),
                      ],
                    ),

                    borderRadius:
                    BorderRadius.only(
                      bottomLeft:
                      Radius.circular(30),
                      bottomRight:
                      Radius.circular(30),
                    ),
                  ),

                  child: Column(
                    children: [

                      // Top row
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          // Back / home
                          InkWell(
                            borderRadius:
                            BorderRadius.circular(
                              13,
                            ),

                            onTap: () {

                              if (Navigator.canPop(
                                context,
                              )) {
                                Navigator.pop(
                                  context,
                                );
                              }
                            },

                            child: Container(
                              height: 42,
                              width: 42,

                              decoration:
                              BoxDecoration(
                                color: Colors.white
                                    .withOpacity(.16),
                                borderRadius:
                                BorderRadius.circular(
                                  13,
                                ),
                              ),

                              child:
                              const Icon(
                                Icons.arrow_back_ios_new,
                                color:
                                Colors.white,
                                size: 18,
                              ),
                            ),
                          ),

                          const Text(
                            "Profile",
                            style:
                            TextStyle(
                              color:
                              Colors.white,
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          // Edit
                          InkWell(
                            borderRadius:
                            BorderRadius.circular(
                              13,
                            ),

                            onTap: () {
                              // Existing edit functionality
                              // yahan connect kar sakte ho.
                            },

                            child: Container(
                              height: 42,
                              width: 42,

                              decoration:
                              BoxDecoration(
                                color: Colors.white
                                    .withOpacity(.16),
                                borderRadius:
                                BorderRadius.circular(
                                  13,
                                ),
                              ),

                              child:
                              const Icon(
                                Icons.edit_outlined,
                                color:
                                Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Avatar
                      Container(
                        height: 92,
                        width: 92,

                        decoration:
                        BoxDecoration(
                          color: Colors.white,
                          shape:
                          BoxShape.circle,

                          border: Border.all(
                            color: Colors.white
                                .withOpacity(.65),
                            width: 3,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(.12),
                              blurRadius: 15,
                              offset:
                              const Offset(
                                0,
                                7,
                              ),
                            ),
                          ],
                        ),

                        child: Center(
                          child: Text(
                            avatarLetter,

                            style:
                            const TextStyle(
                              color:
                              Color(0xff0EA5E9),
                              fontSize: 38,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        _schoolName.isNotEmpty
                            ? _schoolName
                            : "School",

                        textAlign:
                        TextAlign.center,

                        maxLines: 2,

                        overflow:
                        TextOverflow.ellipsis,

                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                          fontSize: 19,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        _schoolRole.isNotEmpty
                            ? _schoolRole
                            : "School Admin",

                        style:
                        TextStyle(
                          color:
                          Colors.white
                              .withOpacity(.85),
                          fontSize: 13,
                        ),
                      ),

                      if (_kycStatus.isNotEmpty) ...[
                        const SizedBox(height: 10),

                        _profileStatusBadge(
                          _kycStatus,
                        ),
                      ],
                    ],
                  ),
                ),

                // ==================================================
                // OVERVIEW CARD
                // ==================================================

                Transform.translate(
                  offset:
                  const Offset(0, -22),

                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),

                    child: Container(
                      width: double.infinity,

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 18,
                      ),

                      decoration:
                      BoxDecoration(
                        color:
                        Colors.white,

                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(.07),
                            blurRadius: 14,
                            offset:
                            const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [

                          _profileStat(
                            icon:
                            Icons.groups_rounded,
                            label:
                            "Students",
                            value:
                            "$_studentsCount",
                          ),

                          _profileDivider(),

                          _profileStat(
                            icon:
                            Icons.verified_user_outlined,
                            label:
                            "KYC",
                            value:
                            _kycStatus.isNotEmpty
                                ? _kycStatus
                                : "Pending",
                          ),

                          _profileDivider(),

                          _profileStat(
                            icon:
                            Icons.school_rounded,
                            label:
                            "Role",
                            value:
                            "School",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // INFORMATION
                // ==================================================

                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    18,
                    0,
                    18,
                    30,
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      _profileSectionTitle(
                        "CONTACT INFORMATION",
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _profileInfoCard(
                        icon:
                        Icons.email_outlined,
                        title:
                        "Email",
                        value:
                        _schoolEmail,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _profileInfoCard(
                        icon:
                        Icons.phone_outlined,
                        title:
                        "Phone",
                        value:
                        _schoolPhone,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _profileInfoCard(
                        icon:
                        Icons.badge_outlined,
                        title:
                        "Account Type",
                        value:
                        _schoolRole.isNotEmpty
                            ? _schoolRole
                            : "School",
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      _profileSectionTitle(
                        "ACCOUNT",
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _profileActionCard(
                        icon:
                        Icons.lock_outline_rounded,
                        title:
                        "Change Password",
                        color:
                        const Color(0xff0EA5E9),
                        onTap: () {
                          // Existing change password
                          // screen yahan connect karo.
                        },
                      ),

                      _profileActionCard(
                        icon:
                        Icons.account_balance_outlined,
                        title:
                        "Bank Details",
                        color:
                        const Color(0xffA020F0),
                        onTap: () {
                          // Existing bank details
                          // screen yahan connect karo.
                        },
                      ),

                      _profileActionCard(
                        icon:
                        Icons.description_outlined,
                        title:
                        "Documents",
                        color:
                        const Color(0xffFF6B00),
                        onTap: () {
                          // Existing documents
                          // screen yahan connect karo.
                        },
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      _profileSectionTitle(
                        "PREFERENCES",
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _profileActionCard(
                        icon:
                        Icons.notifications_none_rounded,
                        title:
                        "Notification Settings",
                        color:
                        const Color(0xff2563EB),
                        onTap: () {},
                      ),

                      _profileActionCard(
                        icon:
                        Icons.help_outline_rounded,
                        title:
                        "Help & Support",
                        color:
                        const Color(0xff16C74A),
                        onTap: () {},
                      ),

                      _profileActionCard(
                        icon:
                        Icons.info_outline_rounded,
                        title:
                        "About App",
                        color:
                        const Color(0xff64748B),
                        onTap: () {},
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ==================================================
                      // LOGOUT
                      // ==================================================

                      InkWell(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),

                        onTap: () {
                          _confirmAndLogout(
                            context,
                          );
                        },

                        child: Container(
                          width:
                          double.infinity,

                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 14,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            Colors.red
                                .withOpacity(.07),

                            borderRadius:
                            BorderRadius.circular(
                              16,
                            ),

                            border:
                            Border.all(
                              color:
                              Colors.red
                                  .withOpacity(.18),
                            ),
                          ),

                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children: [

                              const Icon(
                                Icons.logout_rounded,
                                color:
                                Colors.red,
                                size: 20,
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              const Text(
                                "Logout",
                                style:
                                TextStyle(
                                  color:
                                  Colors.red,
                                  fontWeight:
                                  FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Center(
                        child: Text(
                          "Kofalt Global",
                          style:
                          TextStyle(
                            color:
                            Colors.grey.shade400,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _profileStatusBadge(
      String status,
      ) {
    final normalized =
    status.toLowerCase();

    final bool approved =
        normalized == "approved";

    final bool rejected =
        normalized == "rejected";

    final Color color =
    approved
        ? const Color(0xff16A34A)
        : rejected
        ? const Color(0xffDC2626)
        : const Color(0xffF59E0B);

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white.withOpacity(.18),
        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize:
        MainAxisSize.min,

        children: [

          Container(
            height: 7,
            width: 7,

            decoration:
            BoxDecoration(
              color: color,
              shape:
              BoxShape.circle,
            ),
          ),

          const SizedBox(
            width: 6,
          ),

          Text(
            "KYC ${status.toUpperCase()}",
            style:
            const TextStyle(
              color:
              Colors.white,
              fontSize: 9.5,
              fontWeight:
              FontWeight.w700,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE STAT
  // ============================================================

  Widget _profileStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [

          Icon(
            icon,
            color:
            const Color(0xff0EA5E9),
            size: 20,
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            value,

            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,

            style:
            const TextStyle(
              color:
              Color(0xff1E293B),
              fontSize: 15,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            label,

            style:
            TextStyle(
              color:
              Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileDivider() {
    return Container(
      height: 38,
      width: 1,
      color:
      Colors.grey.shade200,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _profileSectionTitle(
      String title,
      ) {
    return Text(
      title,

      style:
      TextStyle(
        color:
        Colors.grey.shade500,
        fontSize: 10.5,
        fontWeight:
        FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _profileInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(14),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(16),

        border:
        Border.all(
          color:
          Colors.grey.shade100,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(.035),
            blurRadius: 8,
            offset:
            const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            height: 42,
            width: 42,

            decoration:
            BoxDecoration(
              color:
              const Color(0xff0EA5E9)
                  .withOpacity(.10),

              borderRadius:
              BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color:
              const Color(0xff0EA5E9),
              size: 20,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style:
                  TextStyle(
                    color:
                    Colors.grey.shade500,
                    fontSize: 10.5,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value.isNotEmpty
                      ? value
                      : "Not available",

                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,

                  style:
                  const TextStyle(
                    color:
                    Color(0xff1E293B),
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w600,
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
  // ACTION CARD
  // ============================================================

  Widget _profileActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(16),

        border:
        Border.all(
          color:
          Colors.grey.shade100,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(.035),
            blurRadius: 8,
            offset:
            const Offset(0, 3),
          ),
        ],
      ),

      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 2,
        ),

        leading: Container(
          height: 40,
          width: 40,

          decoration:
          BoxDecoration(
            color:
            color.withOpacity(.10),
            borderRadius:
            BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),

        title: Text(
          title,
          style:
          const TextStyle(
            color:
            Color(0xff1E293B),
            fontSize: 13,
            fontWeight:
            FontWeight.w600,
          ),
        ),

        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 13,
          color:
          Colors.grey.shade400,
        ),

        onTap: onTap,
      ),
    );
  }
}

// ============================================================
//  SCHOOL DASHBOARD CARD
// ============================================================

class SDashboardCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const SDashboardCard({super.key, required this.title, required this.value, required this.icon, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 48, width: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(colors: [iconColor, iconColor.withOpacity(.8)])), child: Icon(icon, color: Colors.white, size: 26)),
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
//  DETAIL SCREENS
// ============================================================

Widget _sDetailHeader({required String title, required String subtitle, required List<Color> colors, required VoidCallback onBack, List<Widget>? extra}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.only(left: 24, right: 24, top: 52, bottom: 24),
    decoration: BoxDecoration(borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)), gradient: LinearGradient(colors: colors)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(onTap: onBack, child: Container(height: 40, width: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18))),
      const SizedBox(height: 16),
      Text(title,    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      if (extra != null) ...[const SizedBox(height: 14), ...extra],
    ]),
  );
}

// ============================================================
// 1. PROGRAMS RUNNING
// Ab yeh Kit Ordering se derive hota hai — jo kit/course order
// hua wahi program is school ke liye "Active" maana jaata hai.
// ============================================================
class ProgramsRunningScreen extends StatefulWidget {
  const ProgramsRunningScreen({super.key});

  @override
  State<ProgramsRunningScreen> createState() => _ProgramsRunningScreenState();
}

class _ProgramsRunningScreenState extends State<ProgramsRunningScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _programs = [];

  final Map<String, IconData> _icons = const {
    'Vedic Math': Icons.plus_one,
    'Phonics': Icons.mic_none_rounded,
    'English': Icons.menu_book_outlined,
    'Abacus': Icons.calculate_rounded,
  };

  final List<Color> _palette = const [
    Color(0xff0EA5E9),
    Color(0xffA020F0),
    Color(0xff16C74A),
    Color(0xffFF6B00),
    Color(0xff2563EB),
    Color(0xffFF1493),
  ];

  @override
  void initState() {
    super.initState();
    _loadProgramsFromOrders();
  }

  // Fetches this school's kit-order history, grouped by program name.
  // TODO (backend): create this endpoint —
  // POST https://apps.kofalt.in/api/get_kit_orders.php
  // body: { "buyer_id": <school id> }
  // expected response:
  // { "status": "success",
  //   "data": [ { "program": "Abacus", "total_quantity": 50 }, ... ] }
  Future<void> _loadProgramsFromOrders() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      final buyerId = session?['id'];
      if (buyerId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final res = await http.post(
        Uri.parse("https://apps.kofalt.in/api/get_kit_orders.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"buyer_id": buyerId}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final rows = (data['data'] as List? ?? []);
          if (mounted) {
            setState(() {
              _programs = rows.map<Map<String, dynamic>>((r) {
                return {
                  'name': (r['program'] ?? '').toString(),
                  'students': int.tryParse(r['total_quantity'].toString()) ?? 0,
                };
              }).toList();
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading programs from orders: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(children: [
        _sDetailHeader(
          title: "Programs Running",
          subtitle: _isLoading ? "Loading…" : "${_programs.length} active programs",
          colors: const [Color(0xff0EA5E9), Color(0xff0284C7)],
          onBack: () => Navigator.pop(context),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xff0EA5E9)))
              : _programs.isEmpty
              ? _emptyProgramsState(context)
              : ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: _programs.length,
            itemBuilder: (_, i) {
              final p = _programs[i];
              final color = _palette[i % _palette.length];
              final icon = _icons[p['name']] ?? Icons.inventory_2_outlined;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)]),
                child: Row(children: [
                  Container(height: 52, width: 52, decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color, size: 28)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("${p['students']} Kits Ordered", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xff16C74A).withOpacity(.1), borderRadius: BorderRadius.circular(20)), child: const Text("Active", style: TextStyle(color: Color(0xff16C74A), fontSize: 12, fontWeight: FontWeight.w600))),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _emptyProgramsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            Text("No programs running yet", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            const SizedBox(height: 6),
            Text("Order a kit to activate a program for your school", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SchoolKitOrderScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff0EA5E9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Go to Kit Ordering", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 2. STUDENT DATA
// FAB ab "Add Student" hai — class select karke uski strength
// mein students add karo (existing strength ke upar add hota hai).
// ============================================================
class SchoolStudentDataScreen extends StatefulWidget {
  const SchoolStudentDataScreen({super.key});

  @override
  State<SchoolStudentDataScreen> createState() => _SchoolStudentDataScreenState();
}

class _SchoolStudentDataScreenState extends State<SchoolStudentDataScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _classes = [];

  int get _totalStudents => _classes.fold(0, (sum, c) => sum + (int.tryParse(c["strength"]?.toString() ?? '0') ?? 0));

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      final schoolId = session?['id'];
      if (schoolId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final res = await http.post(
        Uri.parse("https://apps.kofalt.in/api/schools/get_class_strength.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"school_id": schoolId}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final list = (data['classes'] as List? ?? []);
          if (mounted) {
            setState(() {
              _classes = list.map((c) => Map<String, dynamic>.from(c)).toList();
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching class strength: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openAddStudentDialog() async {
    String? selectedClass = _classes.isNotEmpty ? _classes.first["class_name"] as String : null;
    final qtyController = TextEditingController(text: "1");

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text("Add Students to Class", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Class", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedClass,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: _classes
                        .map((c) => DropdownMenuItem<String>(
                      value: c["class_name"].toString(),
                      child: Text(c["class_name"].toString()),
                    ))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedClass = v),
                  ),
                  const SizedBox(height: 14),
                  const Text("No. of Students to Add", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "e.g. 5",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffA020F0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final addQty = int.tryParse(qtyController.text.trim()) ?? 0;
                    if (selectedClass == null || addQty <= 0) return;
                    Navigator.pop(ctx);
                    _addStudentsToClass(selectedClass!, addQty);
                  },
                  child: const Text("Add", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addStudentsToClass(String className, int qty) async {
    try {
      final session = await SessionManager.getSession();
      final schoolId = session?['id'];
      if (schoolId == null) return;

      final res = await http.post(
        Uri.parse("https://apps.kofalt.in/api/schools/update_class_strength.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "school_id": schoolId,
          "class_name": className,
          "add_qty": qty
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          _fetchClasses();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("+$qty student(s) added to $className successfully!"),
                backgroundColor: const Color(0xffA020F0),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error updating class strength: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalStudents = _totalStudents;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 55,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffA020F0),
                  Color(0xff7B10BF),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Class Strength",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Total Classes : ${_classes.length}",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    _statCard(
                      "Classes",
                      "${_classes.length}",
                    ),
                    const SizedBox(width: 18),
                    _statCard(
                      "Students",
                      "$totalStudents",
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Class List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final data = _classes[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xffA020F0).withOpacity(.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Color(0xffA020F0),
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["class_name"],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Class Strength",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xffA020F0).withOpacity(.12),
                          borderRadius:
                          BorderRadius.circular(30),
                        ),
                        child: Text(
                          "${data["strength"]} Students",
                          style: const TextStyle(
                            color: Color(0xffA020F0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddStudentDialog,
        backgroundColor: const Color(0xffA020F0),
        icon: const Icon(
          Icons.person_add_alt_1_rounded,
          color: Colors.white,
        ),
        label: const Text(
          "Add Student",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  static Widget _statCard(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 3. PENDING PAYMENTS — dynamic, loaded from backend
// ============================================================
class PendingPaymentsScreen extends StatefulWidget {
  const PendingPaymentsScreen({super.key});

  @override
  State<PendingPaymentsScreen> createState() => _PendingPaymentsScreenState();
}

class _PendingPaymentsScreenState extends State<PendingPaymentsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingPayments();
  }

  // TODO (backend): create this endpoint —
  // POST https://apps.kofalt.in/api/get_pending_payments.php
  // body: { "school_id": <session id> }
  // expected response:
  // { "status": "success",
  //   "data": [ { "student": "Anjali Mehta", "amount": "2500", "due": "15 Feb 2026", "status": "Overdue" }, ... ] }
  Future<void> _fetchPendingPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final session = await SessionManager.getSession();
      final schoolId = session?['id'];
      if (schoolId == null) {
        setState(() {
          _isLoading = false;
          _error = "Session not found. Please log in again.";
        });
        return;
      }

      final res = await http.post(
        Uri.parse("https://apps.kofalt.in/api/get_pending_payments.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"school_id": schoolId}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final rows = (data['data'] as List? ?? []);
          if (mounted) {
            setState(() {
              _payments = rows.map<Map<String, dynamic>>((r) {
                final rawAmount = (r['amount'] ?? '0').toString();
                final numericAmount = double.tryParse(rawAmount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
                return {
                  'student': (r['student'] ?? '').toString(),
                  'amount': "₹${numericAmount.toStringAsFixed(0)}",
                  'due': (r['due'] ?? '').toString(),
                  'status': (r['status'] ?? 'Pending').toString(),
                };
              }).toList();
            });
          }
        } else {
          setState(() => _error = data['message']?.toString() ?? "Could not load payments.");
        }
      } else {
        setState(() => _error = "Could not reach server (${res.statusCode}).");
      }
    } catch (e) {
      debugPrint("Error fetching pending payments: $e");
      if (mounted) setState(() => _error = "Network error. Pull to refresh and try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _c(String s) {
    if (s == 'Overdue') return Colors.red;
    if (s == 'Due Soon') return const Color(0xffFF6B00);
    return const Color(0xffFFB800);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(children: [
        _sDetailHeader(
          title: "Pending Payments",
          subtitle: _isLoading ? "Loading…" : "${_payments.length} pending dues",
          colors: const [Color(0xffFF6B00), Color(0xffFF9500)],
          onBack: () => Navigator.pop(context),
        ),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xffFF6B00),
            onRefresh: _fetchPendingPayments,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xffFF6B00)))
                : _error != null
                ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Center(child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _fetchPendingPayments,
                    child: const Text("Retry"),
                  ),
                ),
              ],
            )
                : _payments.isEmpty
                ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Center(child: Text("No pending payments 🎉", style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
              ],
            )
                : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(18),
              itemCount: _payments.length,
              itemBuilder: (_, i) {
                final p = _payments[i];
                final c = _c(p['status']!);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
                  child: Row(children: [
                    Container(height: 46, width: 46, decoration: BoxDecoration(color: c.withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.payments_outlined, color: c, size: 24)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p['student']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text("Due: ${p['due']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(p['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: c.withOpacity(.1), borderRadius: BorderRadius.circular(10)), child: Text(p['status']!, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600))),
                    ]),
                  ]),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}

// 4. KIT ORDER SCREEN
class SchoolKitOrderScreen extends StatefulWidget {
  const SchoolKitOrderScreen({super.key});

  @override
  State<SchoolKitOrderScreen> createState() => _SchoolKitOrderScreenState();
}

class _SchoolKitOrderScreenState extends State<SchoolKitOrderScreen> {
  int _mainKitQty = 0;
  final Map<int, int> _levelQty = {for (var l in [2, 3, 4, 5, 6, 7, 8]) l: 0};

  // NEW: 4 extra courses
  final Map<String, int> _courseQty = {
    for (var c in ['Vedic Math', 'Phonics', 'English', 'Abacus']) c: 0,
  };

  int get _totalItems =>
      _mainKitQty +
          _levelQty.values.fold<int>(0, (a, b) => a + b) +
          _courseQty.values.fold<int>(0, (a, b) => a + b);

  int _safeQty(int value) {
    return value < 0 ? 0 : value;
  }

  void _changeMainQty(int delta) {
    setState(() {
      _mainKitQty = _safeQty(_mainKitQty + delta);
    });
  }

  void _changeLevelQty(int level, int delta) {
    setState(() {
      _levelQty[level] = _safeQty(_levelQty[level]! + delta);
    });
  }

  void _changeCourseQty(String course, int delta) {
    setState(() {
      _courseQty[course] = _safeQty(_courseQty[course]! + delta);
    });
  }

  void _setMainQty(int value) {
    setState(() {
      _mainKitQty = _safeQty(value);
    });
  }

  void _setLevelQty(int level, int value) {
    setState(() {
      _levelQty[level] = _safeQty(value);
    });
  }

  void _setCourseQty(String course, int value) {
    setState(() {
      _courseQty[course] = _safeQty(value);
    });
  }

  // NEW: dialog to type quantity directly instead of only using +/- steppers
  Future<void> _editQtyDialog({
    required String name,
    required int currentQty,
    required Color color,
    required ValueChanged<int> onConfirm,
  }) async {
    final controller = TextEditingController(text: currentQty.toString());
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter quantity",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: color,
                  width: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());

                if (parsed != null && parsed >= 0) {
                  onConfirm(parsed);
                  Navigator.pop(ctx);
                }
              },
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _openOrderSummary() {
    final items = <Map<String, dynamic>>[];
    if (_mainKitQty > 0) items.add({'name': 'New Kit (Main)', 'qty': _mainKitQty});
    for (final l in _levelQty.keys) {
      if (_levelQty[l]! > 0) items.add({'name': 'Level $l Kit', 'qty': _levelQty[l]});
    }
    // NEW: include courses in summary
    for (final c in _courseQty.keys) {
      if (_courseQty[c]! > 0) items.add({'name': c, 'qty': _courseQty[c]});
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("$_totalItems items", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (_, i) {
                        final it = items[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(children: [
                            Container(
                              height: 38, width: 38,
                              decoration: BoxDecoration(color: const Color(0xff16C74A).withOpacity(.1), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.inventory_2_outlined, color: Color(0xff16C74A), size: 19),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(it['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                            Text("x${it['qty']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ]),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _placeOrder();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff16C74A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text("Confirm Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff16C74A))),
    );

    try {
      final session = await SessionManager.getSession();
      if (session == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: User session not found. Please log in.")),
        );
        return;
      }
      final buyerId = session['id'];

      final orders = <Future>[];
      if (_mainKitQty > 0) {
        orders.add(
            http.post(
              Uri.parse("https://apps.kofalt.in/api/order_kit.php"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "buyer_id": buyerId,
                "level": "Level 1",
                "quantity": _mainKitQty,
              }),
            )
        );
      }
      for (final l in _levelQty.keys) {
        final qty = _levelQty[l]!;
        if (qty > 0) {
          orders.add(
              http.post(
                Uri.parse("https://apps.kofalt.in/api/order_kit.php"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "buyer_id": buyerId,
                  "level": "Level $l",
                  "quantity": qty,
                }),
              )
          );
        }
      }

      // NEW: send course orders too
      for (final c in _courseQty.keys) {
        final qty = _courseQty[c]!;
        if (qty > 0) {
          orders.add(
              http.post(
                Uri.parse("https://apps.kofalt.in/api/order_kit.php"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "buyer_id": buyerId,
                  "level": c,
                  "quantity": qty,
                }),
              )
          );
        }
      }

      final responses = await Future.wait(orders);

      if (!mounted) return;
      Navigator.pop(context); // Close loader

      bool allSuccess = true;
      for (final res in responses) {
        final data = jsonDecode((res as http.Response).body);
        if (data['status'] != 'success') {
          allSuccess = false;
        }
      }

      if (allSuccess) {
        final placedItems = _totalItems;
        setState(() {
          _mainKitQty = 0;
          for (final l in _levelQty.keys) {
            _levelQty[l] = 0;
          }
          for (final c in _courseQty.keys) {
            _courseQty[c] = 0;
          }
        });

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 64, width: 64,
                  decoration: BoxDecoration(color: const Color(0xff16C74A).withOpacity(.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: Color(0xff16C74A), size: 40),
                ),
                const SizedBox(height: 16),
                const Text("Order Placed!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  "Total items ordered: $placedItems\nMLM downline commissions distributed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff16C74A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Some orders failed to process. Please check connection."), backgroundColor: Colors.red),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Network error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(children: [
        _sDetailHeader(title: "Kit Ordering", subtitle: "Main kit + Level 2-8 kits + Courses", colors: const [Color(0xff16C74A), Color(0xff059669)], onBack: () => Navigator.pop(context)),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label("New Main Kit"),
            const SizedBox(height: 10),
            _kitCard(
              name: "New Kit (Main)",
              desc: "For new student enrollments",
              color: const Color(0xff16C74A),
              qty: _mainKitQty,
              onAdd: () => _changeMainQty(1),
              onRemove: () => _changeMainQty(-1),
              onQtyChanged: (v) => _setMainQty(v),
            ),
            const SizedBox(height: 20),
            _label("Level Kits (2-8)"),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _levelQty.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final lvl = _levelQty.keys.elementAt(i);
                return _kitCard(
                  name: "Level $lvl Kit",
                  desc: "Advanced training modules",
                  color: const Color(0xff16C74A),
                  qty: _levelQty[lvl]!,
                  onAdd: () => _changeLevelQty(lvl, 1),
                  onRemove: () => _changeLevelQty(lvl, -1),
                  onQtyChanged: (v) => _setLevelQty(lvl, v),
                );
              },
            ),
            // NEW: Courses section
            const SizedBox(height: 20),
            _label("Courses"),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _courseQty.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final course = _courseQty.keys.elementAt(i);
                return _kitCard(
                  name: course,
                  desc: "Course kit",
                  color: const Color(0xff16C74A),
                  qty: _courseQty[course]!,
                  onAdd: () => _changeCourseQty(course, 1),
                  onRemove: () => _changeCourseQty(course, -1),
                  onQtyChanged: (v) => _setCourseQty(course, v),
                );
              },
            ),
          ]),
        )),
      ]),
      bottomNavigationBar: _totalItems == 0
          ? null
          : Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10)],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Selected", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text("$_totalItems items", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              ElevatedButton(
                onPressed: _openOrderSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff16C74A),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text("View Summary", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E)));

  Widget _kitCard({
    required String name,
    required String desc,
    required Color color,
    required int qty,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    required ValueChanged<int> onQtyChanged, // NEW
  }) {
    final selected = qty > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? color.withOpacity(.4) : Colors.transparent, width: 1.4),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.inventory_2_outlined, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(desc, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          qty == 0
              ? GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
              child: const Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          )
              : Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepBtn(Icons.remove, color, onRemove),
                // NEW: tap on the number to type quantity directly
                GestureDetector(
                  onTap: () => _editQtyDialog(
                    name: name,
                    currentQty: qty,
                    color: color,
                    onConfirm: onQtyChanged,
                  ),
                  child: SizedBox(
                    width: 28,
                    child: Text("$qty", textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                _stepBtn(Icons.add, color, onAdd),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 28,
      width: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 16),
    ),
  );
}

// ============================================================
// 5. TRAINING SCHEDULE
// School sirf "Request Training" bhej sakta hai — topic + preferred
// date + notes. Request Admin ke pass jaati hai; Admin apni marzi
// se schedule/approve/reject karega.
// ============================================================
class TrainingScheduleScreen extends StatefulWidget {
  const TrainingScheduleScreen({super.key});

  @override
  State<TrainingScheduleScreen> createState() => _TrainingScheduleScreenState();
}

class _TrainingScheduleScreenState extends State<TrainingScheduleScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _schedule = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  // Shows admin-scheduled trainings + this school's own pending requests.
  // TODO (backend): create this endpoint —
  // POST https://apps.kofalt.in/api/get_training_schedule.php
  // body: { "school_id": <session id> }
  // expected response:
  // { "status": "success",
  //   "data": [ { "topic": "Abacus", "date": "15 Mar 2026", "time": "10:00 AM", "status": "Scheduled" }, ... ] }
  Future<void> _fetchSchedule() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      final schoolId = session?['id'];
      if (schoolId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final res = await http.post(
        Uri.parse("https://apps.kofalt.in/api/get_training_schedule.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"school_id": schoolId}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          if (mounted) {
            setState(() {
              _schedule = List<Map<String, dynamic>>.from(data['data'] ?? []);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching training schedule: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openRequestTrainingDialog() async {
    final topicController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? preferredDate;
    TimeOfDay? preferredTime;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text("Request Training", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Topic / Program", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: topicController,
                      decoration: InputDecoration(
                        hintText: "e.g. Abacus, Vedic Maths",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text("Preferred Date & Time", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: DateTime.now().add(const Duration(days: 3)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setDialogState(() => preferredDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                              child: Row(children: [
                                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    preferredDate == null
                                        ? "Date"
                                        : "${preferredDate!.day}/${preferredDate!.month}/${preferredDate!.year}",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: preferredDate == null ? Colors.grey.shade500 : Colors.black87, fontSize: 13),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: preferredTime ?? const TimeOfDay(hour: 10, minute: 0),
                              );
                              if (picked != null) setDialogState(() => preferredTime = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                              child: Row(children: [
                                Icon(Icons.access_time_rounded, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    preferredTime == null ? "Time" : preferredTime!.format(ctx),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: preferredTime == null ? Colors.grey.shade500 : Colors.black87, fontSize: 13),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text("Notes (optional)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Anything admin should know",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (topicController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    await _submitTrainingRequest(
                      topic: topicController.text.trim(),
                      date: preferredDate,
                      time: preferredTime,
                      notes: notesController.text.trim(),
                    );
                  },
                  child: const Text("Send Request", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // TODO (backend): create this endpoint — it should insert a "Pending"
  // request that shows up in the Admin dashboard so Admin can approve and
  // set a final date/time (however admin wants to give the training).
  // POST https://apps.kofalt.in/api/request_training.php
  // body: { "school_id": <session id>, "topic": topic, "preferred_date": date, "notes": notes }
  Future<void> _submitTrainingRequest({required String topic, DateTime? date, TimeOfDay? time, String? notes}) async {
    try {
      final session = await SessionManager.getSession();
      final schoolId = session?['id'];
      if (schoolId == null) return;

      // Format time as "HH:mm" (24-hr) for the backend; keep null if not picked.
      final formattedTime = time == null
          ? null
          : "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

      final res = await http.post(
        Uri.parse("https://apps.kofalt.in/api/request_training.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "school_id": schoolId,
          "topic": topic,
          "preferred_date": date?.toIso8601String(),
          "preferred_time": formattedTime,
          "notes": notes,
        }),
      );

      final data = res.statusCode == 200 ? jsonDecode(res.body) : null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            data != null && data['status'] == 'success'
                ? "Training request sent to Admin"
                : "Could not send request. Try again.",
          )),
        );
      }
      _fetchSchedule(); // refresh to show the new "Pending" entry
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Network error: $e")),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xff16C74A);
      case 'rejected':
        return Colors.red;
      default:
        return const Color(0xffFFB800); // Pending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(children: [
        _sDetailHeader(title: "Training Schedule", subtitle: "Request training from Admin", colors: const [Color(0xff2563EB), Color(0xff1D4ED8)], onBack: () => Navigator.pop(context)),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xff2563EB)))
              : _schedule.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 54, color: Colors.grey.shade300),
                  const SizedBox(height: 14),
                  Text("No training scheduled yet", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Text("Tap \"Request Training\" below and Admin will schedule it for you", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: _schedule.length,
            itemBuilder: (_, i) {
              final s = _schedule[i];
              final status = (s['status'] ?? 'Pending').toString();
              final color = _statusColor(status);
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)]),
                child: Row(children: [
                  Container(height: 48, width: 48, decoration: BoxDecoration(color: const Color(0xff2563EB).withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.calendar_today_outlined, color: Color(0xff2563EB), size: 24)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['topic'] ?? s['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      s['date'] != null ? "${s['date']}${s['time'] != null ? ' • ${s['time']}' : ''}" : "Date to be confirmed by Admin",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ]),
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRequestTrainingDialog,
        backgroundColor: const Color(0xff2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Request Training", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// 6. CIRCULARS
class CircularsScreen extends StatefulWidget {
  const CircularsScreen({super.key});

  @override
  State<CircularsScreen> createState() => _CircularsScreenState();
}

class _CircularsScreenState extends State<CircularsScreen> {
  bool _isLoading = false;
  List<dynamic> _circulars = [];

  Future<void> _fetchCirculars() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("https://apps.kofalt.in/api/get_circulars.php"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _circulars = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching circulars: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCirculars();
  }

  void _openDetail(Map<String, dynamic> c) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffFF1493), Color(0xffC71585)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.announcement_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        c['title'] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['message'] ?? "",
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 15, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        Text(
                          c['created_at'] ?? "",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF1493),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(children: [
        _sDetailHeader(title: "Circulars", subtitle: "Latest announcements", colors: const [Color(0xffFF1493), Color(0xffC71585)], onBack: () => Navigator.pop(context)),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xffFF1493)))
              : _circulars.isEmpty
              ? const Center(child: Text("No announcements published yet.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: _circulars.length,
            itemBuilder: (_, i) {
              final c = _circulars[i];
              return GestureDetector(
                onTap: () => _openDetail(c),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
                  child: Row(children: [
                    Container(height: 46, width: 46, decoration: BoxDecoration(color: const Color(0xffFF1493).withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.announcement_outlined, color: Color(0xffFF1493), size: 24)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(
                        c['message'] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(c['created_at'] ?? "", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                    ])),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// SHARED HELPERS
Widget _wStat(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
  Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
]);