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
    const _DistributorAgentsTab(),
    const _DistributorAgentOrdersTab(),
    const _DistributorWalletTab(),
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
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: "Agents",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: "Agent Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_outlined),
            activeIcon: Icon(Icons.wallet),
            label: "Wallet",
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

// ============================================================
//  DISTRIBUTOR AGENTS TAB
// ============================================================
class _DistributorAgentsTab extends StatefulWidget {
  const _DistributorAgentsTab();

  @override
  State<_DistributorAgentsTab> createState() => _DistributorAgentsTabState();
}

class _DistributorAgentsTabState extends State<_DistributorAgentsTab> {
  bool _isLoading = false;
  List<dynamic> _agents = [];

  @override
  void initState() {
    super.initState();
    _fetchAgents();
  }

  Future<void> _fetchAgents() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final distId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/distributor/get_agents.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"distributor_id": distId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              _agents = data['agents'] ?? [];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching agents: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openAddAgentForm() {
    if (_agents.length >= 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot add more agents. Max limit is 7 agents.")),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Add New Agent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? "Email is required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Phone (10 digits)", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.length != 10 ? "10-digit phone required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.length < 6 ? "Password min 6 chars" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: "Address / City", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? "Address is required" : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2563EB)),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.pop(ctx);
                      
                      final session = await SessionManager.getSession();
                      if (session == null) return;
                      final distId = session['id'];

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
                      );

                      try {
                        final res = await http.post(
                          Uri.parse("https://apps.kofalt.in/api/distributor/add_agent.php"),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "distributor_id": distId,
                            "name": nameCtrl.text,
                            "email": emailCtrl.text,
                            "phone": phoneCtrl.text,
                            "password": passCtrl.text,
                            "address": addressCtrl.text,
                          }),
                        );
                        if (context.mounted) Navigator.pop(context); // close loader
                        final data = jsonDecode(res.body);
                        if (data['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Agent created successfully!"), backgroundColor: Colors.green),
                          );
                          _fetchAgents();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(data['message'] ?? "Failed to create agent"), backgroundColor: Colors.red),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text("Create Agent", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openEditAgent(dynamic agent) {
    final nameCtrl = TextEditingController(text: agent['name']);
    final phoneCtrl = TextEditingController(text: agent['phone']);
    final emailCtrl = TextEditingController(text: agent['email']);
    final addressCtrl = TextEditingController(text: agent['city'] ?? agent['address'] ?? "");
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Edit Agent Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? "Email is required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Phone (10 digits)", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.length != 10 ? "10-digit phone required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: "Address / City", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? "Address is required" : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2563EB)),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.pop(ctx);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
                      );

                      try {
                        final res = await http.post(
                          Uri.parse("https://apps.kofalt.in/api/distributor/edit_agent.php"),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "agent_id": agent['id'],
                            "name": nameCtrl.text,
                            "email": emailCtrl.text,
                            "phone": phoneCtrl.text,
                            "address": addressCtrl.text,
                          }),
                        );
                        if (context.mounted) Navigator.pop(context); // close loader
                        final data = jsonDecode(res.body);
                        if (data['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Agent updated successfully!"), backgroundColor: Colors.green),
                          );
                          _fetchAgents();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(data['message'] ?? "Update failed"), backgroundColor: Colors.red),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text("Save Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openResetPassword(dynamic agent) {
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Reset Password for ${agent['name']}"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
            validator: (v) => v == null || v.length < 6 ? "Password must be at least 6 characters" : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
              );

              try {
                final res = await http.post(
                  Uri.parse("https://apps.kofalt.in/api/distributor/reset_password.php"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "agent_id": agent['id'],
                    "password": passCtrl.text,
                  }),
                );
                if (context.mounted) Navigator.pop(context);
                final data = jsonDecode(res.body);
                if (data['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password reset successfully!"), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(data['message'] ?? "Reset failed"), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleAgentStatus(dynamic agent) async {
    final nextStatus = agent['status'] == 'Active' ? 'Suspended' : 'Active';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
    );

    try {
      final res = await http.post(
        Uri.parse("https://apps.kofalt.in/api/distributor/toggle_agent.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "agent_id": agent['id'],
          "status": nextStatus,
        }),
      );
      if (context.mounted) Navigator.pop(context);
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Agent marked as $nextStatus"), backgroundColor: Colors.green),
        );
        _fetchAgents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Update failed"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _viewAgentSales(dynamic agent) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
    );

    try {
      final session = await SessionManager.getSession();
      final distId = session?['id'] ?? 0;
      final res = await http.post(
        Uri.parse("https://apps.kofalt.in/api/distributor/get_agent_sales.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "agent_id": agent['id'],
          "distributor_id": distId,
        }),
      );
      if (context.mounted) Navigator.pop(context);
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        final orders = data['orders'] as List? ?? [];
        final totalSales = (data['total_sales'] ?? 0.0).toDouble();
        final totalKits = (data['total_kits'] ?? 0).toInt();
        final totalCommission = (data['total_commission'] ?? 0.0).toDouble();
        final agentGeneratedComm = (data['agent_generated_commission'] ?? 0.0).toDouble();

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AgentPerformanceScreen(
                agent: agent,
                orders: orders,
                totalSales: totalSales,
                totalKits: totalKits,
                totalCommission: totalCommission,
                agentGeneratedComm: agentGeneratedComm,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("My Downline Agents", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xff2563EB),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAgentForm,
        backgroundColor: const Color(0xff2563EB),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("Add Agent", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAgents,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xff2563EB)))
            : _agents.isEmpty
                ? const Center(child: Text("No agents recruited yet.", style: TextStyle(color: Colors.grey)))
                : Column(
                    children: [
                      // Linear Chain Hierarchy Tracker
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xffEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xffDBEAFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("MLM Level Chain Overview:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1E40AF))),
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Chip(label: Text("Distributor L1"), backgroundColor: Colors.white),
                                for (var i = 0; i < _agents.length; i++) ...[
                                  const Icon(Icons.arrow_right_alt, color: Color(0xff2563EB)),
                                  Chip(
                                    label: Text("${_agents[i]['name'].toString().split(' ')[0]} L${i + 2}"),
                                    backgroundColor: Colors.white,
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _agents.length,
                          itemBuilder: (context, index) {
                            final agent = _agents[index];
                            final isSuspended = agent['status'] == 'Suspended';
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSuspended ? Colors.red.shade50 : const Color(0xffEFF6FF),
                                  child: Icon(Icons.person, color: isSuspended ? Colors.red : const Color(0xff2563EB)),
                                ),
                                title: Text(agent['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("Level ${agent['level']} • Phone: ${agent['phone']}\nStatus: ${agent['status']}"),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (val) {
                                    if (val == 'edit') _openEditAgent(agent);
                                    if (val == 'reset') _openResetPassword(agent);
                                    if (val == 'toggle') _toggleAgentStatus(agent);
                                    if (val == 'sales') _viewAgentSales(agent);
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'sales', child: Text("View Performance")),
                                    const PopupMenuItem(value: 'edit', child: Text("Edit Details")),
                                    const PopupMenuItem(value: 'reset', child: Text("Reset Password")),
                                    PopupMenuItem(
                                      value: 'toggle',
                                      child: Text(isSuspended ? "Activate Agent" : "Suspend Agent", style: TextStyle(color: isSuspended ? Colors.green : Colors.red)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// ============================================================
//  DISTRIBUTOR AGENT ORDERS TAB
// ============================================================
class _DistributorAgentOrdersTab extends StatefulWidget {
  const _DistributorAgentOrdersTab();

  @override
  State<_DistributorAgentOrdersTab> createState() => _DistributorAgentOrdersTabState();
}

class _DistributorAgentOrdersTabState extends State<_DistributorAgentOrdersTab> {
  bool _isLoading = false;
  List<dynamic> _orders = [];
  String _selectedStatus = "All";
  final List<String> _statuses = ["All", "Pending", "Paid", "Shipped", "Delivered", "Cancelled"];

  @override
  void initState() {
    super.initState();
    _fetchAgentOrders();
  }

  Future<void> _fetchAgentOrders() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final distId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/distributor/get_agent_sales.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"distributor_id": distId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              _orders = data['orders'] ?? [];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching agent orders: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filtered {
    if (_selectedStatus == "All") return _orders;
    return _orders.where((o) {
      if (_selectedStatus == "Paid") return o['payment_status'] == "Paid";
      if (_selectedStatus == "Pending") return o['payment_status'] == "Pending";
      return o['delivery_status'] == _selectedStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("Agent Kit Orders", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xff2563EB),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Horizontal status filter row
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statuses.length,
              itemBuilder: (context, index) {
                final status = _statuses[index];
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: const Color(0xff2563EB),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedStatus = status);
                    },
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchAgentOrders,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xff2563EB)))
                  : _filtered.isEmpty
                      ? const Center(child: Text("No MLM orders found matching filter.", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final o = _filtered[index];
                            final isPaid = o['payment_status'] == 'Paid';
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Order #${o['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            isPaid ? "Paid" : "Pending",
                                            style: TextStyle(
                                              color: isPaid ? Colors.green : Colors.orange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Text("Agent: ${o['buyer_name']}", style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff2563EB))),
                                    const SizedBox(height: 4),
                                    Text("School: ${o['school_name']}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 2),
                                    Text("Kit: ${o['kit_level']} x ${o['quantity']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          o['created_at'] != null ? o['created_at'].toString().split(' ')[0] : "",
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                        ),
                                        Text(
                                          "₹${o['total_amount']}",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  DISTRIBUTOR WALLET TAB
// ============================================================
class _DistributorWalletTab extends StatefulWidget {
  const _DistributorWalletTab();

  @override
  State<_DistributorWalletTab> createState() => _DistributorWalletTabState();
}

class _DistributorWalletTabState extends State<_DistributorWalletTab> {
  bool _isLoading = false;
  double _balance = 0.0;
  double _totalEarned = 0.0;
  List<dynamic> _txs = [];

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final distId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_wallet_details.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": distId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              _balance = (data['balance'] ?? 0.0).toDouble();
              _totalEarned = (data['total_earned'] ?? 0.0).toDouble();
              _txs = data['transactions'] ?? [];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching wallet data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("MLM Wallet & Earning Logs", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xff2563EB),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWalletData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xff2563EB)))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wallet details card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff0F172A), Color(0xff1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet, color: Colors.blue, size: 24),
                                SizedBox(width: 10),
                                Text("Wallet Balance", style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "₹${_balance.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const Divider(color: Colors.white10, height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total Commissions:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text("₹${_totalEarned.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text("Transaction History Log", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
                      const SizedBox(height: 10),

                      _txs.isEmpty
                          ? Container(
                              height: 150,
                              alignment: Alignment.center,
                              child: const Text("No transactions recorded yet.", style: TextStyle(color: Colors.grey)),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _txs.length,
                              itemBuilder: (context, index) {
                                final tx = _txs[index];
                                final isCredit = tx['type'] == 'Credit';

                                return Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0.5,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                      child: Icon(
                                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                        color: isCredit ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    title: Text(tx['description'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    subtitle: Text(
                                      tx['created_at'] != null ? tx['created_at'].toString().split(' ')[0] : "",
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    trailing: Text(
                                      "${isCredit ? '+' : '-'}₹${double.tryParse(tx['amount'].toString())?.toStringAsFixed(2) ?? tx['amount']}",
                                      style: TextStyle(
                                        color: isCredit ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ============================================================
//  AGENT PERFORMANCE MONITOR SCREEN
// ============================================================
class AgentPerformanceScreen extends StatelessWidget {
  final dynamic agent;
  final List<dynamic> orders;
  final double totalSales;
  final int totalKits;
  final double totalCommission;
  final double agentGeneratedComm;

  const AgentPerformanceScreen({
    super.key,
    required this.agent,
    required this.orders,
    required this.totalSales,
    required this.totalKits,
    required this.totalCommission,
    required this.agentGeneratedComm,
  });

  @override
  Widget build(BuildContext context) {
    double maxAmt = 100.0;
    for (var o in orders) {
      final amt = double.tryParse(o['total_amount'].toString()) ?? 0.0;
      if (amt > maxAmt) maxAmt = amt;
    }

    return Scaffold(
      backgroundColor: const Color(0xffF1F5F9),
      appBar: AppBar(
        title: Text("${agent['name']}'s Performance", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xff2563EB),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard("Kits Sold", "$totalKits Kits", Icons.shopping_bag_outlined, Colors.orange),
                _buildStatCard("Total Sales", "₹${totalSales.toStringAsFixed(0)}", Icons.trending_up, Colors.green),
                _buildStatCard("Agent Payouts", "₹${totalCommission.toStringAsFixed(0)}", Icons.wallet, Colors.purple),
                _buildStatCard("Earned by Me", "₹${agentGeneratedComm.toStringAsFixed(0)}", Icons.payments_outlined, Colors.blue),
              ],
            ),
            const SizedBox(height: 25),

            // Performance Graph Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Sales & Purchase Volume Trend", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
                  const SizedBox(height: 20),
                  orders.isEmpty
                      ? const SizedBox(
                          height: 120,
                          child: Center(child: Text("No sales data available for graphing", style: TextStyle(color: Colors.grey, fontSize: 12))),
                        )
                      : SizedBox(
                          height: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: orders.reversed.take(6).map((o) {
                              final amt = double.tryParse(o['total_amount'].toString()) ?? 0.0;
                              final ratio = amt / maxAmt;
                              final barHeight = (ratio * 100).clamp(10.0, 100.0);
                              final dateStr = o['created_at'] != null && o['created_at'].toString().length >= 10
                                  ? o['created_at'].toString().substring(5, 10)
                                  : "Order";
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Tooltip(
                                    message: "₹$amt (${o['quantity']} Kits)",
                                    triggerMode: TooltipTriggerMode.tap,
                                    child: Container(
                                      width: 28,
                                      height: barHeight,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xff2563EB), Color(0xff60A5FA)],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(dateStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w500)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Orders Placed List
            const Text("Agent Order History", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
            const SizedBox(height: 10),
            orders.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text("No kit orders placed yet.", style: TextStyle(color: Colors.grey))),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final o = orders[index];
                      final isPaid = o['payment_status'] == 'Paid';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0.5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Order #${o['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isPaid ? "Paid" : "Pending",
                                      style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Text("School: ${o['school_name'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text("Kit Level: ${o['kit_level'] ?? 'N/A'} x ${o['quantity']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text("Earned Commission: ", style: TextStyle(fontSize: 12, color: Color(0xff475569))),
                                  Text(
                                    "₹${double.tryParse(o['commission_earned']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(o['created_at']?.toString().substring(0, 10) ?? "", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                                  Text("₹${o['total_amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6)],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
        ],
      ),
    );
  }
}