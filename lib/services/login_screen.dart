import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thenew/Screens/EducationHomeScreen.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:thenew/services/kyc_status_screen.dart';
import 'package:thenew/dashboards/distributor_dashboard.dart';
import 'package:thenew/dashboards/franchisedashboard.dart';
import 'package:thenew/dashboards/schoolDashboard.dart';
import 'package:thenew/dashboards/studentdashboard.dart';
import 'package:thenew/dashboards/super_admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isPasswordHidden = true;
  bool _rememberMe = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  //  BACK NAVIGATION -> EducationHomeScreen
  // ----------------------------------------------------------
  void _goToEducationHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const EducationLLMHomeScreen()),
          (route) => false,
    );
  }

  String? _validate() {
    if (_emailController.text.trim().isEmpty) return "Please enter your email or phone number";
    if (_passwordController.text.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  void _onLogin() async {
    final error = _validate();
    if (error != null) {
      _showError(error);
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xff2563EB)),
                SizedBox(height: 18),
                Text(
                  "Authenticating...",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final url = Uri.parse("https://apps.kofalt.in/api/login.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
        }),
      ).timeout(const Duration(seconds: 15));

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          final user = responseData['user'];

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
          );

          if (mounted) {
            _showSuccess("Login Successful!");

            // Check KYC Status
            if (user['role'] == 'Super Admin' || user['kyc_status'] == 'Approved') {
              // Redirect to role-specific dashboard
              _navigateToDashboard(user['role']);
            } else {
              // KYC Pending or Rejected -> Route to blocking screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => KycStatusScreen(userSession: user),
                ),
                    (route) => false,
              );
            }
          }
        } else {
          _showError(responseData['message'] ?? "Login failed.");
        }
      } else {
        _showError(responseData['message'] ?? "Invalid username or password.");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loader
        _showError("Connection error: $e");
      }
    }
  }

  void _navigateToDashboard(String role) {
    Widget dashboard;
    switch (role) {
      case "Super Admin":
        dashboard = const SuperAdminDashboard();
        break;
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xff2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent the default pop; we handle navigation ourselves below.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goToEducationHome();
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff5f5f5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── BACK BUTTON ──
                    GestureDetector(
                      onTap: _goToEducationHome,
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── LOGO + HEADER ──
                    Center(
                      child: Column(
                        children: [
                          // gradient logo box
                          Container(
                            height: 72,
                            width: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff2563EB),
                                  Color(0xffA020F0),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff2563EB).withOpacity(.28),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Image.asset(
                                'assets/image/k-logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign in to continue your journey",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ── EMAIL ──
                    _label("Email"),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _emailController,
                      hint: "Enter your email address",
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    // ── PASSWORD ──
                    _label("Password"),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xfff1f2f6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _isPasswordHidden,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 20),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.grey,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _isPasswordHidden = !_isPasswordHidden),
                            icon: Icon(
                              _isPasswordHidden
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          hintText: "Enter your password",
                          hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── REMEMBER ME + FORGOT ──
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _rememberMe = !_rememberMe),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: _rememberMe
                                      ? const LinearGradient(
                                    colors: [Color(0xff2563EB), Color(0xffA020F0)],
                                  )
                                      : null,
                                  color: _rememberMe ? null : const Color(0xffe0e0e0),
                                ),
                                child: _rememberMe
                                    ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Remember me",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // TODO: forgot password
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // ── LOGIN BUTTON ──
                    GestureDetector(
                      onTap: _onLogin,
                      child: Container(
                        height: 62,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xff2563EB), Color(0xffA020F0)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff2563EB).withOpacity(.28),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── DIVIDER ──
                    // Row(
                    //   children: [
                    //     Expanded(child: Divider(color: Colors.grey.shade300)),
                    //     Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 14),
                    //       child: Text(
                    //         "or continue with",
                    //         style: TextStyle(
                    //           fontSize: 13,
                    //           color: Colors.grey.shade400,
                    //         ),
                    //       ),
                    //     ),
                    //     Expanded(child: Divider(color: Colors.grey.shade300)),
                    //   ],
                    // ),

                    const SizedBox(height: 24),

                    // ── SOCIAL BUTTONS ──
                    // Row(
                    //   children: [
                    //     Expanded(child: _socialButton("Google", "G", const Color(0xffEA4335))),
                    //     const SizedBox(width: 14),
                    //     Expanded(child: _socialButton("Apple", "", const Color(0xff111111))),
                    //   ],
                    // ),

                    const SizedBox(height: 40),

                    // ── SIGN UP LINK ──
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                            children: [
                              TextSpan(
                                text: "Join Us",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff2563EB),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──
  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff1f2f6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _socialButton(String label, String letterIcon, Color color) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // letter-based icon to avoid asset dependency
          Container(
            height: 26,
            width: 26,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                letterIcon,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}