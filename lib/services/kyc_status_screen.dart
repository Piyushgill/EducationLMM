import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thenew/Screens/EducationHomeScreen.dart';
import 'package:thenew/dashboards/distributor_dashboard.dart';
import 'package:thenew/dashboards/franchisedashboard.dart';
import 'package:thenew/dashboards/schoolDashboard.dart';
import 'package:thenew/dashboards/studentdashboard.dart';
import 'package:thenew/services/session_manager.dart';

class KycStatusScreen extends StatefulWidget {
  final Map<String, dynamic> userSession;
  const KycStatusScreen({super.key, required this.userSession});

  @override
  State<KycStatusScreen> createState() => _KycStatusScreenState();
}

class _KycStatusScreenState extends State<KycStatusScreen> {
  bool _isChecking = false;
  late String _currentStatus;
  late String _userName;
  late String _userRole;
  late int _userId;

  @override
  void initState() {
    super.initState();
    _userId = widget.userSession['id'] ?? 0;
    _userName = widget.userSession['name'] ?? 'User';
    _userRole = widget.userSession['role'] ?? 'Distributor';
    _currentStatus = widget.userSession['kyc_status'] ?? 'Pending';
  }

  Future<void> _checkKycStatus() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      final url = Uri.parse("https://apps.kofalt.in/api/check_status.php?user_id=$_userId");
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final newStatus = data['kyc_status'];
          await SessionManager.updateKycStatus(newStatus);
          
          if (mounted) {
            setState(() {
              _currentStatus = newStatus;
            });
            
            if (newStatus == 'Approved') {
              _showSnackBar("KYC Approved! Redirecting...", isError: false);
              _navigateToDashboard();
            } else {
              _showSnackBar("Status checked: Still $_currentStatus", isError: false);
            }
          }
        }
      } else {
        _showSnackBar("Could not fetch latest status. Server returned ${response.statusCode}", isError: true);
      }
    } catch (e) {
      _showSnackBar("Error connecting to server: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  void _navigateToDashboard() {
    Widget dashboard;
    switch (_userRole) {
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

  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const EducationLLMHomeScreen()),
        (route) => false,
      );
    }
  }

  void _showSnackBar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade400 : const Color(0xff2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = _currentStatus == 'Pending';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // ── LOGO ──
              Center(
                child: Image.asset(
                  'assets/image/k-logo.png',
                  height: 64,
                  width: 64,
                  fit: BoxFit.contain,
                ),
              ),
              
              const Spacer(),
              
              // ── STATUS GRAPHIC ──
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: isPending ? const Color(0xffEFF6FF) : const Color(0xffFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPending ? const Color(0xffBFDBFE) : const Color(0xffFCA5A5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isPending
                      ? const Icon(Icons.verified_user_outlined, size: 54, color: Color(0xff2563EB))
                      : const Icon(Icons.gpp_bad_outlined, size: 54, color: Colors.red),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // ── STATUS TITLE ──
              Text(
                isPending ? "KYC Verification Pending" : "KYC Verification Rejected",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // ── USER DETAIL ROW ──
              Text(
                "Hello, $_userName ($_userRole)",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ── STATUS DESCRIPTION ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xfff1f2f6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPending
                      ? "Your KYC details are currently being verified by our admin team.\n\nOnce approved, you will be granted access to your dashboard automatically. This usually takes 24-48 hours."
                      : "We're sorry, but your KYC details have been rejected by the admin team.\n\nPlease contact our support team at support@kofalt.in to correct your documents and resubmit.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // ── REFRESH STATUS BUTTON ──
              if (isPending)
                GestureDetector(
                  onTap: _checkKycStatus,
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xff2563EB), Color(0xffA020F0)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff2563EB).withOpacity(.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isChecking
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Refresh Status",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 14),
              
              // ── LOGOUT BUTTON ──
              GestureDetector(
                onTap: _logout,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xffF1F5F9),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
