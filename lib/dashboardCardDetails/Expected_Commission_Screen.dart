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

  @override
  void initState() {
    super.initState();
    _fetchCommissions();
  }

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

  @override
  Widget build(BuildContext context) {
    const double target = 25000.0;
    final double ratio = target > 0 ? (_totalEarned / target).clamp(0.0, 1.0) : 0.0;
    final double remaining = (target - _totalEarned).clamp(0.0, target);
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
                                  Text(
                                    "₹${target.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff2563EB),
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