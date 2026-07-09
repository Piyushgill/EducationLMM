import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/session_manager.dart';

class TotalStudentsScreen extends StatefulWidget {
  const TotalStudentsScreen({super.key});

  @override
  State<TotalStudentsScreen> createState() => _TotalStudentsScreenState();
}

class _TotalStudentsScreenState extends State<TotalStudentsScreen> {
  String _selectedSchool = 'All Schools';
  bool _isLoading = false;
  List<dynamic> _schools = [];
  List<dynamic> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchNetworkData();
  }

  Future<void> _fetchNetworkData() async {
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
                _students = users.where((u) => u['role'] == 'Student').toList();
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching students: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate school list items grouped for display
    final List<Map<String, dynamic>> schoolData = _schools.map((sch) {
      final schId = sch['id'] as int;
      final schName = sch['name'] as String? ?? "Unknown School";
      final count = _students.where((st) => st['parent_id'] == schId).length;
      return {
        'id': schId,
        'school': schName,
        'students': count,
        'level': 'Level 1-3',
        'location': sch['email'] ?? 'India',
      };
    }).toList();

    final total = schoolData.fold(0, (sum, s) => sum + (s['students'] as int));

    final filtered = _selectedSchool == 'All Schools'
        ? schoolData
        : schoolData.where((s) => s['school'] == _selectedSchool).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
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
                colors: [Color(0xffA020F0), Color(0xff7B10BF)],
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
                      child: const Icon(Icons.people_outline, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Students", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Total students enrolled", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Text("$total", style: const TextStyle(color: Color(0xffA020F0), fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Dropdown filter
          Padding(
            padding: const EdgeInsets.all(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10)],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSchool,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xffA020F0)),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedSchool = newValue);
                    }
                  },
                  items: ['All Schools', ...schoolData.map((s) => s['school'] as String)]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // List Cards
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xffA020F0)))
                : filtered.isEmpty
                    ? Center(child: Text("No student records found", style: TextStyle(color: Colors.grey.shade500, fontSize: 15)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 3))],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: const Color(0xffA020F0).withOpacity(.1),
                                  child: const Icon(Icons.school, color: Color(0xffA020F0), size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['school'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(height: 3),
                                      Text("Levels: ${item['level']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                      Text("Email: ${item['location']}", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${item['students']}",
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xffA020F0)),
                                    ),
                                    const Text("Students", style: TextStyle(fontSize: 10, color: Colors.grey)),
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
}