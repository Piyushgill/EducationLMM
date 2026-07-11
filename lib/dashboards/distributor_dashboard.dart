import 'package:flutter/material.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/login_screen.dart';
import 'package:thenew/dashboards/super_admin_dashboard.dart';
import 'package:thenew/Screens/EducationHomeScreen.dart';
import 'package:thenew/Screens/ourprogramsmain.dart';
import 'package:thenew/Screens/profilescreen.dart';
import 'package:thenew/dashboardCardDetails/Expected_Commission_Screen.dart';
import 'package:thenew/dashboardCardDetails/active_schools_screen.dart';
import 'package:thenew/dashboardCardDetails/commission_screen.dart';
import 'package:thenew/dashboardCardDetails/network_size_screen.dart';
import 'package:thenew/dashboardCardDetails/revenue_screen.dart';
import 'package:thenew/dashboardCardDetails/total_students_screen.dart';
import 'package:thenew/dashboardCardDetails/visitors_screen.dart';

// ── Role constant used to filter admin-managed content (Videos/Testimonials/FAQs) ──
const String _kMyRole = "Distributor";

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
// ─────────────────────────────────────────────────────────────
//  ROOT SCAFFOLD
// ─────────────────────────────────────────────────────────────

class DistributorDashboard extends StatefulWidget {
  const DistributorDashboard({super.key});

  @override
  State<DistributorDashboard> createState() => _DistributorDashboardState();
}

class _DistributorDashboardState extends State<DistributorDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
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
        selectedItemColor:  Color(0xff2563EB),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedLabelStyle:  TextStyle(fontWeight: FontWeight.w600),
        items:  [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profile"),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HOME TAB  (StatefulWidget so it can hold Future state)
// ─────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _isLoadingStats = false;
  int _networkSize = 0;
  int _activeSchools = 0;
  int _totalStudents = 0;
  double _totalCommission = 0.0;
  String _userName = "Distributor";
  String _userEmail = "";

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
          _userName = session['name'] ?? "Distributor";
          _userEmail = session['email'] ?? "";
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

  // ----------------------------------------------------------
  //  Fetch Videos / Testimonials / FAQs added by Super Admin,
  //  keeping only the ones targeted at "Distributor" or "All".
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
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [Color(0xff2563EB), Color(0xffA020F0)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (ctx) => GestureDetector(
                          onTap: () => Scaffold.of(ctx).openDrawer(),
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
                      ),

                      const SizedBox(width: 6),

                      Image.asset(
                        'assets/image/kofalt-global-title-logo.png',
                        height: 38,
                        fit: BoxFit.contain,
                      ),

                      const Spacer(),

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
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_userName,
                        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Distributor",
                        style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 16)),
                  ),
                ],
              ),
            ),

            // ── SCROLLABLE BODY ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Dashboard Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: .95,
                      children: [
                        DashboardCard(title: "Network Size",
                            value: "$_networkSize",
                            icon: Icons.groups_2_outlined,
                            iconColor: const Color(0xff2563EB),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const NetworkSizeScreen())
                            )
                        ),
                        DashboardCard(title: "Active Schools",
                            value: "$_activeSchools",
                            icon: Icons.school_outlined,
                            iconColor: const Color(0xff16C74A),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ActiveSchoolsScreen())
                            )
                        ),
                        DashboardCard(title: "Total Students",
                            value: "$_totalStudents",
                            icon: Icons.groups_outlined,
                            iconColor: const Color(0xffA020F0),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const TotalStudentsScreen())
                            )
                        ),
                        DashboardCard(title: "Revenue",
                            value: "₹${(_totalCommission * 1.5).toStringAsFixed(0)}",
                            icon: Icons.currency_rupee_rounded,
                            iconColor: const Color(0xffFF6B00),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const RevenueScreen())
                            )
                        ),
                        DashboardCard(title: "Commission",
                            value: "₹${_totalCommission.toStringAsFixed(0)}",
                            icon: Icons.trending_up_rounded,
                            iconColor: const Color(0xffFF1493),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const CommissionScreen())
                            )
                        ),
                        DashboardCard(title: "Expected Commission",
                            value: "₹${(_totalCommission * 0.25).toStringAsFixed(0)}",
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: const Color(0xff16C74A),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ExpectedCommissionScreen())
                            )
                        ),
                        DashboardCard(title: "Visitors",
                            value: "${_networkSize * 12 + 15}",
                            icon: Icons.remove_red_eye_outlined,
                            iconColor: const Color(0xff5B5BF6),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const VisitorsScreen())
                            )
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── TRAINING VIDEOS (live, from Admin panel) ──
                    _sectionTitle("Training Videos"),
                    const SizedBox(height: 12),
                    _isLoadingVideos
                        ? _VideoShimmerRow()
                        : _adminVideos.isEmpty
                        ? _SectionEmpty(label: "No training videos yet")
                        : SizedBox(
                      height: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _adminVideos.length,
                        itemBuilder: (_, i) {
                          final v = _adminVideos[i];
                          return _videoCard(
                            v['title'] ?? "",
                            (v['description'] ?? "").toString().isNotEmpty ? v['description'] : "Tap to watch",
                            const Color(0xff2563EB),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── TESTIMONIALS (live, from Admin panel) ──
                    _sectionTitle("Testimonials"),
                    const SizedBox(height: 12),
                    _isLoadingTestimonials
                        ? _TestimonialShimmer()
                        : _adminTestimonials.isEmpty
                        ? _SectionEmpty(label: "No testimonials yet")
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

                    // ── FAQ (live, from Admin panel) ──
                    _sectionTitle("FAQ"),
                    const SizedBox(height: 12),
                    if (_isLoadingFaqs)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
                      )
                    else if (_adminFaqs.isEmpty)
                      _SectionEmpty(label: "No FAQs yet")
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

  // ── HELPER WIDGETS ─────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E)),
  );

  Widget _videoCard(String title, String duration, Color color) => Container(
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
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(duration, style: TextStyle(color: Colors.grey.shade600, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    ),
  );

  Widget _testimonialCard(String name, String text, int stars) => Container(
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
              child: Text(name.isNotEmpty ? name[0] : "?",
                  style: const TextStyle(color: Color(0xff2563EB), fontWeight: FontWeight.bold)),
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

  Widget _faqItem(String q, String a) => Container(
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [

            //================ HEADER =================//
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff2563EB),
                    Color(0xffA020F0),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 42,
                      color: Color(0xff2563EB),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _userEmail.isEmpty
                        ? "Distributor Account"
                        : _userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Distributor",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //================ STATS =================//

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [

                  Expanded(
                    child: _drawerStat(
                      "Network",
                      "$_networkSize",
                      Icons.groups,
                      Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _drawerStat(
                      "Schools",
                      "$_activeSchools",
                      Icons.school,
                      Colors.green,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 18),

            //================ MENU =================//

            _drawerTile(
              Icons.dashboard_outlined,
              "Dashboard",
                  () {
                Navigator.pop(context);
              },
            ),

            _drawerTile(
              Icons.menu_book_outlined,
              "Programs",
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>  ourprogramsmainScreen(),
                  ),
                );
              },
            ),

            _drawerTile(
              Icons.cast_for_education,
              "Education",
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EducationLLMHomeScreen(),
                  ),
                );
              },
            ),

            _drawerTile(
              Icons.settings_outlined,
              "Settings",
                  () {},
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () =>
                      _confirmAndLogout(context),
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
Widget _drawerTile(
    IconData icon,
    String title,
    VoidCallback onTap,
    ) {
  return Padding(
    padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4),
    child: ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor:
        const Color(0xff2563EB).withOpacity(.1),
        child: Icon(
          icon,
          color: const Color(0xff2563EB),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
      onTap: onTap,
    ),
  );
}

Widget _drawerStat(
    String title,
    String value,
    IconData icon,
    Color color,
    ) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 8,
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  SHIMMER SKELETON WIDGETS
// ─────────────────────────────────────────────────────────────

/// Animated shimmer base
class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-1.0 + 2 * _anim.value, 0),
          end:   Alignment( 1.0 + 2 * _anim.value, 0),
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}

Widget _shimmerBox({double w = double.infinity, double h = 14, double r = 8}) => Container(
  width: w, height: h,
  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(r)),
);

/// Shimmer row for Training Videos
class _VideoShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, __) => _Shimmer(
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(w: 34, h: 34, r: 17),
                const Spacer(),
                _shimmerBox(h: 12),
                const SizedBox(height: 6),
                _shimmerBox(w: 60, h: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer cards for Testimonials
class _TestimonialShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
            (_) => _Shimmer(
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _shimmerBox(w: 36, h: 36, r: 18),
                    const SizedBox(width: 10),
                    _shimmerBox(w: 110, h: 12),
                  ],
                ),
                const SizedBox(height: 12),
                _shimmerBox(h: 11),
                const SizedBox(height: 6),
                _shimmerBox(w: 200, h: 11),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EMPTY & ERROR STATES
// ─────────────────────────────────────────────────────────────

class _SectionEmpty extends StatelessWidget {
  final String label;
  const _SectionEmpty({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 36),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DASHBOARD CARD (unchanged public API)
// ─────────────────────────────────────────────────────────────

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
            Spacer(),
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}