import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyUserSession = "user_session";

  // Save the logged-in or signed-up user profile
  static Future<bool> saveSession({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String role,
    required String kycStatus,
    bool isImpersonating = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> sessionData = {
      "id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      "kyc_status": kycStatus,
      "is_impersonating": isImpersonating,
    };
    return await prefs.setString(_keyUserSession, jsonEncode(sessionData));
  }

  // Get current user session, returns null if not logged in
  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionStr = prefs.getString(_keyUserSession);
    if (sessionStr == null) return null;
    try {
      return jsonDecode(sessionStr) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null;
  }

  // Update only the KYC status in the active session
  static Future<bool> updateKycStatus(String newStatus) async {
    final session = await getSession();
    if (session == null) return false;
    session['kyc_status'] = newStatus;
    
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyUserSession, jsonEncode(session));
  }

  // Clear session on logout
  static Future<bool> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyUserSession);
  }
}
