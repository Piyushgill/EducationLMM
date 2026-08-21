import 'package:flutter/material.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CentreDetailsScreen extends StatefulWidget {
  const CentreDetailsScreen({super.key});

  @override
  State<CentreDetailsScreen> createState() => _CentreDetailsScreenState();
}

class _CentreDetailsScreenState extends State<CentreDetailsScreen> {
  bool _isLoading = false;
  List<dynamic> _centers = [];
  int _totalStudents = 0;
  int _totalBatches = 0;

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
            final List<dynamic> list = data['data'] ?? [];
            int students = 0;
            int batches = 0;
            for (final s in list) {
              students += (s['students'] as int? ?? 0);
              batches += (s['batches'] as int? ?? 0);
            }
            setState(() {
              _centers = list;
              _totalStudents = students;
              _totalBatches = batches;
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

  // ------------------------------------------------------------
  //  ADD CENTER — password no longer managed from this screen.
  // ------------------------------------------------------------
  Future<void> _addcenter({
    required String name,
    required String email,
    required String phone,
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
          "center_city": city,
        }),
      );

      Navigator.pop(context); // Close loader

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("center registered successfully under you!", isError: false);
        _fetchcenters();
      } else {
        _showSnack(data['message'] ?? "Failed to add center", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddcenterDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
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
              if (name.isEmpty || email.isEmpty || phone.isEmpty) {
                _showSnack("Please fill out all required fields", isError: true);
                return;
              }
              Navigator.pop(ctx);
              _addcenter(
                name: name,
                email: email,
                phone: phone,
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

  // ------------------------------------------------------------
  //  CENTER DETAILS POPUP — shown on tapping a center card.
  // ------------------------------------------------------------
  void _showCentreDetailsPopup(dynamic centre) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xff7C3AED).withOpacity(.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.store_mall_directory_outlined, color: Color(0xff7C3AED), size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        centre['name'] ?? "",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        centre['center_city'] ?? "No City Specified",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xff16C74A).withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    centre['status'] ?? "Active",
                    style: const TextStyle(color: Color(0xff16C74A), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _detailRow(Icons.email_outlined, "Email", centre['email'] ?? "Not available"),
            _detailRow(Icons.phone_outlined, "Phone", centre['phone'] ?? "Not available"),
            _detailRow(Icons.person_outline, "Principal", centre['principal_name'] ?? "Not available"),
            _detailRow(Icons.menu_book_outlined, "Board Type", centre['board_type'] ?? "Not available"),
            _detailRow(Icons.badge_outlined, "Reg. Number", centre['reg_number'] ?? "Not available"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _infoChip(
                    Icons.groups_outlined,
                    "${centre['students'] ?? 0} Students",
                    const Color(0xff2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoChip(
                    Icons.calendar_view_week_outlined,
                    "${centre['batches'] ?? 0} Batches",
                    const Color(0xff7C3AED),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchcenters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          _detailHeader(
            title: "Centre Details",
            subtitle: "All your centres",
            colors: const [
              Color(0xff7C3AED),
              Color(0xffDB2777),
            ],
            onBack: () => Navigator.pop(context),
            extra: [
              Row(
                children: [
                  _hStatWhite("Total", "${_centers.length}"),
                  const SizedBox(width: 16),
                  _hStatWhite("Students", "$_totalStudents"),
                  const SizedBox(width: 16),
                  _hStatWhite("Batches", "$_totalBatches"),
                ],
              ),
            ],
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xff7C3AED)))
                : _centers.isEmpty
                ? const Center(child: Text("No centers registered yet under your profile.", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: _centers.length,
              itemBuilder: (context, index) {
                final centre = _centers[index];

                return GestureDetector(
                  onTap: () => _showCentreDetailsPopup(centre),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 46,
                              width: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xff7C3AED).withOpacity(.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.store_mall_directory_outlined,
                                color: Color(0xff7C3AED),
                                size: 24,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    centre['name'] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    centre['center_city'] ?? "No City Specified",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xff16C74A).withOpacity(.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                centre['status'] ?? "Active",
                                style: const TextStyle(
                                  color: Color(0xff16C74A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            _infoChip(
                              Icons.groups_outlined,
                              "${centre['students']} Students",
                              const Color(0xff2563EB),
                            ),

                            const SizedBox(width: 16),

                            _infoChip(
                              Icons.calendar_view_week_outlined,
                              "${centre['batches']} Batches",
                              const Color(0xff7C3AED),
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddcenterDialog,
        backgroundColor: const Color(0xff7C3AED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Register center", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _detailHeader({
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onBack,
    List<Widget>? extra,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 50,
        bottom: 28,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        gradient: LinearGradient(colors: colors),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          if (extra != null) ...[
            const SizedBox(height: 18),
            ...extra,
          ],
        ],
      ),
    );
  }

  Widget _hStatWhite(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _infoChip(
      IconData icon,
      String text,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}