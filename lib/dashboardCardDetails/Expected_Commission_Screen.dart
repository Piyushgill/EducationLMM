import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/session_manager.dart';

class ExpectedCommissionScreen extends StatefulWidget {
  const ExpectedCommissionScreen({super.key});

  @override
  State<ExpectedCommissionScreen> createState() => _ExpectedCommissionScreenState();
}

class _ExpectedCommissionScreenState extends State<ExpectedCommissionScreen> {
  bool _isLoading = false;
  double _totalEarned = 0.0;
  double _totalPending = 0.0;

  // Fallback default only used if the API doesn't return a target yet.
  double _target = 25000.0;

  @override
  void initState() {
    super.initState();
    _fetchCommissions();
  }

  // ------------------------------------------------------------
  //  FETCH COMMISSIONS + TARGET
  //  NOTE: this assumes get_commissions.php now also returns a
  //  "target" field, e.g.:
  //  { "status": "success", "data": [...], "target": 30000 }
  //  If your backend doesn't send "target" yet, add that column/
  //  field there, or tell me the separate endpoint and I'll wire
  //  it up instead.
  // ------------------------------------------------------------
  Future<void> _fetchCommissions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final userId = session['id'];
        final response = await http.post(
          Uri.parse("https://apps.kofalt.in/api/get_commissions.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": userId}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success' && data['data'] != null) {
            final List<dynamic> list = data['data'];
            double earned = 0.0;
            double pending = 0.0;
            for (var c in list) {
              final amt = (c['amount'] as num).toDouble();
              if (c['status'] == 'Paid') {
                earned += amt;
              } else {
                pending += amt;
              }
            }
            if (mounted) {
              setState(() {
                _totalEarned = earned;
                _totalPending = pending;
                if (data['target'] != null) {
                  _target = double.tryParse(data['target'].toString()) ?? _target;
                }
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching expected commissions: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ------------------------------------------------------------
  //  EDIT TARGET
  //  NOTE: confirm this endpoint name/field names with backend.
  // ------------------------------------------------------------
  void _openEditTargetDialog() {
    final targetCtrl = TextEditingController(text: _target.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Set Monthly Target"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: targetCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Target Amount (₹)", border: OutlineInputBorder()),
            validator: (v) {
              final n = double.tryParse(v ?? "");
              if (n == null || n <= 0) return "Enter a valid amount";
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newTarget = double.parse(targetCtrl.text);
              Navigator.pop(ctx);

              final session = await SessionManager.getSession();
              if (session == null) return;
              final userId = session['id'];

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff2563EB))),
              );

              try {
                final res = await http.post(
                  Uri.parse("https://apps.kofalt.in/api/set_commission_target.php"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({"user_id": userId, "target": newTarget}),
                );
                if (context.mounted) Navigator.pop(context); // close loader
                final data = jsonDecode(res.body);
                if (data['status'] == 'success') {
                  setState(() => _target = newTarget);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Target updated!"), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(data['message'] ?? "Failed to update target"), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double ratio = _target > 0 ? (_totalEarned / _target).clamp(0.0, 1.0) : 0.0;
    final double remaining = (_target - _totalEarned).clamp(0.0, _target);
    final double expectedNextMonth = _totalEarned + _totalPending + (remaining * 0.15);

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff2563EB)))
          : Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 50,
              bottom: 28,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              gradient: LinearGradient(
                colors: [
                  Color(0xff2563EB),
                  Color(0xff16C74A),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _openEditTargetDialog,
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Expected Commission",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Monthly target & achievement",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Target Commission",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: _openEditTargetDialog,
                              child: Row(
                                children: [
                                  Text(
                                    "₹${_target.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff2563EB),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.edit, size: 14, color: Color(0xff2563EB)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 10,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff16C74A)),
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Earned ₹${_totalEarned.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              "${(ratio * 100).toStringAsFixed(1)}%",
                              style: const TextStyle(
                                color: Color(0xff16C74A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _statCard(
                    "Expected Next Month",
                    "₹${expectedNextMonth.toStringAsFixed(0)}",
                    Icons.trending_up,
                    const Color(0xff16C74A),
                  ),
                  const SizedBox(height: 12),
                  _statCard(
                    "Remaining To Target",
                    "₹${remaining.toStringAsFixed(0)}",
                    Icons.flag,
                    const Color(0xffFF6B00),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}