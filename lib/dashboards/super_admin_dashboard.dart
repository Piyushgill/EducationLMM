import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/session_manager.dart';
import 'package:thenew/services/login_screen.dart';
import 'package:thenew/dashboards/distributor_dashboard.dart';
import 'package:thenew/dashboards/franchisedashboard.dart';
import 'package:thenew/dashboards/schoolDashboard.dart';
import 'package:thenew/dashboards/studentdashboard.dart';

// ── Theme Constants (matches School/Franchise dashboards) ──
class _AdminTheme {
  static const Color primary = Color(0xff4F46E5); // Indigo-600
  static const Color primaryDark = Color(0xff4338CA); // Indigo-700
  static const Color primaryLight = Color(0xffEEF2FF); // Indigo-50
}

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
  bool _isLoadingVideos = false;
  bool _isLoadingTestimonials = false;
  bool _isLoadingFaqs = false;

  List<dynamic> _pendingList = [];
  List<dynamic> _usersList = [];
  List<dynamic> _coursesList = [];
  List<dynamic> _ordersList = [];
  List<dynamic> _kitsList = [];
  List<dynamic> _videosList = [];
  List<dynamic> _testimonialsList = [];
  List<dynamic> _faqsList = [];

  // Directory (Users) header sorting state
  String _sortColumn = 'name'; // 'name' | 'role' | 'status'
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchPendingKyc();
    _fetchAllUsers();
    _fetchCourses();
    _fetchOrders();
    _fetchKits();
    _fetchVideos();
    _fetchTestimonials();
    _fetchFaqs();
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

  Future<void> _fetchVideos() async {
    setState(() => _isLoadingVideos = true);
    try {
      final response = await http.get(
        Uri.parse("https://apps.kofalt.in/api/admin/get_videos.php"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _videosList = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching videos: $e");
    } finally {
      setState(() => _isLoadingVideos = false);
    }
  }

  Future<void> _fetchTestimonials() async {
    setState(() => _isLoadingTestimonials = true);
    try {
      final response = await http.get(
        Uri.parse("https://apps.kofalt.in/api/admin/get_testimonials.php"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _testimonialsList = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching testimonials: $e");
    } finally {
      setState(() => _isLoadingTestimonials = false);
    }
  }

  Future<void> _fetchFaqs() async {
    setState(() => _isLoadingFaqs = true);
    try {
      final response = await http.get(
        Uri.parse("https://apps.kofalt.in/api/admin/get_faqs.php"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _faqsList = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching FAQs: $e");
    } finally {
      setState(() => _isLoadingFaqs = false);
    }
  }

  Future<void> _actionKyc(int userId, String action, {String? reason}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
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
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
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
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
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
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
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
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
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
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
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
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
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

  /// targetRoles controls visibility: e.g. ["All"] means every role can see the video,
  /// or a specific subset like ["School", "Student"].
  Future<void> _addVideo(String title, String description, String videoUrl, List<String> targetRoles) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
    );
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_video.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "description": description,
          "video_url": videoUrl,
          "target_roles": targetRoles,
        }),
      );
      Navigator.pop(context); // Close loader
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("Video added to library successfully!", isError: false);
        _fetchVideos();
      } else {
        _showSnack(data['message'] ?? "Failed to add video", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  Future<void> _deleteVideo(int videoId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
    );
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/delete_video.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"video_id": videoId}),
      );
      Navigator.pop(context); // Close loader
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("Video removed from library!", isError: false);
        _fetchVideos();
      } else {
        _showSnack(data['message'] ?? "Failed to delete video", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  Future<void> _addTestimonial(String name, String role, String message, int rating, List<String> targetRoles) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
    );
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_testimonial.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "role": role,
          "message": message,
          "rating": rating,
          "target_roles": targetRoles,
        }),
      );
      Navigator.pop(context); // Close loader
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("Testimonial added successfully!", isError: false);
        _fetchTestimonials();
      } else {
        _showSnack(data['message'] ?? "Failed to add testimonial", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  Future<void> _deleteTestimonial(int testimonialId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
    );
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/delete_testimonial.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"testimonial_id": testimonialId}),
      );
      Navigator.pop(context); // Close loader
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("Testimonial removed!", isError: false);
        _fetchTestimonials();
      } else {
        _showSnack(data['message'] ?? "Failed to delete testimonial", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  Future<void> _addFaq(String question, String answer, List<String> targetRoles) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
    );
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/add_faq.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "question": question,
          "answer": answer,
          "target_roles": targetRoles,
        }),
      );
      Navigator.pop(context); // Close loader
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("FAQ added successfully!", isError: false);
        _fetchFaqs();
      } else {
        _showSnack(data['message'] ?? "Failed to add FAQ", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  Future<void> _deleteFaq(int faqId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _AdminTheme.primary)),
    );
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/admin/delete_faq.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"faq_id": faqId}),
      );
      Navigator.pop(context); // Close loader
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _showSnack("FAQ removed!", isError: false);
        _fetchFaqs();
      } else {
        _showSnack(data['message'] ?? "Failed to delete FAQ", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Close loader
      _showSnack("Network error: $e", isError: true);
    }
  }

  /// Combined refresh used by pull-to-refresh on every tab.
  Future<void> _refreshAll() async {
    await Future.wait([
      _fetchPendingKyc(),
      _fetchAllUsers(),
      _fetchCourses(),
      _fetchOrders(),
      _fetchKits(),
      _fetchVideos(),
      _fetchTestimonials(),
      _fetchFaqs(),
    ]);
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

  Future<void> _loginAsUser(Map<String, dynamic> user) async {
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
            style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
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
            style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
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
            style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
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
            style: ElevatedButton.styleFrom(backgroundColor: _AdminTheme.primary, foregroundColor: Colors.white),
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

  /// Video dialog with role checkboxes (All / Distributor / Franchise / School / Student).
  /// Selecting "All" auto-clears the rest; selecting any specific role clears "All".
  /// Whichever roles are checked, only those role's users will see this video.
  void _showVideoDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final Map<String, bool> targetRoles = {
      "All": true,
      "Distributor": false,
      "Franchise Partner": false,
      "School": false,
      "Student": false,
    };

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
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: "Video Title"),
                  ),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  TextField(
                    controller: urlCtrl,
                    decoration: const InputDecoration(labelText: "Video URL"),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Visible To",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B)),
                  ),
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
                            // Selecting "All" clears every other checkbox
                            targetRoles.updateAll((key, value) => key == "All" ? (val ?? false) : false);
                          } else {
                            targetRoles[role] = val ?? false;
                            // Any specific role selection turns "All" off
                            if (targetRoles[role] == true) {
                              targetRoles["All"] = false;
                            }
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
                    _showSnack("Please fill title and video URL", isError: true);
                    return;
                  }
                  final selectedRoles = targetRoles.entries.where((e) => e.value).map((e) => e.key).toList();
                  if (selectedRoles.isEmpty) {
                    _showSnack("Please select at least one role", isError: true);
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

  /// Testimonial dialog with a tappable 1-5 star rating selector and role checkboxes.
  void _showTestimonialDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    int rating = 5;
    final Map<String, bool> targetRoles = {
      "All": true,
      "Distributor": false,
      "Franchise Partner": false,
      "School": false,
      "Student": false,
    };

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
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Person's Name"),
                  ),
                  TextField(
                    controller: roleCtrl,
                    decoration: const InputDecoration(labelText: "Role / Designation (e.g. School Principal)"),
                  ),
                  TextField(
                    controller: msgCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: "Testimonial Message"),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Rating",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (i) {
                      final starIndex = i + 1;
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setDialogState(() => rating = starIndex),
                        icon: Icon(
                          starIndex <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xffF59E0B),
                          size: 30,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Visible To",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B)),
                  ),
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
                            if (targetRoles[role] == true) {
                              targetRoles["All"] = false;
                            }
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
                    _showSnack("Please fill out all fields", isError: true);
                    return;
                  }
                  final selectedRoles = targetRoles.entries.where((e) => e.value).map((e) => e.key).toList();
                  if (selectedRoles.isEmpty) {
                    _showSnack("Please select at least one role", isError: true);
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
    final Map<String, bool> targetRoles = {
      "All": true,
      "Distributor": false,
      "Franchise Partner": false,
      "School": false,
      "Student": false,
    };

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
                  TextField(
                    controller: questionCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: "Question"),
                  ),
                  TextField(
                    controller: answerCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: "Answer"),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Visible To",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B)),
                  ),
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
                            if (targetRoles[role] == true) {
                              targetRoles["All"] = false;
                            }
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
                    _showSnack("Please fill out both fields", isError: true);
                    return;
                  }
                  final selectedRoles = targetRoles.entries.where((e) => e.value).map((e) => e.key).toList();
                  if (selectedRoles.isEmpty) {
                    _showSnack("Please select at least one role", isError: true);
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
                              backgroundColor: _AdminTheme.primaryLight,
                              child: Text(
                                userKyc['name']?[0]?.toUpperCase() ?? "?",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _AdminTheme.primary),
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

  // ── Shared UI Helpers ──

  /// A consistent empty-state block used across tabs (icon + headline + optional subtext).
  Widget _emptyState(IconData icon, String message, {String? subMessage}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _AdminTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: _AdminTheme.primary.withOpacity(0.7)),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff64748B)),
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                subMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// A colored icon badge + title/subtitle + trailing action button, used to visually
  /// separate the sections inside the Content tab (Announcements, Courses, Videos, etc.)
  Widget _contentSectionHeader({
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
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
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

  /// Section divider used between Content tab blocks.
  Widget _sectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }

  // ── Tab Views ──

  Widget _buildKycAuditTab() {
    if (_isLoadingPending) {
      return const Center(child: CircularProgressIndicator(color: _AdminTheme.primary));
    }

    return RefreshIndicator(
      color: _AdminTheme.primary,
      onRefresh: _refreshAll,
      child: _pendingList.isEmpty
          ? ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          _emptyState(
            Icons.check_circle_outline_rounded,
            "Audit queue is empty!",
            subMessage: "New KYC submissions will show up here for review.",
          ),
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
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user['role'] ?? "",
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                              ),
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
    );
  }

  // ── Directory Sorting Helpers ──

  List<dynamic> _getSortedUsers() {
    final list = List<dynamic>.from(_usersList);
    list.sort((a, b) {
      String valA;
      String valB;
      switch (_sortColumn) {
        case 'role':
          valA = (a['role'] ?? '').toString();
          valB = (b['role'] ?? '').toString();
          break;
        case 'status':
          valA = (a['kyc_status'] ?? '').toString();
          valB = (b['kyc_status'] ?? '').toString();
          break;
        case 'name':
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? _AdminTheme.primary : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isActive ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.unfold_more,
              size: 14,
              color: isActive ? _AdminTheme.primary : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _sortHeaderLabel("Name", "name", flex: 3),
          _sortHeaderLabel("Role", "role", flex: 2),
          _sortHeaderLabel("KYC Status", "status", flex: 2),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator(color: _AdminTheme.primary));
    }
    if (_usersList.isEmpty) {
      return RefreshIndicator(
        color: _AdminTheme.primary,
        onRefresh: _refreshAll,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.18),
            _emptyState(Icons.people_outline_rounded, "No users found.", subMessage: "Registered users will appear here."),
          ],
        ),
      );
    }

    final sortedUsers = _getSortedUsers();

    return Column(
      children: [
        _buildDirectoryHeader(),
        Expanded(
          child: RefreshIndicator(
            color: _AdminTheme.primary,
            onRefresh: _refreshAll,
            child: ListView.builder(
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
                          onPressed: () => _loginAsUser(user),
                          icon: const Icon(Icons.login, color: _AdminTheme.primary, size: 28),
                          visualDensity: VisualDensity.compact,
                        ),
                        PopupMenuButton<String>(
                          tooltip: "Update KYC Status",
                          icon: Icon(
                            Icons.fact_check_outlined,
                            color: user['kyc_status'] == 'Approved'
                                ? Colors.green.shade600
                                : (user['kyc_status'] == 'Rejected' ? Colors.red.shade600 : Colors.orange.shade600),
                            size: 26,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          onSelected: (value) {
                            if (value == 'Rejected') {
                              _showRejectionDialog(user['id']);
                            } else {
                              _actionKyc(user['id'], value);
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'Approved',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                                  const SizedBox(width: 10),
                                  const Text("Approve"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'Rejected',
                              child: Row(
                                children: [
                                  Icon(Icons.cancel, color: Colors.red.shade600, size: 18),
                                  const SizedBox(width: 10),
                                  const Text("Reject"),
                                ],
                              ),
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
        ),
      ],
    );
  }

  /// Opens a premium, role-filtered list of users when a stat card is tapped.
  void _openRoleUsersList(String role, Color color, IconData icon) {
    final filtered = _usersList.where((u) => u['role'] == role).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoleUsersListScreen(
          role: role,
          color: color,
          icon: icon,
          users: filtered,
          onRefresh: _fetchAllUsers,
          onLoginAs: _loginAsUser,
          onViewKyc: _showKycDetailsModal,
          onApprove: (id) => _actionKyc(id, "Approved"),
          onReject: _showRejectionDialog,
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    int total = _usersList.length;
    int students = _usersList.where((u) => u['role'] == 'Student').length;
    int schools = _usersList.where((u) => u['role'] == 'School').length;
    int franchises = _usersList.where((u) => u['role'] == 'Franchise Partner').length;
    int distributors = _usersList.where((u) => u['role'] == 'Distributor').length;

    return RefreshIndicator(
      color: _AdminTheme.primary,
      onRefresh: _refreshAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _AdminTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.dashboard_rounded, color: _AdminTheme.primary, size: 18),
                ),
                const SizedBox(width: 10),
                const Text("Platform Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: Colors.green.shade500, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text("Live", style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Premium hero card with decorative watermark pattern ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_AdminTheme.primary, _AdminTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: _AdminTheme.primary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: -40,
                    child: Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text("Total Registered Users", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text("$total", style: const TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.w800, letterSpacing: -1)),
                      const SizedBox(height: 4),
                      Text(
                        "Across Students, Schools, Franchises & Distributors",
                        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.5, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            Text("Browse by role", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.3)),
            const SizedBox(height: 5),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.90,
              children: [
                _statCard(
                  "Students", students, Icons.school_rounded, const Color(0xff3B82F6),
                  onTap: () => _openRoleUsersList("Student", const Color(0xff3B82F6), Icons.school_rounded),
                ),
                _statCard(
                  "Schools", schools, Icons.domain_rounded, const Color(0xff10B981),
                  onTap: () => _openRoleUsersList("School", const Color(0xff10B981), Icons.domain_rounded),
                ),
                _statCard(
                  "Franchises", franchises, Icons.storefront_rounded, const Color(0xffF59E0B),
                  onTap: () => _openRoleUsersList("Franchise Partner", const Color(0xffF59E0B), Icons.storefront_rounded),
                ),
                _statCard(
                  "Distributors", distributors, Icons.local_shipping_rounded, const Color(0xff8B5CF6),
                  onTap: () => _openRoleUsersList("Distributor", const Color(0xff8B5CF6), Icons.local_shipping_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      String label,
      int count,
      IconData icon,
      Color color, {
        VoidCallback? onTap,
      }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [

              // Left Accent
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: color.withOpacity(.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: 24,
                            ),
                          ),

                          const Spacer(),

                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey.shade400,
                            size: 16,
                          ),
                        ],
                      ),

                      const Spacer(),

                      Text(
                        "$count",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1E293B),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Tap to View",
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentManagerTab() {
    return RefreshIndicator(
      color: _AdminTheme.primary,
      onRefresh: _refreshAll,
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
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF1E6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.campaign_outlined, size: 24, color: Color(0xffFF6B00)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Announcements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text("Publish circular alerts to selected dashboards", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showCircularDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF6B00),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Publish"),
                    ),
                  ],
                ),
              ),
            ),
            _sectionDivider(),

            _contentSectionHeader(
              title: "Course Catalogs",
              icon: Icons.menu_book_rounded,
              iconColor: _AdminTheme.primary,
              buttonLabel: "New Course",
              onPressed: _showCourseDialog,
            ),
            const SizedBox(height: 12),

            if (_isLoadingCourses)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_coursesList.isEmpty)
              _emptyState(Icons.menu_book_outlined, "No courses registered yet.", subMessage: "Add a course using the button above.")
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

            _sectionDivider(),
            _contentSectionHeader(
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
              _emptyState(Icons.smart_display_outlined, "No videos in the library yet.", subMessage: "Add one using the button above.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _videosList.length,
                itemBuilder: (context, index) {
                  final video = _videosList[index];
                  final List<dynamic> roles = video['target_roles'] is List
                      ? video['target_roles']
                      : (video['target_roles']?.toString().split(',') ?? ["All"]);

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
                            decoration: BoxDecoration(
                              color: _AdminTheme.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                  Text(
                                    video['description'],
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: roles.map<Widget>((role) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _AdminTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        role.toString(),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _AdminTheme.primary),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: "Remove Video",
                            onPressed: () => _deleteVideo(video['id']),
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            _sectionDivider(),
            _contentSectionHeader(
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
              _emptyState(Icons.reviews_outlined, "No testimonials added yet.", subMessage: "Add one using the button above.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _testimonialsList.length,
                itemBuilder: (context, index) {
                  final t = _testimonialsList[index];
                  final int rating = int.tryParse(t['rating']?.toString() ?? '5') ?? 5;
                  final List<dynamic> tRoles = t['target_roles'] is List
                      ? t['target_roles']
                      : (t['target_roles']?.toString().split(',') ?? ["All"]);

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
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: _AdminTheme.primaryLight,
                            child: Text(
                              (t['name'] ?? "?")[0].toString().toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: _AdminTheme.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text(t['role'] ?? "", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                const SizedBox(height: 6),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                                      color: const Color(0xffF59E0B),
                                      size: 16,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 8),
                                Text(t['message'] ?? "", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: tRoles.map<Widget>((role) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _AdminTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        role.toString(),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _AdminTheme.primary),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: "Remove Testimonial",
                            onPressed: () => _deleteTestimonial(t['id']),
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            _sectionDivider(),
            _contentSectionHeader(
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
              _emptyState(Icons.quiz_outlined, "No FAQs added yet.", subMessage: "Add one using the button above.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqsList.length,
                itemBuilder: (context, index) {
                  final faq = _faqsList[index];
                  final List<dynamic> fRoles = faq['target_roles'] is List
                      ? faq['target_roles']
                      : (faq['target_roles']?.toString().split(',') ?? ["All"]);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                    color: Colors.white,
                    child: ExpansionTile(
                      leading: const Icon(Icons.help_outline, color: _AdminTheme.primary),
                      title: Text(faq['question'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      trailing: IconButton(
                        tooltip: "Remove FAQ",
                        onPressed: () => _deleteFaq(faq['id']),
                        icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                        visualDensity: VisualDensity.compact,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(faq['answer'] ?? "", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: fRoles.map<Widget>((role) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _AdminTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      role.toString(),
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _AdminTheme.primary),
                                    ),
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
    );
  }

  Widget _buildKitsOrdersTab() {
    return RefreshIndicator(
      color: _AdminTheme.primary,
      onRefresh: _refreshAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Catalog header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xffECFDF5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: Color(0xff10B981), size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text("Kits Catalog & Pricing", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showKitCatalogDialog,
                  icon: const Icon(
                    Icons.add,
                    size: 12,
                  ),
                  label: const Text(
                    "Add Kit",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingKits)
              const Center(child: CircularProgressIndicator())
            else if (_kitsList.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _emptyState(Icons.inventory_2_outlined, "No kits registered in catalog yet."),
              )
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
                              decoration: BoxDecoration(
                                color: const Color(0xffECFDF5),
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _AdminTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: _AdminTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Text("Kit Purchase Orders", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
              ],
            ),
            const SizedBox(height: 12),

            if (_isLoadingOrders)
              const Center(child: CircularProgressIndicator())
            else if (_ordersList.isEmpty)
              _emptyState(Icons.receipt_long_outlined, "No kit orders placed yet.", subMessage: "Orders from franchises and schools will show up here.")
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
                              const Text(
                                "Update Shipping:",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 10),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  _updateOrderStatus(order['order_id'], value);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                offset: const Offset(0, 40),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: "Shipped",
                                    child: Row(
                                      children: const [
                                        Icon(Icons.local_shipping, color: Colors.blue, size: 18),
                                        SizedBox(width: 8),
                                        Text("Ship"),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: "Delivered",
                                    child: Row(
                                      children: const [
                                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                                        SizedBox(width: 8),
                                        Text("Deliver"),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: "Cancelled",
                                    child: Row(
                                      children: const [
                                        Icon(Icons.cancel, color: Colors.red, size: 18),
                                        SizedBox(width: 8),
                                        Text("Cancel"),
                                      ],
                                    ),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _AdminTheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Update",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white,
                                        size: 18,
                                      ),
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
    );
  }

  // ── Main Scaffold Build ──
  // Tab order: Overview is first now, followed by KYC Queue, Directory, Content, Kits & Orders.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.05),
        title: const Text("Super Admin Control", style: TextStyle(color: Color(0xff1E293B), fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              _refreshAll();
              _showSnack("Dashboard data refreshed!", isError: false);
            },
            icon: const Icon(Icons.refresh, color: _AdminTheme.primary),
            visualDensity: VisualDensity.compact,
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
            visualDensity: VisualDensity.compact,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _AdminTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _AdminTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          isScrollable: true,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "KYC Queue"),
            Tab(text: "Directory"),
            Tab(text: "Content"),
            Tab(text: "Kits & Orders"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(),
          _buildKycAuditTab(),
          _buildUsersTab(),
          _buildContentManagerTab(),
          _buildKitsOrdersTab(),
        ],
      ),
    );
  }
}

// ============================================================
//  ROLE USERS LIST SCREEN — premium filtered list opened from
//  tapping a stat card on the Overview tab (Students / Schools /
//  Franchises / Distributors).
// ============================================================

class RoleUsersListScreen extends StatefulWidget {
  final String role;
  final Color color;
  final IconData icon;
  final List<dynamic> users;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Map<String, dynamic> user) onLoginAs;
  final void Function(Map<String, dynamic> user) onViewKyc;
  final void Function(int userId) onApprove;
  final void Function(int userId) onReject;

  const RoleUsersListScreen({
    super.key,
    required this.role,
    required this.color,
    required this.icon,
    required this.users,
    required this.onRefresh,
    required this.onLoginAs,
    required this.onViewKyc,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<RoleUsersListScreen> createState() => _RoleUsersListScreenState();
}

class _RoleUsersListScreenState extends State<RoleUsersListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = "";
  String _statusFilter = "All"; // All | Approved | Pending | Rejected

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<dynamic> get _filtered {
    return widget.users.where((u) {
      final name = (u['name'] ?? "").toString().toLowerCase();
      final phone = (u['phone'] ?? "").toString().toLowerCase();
      final matchesQuery = _query.isEmpty || name.contains(_query) || phone.contains(_query);
      final status = (u['kyc_status'] ?? "Pending").toString();
      final matchesStatus = _statusFilter == "All" || status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  int _countByStatus(String status) {
    if (status == "All") return widget.users.length;
    return widget.users.where((u) => (u['kyc_status'] ?? "Pending").toString() == status).length;
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
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.color, widget.color.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                boxShadow: [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20, top: -20,
                    child: Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08))),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 38, width: 38,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
                            child: Icon(widget.icon, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text("${widget.role}s", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text("${widget.users.length} total registered", style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                      const SizedBox(height: 18),

                      // ── Search bar ──
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
        body: RefreshIndicator(
          color: widget.color,
          onRefresh: widget.onRefresh,
          child: filtered.isEmpty
              ? ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.16),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: widget.color.withOpacity(0.08), shape: BoxShape.circle),
                      child: Icon(widget.icon, size: 32, color: widget.color.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.users.isEmpty ? "No ${widget.role.toLowerCase()}s yet." : "No matches found.",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff64748B)),
                    ),
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
              final Color statusColor = status == 'Approved'
                  ? const Color(0xff10B981)
                  : (status == 'Rejected' ? const Color(0xffEF4444) : const Color(0xffF59E0B));
              final bool isSuspended = user['status'] == 'Suspended';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [widget.color.withOpacity(0.15), widget.color.withOpacity(0.05)]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            (user['name'] ?? "?")[0].toString().toUpperCase(),
                            style: TextStyle(color: widget.color, fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? "",
                              style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.5,
                                decoration: isSuspended ? TextDecoration.lineThrough : null,
                                color: const Color(0xff1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(user['phone'] ?? "", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                "KYC: $status",
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: "Login As User",
                                onPressed: () => widget.onLoginAs(user),
                                icon: Icon(Icons.login_rounded, color: widget.color, size: 22),
                                visualDensity: VisualDensity.compact,
                              ),
                              PopupMenuButton<String>(
                                tooltip: "Update KYC Status",
                                icon: Icon(Icons.fact_check_outlined, color: statusColor, size: 20),

                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                onSelected: (value) {
                                  if (value == 'view') {
                                    widget.onViewKyc(user);
                                  } else if (value == 'Approved') {
                                    widget.onApprove(user['id']);
                                  } else if (value == 'Rejected') {
                                    widget.onReject(user['id']);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Row(children: [
                                      Icon(Icons.visibility_outlined, color: Color(0xff94A3B8), size: 18),
                                      SizedBox(width: 10),
                                      Text("View Details"),
                                    ]),
                                  ),
                                  PopupMenuItem(
                                    value: 'Approved',
                                    child: Row(children: [
                                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                                      const SizedBox(width: 10),
                                      const Text("Approve"),
                                    ]),
                                  ),
                                  PopupMenuItem(
                                    value: 'Rejected',
                                    child: Row(children: [
                                      Icon(Icons.cancel, color: Colors.red.shade600, size: 18),
                                      const SizedBox(width: 10),
                                      const Text("Reject"),
                                    ]),
                                  ),
                                ],
                              ),
                            ],
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
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.25) : widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("$count", style: TextStyle(color: isSelected ? Colors.white : widget.color, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}