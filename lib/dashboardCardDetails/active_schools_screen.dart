import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/session_manager.dart';

class ActiveSchoolsScreen extends StatefulWidget {
  const ActiveSchoolsScreen({super.key});

  @override
  State<ActiveSchoolsScreen> createState() => _ActiveSchoolsScreenState();
}

class _ActiveSchoolsScreenState extends State<ActiveSchoolsScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = false;
  List<dynamic> _schools = [];

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  Future<void> _fetchSchools() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final userId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_user_network.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": userId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success' && data['network_users'] != null) {
            final List<dynamic> users = data['network_users'];
            if (mounted) {
              setState(() {
                _schools = users.where((u) => u['role'] == 'School').toList();
              });
            }
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

  // ------------------------------------------------------------
  //  ADD SCHOOL FORM
  //  NOTE: endpoint follows the same pattern as
  //  distributor/add_agent.php. Confirm the exact URL/field
  //  names with your backend and adjust if they differ.
  // ------------------------------------------------------------
  void _openAddSchoolForm() {
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
                    const Text("Add New School", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "School Name", border: OutlineInputBorder()),
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
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff16C74A)),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.pop(ctx);

                      final session = await SessionManager.getSession();
                      if (session == null) return;
                      final distId = session['id'];

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff16C74A))),
                      );

                      try {
                        final res = await http.post(
                          Uri.parse("https://apps.kofalt.in/api/distributor/add_school.php"),
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
                            const SnackBar(content: Text("School created successfully!"), backgroundColor: Colors.green),
                          );
                          _fetchSchools();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(data['message'] ?? "Failed to create school"), backgroundColor: Colors.red),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text("Create School", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'All'
        ? _schools
        : _schools.where((s) => s['status'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSchoolForm,
        backgroundColor: const Color(0xff16C74A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add School", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 24, right: 24, top: 52, bottom: 28),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff16C74A), Color(0xff0D9E38)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 44, width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      height: 52, width: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.school_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Active Schools", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Real-time network directory", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Text("${_schools.length}", style: const TextStyle(color: Color(0xff16C74A), fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: ['All', 'Active', 'Suspended'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xff16C74A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // School Cards
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xff16C74A)))
                : filtered.isEmpty
                ? Center(child: Text("No schools found", style: TextStyle(color: Colors.grey.shade500, fontSize: 15)))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final s = filtered[index];
                final isActive = s['status'] == 'Active';
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 46, width: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xff16C74A).withOpacity(.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.school_outlined, color: Color(0xff16C74A), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text(s['email'] ?? "", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xff16C74A).withOpacity(.1) : Colors.red.withOpacity(.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(s['status'] ?? 'Active', style: TextStyle(color: isActive ? const Color(0xff16C74A) : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _infoItem(Icons.phone, s['phone'] ?? "No Phone", const Color(0xff2563EB)),
                          const SizedBox(width: 14),
                          _infoItem(Icons.calendar_today_outlined, "Joined Recently", const Color(0xffFF6B00)),
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
    );
  }

  Widget _infoItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}