import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/session_manager.dart';
import 'package:thenew/services/login_screen.dart';
import 'package:thenew/dashboards/distributor_dashboard.dart';
import 'package:thenew/dashboards/franchisedashboard.dart';
import 'package:thenew/dashboards/schoolDashboard.dart';
import 'package:thenew/dashboards/studentdashboard.dart';
import 'package:thenew/dashboards/agent_dashboard.dart';
import 'package:thenew/widgets/dynamic_video_player.dart';
import 'package:thenew/widgets/view_all_content_screens.dart';


class _AdminTheme {
  static const Color primary = Color(0xff4F46E5);
  static const Color primaryDark = Color(0xff4338CA);
  static const Color primaryLight = Color(0xffEEF2FF);
}

Widget adminEmptyState(IconData icon, String message, {String? subMessage}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(color: _AdminTheme.primaryLight, shape: BoxShape.circle),
            child: Icon(icon, size: 34, color: _AdminTheme.primary.withOpacity(0.7)),
          ),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff64748B))),
          if (subMessage != null) ...[
            const SizedBox(height: 4),
            Text(subMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
          ],
        ],
      ),
    ),
  );
}

Widget adminSectionDivider() => Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Divider(height: 1, color: Colors.grey.shade200));

Widget adminContentSectionHeader({
  required String title,
  required IconData icon,
  required Color iconColor,
  String? subtitle,
  required String buttonLabel,
  required VoidCallback onPressed,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
            if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))],
          ],
        ),
      ),
      const SizedBox(width: 8),
      ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 16),
        label: Text(buttonLabel, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: iconColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ],
  );
}
Widget adminDetailHeader({
  required BuildContext context,
  required String title,
  required String subtitle,
  required IconData icon,
  List<Color> colors = const [_AdminTheme.primary, _AdminTheme.primaryDark],
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
      ],
    ),
  );
}

void adminShowSnack(BuildContext context, String msg, bool isError) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
void adminShowRejectionDialog(BuildContext context, int userId, void Function(int userId, String action, {String? reason}) onAction) {
  final reasonCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Reject KYC", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Please specify a reason for rejecting this KYC profile:"),
          const SizedBox(height: 12),
          TextField(
            controller: reasonCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "e.g., Signature is blurry, Aadhaar back missing...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          onPressed: () {
            final reason = reasonCtrl.text.trim();
            if (reason.isEmpty) {
              adminShowSnack(ctx, "Please enter a rejection reason", true);
              return;
            }
            Navigator.pop(ctx);
            onAction(userId, "Rejected", reason: reason);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text("Confirm Reject"),
        ),
      ],
    ),
  );
}
class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  Timer? _autoRefreshTimer;
  String _adminName = "Super Admin";
  String _adminEmail = "";
  bool _isLoadingStats = false;

  int _totalUsers = 0;
  int _students = 0;
  int _schools = 0;
  int _franchises = 0;
  int _distributors = 0;
  int _agents = 0;
  int _pendingKyc = 0;
  int _totalOrders = 0;

  @override
  void initState() {
    super.initState();
    _loadAdminSession();
    _fetchStats();

    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchStats(silent: true));
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAdminSession() async {
    final session = await SessionManager.getSession();
    if (session != null && mounted) {
      setState(() {
        _adminName = session['name'] ?? "Super Admin";
        _adminEmail = session['email'] ?? "";
      });
    }
  }

  Future<void> _fetchStats({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingStats = true);
    try {
      final usersRes = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/get_all_users.php"),
        headers: {"Content-Type": "application/json"},
      );
      if (usersRes.statusCode == 200) {
        final data = jsonDecode(usersRes.body);
        if (data['status'] == 'success') {
          final List<dynamic> users = data['data'];
          if (mounted) {
            setState(() {
              _totalUsers = users.length;
              _students = users.where((u) => u['role'] == 'Student').length;
              _schools = users.where((u) => u['role'] == 'School').length;
              _franchises = users.where((u) => u['role'] == 'Franchise Partner').length;
              _distributors = users.where((u) => u['role'] == 'Distributor').length;
              _agents = users.where((u) => u['role'] == 'Agent').length;
            });
          }
        }
      }
      final pendingRes = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/get_pending_kyc.php"),
        headers: {"Content-Type": "application/json"},
      );
      if (pendingRes.statusCode == 200) {
        final data = jsonDecode(pendingRes.body);
        if (data['status'] == 'success' && mounted) {
          setState(() => _pendingKyc = (data['data'] as List).length);
        }
      }
      final ordersRes = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_kit_orders.php"));
      if (ordersRes.statusCode == 200) {
        final data = jsonDecode(ordersRes.body);
        if (data['status'] == 'success' && mounted) {
          setState(() => _totalOrders = (data['data'] as List).length);
        }
      }
    } catch (e) {
      debugPrint("Error fetching admin stats: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoadingStats = false);
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SessionManager.clearSession();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: _AdminTheme.primary,
          onRefresh: () => _fetchStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Manage Platform", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
                      const SizedBox(height: 4),
                      Text("Tap a card to open and manage that section", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      const SizedBox(height: 14),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: .95,
                        children: [
                          _AdminCard(
                            title: "KYC Queue",
                            value: "$_pendingKyc",
                            icon: Icons.fact_check_outlined,
                            iconColor: const Color(0xffF59E0B),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycQueueScreen())),
                          ),
                          _AdminCard(
                            title: "Directory",
                            value: "$_totalUsers",
                            icon: Icons.people_alt_outlined,
                            iconColor: _AdminTheme.primary,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DirectoryScreen())),
                          ),
                          _AdminCard(
                            title: "Students",
                            value: "$_students",
                            icon: Icons.school_outlined,
                            iconColor: const Color(0xff3B82F6),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleUsersListScreen(role: "Student", color: Color(0xff3B82F6), icon: Icons.school_rounded))),
                          ),
                          _AdminCard(
                            title: "Schools",
                            value: "$_schools",
                            icon: Icons.domain_outlined,
                            iconColor: const Color(0xff10B981),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleUsersListScreen(role: "School", color: Color(0xff10B981), icon: Icons.domain_rounded))),
                          ),
                          _AdminCard(
                            title: "Franchises",
                            value: "$_franchises",
                            icon: Icons.storefront_outlined,
                            iconColor: const Color(0xffF59E0B),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleUsersListScreen(role: "Franchise Partner", color: Color(0xffF59E0B), icon: Icons.storefront_rounded))),
                          ),
                          _AdminCard(
                            title: "Distributors",
                            value: "$_distributors",
                            icon: Icons.local_shipping_outlined,
                            iconColor: const Color(0xff8B5CF6),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleUsersListScreen(role: "Distributor", color: Color(0xff8B5CF6), icon: Icons.local_shipping_rounded))),
                          ),
                          _AdminCard(
                            title: "Agents",
                            value: "$_agents",
                            icon: Icons.person_pin_outlined,
                            iconColor: const Color(0xffFF6D00),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleUsersListScreen(role: "Agent", color: Color(0xffFF6D00), icon: Icons.person_pin_rounded))),
                          ),
                          _AdminCard(
                            title: "Content Manager",
                            value: "Manage",
                            icon: Icons.dashboard_customize_outlined,
                            iconColor: const Color(0xffFF6B00),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentManagerScreen())),
                          ),
                          _AdminCard(
                            title: "Kits & Orders",
                            value: "$_totalOrders",
                            icon: Icons.inventory_2_outlined,
                            iconColor: const Color(0xff16C74A),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KitsOrdersScreen())),
                          ),
                          _AdminCard(
                            title: "MLM Dashboard",
                            value: "Track",
                            icon: Icons.account_tree_outlined,
                            iconColor: const Color(0xff06B6D4),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MlmCommissionsScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_AdminTheme.primary, _AdminTheme.primaryDark]),
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
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/image/kmain.png',
                height: 54,
                width: 145,        // 👈 jitna bada chahiye utna badha do
                fit: BoxFit.fill,  // 👈 yahi "stretch" effect deta hai
              ),
              Spacer(),
              // Stack(
              //   children: [
              //     Container(
              //       height: 48,
              //       width: 48,
              //       decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(16)),
              //       child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
              //     ),
              //     Positioned(right: 10, top: 10, child: Container(height: 10, width: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
              //   ],
              // ),
            ],
          ),
          const SizedBox(height: 20),
          Align(alignment: Alignment.centerLeft, child: Text(_adminName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold))),
          const SizedBox(height: 4),
          Align(alignment: Alignment.centerLeft, child: Text("Platform Control Center", style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 14))),
          const SizedBox(height: 18),
          Row(
            children: [
              _hStat("Users", "$_totalUsers"),
              _vDivider(),
              _hStat("Pending KYC", "$_pendingKyc"),
              _vDivider(),
              _hStat("Orders", "$_totalOrders"),
            ],
          ),
        ],
      ),
    );
  }
  Widget _hStat(String label, String value) => Expanded(
    child: Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    ),
  );
  Widget _vDivider() => Container(height: 28, width: 1, color: Colors.white.withOpacity(.3));
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_AdminTheme.primary, _AdminTheme.primaryDark]),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(.2),
                    child: Text(
                      _adminName.isNotEmpty ? _adminName[0].toUpperCase() : "A",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_adminName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Text(_adminEmail.isNotEmpty ? _adminEmail : "Super Admin Account", style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _drawerItem(icon: Icons.dashboard_rounded, label: "Home", selected: true, onTap: () => Navigator.pop(context)),
            _drawerItem(
              icon: Icons.fact_check_outlined,
              label: "KYC Queue",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const KycQueueScreen()));
              },
            ),
            _drawerItem(
              icon: Icons.people_alt_outlined,
              label: "Directory",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DirectoryScreen()));
              },
            ),
            _drawerItem(
              icon: Icons.dashboard_customize_outlined,
              label: "Content Manager",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentManagerScreen()));
              },
            ),
            _drawerItem(
              icon: Icons.inventory_2_outlined,
              label: "Kits & Orders",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const KitsOrdersScreen()));
              },
            ),
            _drawerItem(
              icon: Icons.account_balance_wallet_outlined,
              label: "MLM & Commissions",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MlmCommissionsScreen()));
              },
            ),
            _drawerItem(
              icon: Icons.calendar_today_outlined,
              label: "Training Requests",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTrainingRequestsScreen()));
              },
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Divider()),
            _drawerItem(
              icon: Icons.settings_outlined,
              label: "Settings",
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings coming soon.")));
              },
            ),
            _drawerItem(
              icon: Icons.help_outline_rounded,
              label: "Help & Support",
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Help & Support coming soon.")));
              },
            ),
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

  Widget _drawerItem({required IconData icon, required String label, required VoidCallback onTap, bool selected = false, Color? color}) {
    final c = color ?? (selected ? _AdminTheme.primary : Colors.grey.shade700);
    return Material(
      color: selected ? _AdminTheme.primary.withOpacity(.08) : Colors.transparent,
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
class _AdminCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _AdminCard({required this.title, required this.value, required this.icon, required this.iconColor, required this.onTap});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(colors: [iconColor, iconColor.withOpacity(.8)])),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const Spacer(),
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
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
// kyc queue screen Starting

class KycQueueScreen extends StatefulWidget {
  const KycQueueScreen({super.key});

  @override
  State<KycQueueScreen> createState() => _KycQueueScreenState();
}

class _KycQueueScreenState extends State<KycQueueScreen> {
  bool _isLoading = false;
  List<dynamic> _pendingList = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchPendingKyc();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchPendingKyc(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPendingKyc({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final response = await http.post(Uri.parse("https://apps.kofalt.in/api/admin/get_pending_kyc.php"), headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) {
          setState(() => _pendingList = data['data']);
        }
      }
    } catch (e) {
      debugPrint("Error fetching pending KYC: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _actionKyc(int userId, String action, {String? reason}) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/action_kyc.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "action": action, "reason": reason}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "KYC status updated to $action!", false);
        _fetchPendingKyc();
      } else {
        adminShowSnack(context, data['message'] ?? "Action failed", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Widget _infoRow(String label, dynamic val) {
    if (val == null || val.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
          Expanded(child: Text(val.toString(), style: const TextStyle(color: Color(0xff334155), fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _modalSectionHeader(String label) => Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E293B)));

  Widget _imageCard(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _viewFullImage(url),
          child: Container(
            width: 150,
            height: 100,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12), color: Colors.grey.shade50),
            clipBehavior: Clip.antiAlias,
            child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey))),
          ),
        ),
      ],
    );
  }
  void _viewFullImage(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(child: Image.network(url, fit: BoxFit.contain)),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showKycDetailsModal(Map<String, dynamic> userKyc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: _AdminTheme.primaryLight,
                              child: Text(userKyc['name']?[0]?.toUpperCase() ?? "?", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _AdminTheme.primary)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(userKyc['name'] ?? "Unknown", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text("Role: ${userKyc['role']} • Phone: ${userKyc['phone']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        _modalSectionHeader("Form Data"),
                        const SizedBox(height: 8),
                        if (userKyc['role'] == 'Student') ...[
                          _infoRow("School Name", userKyc['school_name']),
                          _infoRow("Grade / Class", userKyc['class_grade']),
                          _infoRow("Date of Birth", userKyc['dob']),
                        ],
                        if (userKyc['role'] == 'School') ...[
                          _infoRow("Principal Name", userKyc['principal_name']),
                          _infoRow("Board Type", userKyc['board_type']),
                          _infoRow("Reg Number", userKyc['reg_number']),
                          _infoRow("School City", userKyc['school_city']),
                        ],
                        if (userKyc['role'] == 'Franchise Partner' || userKyc['role'] == 'Distributor') ...[
                          _infoRow("Business Name", userKyc['business_name']),
                          _infoRow("GST Number", userKyc['gst_number']),
                          _infoRow("City Location", userKyc['city']),
                          _infoRow("Exp Detail", userKyc['experience']),
                          _infoRow("Target Area", userKyc['area']),
                        ],
                        _infoRow("Aadhaar ID", userKyc['aadhaar_number']),
                        _infoRow("PAN ID", userKyc['pan_number']),
                        _infoRow("GST ID (Doc)", userKyc['gst_number_doc']),
                        _infoRow("School Reg ID", userKyc['school_reg_number']),
                        const Divider(height: 32),
                        _modalSectionHeader("Bank Details"),
                        const SizedBox(height: 8),
                        _infoRow("Bank Name", userKyc['bank_name']),
                        _infoRow("Account No.", userKyc['bank_account']),
                        _infoRow("IFSC Code", userKyc['bank_ifsc']),
                        const Divider(height: 32),
                        _modalSectionHeader("Uploaded Files"),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (userKyc['aadhaar_front'] != null) _imageCard("Aadhaar Front", userKyc['aadhaar_front']),
                            if (userKyc['aadhaar_back'] != null) _imageCard("Aadhaar Back", userKyc['aadhaar_back']),
                            if (userKyc['pan_image'] != null) _imageCard("PAN Image", userKyc['pan_image']),
                            if (userKyc['gst_cert'] != null) _imageCard("GST Certificate", userKyc['gst_cert']),
                            if (userKyc['school_reg_cert'] != null) _imageCard("School Reg Cert", userKyc['school_reg_cert']),
                            if (userKyc['selfie'] != null) _imageCard("Selfie Image", userKyc['selfie']),
                            if (userKyc['signature'] != null) _imageCard("Signature", userKyc['signature']),
                          ],
                        ),
                        const SizedBox(height: 36),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  adminShowRejectionDialog(context, userKyc['id'], _actionKyc);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  foregroundColor: Colors.red.shade600,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _actionKyc(userKyc['id'], "Approved");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _AdminTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text("Approve", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          adminDetailHeader(context: context, title: "KYC Queue", subtitle: "${_pendingList.length} pending reviews", icon: Icons.fact_check_outlined),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _AdminTheme.primary))
                : RefreshIndicator(
              color: _AdminTheme.primary,
              onRefresh: () => _fetchPendingKyc(),
              child: _pendingList.isEmpty
                  ? ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                  adminEmptyState(Icons.check_circle_outline_rounded, "Audit queue is empty!", subMessage: "New KYC submissions will show up here."),
                ],
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingList.length,
                itemBuilder: (context, index) {
                  final user = _pendingList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shadowColor: Colors.black.withOpacity(0.04),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade100)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: _AdminTheme.primaryLight,
                            child: Text(user['name']?[0]?.toUpperCase() ?? "?", style: const TextStyle(color: _AdminTheme.primary, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                                      child: Text(user['role'] ?? "", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        user['created_by_name'] != null && user['created_by_name'].toString().isNotEmpty
                                            ? "Created by: ${user['created_by_name']}"
                                            : "• ${user['phone']}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: user['created_by_name'] != null && user['created_by_name'].toString().isNotEmpty ? const Color(0xff2563EB) : Colors.grey.shade500,
                                          fontSize: 11,
                                          fontWeight: user['created_by_name'] != null ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showKycDetailsModal(user),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _AdminTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            child: const Text("Review"),
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

// Directory Screen Start

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  bool _isLoading = false;
  List<dynamic> _usersList = [];
  Timer? _timer;
  String _sortColumn = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchAllUsers(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAllUsers({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final response = await http.post(Uri.parse("https://apps.kofalt.in/api/admin/get_all_users.php"), headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) setState(() => _usersList = data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching all users: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _actionKyc(int userId, String action, {String? reason}) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/action_kyc.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "action": action, "reason": reason}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "KYC status updated to $action!", false);
        _fetchAllUsers();
      } else {
        adminShowSnack(context, data['message'] ?? "Action failed", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _loginAsUser(Map<String, dynamic> user) async {
    final int userId = user['id'] is int ? user['id'] : int.tryParse(user['id'].toString()) ?? 0;
    await SessionManager.saveSession(
      id: userId,
      name: user['name'] ?? "",
      email: user['email'] ?? "",
      phone: user['phone'] ?? "",
      role: user['role'] ?? "",
      kycStatus: user['kyc_status'] ?? "Pending",
      isImpersonating: true,
    );
    if (!mounted) return;
    Widget dashboard;
    switch (user['role']) {
      case "Distributor":
        dashboard = const DistributorDashboard();
        break;
      case "Franchise Partner":
        dashboard = const FranchiseDashboard();
        break;
      case "School":
        dashboard = const SchoolDashboard();
        break;
      case "Student":
        dashboard = const StudentDashboard();
        break;
      default:
        dashboard = const DistributorDashboard();
    }
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => dashboard), (route) => false);
  }

  List<dynamic> _getSortedUsers() {
    final list = List<dynamic>.from(_usersList);
    list.sort((a, b) {
      String valA, valB;
      switch (_sortColumn) {
        case 'role':
          valA = (a['role'] ?? '').toString();
          valB = (b['role'] ?? '').toString();
          break;
        case 'status':
          valA = (a['kyc_status'] ?? '').toString();
          valB = (b['kyc_status'] ?? '').toString();
          break;
        default:
          valA = (a['name'] ?? '').toString();
          valB = (b['name'] ?? '').toString();
      }
      final cmp = valA.toLowerCase().compareTo(valB.toLowerCase());
      return _sortAscending ? cmp : -cmp;
    });
    return list;
  }

  void _onSortTap(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  Widget _sortHeaderLabel(String label, String column, {int flex = 1}) {
    final bool isActive = _sortColumn == column;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => _onSortTap(column),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? _AdminTheme.primary : Colors.grey.shade600)),
            const SizedBox(width: 4),
            Icon(isActive ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.unfold_more, size: 14, color: isActive ? _AdminTheme.primary : Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedUsers = _getSortedUsers();
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          adminDetailHeader(context: context, title: "Directory", subtitle: "${_usersList.length} registered users", icon: Icons.people_alt_outlined),
          if (!_isLoading && _usersList.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                children: [
                  _sortHeaderLabel("Name", "name", flex: 3),
                  _sortHeaderLabel("Role", "role", flex: 2),
                  _sortHeaderLabel("KYC Status", "status", flex: 2),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _AdminTheme.primary))
                : RefreshIndicator(
              color: _AdminTheme.primary,
              onRefresh: () => _fetchAllUsers(),
              child: _usersList.isEmpty
                  ? ListView(children: [SizedBox(height: MediaQuery.of(context).size.height * 0.18), adminEmptyState(Icons.people_outline_rounded, "No users found.")])
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedUsers.length,
                itemBuilder: (context, index) {
                  final user = sortedUsers[index];
                  final bool isSuspended = user['status'] == 'Suspended';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shadowColor: Colors.black.withOpacity(0.04),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade100)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isSuspended ? Colors.red.shade50 : const Color(0xffF1F5F9),
                            child: Text(user['name']?[0]?.toUpperCase() ?? "?", style: TextStyle(color: isSuspended ? Colors.red : Colors.grey.shade700, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['name'] ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, decoration: isSuspended ? TextDecoration.lineThrough : null)),
                                const SizedBox(height: 2),
                                Text("${user['role']} • ${user['phone']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user['kyc_status'] == 'Approved' ? Colors.green.shade50 : (user['kyc_status'] == 'Rejected' ? Colors.red.shade50 : Colors.orange.shade50),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "KYC: ${user['kyc_status']}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: user['kyc_status'] == 'Approved' ? Colors.green.shade600 : (user['kyc_status'] == 'Rejected' ? Colors.red.shade600 : Colors.orange.shade600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(tooltip: "Login As User", onPressed: () => _loginAsUser(user), icon: const Icon(Icons.login, color: _AdminTheme.primary, size: 26), visualDensity: VisualDensity.compact),
                          PopupMenuButton<String>(
                            tooltip: "Update KYC Status",
                            icon: Icon(
                              Icons.fact_check_outlined,
                              color: user['kyc_status'] == 'Approved' ? Colors.green.shade600 : (user['kyc_status'] == 'Rejected' ? Colors.red.shade600 : Colors.orange.shade600),
                              size: 24,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            onSelected: (value) {
                              if (value == 'Rejected') {
                                adminShowRejectionDialog(context, user['id'], _actionKyc);
                              } else {
                                _actionKyc(user['id'], value);
                              }
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem(value: 'Approved', child: Row(children: [Icon(Icons.check_circle, color: Colors.green.shade600, size: 18), const SizedBox(width: 10), const Text("Approve")])),
                              PopupMenuItem(value: 'Rejected', child: Row(children: [Icon(Icons.cancel, color: Colors.red.shade600, size: 18), const SizedBox(width: 10), const Text("Reject")])),
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

// Role Users list Scren Start

class RoleUsersListScreen extends StatefulWidget {
  final String role;
  final Color color;
  final IconData icon;

  const RoleUsersListScreen({super.key, required this.role, required this.color, required this.icon});

  @override
  State<RoleUsersListScreen> createState() => _RoleUsersListScreenState();
}

class _RoleUsersListScreenState extends State<RoleUsersListScreen> {
  bool _isLoading = false;
  List<dynamic> _allUsers = [];
  Timer? _timer;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = "";
  String _statusFilter = "All";

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchUsers(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final response = await http.post(Uri.parse("https://apps.kofalt.in/api/admin/get_all_users.php"), headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) {
          setState(() => _allUsers = (data['data'] as List).where((u) => u['role'] == widget.role).toList());
        }
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleUserStatus(int userId, String newStatus) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator(color: widget.color)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/toggle_user_status.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "status": newStatus}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "User status updated to $newStatus!", false);
        _fetchUsers();
      } else {
        adminShowSnack(context, data['message'] ?? "Action failed", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _actionKyc(int userId, String action, {String? reason}) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator(color: widget.color)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/action_kyc.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "action": action, "reason": reason}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "KYC status updated to $action!", false);
        _fetchUsers();
      } else {
        adminShowSnack(context, data['message'] ?? "Action failed", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _loginAsUser(Map<String, dynamic> user) async {
    final int userId = user['id'] is int ? user['id'] : int.tryParse(user['id'].toString()) ?? 0;
    await SessionManager.saveSession(
      id: userId,
      name: user['name'] ?? "",
      email: user['email'] ?? "",
      phone: user['phone'] ?? "",
      role: user['role'] ?? "",
      kycStatus: user['kyc_status'] ?? "Pending",
      isImpersonating: true,
    );
    if (!mounted) return;
    Widget dashboard;
    switch (user['role']) {
      case "Distributor":
        dashboard = const DistributorDashboard();
        break;
      case "Franchise Partner":
        dashboard = const FranchiseDashboard();
        break;
      case "School":
        dashboard = const SchoolDashboard();
        break;
      case "Student":
        dashboard = const StudentDashboard();
        break;
      case "Agent":
        dashboard = const AgentDashboard();
        break;
      default:
        dashboard = const DistributorDashboard();
    }
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => dashboard), (route) => false);
  }

  List<dynamic> get _filtered {
    return _allUsers.where((u) {
      final name = (u['name'] ?? "").toString().toLowerCase();
      final phone = (u['phone'] ?? "").toString().toLowerCase();
      final matchesQuery = _query.isEmpty || name.contains(_query) || phone.contains(_query);
      final status = (u['kyc_status'] ?? "Pending").toString();
      final matchesStatus = _statusFilter == "All" || status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  int _countByStatus(String status) {
    if (status == "All") return _allUsers.length;
    return _allUsers.where((u) => (u['kyc_status'] ?? "Pending").toString() == status).length;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [widget.color, widget.color.withOpacity(0.75)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                boxShadow: [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(height: 38, width: 38, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16)),
                      ),
                      const Spacer(),
                      Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)), child: Icon(widget.icon, color: Colors.white, size: 20)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text("${widget.role}s", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text("${_allUsers.length} total registered", style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Search by name or phone",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: widget.color, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _statusChip("All", _countByStatus("All")),
                    const SizedBox(width: 8),
                    _statusChip("Approved", _countByStatus("Approved")),
                    const SizedBox(width: 8),
                    _statusChip("Pending", _countByStatus("Pending")),
                    const SizedBox(width: 8),
                    _statusChip("Rejected", _countByStatus("Rejected")),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: widget.color))
            : RefreshIndicator(
          color: widget.color,
          onRefresh: () => _fetchUsers(),
          child: filtered.isEmpty
              ? ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.16),
              Center(
                child: Column(
                  children: [
                    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: widget.color.withOpacity(0.08), shape: BoxShape.circle), child: Icon(widget.icon, size: 32, color: widget.color.withOpacity(0.6))),
                    const SizedBox(height: 14),
                    Text(_allUsers.isEmpty ? "No ${widget.role.toLowerCase()}s yet." : "No matches found.", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff64748B))),
                  ],
                ),
              ),
            ],
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final user = filtered[index];
              final String status = (user['kyc_status'] ?? "Pending").toString();
              final Color statusColor = status == 'Approved' ? const Color(0xff10B981) : (status == 'Rejected' ? const Color(0xffEF4444) : const Color(0xffF59E0B));
              final bool isSuspended = user['status'] == 'Suspended';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.color.withOpacity(0.15), widget.color.withOpacity(0.05)]), borderRadius: BorderRadius.circular(14)),
                        child: Center(child: Text((user['name'] ?? "?")[0].toString().toUpperCase(), style: TextStyle(color: widget.color, fontWeight: FontWeight.bold, fontSize: 17))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['name'] ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, decoration: isSuspended ? TextDecoration.lineThrough : null, color: const Color(0xff1E293B))),
                            if (widget.role == 'Agent' && user['distributor_name'] != null) ...[
                              const SizedBox(height: 2),
                              Text("Distributor: ${user['distributor_name']}", style: const TextStyle(color: Color(0xff2563EB), fontWeight: FontWeight.w600, fontSize: 11.5)),
                            ],
                            const SizedBox(height: 2),
                            Text(user['phone'] ?? "", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text("KYC: $status", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (user['status'] == 'Suspended' ? Colors.red : Colors.green).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    user['status'] == 'Suspended' ? "Inactive" : "Active",
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: user['status'] == 'Suspended' ? Colors.red.shade700 : Colors.green.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(tooltip: "Login As User", onPressed: () => _loginAsUser(user), icon: Icon(Icons.login_rounded, color: widget.color, size: 22), visualDensity: VisualDensity.compact),
                      PopupMenuButton<String>(
                        tooltip: "Toggle Active/Inactive",
                        icon: Icon(
                          user['status'] == 'Suspended' ? Icons.toggle_off_rounded : Icons.toggle_on_rounded,
                          color: user['status'] == 'Suspended' ? Colors.red.shade400 : Colors.green.shade600,
                          size: 28,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onSelected: (value) {
                          _toggleUserStatus(user['id'], value);
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'Active',
                            child: Row(children: [Icon(Icons.check_circle, color: Colors.green.shade600, size: 18), const SizedBox(width: 10), const Text("Set Active")]),
                          ),
                          PopupMenuItem(
                            value: 'Suspended',
                            child: Row(children: [Icon(Icons.block, color: Colors.red.shade600, size: 18), const SizedBox(width: 10), const Text("Set Inactive (Suspend)")]),
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
    );
  }

  Widget _statusChip(String label, int count) {
    final bool isSelected = _statusFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? widget.color : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? widget.color : Colors.grey.shade200),
          boxShadow: isSelected ? [BoxShadow(color: widget.color.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 12.5)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: isSelected ? Colors.white.withOpacity(0.25) : widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text("$count", style: TextStyle(color: isSelected ? Colors.white : widget.color, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// Content manage Screen Start

class ContentManagerScreen extends StatefulWidget {
  const ContentManagerScreen({super.key});

  @override
  State<ContentManagerScreen> createState() => _ContentManagerScreenState();
}

class _ContentManagerScreenState extends State<ContentManagerScreen> {
  bool _isLoadingCourses = false;
  bool _isLoadingVideos = false;
  bool _isLoadingTestimonials = false;
  bool _isLoadingFaqs = false;
  bool _isLoadingGallery = false;
  bool _isLoadingPrograms = false;
  List<dynamic> _coursesList = [];
  List<dynamic> _videosList = [];
  List<dynamic> _testimonialsList = [];
  List<dynamic> _faqsList = [];
  List<dynamic> _galleryList = [];
  List<dynamic> _programsList = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _fetchPrograms();
    _fetchGallery();
    _fetchVideos();
    _fetchTestimonials();
    _fetchFaqs();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refreshAll(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refreshAll({bool silent = false}) async {
    await Future.wait([
      _fetchCourses(silent: silent),
      _fetchPrograms(silent: silent),
      _fetchGallery(silent: silent),
      _fetchVideos(silent: silent),
      _fetchTestimonials(silent: silent),
      _fetchFaqs(silent: silent),
    ]);
  }

  Future<void> _fetchCourses({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingCourses = true);
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_courses.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) setState(() => _coursesList = data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoadingCourses = false);
    }
  }

  Future<void> _addCourse(String title, String description, String classGrade, String subject) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_course.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": title, "description": description, "class_grade": classGrade, "subject": subject}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Course created successfully!", false);
        _fetchCourses();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to create course", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _addChapter(int courseId, int chapterNumber, String title, String resourceUrl) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_chapter.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"course_id": courseId, "chapter_number": chapterNumber, "title": title, "resource_url": resourceUrl}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Chapter lesson uploaded successfully!", false);
        _fetchCourses();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to upload chapter", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _addCircular(String title, String message, List<String> targetRoles) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_circular.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": title, "message": message, "target_roles": targetRoles}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Announcement notice published successfully!", false);
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to publish announcement", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _fetchVideos({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingVideos = true);
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_videos.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) setState(() => _videosList = data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching videos: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoadingVideos = false);
    }
  }

  Future<void> _addVideo(String title, String description, String videoUrl, List<String> targetRoles) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_video.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": title, "description": description, "video_url": videoUrl, "target_roles": targetRoles}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Video added to library successfully!", false);
        _fetchVideos();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to add video", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _deleteVideo(int videoId) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/delete_video.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"video_id": videoId}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Video removed from library!", false);
        _fetchVideos();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to delete video", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _fetchTestimonials({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingTestimonials = true);
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_testimonials.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) setState(() => _testimonialsList = data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching testimonials: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoadingTestimonials = false);
    }
  }

  Future<void> _addTestimonial(String name, String role, String message, int rating, List<String> targetRoles) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_testimonial.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "role": role, "message": message, "rating": rating, "target_roles": targetRoles}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Testimonial added successfully!", false);
        _fetchTestimonials();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to add testimonial", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _deleteTestimonial(int testimonialId) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/delete_testimonial.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"testimonial_id": testimonialId}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Testimonial removed!", false);
        _fetchTestimonials();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to delete testimonial", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _fetchFaqs({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingFaqs = true);
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_faqs.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) setState(() => _faqsList = data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching FAQs: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoadingFaqs = false);
    }
  }

  Future<void> _addFaq(String question, String answer, List<String> targetRoles) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_faq.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": question, "answer": answer, "target_roles": targetRoles}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "FAQ added successfully!", false);
        _fetchFaqs();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to add FAQ", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _deleteFaq(int faqId) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/delete_faq.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"faq_id": faqId}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "FAQ removed!", false);
        _fetchFaqs();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to delete FAQ", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  void _showCourseDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Create Course Catalog", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Course Title")),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Course Description")),
              TextField(controller: gradeCtrl, decoration: const InputDecoration(labelText: "Target Grade (e.g. 10th, Level 3)")),
              TextField(controller: subCtrl, decoration: const InputDecoration(labelText: "Subject (e.g. Abacus, Vedic Maths)")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
            onPressed: () {
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();
              final grade = gradeCtrl.text.trim();
              final sub = subCtrl.text.trim();
              if (title.isEmpty || desc.isEmpty || grade.isEmpty || sub.isEmpty) {
                adminShowSnack(ctx, "Please fill out all fields", true);
                return;
              }
              Navigator.pop(ctx);
              _addCourse(title, desc, grade, sub);
            },
            child: const Text("Add Course"),
          ),
        ],
      ),
    );
  }

  void _showChapterDialog(int courseId) {
    final titleCtrl = TextEditingController();
    final numCtrl = TextEditingController(text: "1");
    final urlCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Upload Lesson Chapter", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: numCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Chapter Number")),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Chapter Title")),
            TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: "Resource / Video URL")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
            onPressed: () {
              final title = titleCtrl.text.trim();
              final numVal = int.tryParse(numCtrl.text) ?? 1;
              final url = urlCtrl.text.trim();
              if (title.isEmpty || url.isEmpty) {
                adminShowSnack(ctx, "Please fill out all fields", true);
                return;
              }
              Navigator.pop(ctx);
              _addChapter(courseId, numVal, title, url);
            },
            child: const Text("Upload Lesson"),
          ),
        ],
      ),
    );
  }

  void _showCircularDialog() {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    final Map<String, bool> targetRoles = {"All": true, "Distributor": false, "Franchise Partner": false, "School": false, "Student": false};
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Publish Announcement", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Announcement Heading")),
                  TextField(controller: msgCtrl, maxLines: 4, decoration: const InputDecoration(labelText: "Announcement Description")),
                  const SizedBox(height: 16),
                  const Text("Visible To", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B))),
                  const Divider(height: 12),
                  ...targetRoles.keys.map((role) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: _AdminTheme.primary,
                      title: Text(role, style: const TextStyle(fontSize: 14)),
                      value: targetRoles[role],
                      onChanged: (val) {
                        setDialogState(() {
                          if (role == "All") {
                            targetRoles.updateAll((key, value) => key == "All" ? (val ?? false) : false);
                          } else {
                            targetRoles[role] = val ?? false;
                            if (targetRoles[role] == true) targetRoles["All"] = false;
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffFF6B00), foregroundColor: Colors.white),
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final msg = msgCtrl.text.trim();
                  if (title.isEmpty || msg.isEmpty) {
                    adminShowSnack(ctx, "Please fill out all fields", true);
                    return;
                  }
                  final selectedRoles = targetRoles.entries.where((e) => e.value).map((e) => e.key).toList();
                  if (selectedRoles.isEmpty) {
                    adminShowSnack(ctx, "Please select at least one role", true);
                    return;
                  }
                  Navigator.pop(ctx);
                  _addCircular(title, msg, selectedRoles);
                },
                child: const Text("Publish"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVideoDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final Map<String, bool> targetRoles = {"All": true, "Distributor": false, "Franchise Partner": false, "School": false, "Student": false};
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Add Video to Library", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Video Title")),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: "Description")),
                  TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: "Video URL")),
                  const SizedBox(height: 16),
                  const Text("Visible To", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B))),
                  const Divider(height: 12),
                  ...targetRoles.keys.map((role) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: _AdminTheme.primary,
                      title: Text(role, style: const TextStyle(fontSize: 14)),
                      value: targetRoles[role],
                      onChanged: (val) {
                        setDialogState(() {
                          if (role == "All") {
                            targetRoles.updateAll((key, value) => key == "All" ? (val ?? false) : false);
                          } else {
                            targetRoles[role] = val ?? false;
                            if (targetRoles[role] == true) targetRoles["All"] = false;
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final desc = descCtrl.text.trim();
                  final url = urlCtrl.text.trim();
                  if (title.isEmpty || url.isEmpty) {
                    adminShowSnack(ctx, "Please fill title and video URL", true);
                    return;
                  }
                  final selectedRoles = targetRoles.entries.where((e) => e.value).map((e) => e.key).toList();
                  if (selectedRoles.isEmpty) {
                    adminShowSnack(ctx, "Please select at least one role", true);
                    return;
                  }
                  Navigator.pop(ctx);
                  _addVideo(title, desc, url, selectedRoles);
                },
                child: const Text("Add Video"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTestimonialDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    int rating = 5;
    final Map<String, bool> targetRoles = {"All": true, "Distributor": false, "Franchise Partner": false, "School": false, "Student": false};
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Add Testimonial", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Person's Name")),
                  TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: "Role / Designation (e.g. School Principal)")),
                  TextField(controller: msgCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "Testimonial Message")),
                  const SizedBox(height: 16),
                  const Text("Rating", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B))),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (i) {
                      final starIndex = i + 1;
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setDialogState(() => rating = starIndex),
                        icon: Icon(starIndex <= rating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xffF59E0B), size: 30),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text("Visible To", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B))),
                  const Divider(height: 12),
                  ...targetRoles.keys.map((role) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: _AdminTheme.primary,
                      title: Text(role, style: const TextStyle(fontSize: 14)),
                      value: targetRoles[role],
                      onChanged: (val) {
                        setDialogState(() {
                          if (role == "All") {
                            targetRoles.updateAll((key, value) => key == "All" ? (val ?? false) : false);
                          } else {
                            targetRoles[role] = val ?? false;
                            if (targetRoles[role] == true) targetRoles["All"] = false;
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final role = roleCtrl.text.trim();
                  final msg = msgCtrl.text.trim();
                  if (name.isEmpty || role.isEmpty || msg.isEmpty) {
                    adminShowSnack(ctx, "Please fill out all fields", true);
                    return;
                  }
                  final selectedRoles = targetRoles.entries.where((e) => e.value).map((e) => e.key).toList();
                  if (selectedRoles.isEmpty) {
                    adminShowSnack(ctx, "Please select at least one role", true);
                    return;
                  }
                  Navigator.pop(ctx);
                  _addTestimonial(name, role, msg, rating, selectedRoles);
                },
                child: const Text("Add Testimonial"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFaqDialog() {
    final questionCtrl = TextEditingController();
    final answerCtrl = TextEditingController();
    final Map<String, bool> targetRoles = {"All": true, "Distributor": false, "Franchise Partner": false, "School": false, "Student": false};
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Add FAQ", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: questionCtrl, maxLines: 2, decoration: const InputDecoration(labelText: "Question")),
                  TextField(controller: answerCtrl, maxLines: 4, decoration: const InputDecoration(labelText: "Answer")),
                  const SizedBox(height: 16),
                  const Text("Visible To", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B))),
                  const Divider(height: 12),
                  ...targetRoles.keys.map((role) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: _AdminTheme.primary,
                      title: Text(role, style: const TextStyle(fontSize: 14)),
                      value: targetRoles[role],
                      onChanged: (val) {
                        setDialogState(() {
                          if (role == "All") {
                            targetRoles.updateAll((key, value) => key == "All" ? (val ?? false) : false);
                          } else {
                            targetRoles[role] = val ?? false;
                            if (targetRoles[role] == true) targetRoles["All"] = false;
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
                onPressed: () {
                  final question = questionCtrl.text.trim();
                  final answer = answerCtrl.text.trim();
                  if (question.isEmpty || answer.isEmpty) {
                    adminShowSnack(ctx, "Please fill out both fields", true);
                    return;
                  }
                  final selectedRoles = targetRoles.entries.where((e) => e.value).map((e) => e.key).toList();
                  if (selectedRoles.isEmpty) {
                    adminShowSnack(ctx, "Please select at least one role", true);
                    return;
                  }
                  Navigator.pop(ctx);
                  _addFaq(question, answer, selectedRoles);
                },
                child: const Text("Add FAQ"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _fetchGallery({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingGallery = true);
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_gallery.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) setState(() => _galleryList = data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching gallery: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoadingGallery = false);
    }
  }

  Future<void> _addGallery(String title, String imageUrl, List<String> targetRoles) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_gallery.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": title, "image_url": imageUrl, "target_roles": targetRoles}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Gallery photo added successfully!", false);
        _fetchGallery();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to add photo", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _deleteGallery(int photoId) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/delete_gallery.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": photoId}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Photo removed from gallery!", false);
        _fetchGallery();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to delete photo", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  void _showGalleryDialog() {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final Map<String, bool> targetRoles = {"All": true, "Distributor": false, "Franchise Partner": false, "School": false, "Student": false};
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Add Gallery Photo", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Photo Title / Caption")),
                  TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: "Image URL (Direct link)")),
                  const SizedBox(height: 16),
                  const Text("Visible To", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B))),
                  const Divider(height: 12),
                  ...targetRoles.keys.map((role) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: _AdminTheme.primary,
                      title: Text(role, style: const TextStyle(fontSize: 14)),
                      value: targetRoles[role],
                      onChanged: (val) {
                        setDialogState(() {
                          if (role == "All") {
                            targetRoles.updateAll((key, value) => key == "All" ? (val ?? false) : false);
                          } else {
                            targetRoles[role] = val ?? false;
                            if (targetRoles[role] == true) targetRoles["All"] = false;
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final url = urlCtrl.text.trim();
                  if (title.isEmpty || url.isEmpty) {
                    adminShowSnack(ctx, "Please fill out title and image URL", true);
                    return;
                  }
                  final selectedRoles = targetRoles.entries.where((e) => e.value).map((e) => e.key).toList();
                  if (selectedRoles.isEmpty) {
                    adminShowSnack(ctx, "Please select at least one role", true);
                    return;
                  }
                  Navigator.pop(ctx);
                  _addGallery(title, url, selectedRoles);
                },
                child: const Text("Add Photo"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _fetchPrograms({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingPrograms = true);
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_programs.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) setState(() => _programsList = data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching programs: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoadingPrograms = false);
    }
  }

  Future<void> _addProgram(String title, String description, String demoUrl, String fullDemoUrl, String thumbUrl, List<String> targetRoles) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_program.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "description": description,
          "demo_video_url": demoUrl,
          "full_demo_video_url": fullDemoUrl,
          "thumbnail_url": thumbUrl,
          "target_roles": targetRoles,
        }),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Program added successfully!", false);
        _fetchPrograms();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to add program", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _deleteProgram(int programId) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/delete_program.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": programId}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Program removed!", false);
        _fetchPrograms();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to delete program", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  void _showProgramDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final demoCtrl = TextEditingController();
    final fullDemoCtrl = TextEditingController();
    final thumbCtrl = TextEditingController();
    final Map<String, bool> targetRoles = {"All": true, "Distributor": false, "Franchise Partner": false, "School": false, "Student": false};
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Add Program & Demos", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Program Title (e.g. Abacus)")) ,
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
                  TextField(controller: demoCtrl, decoration: const InputDecoration(labelText: "Watch Demo Video URL (MP4/Stream)")),
                  TextField(controller: fullDemoCtrl, decoration: const InputDecoration(labelText: "Watch Full Demo Video URL (MP4/Stream)")),
                  TextField(controller: thumbCtrl, decoration: const InputDecoration(labelText: "Thumbnail Image URL (Optional)")),
                  const SizedBox(height: 16),
                  const Text("Visible To", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B))),
                  const Divider(height: 12),
                  ...targetRoles.keys.map((role) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: _AdminTheme.primary,
                      title: Text(role, style: const TextStyle(fontSize: 14)),
                      value: targetRoles[role],
                      onChanged: (val) {
                        setDialogState(() {
                          if (role == "All") {
                            targetRoles.updateAll((key, value) => key == "All" ? (val ?? false) : false);
                          } else {
                            targetRoles[role] = val ?? false;
                            if (targetRoles[role] == true) targetRoles["All"] = false;
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final desc = descCtrl.text.trim();
                  final demo = demoCtrl.text.trim();
                  final full = fullDemoCtrl.text.trim();
                  final thumb = thumbCtrl.text.trim();
                  if (title.isEmpty) {
                    adminShowSnack(ctx, "Please enter a program title", true);
                    return;
                  }
                  final selectedRoles = targetRoles.entries.where((e) => e.value).map((e) => e.key).toList();
                  if (selectedRoles.isEmpty) {
                    adminShowSnack(ctx, "Please select at least one role", true);
                    return;
                  }
                  Navigator.pop(ctx);
                  _addProgram(title, desc, demo, full, thumb, selectedRoles);
                },
                child: const Text("Add Program"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          adminDetailHeader(context: context, title: "Content Manager", subtitle: "Announcements, courses, videos, testimonials & FAQs", icon: Icons.dashboard_customize_outlined),
          Expanded(
            child: RefreshIndicator(
              color: _AdminTheme.primary,
              onRefresh: () => _refreshAll(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      shadowColor: Colors.black.withOpacity(0.05),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xffFFF1E6), borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.campaign_outlined, size: 24, color: Color(0xffFF6B00)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Announcements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text("Publish a custom announcement to selected roles", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _showCircularDialog,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffFF6B00), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              child: const Text("Publish"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    adminSectionDivider(),
                    adminContentSectionHeader(
                      title: "Our Programs & Demos",
                      icon: Icons.school_rounded,
                      iconColor: const Color(0xff2563EB),
                      subtitle: "Manage programs with Demo & Full Demo video streaming.",
                      buttonLabel: "New Program",
                      onPressed: _showProgramDialog,
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingPrograms)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                    else if (_programsList.isEmpty)
                      adminEmptyState(Icons.school_outlined, "No programs added yet.", subMessage: "Add a subject program with demo videos.")
                    else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _programsList.length > 3 ? 3 : _programsList.length,
                        itemBuilder: (context, index) {
                          final prog = _programsList[index];
                          final demoUrl = prog['demo_video_url'] ?? "";
                          final fullUrl = prog['full_demo_video_url'] ?? "";
                          final List<dynamic> pRoles = prog['target_roles'] is List ? prog['target_roles'] : (prog['target_roles']?.toString().split(',') ?? ["All"]);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 1,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(color: const Color(0xff2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                        child: const Icon(Icons.school_rounded, color: Color(0xff2563EB), size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(prog['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            if ((prog['description'] ?? "").toString().isNotEmpty)
                                              Text(prog['description'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                      IconButton(tooltip: "Remove Program", onPressed: () => _deleteProgram(prog['id']), icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22), visualDensity: VisualDensity.compact),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (demoUrl.isNotEmpty)
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: Color(0xff2563EB)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                            ),
                                            onPressed: () {
                                              DynamicVideoPlayerModal.show(
                                                context,
                                                title: "${prog['title']} - Demo",
                                                description: prog['description'] ?? "",
                                                videoUrl: demoUrl,
                                                themeColor: const Color(0xff2563EB),
                                              );
                                            },
                                            icon: const Icon(Icons.play_arrow_rounded, color: Color(0xff2563EB), size: 18),
                                            label: const Text("Watch Demo", style: TextStyle(color: Color(0xff2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                        ),
                                      if (demoUrl.isNotEmpty && fullUrl.isNotEmpty)
                                        const SizedBox(width: 10),
                                      if (fullUrl.isNotEmpty)
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xff2563EB),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              DynamicVideoPlayerModal.show(
                                                context,
                                                title: "${prog['title']} - Full Demo",
                                                description: prog['description'] ?? "",
                                                videoUrl: fullUrl,
                                                themeColor: const Color(0xff2563EB),
                                              );
                                            },
                                            icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 18),
                                            label: const Text("Full Demo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: pRoles.map<Widget>((role) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: const Color(0xff2563EB).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                                        child: Text(role.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xff2563EB))),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (_programsList.length > 3)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllProgramsScreen(programs: _programsList, themeColor: const Color(0xff2563EB))));
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: Text("View All Programs (${_programsList.length})", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                    adminSectionDivider(),
                    adminContentSectionHeader(
                      title: "Photo Gallery",
                      icon: Icons.photo_library_rounded,
                      iconColor: const Color(0xffEC4899),
                      subtitle: "Upload photo gallery items for roles.",
                      buttonLabel: "New Photo",
                      onPressed: _showGalleryDialog,
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingGallery)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                    else if (_galleryList.isEmpty)
                      adminEmptyState(Icons.add_photo_alternate_outlined, "No gallery photos yet.", subMessage: "Add images visible to user dashboards.")
                    else ...[
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: _galleryList.length > 3 ? 3 : _galleryList.length,
                        itemBuilder: (context, index) {
                          final photo = _galleryList[index];
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade100,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    photo['image_url'] ?? "",
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _deleteGallery(photo['id']),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (_galleryList.length > 3)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllGalleryScreen(photos: _galleryList, themeColor: const Color(0xffEC4899))));
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: Text("View All Photos (${_galleryList.length})", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffEC4899))),
                          ),
                        ),
                    ],
                    adminSectionDivider(),
                    adminContentSectionHeader(title: "Course Catalogs", icon: Icons.menu_book_rounded, iconColor: _AdminTheme.primary, buttonLabel: "New Course", onPressed: _showCourseDialog),
                    const SizedBox(height: 12),
                    if (_isLoadingCourses)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                    else if (_coursesList.isEmpty)
                      adminEmptyState(Icons.menu_book_outlined, "No courses registered yet.", subMessage: "Add a course using the button above.")
                    else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _coursesList.length > 3 ? 3 : _coursesList.length,
                        itemBuilder: (context, index) {
                          final course = _coursesList[index];
                          final List<dynamic> chapters = course['chapters'] ?? [];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 1,
                            color: Colors.white,
                            child: ExpansionTile(
                              title: Text(course['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text("${course['subject']} • ${course['class_grade']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(course['description'] ?? "", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                      const Divider(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Lessons / Chapters", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          TextButton.icon(onPressed: () => _showChapterDialog(course['id']), icon: const Icon(Icons.add, size: 16), label: const Text("Add Lesson")),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (chapters.isEmpty)
                                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("No lessons uploaded for this course yet.", style: TextStyle(color: Colors.grey, fontSize: 13)))
                                      else
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: chapters.length,
                                          itemBuilder: (ctx, chIndex) {
                                            final ch = chapters[chIndex];
                                            return ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: CircleAvatar(radius: 14, backgroundColor: Colors.blue.shade50, child: Text("${ch['chapter_number']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                                              title: Text(ch['title'] ?? "", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                              trailing: const Icon(Icons.play_circle_outline, color: Colors.grey),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    adminSectionDivider(),
                    adminContentSectionHeader(
                      title: "Video Library",
                      icon: Icons.play_circle_fill_rounded,
                      iconColor: _AdminTheme.primary,
                      subtitle: "Choose which roles can view each video.",
                      buttonLabel: "New Video",
                      onPressed: _showVideoDialog,
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingVideos)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                    else if (_videosList.isEmpty)
                      adminEmptyState(Icons.smart_display_outlined, "No videos in the library yet.", subMessage: "Add one using the button above.")
                    else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _videosList.length > 3 ? 3 : _videosList.length,
                        itemBuilder: (context, index) {
                          final video = _videosList[index];
                          final List<dynamic> roles = video['target_roles'] is List ? video['target_roles'] : (video['target_roles']?.toString().split(',') ?? ["All"]);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 1,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(color: _AdminTheme.primaryLight, borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.play_circle_fill, color: _AdminTheme.primary, size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(video['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        const SizedBox(height: 2),
                                        if ((video['description'] ?? "").toString().isNotEmpty)
                                          Text(video['description'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: roles.map<Widget>((role) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(color: _AdminTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                                              child: Text(role.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _AdminTheme.primary)),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(tooltip: "Remove Video", onPressed: () => _deleteVideo(video['id']), icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22), visualDensity: VisualDensity.compact),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (_videosList.length > 3)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllVideosScreen(videos: _videosList, themeColor: _AdminTheme.primary)));
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: Text("View All Videos (${_videosList.length})", style: const TextStyle(fontWeight: FontWeight.bold, color: _AdminTheme.primary)),
                          ),
                        ),
                    ],
                    adminSectionDivider(),
                    adminContentSectionHeader(
                      title: "Testimonials",
                      icon: Icons.format_quote_rounded,
                      iconColor: const Color(0xffF59E0B),
                      subtitle: "Choose which roles see each testimonial.",
                      buttonLabel: "New Testimonial",
                      onPressed: _showTestimonialDialog,
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingTestimonials)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                    else if (_testimonialsList.isEmpty)
                      adminEmptyState(Icons.reviews_outlined, "No testimonials added yet.", subMessage: "Add one using the button above.")
                    else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _testimonialsList.length > 3 ? 3 : _testimonialsList.length,
                        itemBuilder: (context, index) {
                          final t = _testimonialsList[index];
                          final int rating = int.tryParse(t['rating']?.toString() ?? '5') ?? 5;
                          final List<dynamic> tRoles = t['target_roles'] is List ? t['target_roles'] : (t['target_roles']?.toString().split(',') ?? ["All"]);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 1,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(radius: 22, backgroundColor: _AdminTheme.primaryLight, child: Text((t['name'] ?? "?")[0].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: _AdminTheme.primary))),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        Text(t['role'] ?? "", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                        const SizedBox(height: 6),
                                        Row(children: List.generate(5, (i) => Icon(i < rating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xffF59E0B), size: 16))),
                                        const SizedBox(height: 8),
                                        Text(t['message'] ?? "", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: tRoles.map<Widget>((role) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(color: _AdminTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                                              child: Text(role.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _AdminTheme.primary)),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(tooltip: "Remove Testimonial", onPressed: () => _deleteTestimonial(t['id']), icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22), visualDensity: VisualDensity.compact),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (_testimonialsList.length > 3)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllTestimonialsScreen(testimonials: _testimonialsList, themeColor: const Color(0xffF59E0B))));
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: Text("View All Testimonials (${_testimonialsList.length})", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffF59E0B))),
                          ),
                        ),
                    ],
                    adminSectionDivider(),
                    adminContentSectionHeader(
                      title: "FAQs",
                      icon: Icons.help_rounded,
                      iconColor: const Color(0xff10B981),
                      subtitle: "Choose which roles see each FAQ.",
                      buttonLabel: "New FAQ",
                      onPressed: _showFaqDialog,
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingFaqs)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                    else if (_faqsList.isEmpty)
                      adminEmptyState(Icons.quiz_outlined, "No FAQs added yet.", subMessage: "Add one using the button above.")
                    else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _faqsList.length > 3 ? 3 : _faqsList.length,
                        itemBuilder: (context, index) {
                          final faq = _faqsList[index];
                          final List<dynamic> fRoles = faq['target_roles'] is List ? faq['target_roles'] : (faq['target_roles']?.toString().split(',') ?? ["All"]);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 1,
                            color: Colors.white,
                            child: ExpansionTile(
                              leading: const Icon(Icons.help_outline, color: _AdminTheme.primary),
                              title: Text(faq['question'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              trailing: IconButton(tooltip: "Remove FAQ", onPressed: () => _deleteFaq(faq['id']), icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20), visualDensity: VisualDensity.compact),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Align(alignment: Alignment.centerLeft, child: Text(faq['answer'] ?? "", style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: fRoles.map<Widget>((role) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(color: _AdminTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                                            child: Text(role.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _AdminTheme.primary)),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (_faqsList.length > 3)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllFaqsScreen(faqs: _faqsList, themeColor: const Color(0xff10B981))));
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: Text("View All FAQs (${_faqsList.length})", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff10B981))),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Kits and orders Screen Start

class KitsOrdersScreen extends StatefulWidget {
  const KitsOrdersScreen({super.key});

  @override
  State<KitsOrdersScreen> createState() => _KitsOrdersScreenState();
}

class _KitsOrdersScreenState extends State<KitsOrdersScreen> {
  bool _isLoadingKits = false;
  bool _isLoadingOrders = false;
  List<dynamic> _kitsList = [];
  List<dynamic> _ordersList = [];
  Timer? _timer;

  String _roleFilter = "All";
  String _statusFilter = "All";
  String _timeFilter = "All";
  String _sortOrder = "Newest";

  @override
  void initState() {
    super.initState();
    _fetchKits();
    _fetchOrders();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchKits(silent: true);
      _fetchOrders(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchKits({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingKits = true);
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_kits.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) setState(() => _kitsList = data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching kits: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoadingKits = false);
    }
  }

  Future<void> _addOrUpdateKit(String level, double price) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_kit_type.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"level": level, "price": price}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Kit catalog updated successfully!", false);
        _fetchKits();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to save kit", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _fetchOrders({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingOrders = true);
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_kit_orders.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) setState(() => _ordersList = data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoadingOrders = false);
    }
  }

  Future<void> _updateOrderStatus(int orderId, String nextStatus) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/update_order_status.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"order_id": orderId, "status": nextStatus}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Order #$orderId marked as $nextStatus!", false);
        _fetchOrders();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to update status", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  Future<void> _markAsPaid(int orderId) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/mark_order_paid.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"order_id": orderId}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Order #$orderId marked as Paid!", false);
        _fetchOrders();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to mark as paid", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  DateTime? _parseOrderDate(dynamic order) {
    final raw = order['created_at'] ?? order['order_date'] ?? order['date'];
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  String _formatOrderDateTime(dynamic order) {
    final dt = _parseOrderDate(order);
    if (dt == null) return "Date unavailable";
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? "PM" : "AM";
    final min = dt.minute.toString().padLeft(2, '0');
    return "${dt.day} ${months[dt.month - 1]} ${dt.year} • $hour12:$min $ampm";
  }

  // ---- NEW: KPI calculations ----
  double get _totalSaleAmount {
    double sum = 0;
    for (final o in _ordersList) {
      sum += double.tryParse(o['total_amount'].toString()) ?? 0;
    }
    return sum;
  }

  double get _totalPendingAmount {
    double sum = 0;
    for (final o in _ordersList) {
      if ((o['payment_status'] ?? "Unpaid") != "Paid") {
        sum += double.tryParse(o['total_amount'].toString()) ?? 0;
      }
    }
    return sum;
  }

  int get _pendingOrdersCount {
    return _ordersList.where((o) => (o['payment_status'] ?? "Unpaid") != "Paid").length;
  }

  List<dynamic> get _filteredSortedOrders {
    var list = List<dynamic>.from(_ordersList);

    if (_roleFilter != "All") {
      list = list.where((o) => (o['buyer_role'] ?? "").toString() == _roleFilter).toList();
    }

    if (_statusFilter != "All") {
      list = list.where((o) => (o['delivery_status'] ?? "Pending").toString() == _statusFilter).toList();
    }

    if (_timeFilter != "All") {
      final now = DateTime.now();
      final cutoff = _timeFilter == "Last 7 Days" ? now.subtract(const Duration(days: 7)) : now.subtract(const Duration(days: 30));
      list = list.where((o) {
        final dt = _parseOrderDate(o);
        return dt != null && dt.isAfter(cutoff);
      }).toList();
    }

    // Sort
    list.sort((a, b) {
      final da = _parseOrderDate(a);
      final db = _parseOrderDate(b);
      if (da == null || db == null) return 0;
      return _sortOrder == "Newest" ? db.compareTo(da) : da.compareTo(db);
    });

    return list;
  }

  void _showKitCatalogDialog() {
    final levelCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Manage Kit Pricing", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: levelCtrl, decoration: const InputDecoration(hintText: "e.g. Level 1, Level 5")),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "e.g. 1500")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
            onPressed: () {
              final lvl = levelCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text) ?? 0.0;
              if (lvl.isEmpty || price <= 0) {
                adminShowSnack(ctx, "Please enter valid Level and Price parameters", true);
                return;
              }
              Navigator.pop(ctx);
              _addOrUpdateKit(lvl, price);
            },
            child: const Text("Update Catalog"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteKit(dynamic kit) {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        bool canDelete = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("Delete ${kit['level']}?"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Are you sure you want to delete this kit? This action cannot be undone.\n\nPlease type \"delete\" to confirm:"),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textCtrl,
                    decoration: const InputDecoration(
                      hintText: "delete",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        canDelete = val.toLowerCase().trim() == "delete";
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: canDelete
                      ? () {
                    Navigator.pop(ctx);
                    _deleteKit(kit['id']);
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.grey.shade200,
                  ),
                  child: const Text("Delete", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteKit(dynamic kitId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff16C74A))),
    );

    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/delete_kit.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"kit_id": kitId}),
      );

      if (mounted) Navigator.pop(context); // close loader

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          adminShowSnack(context, "Kit deleted successfully!", false);
          _fetchKits();
        } else {
          adminShowSnack(context, data['message'] ?? "Deletion failed", true);
        }
      } else {
        adminShowSnack(context, "Server error", true);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      adminShowSnack(context, "Error: $e", true);
    }
  }

  Widget _orderFilterChip(String label, String current, List<String> options, void Function(String) onSelect) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelect,
      itemBuilder: (ctx) => options.map((o) => PopupMenuItem(value: o, child: Text(o))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: current == "All" ? Colors.white : _AdminTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: current == "All" ? Colors.grey.shade200 : _AdminTheme.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$label: $current", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: current == "All" ? Colors.grey.shade700 : _AdminTheme.primary)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: current == "All" ? Colors.grey.shade500 : _AdminTheme.primary),
          ],
        ),
      ),
    );
  }

  // ---- NEW: KPI card widget ----
  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff1E293B)),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          adminDetailHeader(
            context: context,
            title: "Kits & Orders",
            subtitle: "${_filteredSortedOrders.length} of ${_ordersList.length} orders • ${_kitsList.length} kit types",
            icon: Icons.inventory_2_outlined,
            colors: const [Color(0xff16C74A), Color(0xff059669)],
          ),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xff16C74A),
              onRefresh: () async {
                await _fetchKits();
                await _fetchOrders();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- NEW: Total Sale & Pending Payment KPI cards ----
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            title: "Total Sale",
                            value: "₹${_totalSaleAmount.toStringAsFixed(0)}",
                            subtitle: "${_ordersList.length} Orders",
                            color: const Color(0xff10B981),
                            icon: Icons.point_of_sale_rounded,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildKpiCard(
                            title: "Total Pending Payment",
                            value: "₹${_totalPendingAmount.toStringAsFixed(0)}",
                            subtitle: "$_pendingOrdersCount Orders",
                            color: Colors.orange,
                            icon: Icons.hourglass_bottom_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: const Color(0xffECFDF5), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.inventory_2_rounded, color: Color(0xff10B981), size: 20)),
                            const SizedBox(width: 10),
                            const Text("Kits Catalog & Pricing", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _showKitCatalogDialog,
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text("Add Kit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 34),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingKits)
                      const Center(child: CircularProgressIndicator())
                    else if (_kitsList.isEmpty)
                      Padding(padding: const EdgeInsets.only(bottom: 10), child: adminEmptyState(Icons.inventory_2_outlined, "No kits registered in catalog yet."))
                    else
                      Container(
                        height: 150,
                        margin: const EdgeInsets.only(bottom: 24),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _kitsList.length,
                          itemBuilder: (ctx, i) {
                            final kit = _kitsList[i];
                            return SizedBox(
                              width: 145,
                              child: Card(
                                margin: const EdgeInsets.only(right: 12, bottom: 4),
                                elevation: 1,
                                shadowColor: Colors.black.withOpacity(0.04),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(color: const Color(0xffECFDF5), borderRadius: BorderRadius.circular(8)),
                                            child: const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xff10B981)),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                            onPressed: () => _confirmDeleteKit(kit),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            splashRadius: 16,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(kit['level'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text("₹${kit['price']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff10B981), fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: _AdminTheme.primaryLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt_long_rounded, color: _AdminTheme.primary, size: 20)),
                        const SizedBox(width: 12),
                        const Text("Kit Purchase Orders", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 34,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _orderFilterChip("Role", _roleFilter, ["All", "School", "Franchise Partner", "Distributor"], (v) => setState(() => _roleFilter = v)),
                          const SizedBox(width: 8),
                          _orderFilterChip("Status", _statusFilter, ["All", "Pending", "Shipped", "Delivered", "Cancelled"], (v) => setState(() => _statusFilter = v)),
                          const SizedBox(width: 8),
                          _orderFilterChip("Time", _timeFilter, ["All", "Last 7 Days", "Last 30 Days"], (v) => setState(() => _timeFilter = v)),
                          const SizedBox(width: 8),
                          _orderFilterChip("Sort", _sortOrder, ["Newest", "Oldest"], (v) => setState(() => _sortOrder = v)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingOrders)
                      const Center(child: CircularProgressIndicator())
                    else if (_filteredSortedOrders.isEmpty)
                      adminEmptyState(Icons.receipt_long_outlined, "No orders match this filter.", subMessage: "Try changing role, status, or time filters.")
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredSortedOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredSortedOrders[index];
                          final String buyerName = order['buyer_name'] ?? "";
                          final String buyerRole = order['buyer_role'] ?? "";
                          final String deliveryStatus = order['delivery_status'] ?? "Pending";
                          final String paymentStatus = order['payment_status'] ?? "Unpaid";
                          final bool isPaid = paymentStatus == "Paid";
                          Color statusColor = Colors.orange;
                          if (deliveryStatus == 'Approved') statusColor = Colors.teal;
                          if (deliveryStatus == 'Shipped') statusColor = Colors.blue;
                          if (deliveryStatus == 'Delivered') statusColor = Colors.green;
                          if (deliveryStatus == 'Cancelled') statusColor = Colors.red;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            elevation: 1,
                            shadowColor: Colors.black.withOpacity(0.04),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Order #${order['order_id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                            child: Text(deliveryStatus, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(color: isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                            child: Text(paymentStatus, style: TextStyle(color: isPaid ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 11)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade400),
                                      const SizedBox(width: 4),
                                      Text(_formatOrderDateTime(order), style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.person_outline, size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(buyerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            Text("Role: $buyerRole • Phone: ${order['buyer_phone']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Item: ${order['kit_level']} (Qty: ${order['quantity']})", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                            Text("Purchase price: ₹${order['price_at_purchase']} • Total: ₹${order['total_amount']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (!isPaid)
                                        OutlinedButton.icon(
                                          onPressed: () => _markAsPaid(order['order_id']),
                                          icon: const Icon(Icons.payments_outlined, size: 15, color: Colors.green),
                                          label: const Text("Mark as Paid", style: TextStyle(fontSize: 12, color: Colors.green)),
                                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                        ),
                                      const SizedBox(width: 10),
                                      const Text("Shipping:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      const SizedBox(width: 8),
                                      PopupMenuButton<String>(
                                        onSelected: (value) => _updateOrderStatus(order['order_id'], value),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        offset: const Offset(0, 40),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(value: "Shipped", child: Row(children: const [Icon(Icons.local_shipping, color: Colors.blue, size: 18), SizedBox(width: 8), Text("Ship")])),
                                          PopupMenuItem(value: "Delivered", child: Row(children: const [Icon(Icons.check_circle, color: Colors.green, size: 18), SizedBox(width: 8), Text("Deliver")])),
                                          PopupMenuItem(value: "Cancelled", child: Row(children: const [Icon(Icons.cancel, color: Colors.red, size: 18), SizedBox(width: 8), Text("Cancel")])),
                                        ],
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(color: _AdminTheme.primary, borderRadius: BorderRadius.circular(10)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                                              SizedBox(width: 6),
                                              Text("Update", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                              SizedBox(width: 4),
                                              Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
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
        ],
      ),
    );
  }
}

// ============================================================
//  MLM & COMMISSIONS MANAGER SCREEN
// ============================================================
class MlmCommissionsScreen extends StatefulWidget {
  const MlmCommissionsScreen({super.key});

  @override
  State<MlmCommissionsScreen> createState() => _MlmCommissionsScreenState();
}

class _MlmCommissionsScreenState extends State<MlmCommissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _isLoading = false;
  
  // Tab 1: Analytics
  List<dynamic> _allUsersForAnalytics = [];

  // Tab 2: Payout Manager
  final Set<int> _selectedReleaseUserIds = {};
  bool _isReleasing = false;

  // Tab 3: Settings & Wallets
  String _commType = 'global';
  final _globalPercentCtrl = TextEditingController(text: '5');
  final Map<String, TextEditingController> _levelCtrls = {
    for (var l in [1,2,3,4,5,6,7,8]) "Level $l": TextEditingController(text: '${l + 4}')
  };
  List<dynamic> _wallets = [];
  List<dynamic> _txs = [];

  // Tab 4: MLM Directory (Distributors & Agents tree)
  List<dynamic> _distributors = [];

  // Tab 5: MLM Orders
  List<dynamic> _orders = [];
  String _selectedStatus = "All";
  final List<String> _statuses = ["All", "Pending", "Paid", "Shipped", "Delivered", "Cancelled"];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    _fetchSettings();
    _fetchWallets();
    _fetchDistributors();
    _fetchMLMOrders();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _globalPercentCtrl.dispose();
    for (var ctrl in _levelCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchSettings() async {
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_commission_settings.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['settings'] != null) {
          final s = data['settings'];
          setState(() {
            _commType = s['commission_type'] ?? 'per_kit';
            if (s['per_kit_commission'] != null) {
              _globalPercentCtrl.text = s['per_kit_commission'].toString();
            } else if (s['global_percent'] != null) {
              _globalPercentCtrl.text = s['global_percent'].toString();
            }
            for (var l in [1,2,3,4,5,6,7,8]) {
              final key = 'percent_Level $l';
              if (s[key] != null) {
                _levelCtrls["Level $l"]!.text = s[key].toString();
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching settings: $e");
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    final settingsMap = <String, String>{
      "commission_type": _commType,
      "per_kit_commission": _globalPercentCtrl.text,
      "global_percent": _globalPercentCtrl.text,
    };
    for (var l in [1,2,3,4,5,6,7,8]) {
      settingsMap["percent_Level $l"] = _levelCtrls["Level $l"]!.text;
    }

    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/update_commission_settings.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"settings": settingsMap}),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Settings updated successfully!", false);
        _fetchSettings();
      } else {
        adminShowSnack(context, data['message'] ?? "Save failed.", true);
      }
    } catch (e) {
      adminShowSnack(context, "Error: $e", true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _releaseCommissions(List<int> userIds) async {
    if (userIds.isEmpty) return;
    setState(() => _isReleasing = true);
    
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/release_commission.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_ids": userIds}),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, data['message'] ?? "Payouts released!", false);
        setState(() {
          _selectedReleaseUserIds.removeAll(userIds);
        });
        _fetchWallets();
      } else {
        adminShowSnack(context, data['message'] ?? "Payout failed.", true);
      }
    } catch (e) {
      adminShowSnack(context, "Error: $e", true);
    } finally {
      setState(() => _isReleasing = false);
    }
  }

  Future<void> _fetchWallets() async {
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_all_wallets.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _wallets = data['wallets'] ?? [];
            _txs = data['transactions'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching wallets: $e");
    }
  }

  Future<void> _fetchDistributors() async {
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_all_users.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final list = data['data'] as List? ?? [];
          setState(() {
            _allUsersForAnalytics = list;
            _distributors = list.where((u) => u['role'] == 'Distributor').toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching distributors: $e");
    }
  }

  Future<void> _fetchMLMOrders() async {
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_kit_orders.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final list = data['data'] as List? ?? [];
          setState(() {
            _orders = list.where((o) => o['order_type'] == 'MLM').toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching MLM orders: $e");
    }
  }

  Future<void> _markOrderAsPaid(int orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
    );
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/mark_order_paid.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"order_id": orderId}),
      );
      if (context.mounted) Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Order #$orderId marked as Paid & commissions calculated!", false);
        _fetchMLMOrders();
        _fetchWallets();
      } else {
        adminShowSnack(context, data['message'] ?? "Action failed", true);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      adminShowSnack(context, "Error: $e", true);
    }
  }

  Future<void> _updateDeliveryStatus(int orderId, String status) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
    );
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/update_order_status.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"order_id": orderId, "status": status}),
      );
      if (context.mounted) Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Order delivery status updated to $status!", false);
        _fetchMLMOrders();
        _fetchWallets();
      } else {
        adminShowSnack(context, data['message'] ?? "Action failed", true);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      adminShowSnack(context, "Error: $e", true);
    }
  }

  void _viewDistributorAgents(dynamic dist) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
    );

    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/distributor/get_agents.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"distributor_id": dist['id']}),
      );
      if (context.mounted) Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        final agentsList = data['agents'] as List? ?? [];
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => Container(
              height: MediaQuery.of(ctx).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${dist['name']}'s Linear Agents", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: agentsList.isEmpty
                        ? const Center(child: Text("No agents recruited under this distributor.", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: agentsList.length,
                            itemBuilder: (context, idx) {
                              final ag = agentsList[idx];
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.orange.shade50,
                                    child: const Icon(Icons.person, color: Colors.orange),
                                  ),
                                  title: Text(ag['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("Level ${ag['level']} • Phone: ${ag['phone']}\nStatus: ${ag['status']}"),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.lock_reset, color: Colors.grey),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _openResetPasswordAdmin(ag);
                                    },
                                    tooltip: "Reset Password",
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
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      adminShowSnack(context, "Error: $e", true);
    }
  }

  void _openResetPasswordAdmin(dynamic user) {
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Reset Password for ${user['name']}"),
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
                builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
              );

              try {
                // We reuse the distributor agent reset API since it updates by agent ID
                final res = await http.post(
                  Uri.parse("https://apps.kofalt.in/api/distributor/reset_password.php"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "agent_id": user['id'],
                    "password": passCtrl.text,
                  }),
                );
                if (context.mounted) Navigator.pop(context);
                final data = jsonDecode(res.body);
                if (data['status'] == 'success') {
                  adminShowSnack(context, "Password reset successfully!", false);
                } else {
                  adminShowSnack(context, data['message'] ?? "Reset failed", true);
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context);
                adminShowSnack(context, "Error: $e", true);
              }
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatusAdmin(dynamic user) async {
    final nextStatus = user['status'] == 'Active' ? 'Suspended' : 'Active';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
    );

    try {
      final res = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/toggle_user_status.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": user['id'],
          "status": nextStatus,
        }),
      );
      if (context.mounted) Navigator.pop(context);
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "User marked as $nextStatus successfully!", false);
        _fetchDistributors();
      } else {
        adminShowSnack(context, data['message'] ?? "Update failed", true);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      adminShowSnack(context, "Error: $e", true);
    }
  }

  List<dynamic> get _filteredOrders {
    if (_selectedStatus == "All") return _orders;
    return _orders.where((o) {
      if (_selectedStatus == "Paid") return o['payment_status'] == "Paid";
      return o['delivery_status'] == _selectedStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF1F5F9),
      appBar: AppBar(
        title: const Text("MLM & Commissions Manager", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: _AdminTheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "MLM Analytics"),
            Tab(text: "Payout Manager"),
            Tab(text: "Config Settings"),
            Tab(text: "Distributors"),
            Tab(text: "MLM Orders"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // TAB 1: MLM ANALYTICS
          RefreshIndicator(
            onRefresh: () async {
              await _fetchDistributors();
              await _fetchMLMOrders();
              await _fetchWallets();
            },
            child: _buildAnalyticsTab(),
          ),

          // TAB 2: PAYOUT MANAGER
          _buildPayoutManagerTab(),

          // TAB 3: CONFIG SETTINGS
          RefreshIndicator(
            onRefresh: () async {
              await _fetchSettings();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Commission Configuration Settings", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _AdminTheme.primary)),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _globalPercentCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Per Kit Commission (₹)",
                            prefixText: "₹",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary),
                            onPressed: _saveSettings,
                            child: const Text("Save Config Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TAB 4: DISTRIBUTORS LIST
          RefreshIndicator(
            onRefresh: _fetchDistributors,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _distributors.length,
              itemBuilder: (context, index) {
                final dist = _distributors[index];
                final isSuspended = dist['status'] == 'Suspended';
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSuspended ? Colors.red.shade50 : const Color(0xffEFF6FF),
                      child: Icon(Icons.business, color: isSuspended ? Colors.red : _AdminTheme.primary),
                    ),
                    title: Text(dist['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Phone: ${dist['phone']}\nStatus: ${dist['status']}"),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'agents') _viewDistributorAgents(dist);
                        if (val == 'reset') _openResetPasswordAdmin(dist);
                        if (val == 'toggle') _toggleUserStatusAdmin(dist);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'agents', child: Text("View Agents Chain")),
                        const PopupMenuItem(value: 'reset', child: Text("Reset Password")),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(isSuspended ? "Activate User" : "Suspend User", style: TextStyle(color: isSuspended ? Colors.green : Colors.red)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // TAB 5: MLM ORDERS
          Column(
            children: [
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _statuses.length,
                  itemBuilder: (context, index) {
                    final st = _statuses[index];
                    final isSel = _selectedStatus == st;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(st),
                        selected: isSel,
                        selectedColor: _AdminTheme.primary,
                        labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedStatus = st);
                        },
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchMLMOrders,
                  child: _filteredOrders.isEmpty
                      ? const Center(child: Text("No MLM orders found.", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final o = _filteredOrders[index];
                            final isPaid = o['payment_status'] == 'Paid';
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Order #${o['order_id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            isPaid ? "Paid" : "Pending Payment",
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
                                    Text("School: ${o['school_name'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 3),
                                    Text("Address: ${o['school_address'] ?? 'N/A'}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    const SizedBox(height: 3),
                                    Text("Contact: ${o['contact_person'] ?? 'N/A'} (${o['mobile_number'] ?? 'N/A'})", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    Text("Kit Level: ${o['kit_level'] ?? o['level'] ?? 'N/A'} x ${o['quantity']}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Agent: ${o['buyer_name'] ?? 'N/A'}", style: const TextStyle(fontSize: 12, color: Colors.blue)),
                                            Text("Delivery Status: ${o['delivery_status']}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                          ],
                                        ),
                                        Text("₹${o['total_amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (!isPaid)
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                            onPressed: () => _markOrderAsPaid(int.parse(o['order_id'].toString())),
                                            child: const Text("Verify Payment", style: TextStyle(color: Colors.white)),
                                          ),
                                        const SizedBox(width: 8),
                                        PopupMenuButton<String>(
                                          onSelected: (status) => _updateDeliveryStatus(int.parse(o['order_id'].toString()), status),
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(value: "Pending", child: Text("Mark Pending")),
                                            const PopupMenuItem(value: "Shipped", child: Text("Mark Shipped")),
                                            const PopupMenuItem(value: "Delivered", child: Text("Mark Delivered")),
                                            const PopupMenuItem(value: "Cancelled", child: Text("Mark Cancelled")),
                                          ],
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                                            child: const Row(
                                              children: [
                                                Text("Update Delivery"),
                                                Icon(Icons.arrow_drop_down),
                                              ],
                                            ),
                                          ),
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
        ],
      ),
    );
  }

  double get _totalMlmSalesAmount {
    double total = 0.0;
    for (var o in _orders) {
      if (o['payment_status'] == 'Paid') {
        total += double.tryParse(o['total_amount'].toString()) ?? 0.0;
      }
    }
    return total;
  }

  double get _totalCommissionsAmount {
    double total = 0.0;
    for (var tx in _txs) {
      total += double.tryParse(tx['amount'].toString()) ?? 0.0;
    }
    return total;
  }

  double get _totalWalletBalance {
    double total = 0.0;
    for (var w in _wallets) {
      total += double.tryParse(w['balance'].toString()) ?? 0.0;
    }
    return total;
  }

  Widget _buildAnalyticsTab() {
    final int totalDists = _distributors.length;
    final int totalAgents = _allUsersForAnalytics.where((u) => u['role'] == 'Agent').length;
    final int totalUsersCount = totalDists + totalAgents;
    
    final double distPercent = totalUsersCount > 0 ? (totalDists / totalUsersCount) : 0.0;
    final double agentPercent = totalUsersCount > 0 ? (totalAgents / totalUsersCount) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: "Total MLM Sales",
                  value: "₹${_totalMlmSalesAmount.toStringAsFixed(0)}",
                  subtitle: "${_orders.where((o) => o['payment_status'] == 'Paid').length} Orders Paid",
                  color: Colors.green,
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildKpiCard(
                  title: "Commissions Paid",
                  value: "₹${_totalCommissionsAmount.toStringAsFixed(0)}",
                  subtitle: "${_txs.length} Payouts",
                  color: Colors.pink,
                  icon: Icons.trending_up_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildKpiCard(
            title: "Total Wallet Balances",
            value: "₹${_totalWalletBalance.toStringAsFixed(2)}",
            subtitle: "Held in user network wallets",
            color: Colors.blue,
            icon: Icons.account_balance_wallet_outlined,
            isWide: true,
          ),
          const SizedBox(height: 25),

          // Network composition visualization
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
                const Text("MLM Network Composition", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
                const SizedBox(height: 15),
                // Horizontal Bar Chart
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        if (distPercent > 0)
                          Expanded(
                            flex: (distPercent * 100).round(),
                            child: Container(color: const Color(0xff8B5CF6)),
                          ),
                        if (agentPercent > 0)
                          Expanded(
                            flex: (agentPercent * 100).round(),
                            child: Container(color: const Color(0xffFF6D00)),
                          ),
                        if (totalUsersCount == 0)
                          Expanded(child: Container(color: Colors.grey.shade200)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLegendItem(label: "Distributors ($totalDists)", percent: distPercent, color: const Color(0xff8B5CF6)),
                    _buildLegendItem(label: "Agents ($totalAgents)", percent: agentPercent, color: const Color(0xffFF6D00)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // MLM Graph Visualizer Section
          const Text("MLM Network Tree Tracker", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
          const SizedBox(height: 10),
          _distributors.isEmpty
              ? const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No distributors available to build trees.", style: TextStyle(color: Colors.grey)))))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _distributors.length,
                  itemBuilder: (context, index) {
                    final d = _distributors[index];
                    return _MlmTreeTrackerTile(distributor: d);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPayoutManagerTab() {
    final eligibleUsers = _wallets.where((w) => (double.tryParse(w['balance']?.toString() ?? '0') ?? 0.0) > 0).toList();
    final allSelected = eligibleUsers.isNotEmpty && eligibleUsers.every((w) => _selectedReleaseUserIds.contains(int.tryParse(w['id']?.toString() ?? '')));
    
    return Column(
      children: [
        // Bulk Actions Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Checkbox(
                value: allSelected,
                activeColor: _AdminTheme.primary,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      for (var w in eligibleUsers) {
                        final id = int.tryParse(w['id']?.toString() ?? '');
                        if (id != null) _selectedReleaseUserIds.add(id);
                      }
                    } else {
                      _selectedReleaseUserIds.clear();
                    }
                  });
                },
              ),
              const Text("Select All Payouts", style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                icon: const Icon(Icons.payments, color: Colors.white),
                label: Text("Release Selected (${_selectedReleaseUserIds.length})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: _selectedReleaseUserIds.isEmpty || _isReleasing
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Confirm Release"),
                            content: Text("Are you sure you want to release payouts for ${_selectedReleaseUserIds.length} users? This will transfer their balances and reset their wallets to ₹0."),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _releaseCommissions(_selectedReleaseUserIds.toList());
                                },
                                child: const Text("Confirm"),
                              ),
                            ],
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
        
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchWallets,
            child: _wallets.isEmpty
                ? const Center(child: Text("No MLM wallets found.", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _wallets.length,
                    itemBuilder: (context, idx) {
                      final w = _wallets[idx];
                      final uid = int.tryParse(w['id']?.toString() ?? '') ?? 0;
                      final bal = double.tryParse(w['balance']?.toString() ?? '0') ?? 0.0;
                      final earned = double.tryParse(w['total_earned']?.toString() ?? '0') ?? 0.0;
                      final isSelected = _selectedReleaseUserIds.contains(uid);
                      
                      final hasBank = w['bank_name'] != null && w['bank_name'].toString().trim().isNotEmpty;
                      
                      // Find order-wise commissions for this user
                      final userTxs = _txs.where((tx) => int.tryParse(tx['recipient_id']?.toString() ?? '') == uid).toList();
                      
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: Checkbox(
                            value: isSelected,
                            activeColor: _AdminTheme.primary,
                            onChanged: bal <= 0
                                ? null
                                : (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedReleaseUserIds.add(uid);
                                      } else {
                                        _selectedReleaseUserIds.remove(uid);
                                      }
                                    });
                                  },
                          ),
                          title: Row(
                            children: [
                              Text(w['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (w['role'] == 'Distributor' ? Colors.blue : Colors.orange).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  w['role'] ?? "",
                                  style: TextStyle(
                                    color: w['role'] == 'Distributor' ? Colors.blue : Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Email: ${w['email']} • Phone: ${w['phone']}", style: const TextStyle(fontSize: 12)),
                              if (w['parent_distributor_name'] != null)
                                Text("Distributor: ${w['parent_distributor_name']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text("Wallet: ₹${bal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
                                  const SizedBox(width: 12),
                                  Text("Total Earned: ₹${earned.toStringAsFixed(2)}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                          trailing: bal <= 0
                              ? const Icon(Icons.keyboard_arrow_down)
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                  onPressed: _isReleasing
                                      ? null
                                      : () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text("Confirm Release"),
                                              content: Text("Release payout of ₹${bal.toStringAsFixed(2)} for ${w['name']}?"),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                                  onPressed: () {
                                                    Navigator.pop(ctx);
                                                    _releaseCommissions([uid]);
                                                  },
                                                  child: const Text("Confirm"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                  child: const Text("Release", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const Text("Bank Payout Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                  const SizedBox(height: 8),
                                  if (hasBank) ...[
                                    Text("Account Holder: ${w['account_holder_name']}", style: const TextStyle(fontSize: 13)),
                                    Text("Bank Name: ${w['bank_name']}", style: const TextStyle(fontSize: 13)),
                                    Text("Account Number: ${w['account_number']}", style: const TextStyle(fontSize: 13)),
                                    Text("IFSC Code: ${w['ifsc_code']}", style: const TextStyle(fontSize: 13)),
                                  ] else
                                    const Text("Bank Details: Not Added", style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold)),
                                  
                                  const SizedBox(height: 16),
                                  const Text("Commission Orders History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                  const SizedBox(height: 8),
                                  if (userTxs.isEmpty)
                                    const Text("No commission payouts recorded from orders yet.", style: TextStyle(fontSize: 12, color: Colors.grey))
                                  else
                                    Column(
                                      children: userTxs.map((tx) => Card(
                                        color: const Color(0xffF8FAFC),
                                        margin: const EdgeInsets.only(bottom: 6),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Order #${tx['order_id']} • Tier ${tx['tier_level']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                  Text("Agent: ${tx['trigger_name']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                                ],
                                              ),
                                              Text("₹${tx['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                                            ],
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    bool isWide = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon (left) + Title (beside icon)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E293B),
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required String label, required double percent, required Color color}) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(
          "$label (${(percent * 100).toStringAsFixed(1)}%)",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    );
  }
}

// ============================================================
//  MLM HIERARCHICAL TREE VISUAL TRACKER
// ============================================================
class _MlmTreeTrackerTile extends StatefulWidget {
  final dynamic distributor;
  const _MlmTreeTrackerTile({required this.distributor});

  @override
  State<_MlmTreeTrackerTile> createState() => _MlmTreeTrackerTileState();
}

class _MlmTreeTrackerTileState extends State<_MlmTreeTrackerTile> {
  bool _isExpanded = false;
  bool _isLoading = false;
  List<dynamic> _agents = [];
  double _distributorSales = 0.0;
  int _distributorKits = 0;

  Future<void> _fetchTree() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch agents chain
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/distributor/get_agents.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"distributor_id": widget.distributor['id']}),
      );
      
      // 2. Fetch distributor sales to show stats
      final salesRes = await http.post(
        Uri.parse("https://apps.kofalt.in/api/distributor/get_agent_sales.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"distributor_id": widget.distributor['id']}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _agents = data['agents'] ?? [];
          });
        }
      }

      if (salesRes.statusCode == 200) {
        final salesData = jsonDecode(salesRes.body);
        if (salesData['status'] == 'success') {
          setState(() {
            _distributorSales = (salesData['total_sales'] ?? 0.0).toDouble();
            _distributorKits = salesData['total_kits'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching MLM tree: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dist = widget.distributor;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.5,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xff8B5CF6).withOpacity(0.1),
              child: const Icon(Icons.business, color: Color(0xff8B5CF6)),
            ),
            title: Text(dist['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Distributor • ID: #${dist['id']}\nPhone: ${dist['phone']}"),
            isThreeLine: true,
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (_isExpanded && _agents.isEmpty) {
                    _fetchTree();
                  }
                });
              },
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            if (_isLoading)
              const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: Color(0xff8B5CF6))))
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Chain Sales: ₹${_distributorSales.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.green)),
                    Text("Total Kits: $_distributorKits Kits", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.orange)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Container(
                color: const Color(0xffF8FAFC),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Root Distributor Node
                    _buildTreeNode(
                      name: dist['name'],
                      role: "Level 1 Distributor",
                      phone: dist['phone'],
                      color: const Color(0xff8B5CF6),
                      isRoot: true,
                    ),
                    
                    if (_agents.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text("No agents recruited under this line.", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                      )
                    else
                      for (int idx = 0; idx < _agents.length; idx++) ...[
                        const Icon(Icons.arrow_downward, color: Colors.grey, size: 20),
                        _buildTreeNode(
                          name: _agents[idx]['name'],
                          role: "Level ${_agents[idx]['level']} Agent",
                          phone: _agents[idx]['phone'],
                          color: const Color(0xffFF6D00),
                          isRoot: false,
                        ),
                      ],
                  ],
                ),
              ),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildTreeNode({
    required String name,
    required String role,
    required String phone,
    required Color color,
    required bool isRoot,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 4)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 18,
            child: Icon(isRoot ? Icons.business : Icons.person_pin_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                Text(role, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
              ],
            ),
          ),
          Text(phone, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Admin Training Requests Screen
// ──────────────────────────────────────────────
class AdminTrainingRequestsScreen extends StatefulWidget {
  const AdminTrainingRequestsScreen({super.key});
  @override
  State<AdminTrainingRequestsScreen> createState() => _AdminTrainingRequestsScreenState();
}

class _AdminTrainingRequestsScreenState extends State<AdminTrainingRequestsScreen> {
  bool _isLoading = true;
  List<dynamic> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_training_requests.php"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success' && mounted) {
          setState(() => _requests = data['data'] ?? []);
        }
      }
    } catch (e) {
      debugPrint("Error fetching training requests: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scheduleTraining(int requestId, {required String date, required String time, required String meetingInfo}) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)));
    try {
      final res = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/schedule_training.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"request_id": requestId, "scheduled_date": date, "scheduled_time": time, "meeting_info": meetingInfo}),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        adminShowSnack(context, "Training scheduled successfully!", false);
        _fetchRequests();
      } else {
        adminShowSnack(context, data['message'] ?? "Failed to schedule", true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      adminShowSnack(context, "Network error: $e", true);
    }
  }

  void _showScheduleDialog(Map<String, dynamic> req) {
    final dateCtrl = TextEditingController(text: req['requested_date'] ?? '');
    final timeCtrl = TextEditingController(text: req['requested_time'] ?? '');
    final meetingCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Schedule Training", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Topic: ${req['topic']}", style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text("School ID: ${req['school_id']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              const SizedBox(height: 16),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: "Scheduled Date (YYYY-MM-DD)", prefixIcon: Icon(Icons.date_range))),
              const SizedBox(height: 8),
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Scheduled Time (e.g. 10:00 AM)", prefixIcon: Icon(Icons.access_time))),
              const SizedBox(height: 8),
              TextField(controller: meetingCtrl, decoration: const InputDecoration(labelText: "Meeting Link / Venue Info", prefixIcon: Icon(Icons.link))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _scheduleTraining(
                req['id'] as int,
                date: dateCtrl.text.trim(),
                time: timeCtrl.text.trim(),
                meetingInfo: meetingCtrl.text.trim(),
              );
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Scheduled': return const Color(0xff16C74A);
      case 'Completed': return Colors.blue;
      case 'Cancelled': return Colors.red;
      default: return const Color(0xffFF6B00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          adminDetailHeader(context: context, title: "Training Requests", subtitle: "${_requests.length} requests from schools", icon: Icons.calendar_today_outlined),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _AdminTheme.primary))
                : _requests.isEmpty
                    ? adminEmptyState(Icons.calendar_today_outlined, "No training requests yet.", subMessage: "Schools will submit their training requests here.")
                    : RefreshIndicator(
                        color: _AdminTheme.primary,
                        onRefresh: _fetchRequests,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            final req = _requests[index];
                            final status = req['status'] ?? 'Pending';
                            final color = _statusColor(status);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 1,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(req['topic'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
                                          child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text("School ID: ${req['school_id']} • ${req['school_name'] ?? ''}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    if ((req['notes'] ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text("Notes: ${req['notes']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    ],
                                    if ((req['requested_date'] ?? '').isNotEmpty)
                                      Text("Preferred: ${req['requested_date']} ${req['requested_time'] ?? ''}".trim(), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    if (status == 'Scheduled') ...[
                                      const SizedBox(height: 4),
                                      Text("Scheduled: ${req['scheduled_date']} ${req['scheduled_time'] ?? ''}".trim(), style: const TextStyle(color: Color(0xff16C74A), fontWeight: FontWeight.w600, fontSize: 13)),
                                      if ((req['meeting_info'] ?? '').isNotEmpty)
                                        Text("Meeting: ${req['meeting_info']}", style: const TextStyle(color: Color(0xff2563EB), fontSize: 12)),
                                    ],
                                    if (status == 'Pending') ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _showScheduleDialog(req),
                                          icon: const Icon(Icons.calendar_month, size: 16),
                                          label: const Text("Schedule Training"),
                                          style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        ),
                                      ),
                                    ],
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