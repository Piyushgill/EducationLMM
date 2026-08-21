import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/session_manager.dart';

class NetworkSizeScreen extends StatefulWidget {
  const NetworkSizeScreen({super.key});

  @override
  State<NetworkSizeScreen> createState() => _NetworkSizeScreenState();
}

class _NetworkSizeScreenState extends State<NetworkSizeScreen> {
  bool _isLoading = false;
  List<dynamic> _members = [];
  String _searchQuery = "";
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNetwork();
  }

  Future<void> _fetchNetwork() async {
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
            if (mounted) {
              setState(() {
                _members = data['network_users'];
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching network size: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  //  ADD SCHOOL FORM
  //  NOTE: endpoint below follows the same pattern as
  //  distributor/add_agent.php. Confirm the exact URL/field
  //  names with your backend and adjust if they differ.
  // ------------------------------------------------------------
  void _openAddForm() {
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
                    const Text(
                      "Add New School",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "School Name",
                    border: OutlineInputBorder(),
                  ),
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

                      // TODO: confirm this endpoint name with your backend.
                      const endpoint = "https://apps.kofalt.in/api/distributor/add_school.php";

                      try {
                        final res = await http.post(
                          Uri.parse(endpoint),
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
                            const SnackBar(
                              content: Text("School created successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _fetchNetwork();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(data['message'] ?? "Failed to create"), backgroundColor: Colors.red),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text(
                      "Create School",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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
    final schools = _members.where((u) => u['role'] == 'School').toList();

    final filtered = schools.where((m) {
      final name = (m['name'] ?? "").toString().toLowerCase();
      final phone = (m['phone'] ?? "").toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || phone.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddForm,
        backgroundColor: const Color(0xff2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add School",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                colors: [Color(0xff2563EB), Color(0xffA020F0)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 44,
                    width: 44,
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
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.school_outlined, color: Colors.white, size: 25),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Network Size", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Schools", style: TextStyle(color: Colors.white70, fontSize: 15)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text("${schools.length}", style: const TextStyle(color: Color(0xff2563EB), fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search schools...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xff2563EB)))
                : filtered.isEmpty
                ? Center(
              child: Text(
                "No schools found",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final m = filtered[index];
                final isActive = m['status'] == 'Active';
                final displayName = (m['name'] ?? "").toString();
                final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xff2563EB).withOpacity(.1),
                        child: Text(
                          initial,
                          style: const TextStyle(color: Color(0xff2563EB), fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text("${m['role']} • ${m['phone']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m['status'] ?? 'Active',
                          style: TextStyle(color: isActive ? Colors.green.shade600 : Colors.red.shade600, fontSize: 11, fontWeight: FontWeight.bold),
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
    );
  }
}