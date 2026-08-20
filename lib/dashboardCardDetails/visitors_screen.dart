import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/session_manager.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  String _selectedTab = 'All';
  bool _isLoading = false;
  List<dynamic> _visitors = [];

  final List<String> _typeOptions = ['School Visit', 'New Lead', 'Demo Request'];
  final List<String> _statusOptions = ['Pending', 'Converted', 'Not Interested'];

  @override
  void initState() {
    super.initState();
    _fetchVisitors();
  }

  // ------------------------------------------------------------
  //  FETCH VISITORS
  //  NOTE: confirm this endpoint name/response shape with your
  //  backend. Expected response:
  //  { "status": "success", "data": [ {id, name, school, type,
  //    status, visit_date, visit_time}, ... ] }
  // ------------------------------------------------------------
  Future<void> _fetchVisitors() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final userId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_visitors.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": userId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success' && data['data'] != null) {
            if (mounted) {
              setState(() {
                _visitors = data['data'];
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching visitors: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ------------------------------------------------------------
  //  ADD VISIT FORM
  //  NOTE: confirm this endpoint name/field names with backend.
  // ------------------------------------------------------------
  void _openAddVisitForm() {
    final nameCtrl = TextEditingController();
    final schoolCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedType = _typeOptions.first;
    String selectedStatus = _statusOptions.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
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
                      const Text("Add New Visit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Visitor / Contact Name", border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: schoolCtrl,
                    decoration: const InputDecoration(labelText: "School / Purpose", border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? "This field is required" : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: "Visit Type", border: OutlineInputBorder()),
                    items: _typeOptions
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setSheetState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder()),
                    items: _statusOptions
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setSheetState(() => selectedStatus = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff5B5BF6)),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(ctx);

                        final session = await SessionManager.getSession();
                        if (session == null) return;
                        final userId = session['id'];
                        final now = DateTime.now();

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff5B5BF6))),
                        );

                        try {
                          final res = await http.post(
                            Uri.parse("https://apps.kofalt.in/api/add_visitor.php"),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode({
                              "user_id": userId,
                              "name": nameCtrl.text,
                              "school": schoolCtrl.text,
                              "type": selectedType,
                              "status": selectedStatus,
                              "visit_date": "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
                              "visit_time": "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
                            }),
                          );
                          if (context.mounted) Navigator.pop(context); // close loader
                          final data = jsonDecode(res.body);
                          if (data['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Visit added successfully!"), backgroundColor: Colors.green),
                            );
                            _fetchVisitors();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(data['message'] ?? "Failed to add visit"), backgroundColor: Colors.red),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: const Text("Add Visit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Converted': return const Color(0xff16C74A);
      case 'Pending': return const Color(0xffFF6B00);
      case 'Not Interested': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'School Visit': return const Color(0xff2563EB);
      case 'New Lead': return const Color(0xffA020F0);
      case 'Demo Request': return const Color(0xff5B5BF6);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalVisits = _visitors.length;
    final converted = _visitors.where((v) => v['status'] == 'Converted').length;
    final pending = _visitors.where((v) => v['status'] == 'Pending').length;
    final notInterested = _visitors.where((v) => v['status'] == 'Not Interested').length;

    List<dynamic> filtered = _selectedTab == 'All'
        ? _visitors
        : _visitors.where((v) => v['status'] == _selectedTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddVisitForm,
        backgroundColor: const Color(0xff5B5BF6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Visit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                colors: [Color(0xff5B5BF6), Color(0xff3535C8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 44, width: 44,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      height: 52, width: 52,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Visits", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("All visitors & leads", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Text("$totalVisits", style: const TextStyle(color: Color(0xff5B5BF6), fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _headerChip(Icons.check_circle_outline, "Converted", "$converted"),
                    const SizedBox(width: 5),
                    _headerChip(Icons.pending_outlined, "Pending", "$pending"),
                    const SizedBox(width: 5),
                    _headerChip(Icons.cancel_outlined, "Not Interested", "$notInterested"),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: ['All', 'Converted', 'Pending', 'Not Interested'].map((tab) {
                final isSelected = _selectedTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = tab),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xff5B5BF6) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
                    ),
                    child: Text(tab, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 11)),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xff5B5BF6)))
                : filtered.isEmpty
                ? Center(child: Text("No visits recorded yet", style: TextStyle(color: Colors.grey.shade500, fontSize: 15)))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final v = filtered[index];
                final name = (v['name'] ?? "").toString();
                final type = (v['type'] ?? "New Lead").toString();
                final status = (v['status'] ?? "Pending").toString();
                final school = (v['school'] ?? "").toString();
                final date = (v['visit_date'] ?? v['date'] ?? "").toString();
                final time = (v['visit_time'] ?? v['time'] ?? "").toString();
                final initialChar = name.isNotEmpty ? name.substring(0, 1) : "?";
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: _typeColor(type).withOpacity(.1),
                        child: Text(initialChar, style: TextStyle(color: _typeColor(type), fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            if (school.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(school, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                            ],
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _typeColor(type).withOpacity(.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(type, style: TextStyle(color: _typeColor(type), fontSize: 10, fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(width: 6),
                                Text("$date $time", style: TextStyle(color: Colors.grey.shade500, fontSize: 8)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(status, style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.w600)),
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

  Widget _headerChip(IconData icon, String label, String count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}