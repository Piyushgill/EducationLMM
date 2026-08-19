import 'package:flutter/material.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/login_screen.dart';
import 'package:thenew/Screens/EducationHomeScreen.dart';
import 'package:thenew/Screens/ourprogramsmain.dart';
import 'package:thenew/Screens/profilescreen.dart';
import 'package:thenew/widgets/notification_bell.dart';

// ── Agent Theme Colors ──
class _AgentTheme {
  static const Color primary = Color(0xffF97316);     // Orange 500
  static const Color primaryDark = Color(0xffEA580C); // Orange 600
  static const Color primaryLight = Color(0xffFFEDD5); // Orange 100
  static const Color accent = Color(0xffF59E0B);      // Amber 500
}

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _AgentHomeTab(),
    const _AgentPlaceOrderTab(),
    const _AgentOrdersTab(),
    const _AgentWalletTab(),
    const AgentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _AgentTheme.primary,
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
            icon: Icon(Icons.add_shopping_cart_outlined),
            activeIcon: Icon(Icons.add_shopping_cart),
            label: "Place Order",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: "Orders",
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
//  AGENT HOME TAB
// ─────────────────────────────────────────────────────────────
class _AgentHomeTab extends StatefulWidget {
  const _AgentHomeTab();

  @override
  State<_AgentHomeTab> createState() => _AgentHomeTabState();
}

class _AgentHomeTabState extends State<_AgentHomeTab> {
  bool _isLoading = false;
  String _agentName = "";
  String _agentEmail = "";
  String _distributorName = "N/A";
  String _distributorPhone = "N/A";
  
  double _totalSales = 0.0;
  int _totalKits = 0;
  double _walletBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final agentId = session['id'];
        setState(() {
          _agentName = session['name'] ?? "";
          _agentEmail = session['email'] ?? "";
        });

        // Fetch sales details and distributor info
        final salesRes = await http.post(
          Uri.parse("https://apps.kofalt.in/api/distributor/get_agent_sales.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"agent_id": agentId}),
        );

        // Fetch parent relation (Distributor)
        final networkRes = await http.post(
          Uri.parse("https://apps.kofalt.in/api/agent/get_agent_distributor.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"agent_id": agentId}),
        );

        if (salesRes.statusCode == 200) {
          final data = jsonDecode(salesRes.body);
          if (data['status'] == 'success') {
            setState(() {
              _totalSales = (data['total_sales'] ?? 0.0).toDouble();
              _totalKits = data['total_kits'] ?? 0;
            });
          }
        }

        if (networkRes.statusCode == 200) {
          final netData = jsonDecode(networkRes.body);
          if (netData['status'] == 'success' && netData['distributor'] != null) {
            final dist = netData['distributor'];
            setState(() {
              _distributorName = dist['name'] ?? "";
              _distributorPhone = dist['phone'] ?? "";
            });
          }
        }

        // Fetch Wallet balance
        final walletRes = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_wallet_details.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": agentId}),
        );
        if (walletRes.statusCode == 200) {
          final wData = jsonDecode(walletRes.body);
          if (wData['status'] == 'success') {
            setState(() {
              _walletBalance = (wData['balance'] ?? 0.0).toDouble();
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading agent home: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
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

  void _showDistributorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.business_center, color: _AgentTheme.primary),
            SizedBox(width: 10),
            Text("Parent Distributor", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $_distributorName", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text("Phone: $_distributorPhone", style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: _AgentTheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_AgentTheme.primary, _AgentTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                            _agentName.isNotEmpty ? _agentName[0].toUpperCase() : "A",
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
                              _agentName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _agentEmail.isEmpty ? "Agent Account" : _agentEmail,
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
                                "AGENT",
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: .5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _drawerStatMini("Kits", "$_totalKits")),
                        Container(height: 26, width: 1, color: Colors.white24),
                        Expanded(child: _drawerStatMini("Sales", "₹${_totalSales.toStringAsFixed(0)}")),
                        Container(height: 26, width: 1, color: Colors.white24),
                        Expanded(child: _drawerStatMini("Wallet", "₹${_walletBalance.toStringAsFixed(0)}")),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //================ MENU ITEMS =================//
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 6),
                    child: Text("MAIN MENU",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade400, letterSpacing: 1.2)),
                  ),
                  _drawerAgentTile(
                    icon: Icons.home_outlined,
                    label: "Education Home Screen",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationLLMHomeScreen()));
                    },
                  ),
                  _drawerAgentTile(
                    icon: Icons.menu_book_outlined,
                    label: "Our Programs",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ourprogramsmainScreen()));
                    },
                  ),
                  _drawerAgentTile(
                    icon: Icons.person_outline,
                    label: "My Profile Card",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentProfileScreen()));
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Divider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 6),
                    child: Text("ACCOUNT",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade400, letterSpacing: 1.2)),
                  ),
                  _drawerAgentTile(
                    icon: Icons.logout_rounded,
                    label: "Logout",
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _confirmAndLogout(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Center(
                child: Text("Kofalt Global • Version 1.0.0",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerStatMini(String label, String value) => Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(.75), fontSize: 10)),
    ],
  );

  Widget _drawerAgentTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? Colors.grey.shade700;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Curved Header ──
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
                  colors: [_AgentTheme.primary, _AgentTheme.primaryDark],
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
                        'assets/image/kmain.png',
                        height: 54,
                        width: 145,        // 👈 jitna bada chahiye utna badha do
                        fit: BoxFit.fill,  // 👈 yahi "stretch" effect deta hai
                      ),
                      const Spacer(),
                      const NotificationBell(role: "Agent"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_agentName,
                        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Agent",
                        style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 16)),
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ──
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadDashboardData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dashboard Stats Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: .95,
                        children: [
                          _AgentDashboardCard(
                            title: "Kits Bought",
                            value: "$_totalKits",
                            icon: Icons.inventory_2_outlined,
                            iconColor: const Color(0xff2563EB),
                            onTap: () {},
                          ),
                          _AgentDashboardCard(
                            title: "Sales Volume",
                            value: "₹${_totalSales.toStringAsFixed(0)}",
                            icon: Icons.trending_up_rounded,
                            iconColor: const Color(0xff16C74A),
                            onTap: () {},
                          ),
                          _AgentDashboardCard(
                            title: "Wallet Balance",
                            value: "₹${_walletBalance.toStringAsFixed(0)}",
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: const Color(0xffA020F0),
                            onTap: () {},
                          ),
                          _AgentDashboardCard(
                            title: "My Distributor",
                            value: "View Details",
                            icon: Icons.business_center_outlined,
                            iconColor: const Color(0xffFF6B00),
                            onTap: _showDistributorDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LOCAL HELPER CLASSES ──
class _AgentDashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _AgentDashboardCard({
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
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: [iconColor, iconColor.withOpacity(.8)]),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const Spacer(),
            Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
          ],
        ),
      ),
    );
  }
}

class _VideoShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (_, __) => Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

class _TestimonialShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  final String label;
  const _SectionEmpty({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Center(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  AGENT PLACE ORDER TAB
// ─────────────────────────────────────────────────────────────
class _AgentPlaceOrderTab extends StatefulWidget {
  const _AgentPlaceOrderTab();

  @override
  State<_AgentPlaceOrderTab> createState() => _AgentPlaceOrderTabState();
}

class _AgentPlaceOrderTabState extends State<_AgentPlaceOrderTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  String _agentName = "";
  String _distributorName = "Fetching...";
  int _agentId = 0;

  final _schoolNameCtrl = TextEditingController();
  final _schoolAddressCtrl = TextEditingController();
  final _contactPersonCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  
  String _selectedKitLevel = "Level 1";
  int _quantity = 1;
  double _kitPrice = 1500.0;
  List<dynamic> _kitsList = [];

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
    _fetchKits();
  }

  @override
  void dispose() {
    _schoolNameCtrl.dispose();
    _schoolAddressCtrl.dispose();
    _contactPersonCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSessionInfo() async {
    final session = await SessionManager.getSession();
    if (session != null) {
      setState(() {
        _agentId = session['id'];
        _agentName = session['name'] ?? "";
      });

      // Fetch Distributor info
      try {
        final netRes = await http.post(
          Uri.parse("https://apps.kofalt.in/api/agent/get_agent_distributor.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"agent_id": _agentId}),
        );
        if (netRes.statusCode == 200) {
          final netData = jsonDecode(netRes.body);
          if (netData['status'] == 'success' && netData['distributor'] != null) {
            final dist = netData['distributor'];
            setState(() {
              _distributorName = dist['name'] ?? "";
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching parent distributor: $e");
      }
    }
  }

  Future<void> _fetchKits() async {
    try {
      final response = await http.get(Uri.parse("https://apps.kofalt.in/api/admin/get_kits.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final list = data['data'] as List;
          setState(() {
            _kitsList = list;
            if (_kitsList.isNotEmpty) {
              _selectedKitLevel = _kitsList[0]['level'] ?? "Level 1";
              _kitPrice = (_kitsList[0]['price'] as num).toDouble();
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching kits: $e");
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/place_order_mlm.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "buyer_id": _agentId,
          "level": _selectedKitLevel,
          "quantity": _quantity,
          "school_name": _schoolNameCtrl.text,
          "school_address": _schoolAddressCtrl.text,
          "contact_person": _contactPersonCtrl.text,
          "mobile_number": _mobileCtrl.text
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _schoolNameCtrl.clear();
        _schoolAddressCtrl.clear();
        _contactPersonCtrl.clear();
        _mobileCtrl.clear();
        setState(() {
          _quantity = 1;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("MLM Order placed & commission distributed successfully!"), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Order placement failed."), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = _kitPrice * _quantity;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text("Place Kit Order", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _AgentTheme.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _AgentTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prefilled fields
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF7ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xffFED7AA)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Agent Name:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffEA580C))),
                              Text(_agentName, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff1E293B))),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Distributor Name:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffEA580C))),
                              Text(_distributorName, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff1E293B))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text("School Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
                    const SizedBox(height: 10),
                    
                    TextFormField(
                      controller: _schoolNameCtrl,
                      decoration: InputDecoration(
                        labelText: "School Name",
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Please enter school name" : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _schoolAddressCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "School Address",
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Please enter school address" : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _contactPersonCtrl,
                      decoration: InputDecoration(
                        labelText: "Contact Person Name",
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Please enter contact person" : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _mobileCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Contact Mobile Number",
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.length != 10 ? "Please enter a valid 10-digit number" : null,
                    ),
                    const SizedBox(height: 20),

                    const Text("Order Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: _selectedKitLevel,
                      decoration: InputDecoration(
                        labelText: "Kit Level",
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _kitsList.isEmpty
                          ? [DropdownMenuItem(value: _selectedKitLevel, child: Text(_selectedKitLevel))]
                          : _kitsList.map((k) => DropdownMenuItem<String>(
                              value: k['level'].toString(),
                              child: Text("${k['level']} (₹${k['price']})")
                            )).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _selectedKitLevel = v;
                            final kit = _kitsList.firstWhere(
                              (k) => k['level'].toString() == v,
                              orElse: () => null,
                            );
                            if (kit != null) {
                              _kitPrice = (kit['price'] as num).toDouble();
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Quantity (Kits):", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(() => _quantity = (_quantity - 1).clamp(1, 100)),
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final inputCtrl = TextEditingController(text: _quantity.toString());
                                final newVal = await showDialog<int>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Text("Enter Quantity"),
                                    content: TextField(
                                      controller: inputCtrl,
                                      keyboardType: TextInputType.number,
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        labelText: "Quantity",
                                        hintText: "Enter number of kits",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                      ElevatedButton(
                                        onPressed: () {
                                          final val = int.tryParse(inputCtrl.text) ?? 1;
                                          Navigator.pop(ctx, val.clamp(1, 1000));
                                        },
                                        child: const Text("Confirm"),
                                      ),
                                    ],
                                  ),
                                );
                                if (newVal != null) {
                                  setState(() => _quantity = newVal);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text("$_quantity", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _quantity = _quantity + 1),
                              icon: const Icon(Icons.add_circle_outline, color: _AgentTheme.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("₹${totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _AgentTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _submitOrder,
                        child: const Text("Submit Order", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  AGENT ORDERS TAB
// ─────────────────────────────────────────────────────────────
class _AgentOrdersTab extends StatefulWidget {
  const _AgentOrdersTab();

  @override
  State<_AgentOrdersTab> createState() => _AgentOrdersTabState();
}

class _AgentOrdersTabState extends State<_AgentOrdersTab> {
  bool _isLoading = false;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final agentId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/distributor/get_agent_sales.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"agent_id": agentId}),
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
      debugPrint("Error loading orders: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text("My Placed Orders", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _AgentTheme.primary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _AgentTheme.primary))
            : _orders.isEmpty
                ? const Center(child: Text("No MLM orders found.", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final o = _orders[index];
                      final isApproved = o['payment_status'] == 'Paid';
                      
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 1,
                        shadowColor: Colors.black.withOpacity(0.04),
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
                                      color: isApproved ? Colors.green.shade50 : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isApproved ? "Approved / Paid" : "Pending",
                                      style: TextStyle(
                                        color: isApproved ? Colors.green : Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Text("School: ${o['school_name']}", style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff334155))),
                              const SizedBox(height: 5),
                              Text("Kit: ${o['kit_level']} x ${o['quantity']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Text("Earned Commission: ", style: TextStyle(fontSize: 13, color: Color(0xff475569))),
                                  Text(
                                    "₹${double.tryParse(o['commission_earned']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    o['created_at'] != null ? o['created_at'].toString().split(' ')[0] : "",
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                  ),
                                  Text(
                                    "₹${double.tryParse(o['total_amount'].toString())?.toStringAsFixed(2) ?? o['total_amount']}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff1E293B)),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  AGENT WALLET TAB
// ─────────────────────────────────────────────────────────────
class _AgentWalletTab extends StatefulWidget {
  const _AgentWalletTab();

  @override
  State<_AgentWalletTab> createState() => _AgentWalletTabState();
}

class _AgentWalletTabState extends State<_AgentWalletTab> {
  bool _isLoading = false;
  double _balance = 0.0;
  double _totalEarned = 0.0;
  List<dynamic> _txs = [];

  @override
  void initState() {
    super.initState();
    _fetchWallet();
  }

  Future<void> _fetchWallet() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final agentId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_wallet_details.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": agentId}),
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
      debugPrint("Error loading wallet: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text("My Earnings & Wallet", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _AgentTheme.primary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWallet,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _AgentTheme.primary))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wallet Balance Card
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
                                Icon(Icons.account_balance_wallet, color: _AgentTheme.primary, size: 24),
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
                                const Text("Total Earnings:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text("₹${_totalEarned.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text("Transaction Ledger", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
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
class AgentProfileScreen extends StatefulWidget {
  const AgentProfileScreen({super.key});

  @override
  State<AgentProfileScreen> createState() => _AgentProfileScreenState();
}

class _AgentProfileScreenState extends State<AgentProfileScreen> {
  static const Color primary = Color(0xffF97316);
  static const Color primaryDark = Color(0xffEA580C);

  String name = "Agent";
  String email = "";
  String phone = "";
  String role = "Agent";
  String kycStatus = "Pending";

  double totalSales = 0;
  int totalKits = 0;
  double walletBalance = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final session = await SessionManager.getSession();

      if (session == null) return;

      setState(() {
        name = session['name']?.toString() ?? "Agent";
        email = session['email']?.toString() ?? "";
        phone = session['phone']?.toString() ?? "";
        role = session['role']?.toString() ?? "Agent";
        kycStatus = session['kyc_status']?.toString() ?? "Pending";
      });

      final agentId = session['id'];

      // Sales
      final salesResponse = await http.post(
        Uri.parse(
          "https://apps.kofalt.in/api/distributor/get_agent_sales.php",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "agent_id": agentId,
        }),
      );

      if (salesResponse.statusCode == 200) {
        final data = jsonDecode(salesResponse.body);

        if (data['status'] == 'success') {
          totalSales =
              double.tryParse(
                data['total_sales'].toString(),
              ) ??
                  0;

          totalKits =
              int.tryParse(
                data['total_kits'].toString(),
              ) ??
                  0;
        }
      }

      // Wallet
      final walletResponse = await http.post(
        Uri.parse(
          "https://apps.kofalt.in/api/get_wallet_details.php",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": agentId,
        }),
      );

      if (walletResponse.statusCode == 200) {
        final data = jsonDecode(walletResponse.body);

        if (data['status'] == 'success') {
          walletBalance =
              double.tryParse(
                data['balance'].toString(),
              ) ??
                  0;
        }
      }
    } catch (e) {
      debugPrint("Agent profile error: $e");
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Color get kycColor {
    switch (kycStatus.toLowerCase()) {
      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  IconData get kycIcon {
    switch (kycStatus.toLowerCase()) {
      case "approved":
        return Icons.verified_rounded;

      case "rejected":
        return Icons.cancel_rounded;

      default:
        return Icons.pending_rounded;
    }
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure you want to logout?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await SessionManager.clearSession();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty
        ? name.trim()[0].toUpperCase()
        : "A";

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: primary,
          onRefresh: loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    34,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary,
                        primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          _headerButton(
                            Icons.arrow_back_ios_new_rounded,
                                () => Navigator.pop(context),
                          ),
                          const Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _headerButton(
                            Icons.settings_outlined,
                                () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // AVATAR
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        email.isEmpty
                            ? "Email not available"
                            : email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // STATS
                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(.07),
                            blurRadius: 14,
                            offset:
                            const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _stat(
                            Icons.trending_up_rounded,
                            "Sales",
                            "₹${totalSales.toStringAsFixed(0)}",
                          ),
                          _divider(),
                          _stat(
                            Icons.shopping_bag_outlined,
                            "Kits",
                            "$totalKits",
                          ),
                          _divider(),
                          _stat(
                            Icons.account_balance_wallet_outlined,
                            "Wallet",
                            "₹${walletBalance.toStringAsFixed(0)}",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    0,
                    18,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      _title("PERSONAL INFORMATION"),

                      _info(
                        Icons.person_outline_rounded,
                        "Full Name",
                        name,
                      ),

                      _info(
                        Icons.email_outlined,
                        "Email Address",
                        email,
                      ),

                      _info(
                        Icons.phone_outlined,
                        "Phone Number",
                        phone,
                      ),

                      _info(
                        Icons.person_pin_rounded,
                        "Account Role",
                        role,
                      ),

                      const SizedBox(height: 20),

                      _title("ACCOUNT STATUS"),

                      _status(),

                      const SizedBox(height: 20),

                      _title("ACCOUNT"),

                      _action(
                        Icons.lock_outline_rounded,
                        "Change Password",
                      ),

                      _action(
                        Icons.notifications_none_rounded,
                        "Notifications",
                      ),

                      _action(
                        Icons.help_outline_rounded,
                        "Help & Support",
                      ),

                      const SizedBox(height: 10),

                      _logoutButton(),
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

  Widget _headerButton(
      IconData icon,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 19,
        ),
      ),
    );
  }

  Widget _stat(
      IconData icon,
      String title,
      String value,
      ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: primary,
            size: 21,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 42,
      color: Colors.grey.shade200,
    );
  }

  Widget _title(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _info(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty
                      ? "Not available"
                      : value,
                  style: const TextStyle(
                    fontSize: 13,
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

  Widget _status() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kycColor.withOpacity(.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              kycIcon,
              color: kycColor,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "KYC Verification",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            kycStatus,
            style: TextStyle(
              color: kycColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(
      IconData icon,
      String title,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primary.withOpacity(.10),
            borderRadius:
            BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 13,
          color: Colors.grey.shade400,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _logoutButton() {
    return InkWell(
      onTap: logout,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xffFECACA),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.red,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
