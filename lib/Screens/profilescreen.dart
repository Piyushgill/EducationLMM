// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:thenew/services/session_manager.dart';
// import 'package:thenew/services/login_screen.dart';
// import 'package:thenew/dashboards/super_admin_dashboard.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class Profilescreen extends StatefulWidget {
//   const Profilescreen({super.key});
//
//   @override
//   State<Profilescreen> createState() => _ProfilescreenState();
// }
//
// class _ProfilescreenState extends State<Profilescreen> {
//   String _name = "Loading...";
//   String _email = "Loading...";
//   String _phone = "Loading...";
//   String _role = "Loading...";
//
//   String _bankName = "";
//   String _accountNumber = "";
//   String _ifscCode = "";
//   String _accountHolderName = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfile();
//   }
//
//   Future<void> _loadProfile() async {
//     final session = await SessionManager.getSession();
//     if (session != null) {
//       setState(() {
//         _name = session['name'] ?? "User Name";
//         _email = session['email'] ?? "";
//         _phone = session['phone'] ?? "";
//         _role = session['role'] ?? "User";
//       });
//       _fetchBankDetails(session['id']);
//     }
//   }
//
//   Future<void> _fetchBankDetails(dynamic userId) async {
//     try {
//       final res = await http.post(
//         Uri.parse("https://apps.kofalt.in/api/get_bank_details.php"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"user_id": userId}),
//       );
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         if (data['status'] == 'success') {
//           setState(() {
//             _bankName = data['bank_name'] ?? "";
//             _accountNumber = data['account_number'] ?? "";
//             _ifscCode = data['ifsc_code'] ?? "";
//             _accountHolderName = data['account_holder_name'] ?? "";
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint("Error fetching bank details: $e");
//     }
//   }
//
//   Future<void> _updateBankDetails() async {
//     final session = await SessionManager.getSession();
//     if (session == null) return;
//
//     final bankCtrl = TextEditingController(text: _bankName);
//     final accCtrl = TextEditingController(text: _accountNumber);
//     final ifscCtrl = TextEditingController(text: _ifscCode);
//     final holderCtrl = TextEditingController(text: _accountHolderName);
//
//     final formKey = GlobalKey<FormState>();
//
//     await showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text("Update Bank Details", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: SingleChildScrollView(
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                   controller: holderCtrl,
//                   decoration: const InputDecoration(labelText: "Account Holder Name"),
//                   validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: bankCtrl,
//                   decoration: const InputDecoration(labelText: "Bank Name"),
//                   validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: accCtrl,
//                   decoration: const InputDecoration(labelText: "Account Number"),
//                   validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: ifscCtrl,
//                   decoration: const InputDecoration(labelText: "IFSC Code"),
//                   validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: _role == "Agent" ? const Color(0xffF97316) : const Color(0xff2563EB)),
//             onPressed: () async {
//               if (!formKey.currentState!.validate()) return;
//               Navigator.pop(ctx);
//
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (_) => const Center(child: CircularProgressIndicator()),
//               );
//
//               try {
//                 final res = await http.post(
//                   Uri.parse("https://apps.kofalt.in/api/update_bank_details.php"),
//                   headers: {"Content-Type": "application/json"},
//                   body: jsonEncode({
//                     "user_id": session['id'],
//                     "bank_name": bankCtrl.text,
//                     "account_number": accCtrl.text,
//                     "ifsc_code": ifscCtrl.text,
//                     "account_holder_name": holderCtrl.text,
//                   }),
//                 );
//                 if (context.mounted) Navigator.pop(context);
//
//                 final resData = jsonDecode(res.body);
//                 if (resData['status'] == 'success') {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Bank details updated successfully!"), backgroundColor: Colors.green),
//                   );
//                   _fetchBankDetails(session['id']);
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Failed: ${resData['message']}"), backgroundColor: Colors.red),
//                   );
//                 }
//               } catch (e) {
//                 if (context.mounted) Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
//                 );
//               }
//             },
//             child: const Text("Save Details", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _confirmAndLogout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to logout?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () async {
//               final nav = Navigator.of(context);
//               Navigator.pop(ctx); // close dialog
//               final session = await SessionManager.getSession();
//               if (session != null && session['is_impersonating'] == true) {
//                 await SessionManager.saveSession(
//                   id: 1,
//                   name: "Super Admin",
//                   email: "admin@educationlmm.com",
//                   phone: "9999999999",
//                   role: "Super Admin",
//                   kycStatus: "Approved",
//                 );
//                 nav.pushAndRemoveUntil(
//                   MaterialPageRoute(builder: (_) => const SuperAdminDashboard()),
//                   (route) => false,
//                 );
//               } else {
//                 await SessionManager.clearSession();
//                 nav.pushAndRemoveUntil(
//                   MaterialPageRoute(builder: (_) => const LoginScreen()),
//                   (route) => false,
//                 );
//               }
//             },
//             child: const Text("Logout", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String get _initials {
//     if (_name.isEmpty || _name == "Loading...") return "U";
//     final parts = _name.trim().split(' ');
//     if (parts.length >= 2) {
//       return (parts[0][0] + parts[1][0]).toUpperCase();
//     }
//     return parts[0][0].toUpperCase();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // ================= HEADER PROFILE SECTION =================
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.only(top: 60, bottom: 35),
//               decoration: BoxDecoration(
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(32),
//                   bottomRight: Radius.circular(32),
//                 ),
//                 gradient: LinearGradient(
//                   colors: _role == "Agent"
//                       ? [const Color(0xffF97316), const Color(0xffEA580C)]
//                       : [const Color(0xff2563EB), const Color(0xffA020F0)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     height: 94,
//                     width: 94,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.18),
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 3),
//                     ),
//                     child: Center(
//                       child: Text(
//                         _initials,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 34,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 22),
//                   Text(
//                     _name,
//                     style: const TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     _role,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.85),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // ================= ACCOUNT DETAILS =================
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(22),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(26),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(.05),
//                       blurRadius: 12,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Account Details",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 26),
//                     Row(
//                       children: [
//                         _iconBox(Icons.email_outlined),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Email",
//                                 style: TextStyle(
//                                   color: Colors.grey.shade600,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 _email,
//                                 style: const TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 26),
//                     Row(
//                       children: [
//                         _iconBox(Icons.phone_outlined),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Phone",
//                                 style: TextStyle(
//                                   color: Colors.grey.shade600,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 _phone,
//                                 style: const TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // ================= BANK DETAILS CARD =================
//             if (_role == "Agent" || _role == "Distributor") ...[
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(22),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(26),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(.05),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             "Bank Details",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.edit_note, color: _role == "Agent" ? const Color(0xffF97316) : const Color(0xff2563EB), size: 28),
//                             onPressed: _updateBankDetails,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       _bankDetailRow("Holder", _accountHolderName.isEmpty ? "Not Added" : _accountHolderName),
//                       const Divider(height: 20),
//                       _bankDetailRow("Bank", _bankName.isEmpty ? "Not Added" : _bankName),
//                       const Divider(height: 20),
//                       _bankDetailRow("A/C No", _accountNumber.isEmpty ? "Not Added" : _accountNumber),
//                       const Divider(height: 20),
//                       _bankDetailRow("IFSC", _ifscCode.isEmpty ? "Not Added" : _ifscCode),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//
//             // ================= SETTINGS CARD =================
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(26),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(.05),
//                       blurRadius: 12,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     _menuTile(
//                       icon: Icons.settings_outlined,
//                       title: "Settings",
//                     ),
//                     _menuTile(
//                       icon: Icons.help_outline_rounded,
//                       title: "Help & Support",
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // ================= LOGOUT BUTTON =================
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: InkWell(
//                 onTap: () => _confirmAndLogout(context),
//                 borderRadius: BorderRadius.circular(22),
//                 child: Container(
//                   height: 60,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: const Color(0xffFFF1F2),
//                     borderRadius: BorderRadius.circular(22),
//                   ),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.logout_rounded,
//                         color: Color(0xffDC2626),
//                       ),
//                       SizedBox(width: 10),
//                       Text(
//                         "Logout",
//                         style: TextStyle(
//                           color: Color(0xffDC2626),
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _iconBox(IconData icon) {
//     return Container(
//       height: 48,
//       width: 48,
//       decoration: BoxDecoration(
//         color: const Color(0xffF5F5F5),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Icon(
//         icon,
//         color: Colors.grey.shade700,
//       ),
//     );
//   }
//
//   Widget _menuTile({
//     required IconData icon,
//     required String title,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 20,
//         vertical: 16,
//       ),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: Colors.grey.shade700,
//             size: 20,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Icon(
//             Icons.chevron_right_rounded,
//             color: Colors.grey.shade500,
//             size: 20,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _bankDetailRow(String label, String val) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
//         Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//       ],
//     );
//   }
// }
