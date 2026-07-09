import 'package:flutter/material.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/login_screen.dart';
import 'package:thenew/dashboards/super_admin_dashboard.dart';
import 'package:thenew/Screens/EducationHomeScreen.dart';

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
    _SchoolHomeTab(onMenuTap: _openDrawer),
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
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff0EA5E9),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),  activeIcon: Icon(Icons.home),    label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  //  DRAWER
  // ----------------------------------------------------------
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DRAWER HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff0EA5E9), Color(0xff0284C7)]),
              ),
              child: Row(children: [
                // Container(
                //   height: 56, width: 56,
                //   decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(18)),
                //   child: const Icon(Icons.school_rounded, color: Colors.white, size: 30),
                // ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      _schoolName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(_schoolEmail.isNotEmpty ? _schoolEmail : "School Account", style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 12)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 8),

            _drawerItem(icon: Icons.home_outlined,         label: "Home",     selected: _currentIndex == 0, onTap: () => _goToTab(0)),
            _drawerItem(icon: Icons.groups_outlined,       label: "Students", onTap: () => _openScreen(const SchoolStudentDataScreen())),
            _drawerItem(icon: Icons.shopping_bag_outlined, label: "Orders",   onTap: () => _openScreen(const SchoolKitOrderScreen())),
            _drawerItem(icon: Icons.person_outline,        label: "Profile",  selected: _currentIndex == 1, onTap: () => _goToTab(1)),

            const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Divider()),

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
                Navigator.pop(context); // drawer close
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
      color: selected ? const Color(0xff0EA5E9).withOpacity(.08) : Colors.transparent,
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
  double _totalCommission = 0.0;
  String _userName = "School";

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
    final String pendingFee = "₹${(_totalCommission * 1.5).toStringAsFixed(0)}";

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
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff0EA5E9), Color(0xff0284C7)]),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                GestureDetector(
                  onTap: widget.onMenuTap,
                  child: Container(height: 48, width: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.menu_rounded, color: Colors.white, size: 28)),
                ),
                Stack(children: [
                  Container(height: 48, width: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28)),
                  Positioned(right: 10, top: 10, child: Container(height: 10, width: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
                ]),
              ]),
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))),
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerLeft, child: Text("School Account", style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 16))),
              const SizedBox(height: 16),
              Row(children: [
                _hStat("Programs",    "3"),
                _vDivider(),
                _hStat("Students",   "$_totalStudents"),
                _vDivider(),
                _hStat("Pending Fee", pendingFee),
                _vDivider(),
                _hStat("Circulars",  "2 New"),
              ]),
            ]),
          ),

          // SCROLLABLE BODY
          Expanded(
            child: SingleChildScrollView(
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
                    SDashboardCard(title: "Programs Running", value: "3",     icon: Icons.menu_book_outlined,      iconColor: const Color(0xff0EA5E9), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgramsRunningScreen()))),
                    SDashboardCard(title: "Student Data",     value: "$_totalStudents",   icon: Icons.groups_outlined,         iconColor: const Color(0xffA020F0), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchoolStudentDataScreen()))),
                    SDashboardCard(title: "Pending Payments", value: pendingFee,  icon: Icons.payments_outlined,       iconColor: const Color(0xffFF6B00), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingPaymentsScreen()))),
                    SDashboardCard(title: "Kit Ordering",     value: "Order", icon: Icons.inventory_2_outlined,    iconColor: const Color(0xff16C74A), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchoolKitOrderScreen()))),
                    SDashboardCard(title: "Training Schedule",value: "3",     icon: Icons.calendar_today_outlined, iconColor: const Color(0xff2563EB), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingScheduleScreen()))),
                    SDashboardCard(title: "Circulars",        value: "2 New", icon: Icons.announcement_outlined,   iconColor: const Color(0xffFF1493), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CircularsScreen()))),
                  ],
                ),

                const SizedBox(height: 24),

                // TRAINING VIDEOS
                _sectionTitle("Training Videos"),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    _videoCard("Abacus Basics",     "15 min", const Color(0xff0EA5E9)),
                    _videoCard("Vedic Maths Tips",  "20 min", const Color(0xffA020F0)),
                    _videoCard("Phonics Workshop",  "18 min", const Color(0xff16C74A)),
                    _videoCard("English Speaking",  "22 min", const Color(0xffFF6B00)),
                  ]),
                ),

                const SizedBox(height: 24),

                // GALLERY
                _sectionTitle("Gallery"),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView(scrollDirection: Axis.horizontal, children: List.generate(6, (i) => Container(
                    width: 90, height: 90, margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(color: const Color(0xff0EA5E9).withOpacity(.1 + i * 0.04), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.image_outlined, color: const Color(0xff0EA5E9).withOpacity(.6), size: 30),
                  ))),
                ),

                const SizedBox(height: 24),

                // TESTIMONIALS
                _sectionTitle("Testimonials"),
                const SizedBox(height: 12),
                _testimonialCard("Mrs. Sharma",   "Students' performance has improved tremendously with these programs.", 5),
                const SizedBox(height: 10),
                _testimonialCard("Mr. Kapoor",    "The kit ordering and tracking system is very smooth.", 4),

                const SizedBox(height: 24),

                // FAQ
                _sectionTitle("FAQ"),
                const SizedBox(height: 12),
                _faqItem("How to register new student?", "Use the Student Data section and tap 'Add Student'. Fill in required details and select program."),
                _faqItem("How to track payments?",       "Go to Pending Payments. All dues are listed with due dates and status."),
                _faqItem("How to order level kits?",     "Go to Kit Ordering, select Main or Level (2-8) kit and place your order."),

                const SizedBox(height: 20),
              ]),
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

  Widget _videoCard(String title, String duration, Color color) => Container(
    width: 150, margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
    child: Row(children: [
      Icon(Icons.play_circle_filled, color: color, size: 28),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 2),
        Text(duration, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      ])),
    ]),
  );

  Widget _testimonialCard(String name, String text, int stars) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(backgroundColor: const Color(0xff0EA5E9).withOpacity(.1), radius: 18, child: Text(name[0], style: const TextStyle(color: Color(0xff0EA5E9), fontWeight: FontWeight.bold))),
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

class _SchoolProfileScreen extends StatefulWidget {
  const _SchoolProfileScreen();

  @override
  State<_SchoolProfileScreen> createState() => _SchoolProfileScreenState();
}

class _SchoolProfileScreenState extends State<_SchoolProfileScreen> {
  String _schoolName = "School Name";
  String _schoolEmail = "";
  String _schoolPhone = "";
  int _studentsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final session = await SessionManager.getSession();
    if (session != null) {
      setState(() {
        _schoolName = session['name'] ?? "School Name";
        _schoolEmail = session['email'] ?? "";
        _schoolPhone = session['phone'] ?? "";
      });
      final userId = session['id'];
      try {
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_user_network.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": userId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              _studentsCount = data['total_students'] ?? 0;
            });
          }
        }
      } catch (e) {
        debugPrint("Error loading profile stats: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff6366F1), Color(0xff4338CA)]),
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Container(height: 40, width: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20)),
                ]),
                const SizedBox(height: 24),
                Container(
                  height: 84, width: 84,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.18), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.4), width: 2)),
                  child: Center(
                    child: Text(
                      _schoolName.isNotEmpty ? _schoolName[0].toUpperCase() : "S",
                      style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(_schoolName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("School Admin", style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 13)),
              ]),
            ),

            // FLOATING STAT CARD
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0, 4))]),
                  child: Row(children: [
                    _pStat("Programs", "3"),
                    _pVDivider(),
                    _pStat("Students", "$_studentsCount"),
                    _pVDivider(),
                    _pStat("Since", "2026"),
                  ]),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _pSectionTitle("Contact Information"),
                const SizedBox(height: 12),
                _pInfoTile(Icons.call_outlined, "Phone", _schoolPhone.isNotEmpty ? _schoolPhone : "+91 98765 43210"),
                const SizedBox(height: 10),
                _pInfoTile(Icons.email_outlined, "Email", _schoolEmail.isNotEmpty ? _schoolEmail : "school@sunrise.edu"),
                const SizedBox(height: 10),
                _pInfoTile(Icons.location_on_outlined, "Address", "India"),

                const SizedBox(height: 24),
                _pSectionTitle("Account"),
                const SizedBox(height: 12),
                _pMenuTile(Icons.lock_outline_rounded, "Change Password", const Color(0xff0EA5E9)),
                _pMenuTile(Icons.account_balance_outlined, "Bank Details", const Color(0xffA020F0)),
                _pMenuTile(Icons.description_outlined, "Documents", const Color(0xffFF6B00)),

                const SizedBox(height: 24),
                _pSectionTitle("Preferences"),
                const SizedBox(height: 12),
                _pMenuTile(Icons.notifications_none_rounded, "Notification Settings", const Color(0xff2563EB)),
                _pMenuTile(Icons.help_outline_rounded, "Help & Support", const Color(0xff16C74A)),
                _pMenuTile(Icons.info_outline_rounded, "About App", const Color(0xff64748B)),

                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => _confirmAndLogout(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.withOpacity(.2))),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 14)),
                    ]),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _pStat(String label, String value) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff1E1E1E))),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
  ]));
  Widget _pVDivider() => Container(height: 32, width: 1, color: Colors.grey.shade200);
  Widget _pSectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E)));

  Widget _pInfoTile(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)]),
    child: Row(children: [
      Container(height: 38, width: 38, decoration: BoxDecoration(color: const Color(0xff6366F1).withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xff6366F1), size: 19)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    ]),
  );

  Widget _pMenuTile(IconData icon, String label, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)]),
    child: ListTile(
      leading: Container(height: 38, width: 38, decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 19)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
      onTap: () {},
    ),
  );
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

// 1. PROGRAMS RUNNING
class ProgramsRunningScreen extends StatelessWidget {
  const ProgramsRunningScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final programs = [
      {'name': 'Abacus',      'students': 50, 'levels': '8', 'icon': Icons.calculate_rounded,  'color': const Color(0xff0EA5E9)},
      {'name': 'Vedic Maths', 'students': 40, 'levels': '8', 'icon': Icons.plus_one,           'color': const Color(0xffA020F0)},
      {'name': 'Phonics',     'students': 30, 'levels': '5', 'icon': Icons.mic_none_rounded,   'color': const Color(0xff16C74A)},
    ];
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(children: [
        _sDetailHeader(title: "Programs Running", subtitle: "${programs.length} active programs", colors: const [Color(0xff0EA5E9), Color(0xff0284C7)], onBack: () => Navigator.pop(context)),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: programs.length,
          itemBuilder: (_, i) {
            final p = programs[i];
            final color = p['color'] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)]),
              child: Row(children: [
                Container(height: 52, width: 52, decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(16)), child: Icon(p['icon'] as IconData, color: color, size: 28)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("${p['levels']} Levels • ${p['students']} Students", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xff16C74A).withOpacity(.1), borderRadius: BorderRadius.circular(20)), child: const Text("Active", style: TextStyle(color: Color(0xff16C74A), fontSize: 12, fontWeight: FontWeight.w600))),
              ]),
            );
          },
        )),
      ]),
    );
  }
}

// 2. STUDENT DATA
class SchoolStudentDataScreen extends StatelessWidget {
  const SchoolStudentDataScreen({super.key});
  final List<Map<String, dynamic>> students = const [
    {'name': 'Anjali Mehta',  'program': 'Abacus',      'level': 'Level 3', 'status': 'Active'},
    {'name': 'Rahul Kumar',   'program': 'Phonics',     'level': 'Level 1', 'status': 'Active'},
    {'name': 'Pooja Sharma',  'program': 'Vedic Maths', 'level': 'Level 5', 'status': 'Active'},
    {'name': 'Sanjay Verma',  'program': 'Abacus',      'level': 'Level 2', 'status': 'Inactive'},
    {'name': 'Meena Gupta',   'program': 'English',     'level': 'Level 3', 'status': 'Active'},
    {'name': 'Aryan Singh',   'program': 'Abacus',      'level': 'Level 6', 'status': 'Active'},
    {'name': 'Divya Patel',   'program': 'Phonics',     'level': 'Level 2', 'status': 'Active'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(children: [
        _sDetailHeader(
          title: "Student Data", subtitle: "Total: ${students.length} Students",
          colors: const [Color(0xffA020F0), Color(0xff7B10BF)],
          onBack: () => Navigator.pop(context),
          extra: [Row(children: [
            _wStat("Total",    "${students.length}"),
            const SizedBox(width: 16),
            _wStat("Active",   "${students.where((s) => s['status'] == 'Active').length}"),
            const SizedBox(width: 16),
            _wStat("Inactive", "${students.where((s) => s['status'] == 'Inactive').length}"),
          ])],
        ),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: students.length,
          itemBuilder: (_, i) {
            final s = students[i];
            final isActive = s['status'] == 'Active';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
              child: Row(children: [
                CircleAvatar(radius: 22, backgroundColor: const Color(0xffA020F0).withOpacity(.1), child: Text(s['name'][0], style: const TextStyle(color: Color(0xffA020F0), fontWeight: FontWeight.bold, fontSize: 16))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text("${s['program']} • ${s['level']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: (isActive ? const Color(0xff16C74A) : Colors.red).withOpacity(.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(s['status'], style: TextStyle(color: isActive ? const Color(0xff16C74A) : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ]),
            );
          },
        )),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xffA020F0),
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text("Add Student", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// 3. PENDING PAYMENTS
class PendingPaymentsScreen extends StatelessWidget {
  const PendingPaymentsScreen({super.key});
  final List<Map<String, dynamic>> payments = const [
    {'student': 'Anjali Mehta', 'amount': '₹2,500', 'due': '15 Feb 2025', 'status': 'Overdue'},
    {'student': 'Rahul Kumar',  'amount': '₹2,000', 'due': '20 Feb 2025', 'status': 'Due Soon'},
    {'student': 'Pooja Sharma', 'amount': '₹3,000', 'due': '25 Feb 2025', 'status': 'Pending'},
    {'student': 'Meena Gupta',  'amount': '₹1,500', 'due': '28 Feb 2025', 'status': 'Pending'},
  ];
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
        _sDetailHeader(title: "Pending Payments", subtitle: "${payments.length} pending dues", colors: const [Color(0xffFF6B00), Color(0xffFF9500)], onBack: () => Navigator.pop(context)),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: payments.length,
          itemBuilder: (_, i) {
            final p = payments[i];
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
        )),
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

  int get _totalItems => _mainKitQty + _levelQty.values.fold(0, (a, b) => a + b);

  void _changeMainQty(int delta) => setState(() => _mainKitQty = (_mainKitQty + delta).clamp(0, 99));
  void _changeLevelQty(int level, int delta) => setState(() => _levelQty[level] = (_levelQty[level]! + delta).clamp(0, 99));

  void _openOrderSummary() {
    final items = <Map<String, dynamic>>[];
    if (_mainKitQty > 0) items.add({'name': 'New Kit (Main)', 'qty': _mainKitQty});
    for (final l in _levelQty.keys) {
      if (_levelQty[l]! > 0) items.add({'name': 'Level $l Kit', 'qty': _levelQty[l]});
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

      final responses = await Future.wait(orders);
      
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
        _sDetailHeader(title: "Kit Ordering", subtitle: "Main kit + Level 2-8 kits", colors: const [Color(0xff16C74A), Color(0xff059669)], onBack: () => Navigator.pop(context)),
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
                SizedBox(width: 28, child: Text("$qty", textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))),
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

// 5. TRAINING SCHEDULE
class TrainingScheduleScreen extends StatelessWidget {
  const TrainingScheduleScreen({super.key});
  final List<Map<String, String>> schedule = const [
    {'title': 'Abacus Training',     'days': 'Monday & Wednesday', 'time': '10:00 AM'},
    {'title': 'Vedic Maths',         'days': 'Tuesday & Thursday', 'time': '11:30 AM'},
    {'title': 'Phonics Workshop',    'days': 'Friday',              'time': '9:00 AM'},
    {'title': 'English Speaking',    'days': 'Saturday',            'time': '10:30 AM'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(children: [
        _sDetailHeader(title: "Training Schedule", subtitle: "Day & time schedule", colors: const [Color(0xff2563EB), Color(0xff1D4ED8)], onBack: () => Navigator.pop(context)),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: schedule.length,
          itemBuilder: (_, i) {
            final s = schedule[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)]),
              child: Row(children: [
                Container(height: 48, width: 48, decoration: BoxDecoration(color: const Color(0xff2563EB).withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.calendar_today_outlined, color: Color(0xff2563EB), size: 24)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(s['days']!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xff2563EB).withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: Text(s['time']!, style: const TextStyle(color: Color(0xff2563EB), fontWeight: FontWeight.w600, fontSize: 13))),
              ]),
            );
          },
        )),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xff2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Schedule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
                          child: Row(children: [
                            Container(height: 46, width: 46, decoration: BoxDecoration(color: const Color(0xffFF1493).withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.announcement_outlined, color: Color(0xffFF1493), size: 24)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(c['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text(c['message'] ?? "", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(c['created_at'] ?? "", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                            ])),
                          ]),
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