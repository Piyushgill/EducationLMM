import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/session_manager.dart';
import 'package:thenew/services/login_screen.dart';
import 'package:thenew/dashboards/distributor_dashboard.dart';
import 'package:thenew/dashboards/franchisedashboard.dart';
import 'package:thenew/dashboards/schoolDashboard.dart';
import 'package:thenew/dashboards/studentdashboard.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingPending = false;
  bool _isLoadingUsers = false;
  bool _isLoadingCourses = false;
  bool _isLoadingOrders = false;
  bool _isLoadingKits = false;
  
  List<dynamic> _pendingList = [];
  List<dynamic> _usersList = [];
  List<dynamic> _coursesList = [];
  List<dynamic> _ordersList = [];
  List<dynamic> _kitsList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchPendingKyc();
    _fetchAllUsers();
    _fetchCourses();
    _fetchOrders();
    _fetchKits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── API Fetch & Creation Functions ──

  Future<void> _fetchPendingKyc() async {
    setState(() => _isLoadingPending = true);
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/get_pending_kyc.php"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _pendingList = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching pending KYC: $e");
    } finally {
      setState(() => _isLoadingPending = false);
    }
  }

  Future<void> _fetchAllUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/get_all_users.php"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _usersList = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching all users: $e");
    } finally {
      setState(() => _isLoadingUsers = false);
    }
  }

  Future<void> _fetchCourses() async {
    setState(() => _isLoadingCourses = true);
    try {
      final response = await http.get(
        Uri.parse("https://apps.kofalt.in/api/admin/get_courses.php"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _coursesList = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    } finally {
      setState(() => _isLoadingCourses = false);
    }
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoadingOrders = true);
    try {
      final response = await http.get(
        Uri.parse("https://apps.kofalt.in/api/admin/get_kit_orders.php"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _ordersList = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    } finally {
      setState(() => _isLoadingOrders = false);
    }
  }

  Future<void> _fetchKits() async {
    setState(() => _isLoadingKits = true);
    try {
      final response = await http.get(
        Uri.parse("https://apps.kofalt.in/api/admin/get_kits.php"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _kitsList = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching kits: $e");
    } finally {
      setState(() => _isLoadingKits = false);
    }
  }

  Future<void> _actionKyc(int userId, String action, {String? reason}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
    );

    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/action_kyc.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "action": action,
          "reason": reason,
        }),
      );
      
      Navigator.pop(context); // Close loader

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("KYC status successfully updated to $action!", isError: false);
        _fetchPendingKyc();
        _fetchAllUsers();
      } else {
        _showSnack(data['message'] ?? "Action failed", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  Future<void> _toggleUserStatus(int userId, String currentStatus) async {
    final nextStatus = currentStatus == 'Active' ? 'Suspended' : 'Active';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
    );

    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/toggle_user_status.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "status": nextStatus,
        }),
      );
      
      Navigator.pop(context); // Close loader

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("User is now $nextStatus!", isError: false);
        _fetchAllUsers();
      } else {
        _showSnack(data['message'] ?? "Action failed", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  Future<void> _addCourse(String title, String description, String classGrade, String subject) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
    );

    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_course.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "description": description,
          "class_grade": classGrade,
          "subject": subject,
        }),
      );
      
      Navigator.pop(context); // Close loader

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("Course created successfully!", isError: false);
        _fetchCourses();
      } else {
        _showSnack(data['message'] ?? "Failed to create course", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  Future<void> _addChapter(int courseId, int chapterNumber, String title, String resourceUrl) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
    );

    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_chapter.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "course_id": courseId,
          "chapter_number": chapterNumber,
          "title": title,
          "resource_url": resourceUrl,
        }),
      );
      
      Navigator.pop(context); // Close loader

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("Chapter lesson uploaded successfully!", isError: false);
        _fetchCourses();
      } else {
        _showSnack(data['message'] ?? "Failed to upload chapter", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  Future<void> _addCircular(String title, String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
    );

    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_circular.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "message": message,
        }),
      );
      
      Navigator.pop(context); // Close loader

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("Announcement notice published successfully!", isError: false);
      } else {
        _showSnack(data['message'] ?? "Failed to publish announcement", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  Future<void> _updateOrderStatus(int orderId, String nextStatus) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
    );
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/update_order_status.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"order_id": orderId, "status": nextStatus}),
      );
      Navigator.pop(context); // Close loader
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("Order #$orderId marked as $nextStatus!", isError: false);
        _fetchOrders();
      } else {
        _showSnack(data['message'] ?? "Failed to update status", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  Future<void> _addOrUpdateKit(String level, double price) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
    );
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_kit_type.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"level": level, "price": price}),
      );
      Navigator.pop(context); // Close loader
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("Kit catalog updated successfully!", isError: false);
        _fetchKits();
      } else {
        _showSnack(data['message'] ?? "Failed to save kit", isError: true);
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
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToDashboard(String role) {
    Widget dashboard;
    switch (role) {
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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
      (route) => false,
    );
  }

  // ── Input Dialog Prompts ──

  void _showRejectionDialog(int userId) {
    final TextEditingController reasonCtrl = TextEditingController();
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) {
                _showSnack("Please enter a rejection reason", isError: true);
                return;
              }
              Navigator.pop(ctx);
              _actionKyc(userId, "Rejected", reason: reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Confirm Reject"),
          ),
        ],
      ),
    );
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
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Course Title"),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Course Description"),
              ),
              TextField(
                controller: gradeCtrl,
                decoration: const InputDecoration(labelText: "Target Grade (e.g. 10th, Level 3)"),
              ),
              TextField(
                controller: subCtrl,
                decoration: const InputDecoration(labelText: "Subject (e.g. Abacus, Vedic Maths)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();
              final grade = gradeCtrl.text.trim();
              final sub = subCtrl.text.trim();
              if (title.isEmpty || desc.isEmpty || grade.isEmpty || sub.isEmpty) {
                _showSnack("Please fill out all fields", isError: true);
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
            TextField(
              controller: numCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Chapter Number"),
            ),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Chapter Title"),
            ),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(labelText: "Resource / Video URL"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final numVal = int.tryParse(numCtrl.text) ?? 1;
              final url = urlCtrl.text.trim();
              if (title.isEmpty || url.isEmpty) {
                _showSnack("Please fill out all fields", isError: true);
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Publish Announcement", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Circular Title"),
            ),
            TextField(
              controller: msgCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Message Text Details"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final msg = msgCtrl.text.trim();
              if (title.isEmpty || msg.isEmpty) {
                _showSnack("Please fill out all fields", isError: true);
                return;
              }
              Navigator.pop(ctx);
              _addCircular(title, msg);
            },
            child: const Text("Publish"),
          ),
        ],
      ),
    );
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
            TextField(
              controller: levelCtrl,
              decoration: const InputDecoration(hintText: "e.g. Level 1, Level 5"),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "e.g. 1500"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final lvl = levelCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text) ?? 0.0;
              if (lvl.isEmpty || price <= 0) {
                _showSnack("Please enter valid Level and Price parameters", isError: true);
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
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
                              backgroundColor: const Color(0xffEFF6FF),
                              child: Text(
                                userKyc['name']?[0]?.toUpperCase() ?? "?",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xff2563EB)),
                              ),
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
                                  _showRejectionDialog(userKyc['id']);
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
                                  backgroundColor: const Color(0xff2563EB),
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

  // ── Helper UI Widgets ──

  Widget _modalSectionHeader(String label) {
    return Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E293B)));
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
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
            ),
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
            InteractiveViewer(
              child: Image.network(url, fit: BoxFit.contain),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab Views ──

  Widget _buildKycAuditTab() {
    if (_isLoadingPending) {
      return const Center(child: CircularProgressIndicator(color: Color(0xff2563EB)));
    }
    if (_pendingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 68, color: Colors.green.shade400),
            const SizedBox(height: 12),
            const Text("Audit queue is empty!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingList.length,
      itemBuilder: (context, index) {
        final user = _pendingList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade100)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xffEFF6FF),
                  child: Text(user['name']?[0]?.toUpperCase() ?? "?", style: const TextStyle(color: Color(0xff2563EB), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text("${user['role']} • ${user['phone']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showKycDetailsModal(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563EB),
                    foregroundColor: Colors.white,
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
    );
  }

  Widget _buildUsersTab() {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator(color: Color(0xff2563EB)));
    }
    if (_usersList.isEmpty) {
      return const Center(child: Text("No users found.", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _usersList.length,
      itemBuilder: (context, index) {
        final user = _usersList[index];
        final bool isSuspended = user['status'] == 'Suspended';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade100)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isSuspended ? Colors.red.shade50 : const Color(0xffF1F5F9),
                  child: Text(
                    user['name']?[0]?.toUpperCase() ?? "?",
                    style: TextStyle(color: isSuspended ? Colors.red : Colors.grey.shade700, fontWeight: FontWeight.bold),
                  ),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: user['kyc_status'] == 'Approved' 
                                  ? Colors.green.shade50 
                                  : (user['kyc_status'] == 'Rejected' ? Colors.red.shade50 : Colors.orange.shade50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "KYC: ${user['kyc_status']}",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: user['kyc_status'] == 'Approved' 
                                    ? Colors.green.shade600 
                                    : (user['kyc_status'] == 'Rejected' ? Colors.red.shade600 : Colors.orange.shade600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: "Login As User",
                  onPressed: () async {
                    final int userId = user['id'] is int
                        ? user['id']
                        : int.tryParse(user['id'].toString()) ?? 0;
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
                    _navigateToDashboard(user['role']);
                  },
                  icon: const Icon(Icons.login, color: Color(0xff2563EB), size: 28),
                ),
                IconButton(
                  onPressed: () => _toggleUserStatus(user['id'], user['status']),
                  icon: Icon(
                    isSuspended ? Icons.play_circle_fill : Icons.pause_circle_filled,
                    color: isSuspended ? Colors.green.shade600 : Colors.red.shade600,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    int total = _usersList.length;
    int students = _usersList.where((u) => u['role'] == 'Student').length;
    int schools = _usersList.where((u) => u['role'] == 'School').length;
    int franchises = _usersList.where((u) => u['role'] == 'Franchise Partner').length;
    int distributors = _usersList.where((u) => u['role'] == 'Distributor').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Platform Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff2563EB), Color(0xff1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: const Color(0xff2563EB).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Registered Users", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text("$total", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _statCard("Students", students, Icons.school_outlined, const Color(0xff3B82F6)),
              _statCard("Schools", schools, Icons.domain_outlined, const Color(0xff10B981)),
              _statCard("Franchises", franchises, Icons.storefront_outlined, const Color(0xffF59E0B)),
              _statCard("Distributors", distributors, Icons.local_shipping_outlined, const Color(0xff8B5CF6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              CircleAvatar(radius: 4, backgroundColor: color),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$count", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentManagerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.campaign_outlined, size: 36, color: Color(0xffFF6B00)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Announcements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text("Publish circular alerts to all dashboards", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _showCircularDialog,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffFF6B00), foregroundColor: Colors.white),
                    child: const Text("Publish"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Course Catalogs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
              ElevatedButton.icon(
                onPressed: _showCourseDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("New Course"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2563EB), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoadingCourses)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_coursesList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text("No courses registered yet. Add courses above.", style: TextStyle(color: Colors.grey)),
              ),
            )
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
                                TextButton.icon(
                                  onPressed: () => _showChapterDialog(course['id']),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text("Add Lesson"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (chapters.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text("No lessons uploaded for this course yet.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: chapters.length,
                                itemBuilder: (ctx, chIndex) {
                                  final ch = chapters[chIndex];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.blue.shade50,
                                      child: Text("${ch['chapter_number']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
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
      ),
    );
  }

  Widget _buildKitsOrdersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Catalog header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Kits Catalog & Pricing", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
              ElevatedButton.icon(
                onPressed: _showKitCatalogDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add/Update Kit"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff10B981), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingKits)
            const Center(child: CircularProgressIndicator())
          else if (_kitsList.isEmpty)
            const Text("No kits registered in catalog yet.", style: TextStyle(color: Colors.grey))
          else
            Container(
              height: 110,
              margin: const EdgeInsets.only(bottom: 24),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _kitsList.length,
                itemBuilder: (ctx, i) {
                  final kit = _kitsList[i];
                  return Card(
                    margin: const EdgeInsets.only(right: 12, bottom: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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

          const Text("Kit Purchase Orders", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
          const SizedBox(height: 12),

          if (_isLoadingOrders)
            const Center(child: CircularProgressIndicator())
          else if (_ordersList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text("No kit orders placed yet on the platform.", style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ordersList.length,
              itemBuilder: (context, index) {
                final order = _ordersList[index];
                final String buyerName = order['buyer_name'] ?? "";
                final String buyerRole = order['buyer_role'] ?? "";
                final String deliveryStatus = order['delivery_status'] ?? "Pending";
                
                Color statusColor = Colors.orange;
                if (deliveryStatus == 'Shipped') statusColor = Colors.blue;
                if (deliveryStatus == 'Delivered') statusColor = Colors.green;
                if (deliveryStatus == 'Cancelled') statusColor = Colors.red;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text(deliveryStatus, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
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
                            const Text("Update Shipping: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _updateOrderStatus(order['order_id'], 'Shipped'),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue)),
                              child: const Text("Ship", style: TextStyle(color: Colors.blue, fontSize: 11)),
                            ),
                            const SizedBox(width: 6),
                            OutlinedButton(
                              onPressed: () => _updateOrderStatus(order['order_id'], 'Delivered'),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green)),
                              child: const Text("Deliver", style: TextStyle(color: Colors.green, fontSize: 11)),
                            ),
                            const SizedBox(width: 6),
                            OutlinedButton(
                              onPressed: () => _updateOrderStatus(order['order_id'], 'Cancelled'),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                              child: const Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Main Scaffold Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Super Admin Control", style: TextStyle(color: Color(0xff1E293B), fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              _fetchPendingKyc();
              _fetchAllUsers();
              _fetchCourses();
              _fetchOrders();
              _fetchKits();
              _showSnack("Dashboard data refreshed!", isError: false);
            },
            icon: const Icon(Icons.refresh, color: Color(0xff2563EB)),
          ),
          IconButton(
            onPressed: () async {
              await SessionManager.clearSession();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xff2563EB),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xff2563EB),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          isScrollable: true,
          tabs: const [
            Tab(text: "KYC Queue"),
            Tab(text: "Directory"),
            Tab(text: "Overview"),
            Tab(text: "Content"),
            Tab(text: "Kits & Orders"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKycAuditTab(),
          _buildUsersTab(),
          _buildStatsTab(),
          _buildContentManagerTab(),
          _buildKitsOrdersTab(),
        ],
      ),
    );
  }
}
