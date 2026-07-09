import 'package:flutter/material.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentEnrollmentScreen extends StatefulWidget {
  const StudentEnrollmentScreen({super.key});

  @override
  State<StudentEnrollmentScreen> createState() => _StudentEnrollmentScreenState();
}

class _StudentEnrollmentScreenState extends State<StudentEnrollmentScreen> {
  bool _isLoading = false;
  List<dynamic> _students = [];
  List<dynamic> _schools = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await _fetchSchools();
    await _fetchStudents();
  }

  Future<void> _fetchSchools() async {
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
            if (mounted) {
              setState(() {
                _schools = data['data'] ?? [];
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching schools: $e");
    }
  }

  Future<void> _fetchStudents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final franchiseId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/franchise/get_students.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"franchise_id": franchiseId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            if (mounted) {
              setState(() {
                _students = data['data'] ?? [];
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

  Future<void> _enrollStudent({
    required int schoolId,
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff10B981))),
    );

    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/franchise/add_student.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "school_id": schoolId,
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
        }),
      );

      Navigator.pop(context); // Close loader

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("Student registered successfully!", isError: false);
        _fetchStudents();
      } else {
        _showSnack(data['message'] ?? "Registration failed", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openEnrollmentForm() {
    if (_schools.isEmpty) {
      _showSnack("Please register at least one School under Center Details first!", isError: true);
      return;
    }

    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    int? selectedSchoolId = _schools[0]['id'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enroll New Student",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedSchoolId,
                      decoration: const InputDecoration(labelText: "Assign to School Center"),
                      items: _schools.map<DropdownMenuItem<int>>((s) {
                        return DropdownMenuItem<int>(
                          value: s['id'] as int,
                          child: Text(s['name'] as String),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedSchoolId = val;
                          });
                        }
                      },
                    ),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Student Full Name"),
                    ),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: "Email Address"),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: "Phone Number"),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: passCtrl,
                      decoration: const InputDecoration(labelText: "Login Password"),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final email = emailCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();
                          final password = passCtrl.text.trim();

                          if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || selectedSchoolId == null) {
                            _showSnack("Please fill out all fields", isError: true);
                            return;
                          }

                          Navigator.pop(context);
                          _enrollStudent(
                            schoolId: selectedSchoolId!,
                            name: name,
                            email: email,
                            phone: phone,
                            password: password,
                          );
                        },
                        child: const Text("Register Student", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
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
                colors: [Color(0xff10B981), Color(0xff059669)],
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
                      child: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Student Enrollment", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Manage affiliate students", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Text("${_students.length}", style: const TextStyle(color: Color(0xff10B981), fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10)],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search enrolled students...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _openEnrollmentForm,
                  child: Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xff10B981),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xff10B981).withOpacity(.3), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xff10B981)))
                : _students.isEmpty
                    ? Center(child: Text("No students enrolled yet", style: TextStyle(color: Colors.grey.shade500, fontSize: 15)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          final isActive = student['status'] == 'Active';
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
                                  radius: 24,
                                  backgroundColor: const Color(0xff10B981).withOpacity(.1),
                                  child: Text(
                                    (student['name'] ?? "?").toString().substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: Color(0xff10B981), fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(student['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text("Center: ${student['school_name'] ?? 'Direct'}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      Text("Phone: ${student['phone'] ?? ''}", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isActive ? const Color(0xff10B981).withOpacity(.1) : Colors.red.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(student['status'] ?? 'Active', style: TextStyle(color: isActive ? const Color(0xff10B981) : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
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