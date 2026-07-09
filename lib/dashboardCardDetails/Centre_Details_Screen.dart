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
  List<dynamic> _schools = [];
  int _totalStudents = 0;
  int _totalBatches = 0;

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
            final List<dynamic> list = data['data'] ?? [];
            int students = 0;
            int batches = 0;
            for (final s in list) {
              students += (s['students'] as int? ?? 0);
              batches += (s['batches'] as int? ?? 0);
            }
            setState(() {
              _schools = list;
              _totalStudents = students;
              _totalBatches = batches;
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
        _showSnack("School registered successfully under you!", isError: false);
        _fetchSchools();
      } else {
        _showSnack(data['message'] ?? "Failed to add school", isError: true);
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

  void _showAddSchoolDialog() {
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
                _showSnack("Please fill out all required fields", isError: true);
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

  @override
  void initState() {
    super.initState();
    _fetchSchools();
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
                  _hStatWhite("Total", "${_schools.length}"),
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
                : _schools.isEmpty
                    ? const Center(child: Text("No schools registered yet under your profile.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(18),
                        itemCount: _schools.length,
                        itemBuilder: (context, index) {
                          final centre = _schools[index];

                          return Container(
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
                                            centre['school_city'] ?? "No City Specified",
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
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSchoolDialog,
        backgroundColor: const Color(0xff7C3AED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Register School", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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