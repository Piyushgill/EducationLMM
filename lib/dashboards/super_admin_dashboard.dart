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
                'assets/image/kofalt-global-title-logo.png',
                height: 38,
                fit: BoxFit.contain,
              ),
              Spacer(),
              Stack(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                  ),
                  Positioned(right: 10, top: 10, child: Container(height: 10, width: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
                ],
              ),
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
                                    Text("• ${user['phone']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
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
                            const SizedBox(height: 2),
                            Text(user['phone'] ?? "", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text("KYC: $status", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(tooltip: "Login As User", onPressed: () => _loginAsUser(user), icon: Icon(Icons.login_rounded, color: widget.color, size: 22), visualDensity: VisualDensity.compact),
                      PopupMenuButton<String>(
                        tooltip: "Update KYC Status",
                        icon: Icon(Icons.fact_check_outlined, color: statusColor, size: 20),
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
  List<dynamic> _coursesList = [];
  List<dynamic> _videosList = [];
  List<dynamic> _testimonialsList = [];
  List<dynamic> _faqsList = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
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
                    adminContentSectionHeader(title: "Course Catalogs", icon: Icons.menu_book_rounded, iconColor: _AdminTheme.primary, buttonLabel: "New Course", onPressed: _showCourseDialog),
                    const SizedBox(height: 12),
                    if (_isLoadingCourses)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                    else if (_coursesList.isEmpty)
                      adminEmptyState(Icons.menu_book_outlined, "No courses registered yet.", subMessage: "Add a course using the button above.")
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _coursesList.length,
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
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _videosList.length,
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
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _testimonialsList.length,
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
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _faqsList.length,
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
                            return Card(
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
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: const Color(0xffECFDF5), borderRadius: BorderRadius.circular(8)),
                                      child: const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xff10B981)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(kit['level'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text("₹${kit['price']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff10B981), fontSize: 16)),
                                  ],
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
                          _orderFilterChip("Status", _statusFilter, ["All", "Pending", "Approved", "Shipped", "Delivered", "Cancelled"], (v) => setState(() => _statusFilter = v)),
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
                                          PopupMenuItem(value: "Approved", child: Row(children: const [Icon(Icons.thumb_up_alt_outlined, color: Colors.teal, size: 18), SizedBox(width: 8), Text("Approve")])),
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