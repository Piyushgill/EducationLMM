import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/session_manager.dart';

class CommissionScreen extends StatefulWidget {
  const CommissionScreen({super.key});

  @override
  State<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends State<CommissionScreen> {
  bool _isLoading = false;
  List<dynamic> _commissions = [];

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
            if (mounted) {
              setState(() {
                _commissions = data['data'];
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching commissions: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalEarned = _commissions
        .where((c) => c['status'] == 'Paid')
        .fold(0.0, (sum, c) => sum + (c['amount'] as num).toDouble());
    
    final double totalPending = _commissions
        .where((c) => c['status'] == 'Pending')
        .fold(0.0, (sum, c) => sum + (c['amount'] as num).toDouble());

    final double totalPayout = totalEarned + totalPending;
    const double monthlyTarget = 25000.0;
    final double progressRatio = monthlyTarget > 0 ? (totalEarned / monthlyTarget).clamp(0.0, 1.0) : 0.0;

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
                colors: [Color(0xffFF1493), Color(0xffC71585)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 44, width: 44,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Commission Earned", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _headerStat("Total Earned", "₹${totalEarned.toStringAsFixed(0)}"),
                    const SizedBox(width: 12),
                    _headerStat("Pending", "₹${totalPending.toStringAsFixed(0)}"),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Commission Breakup", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${_commissions.length} entries", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xffFF1493)))
                : _commissions.isEmpty
                    ? Center(child: Text("No commission payouts logged yet", style: TextStyle(color: Colors.grey.shade500, fontSize: 15)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: _commissions.length,
                        itemBuilder: (context, index) {
                          final c = _commissions[index];
                          final isPaid = c['status'] == 'Paid';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 46, width: 46,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFF1493).withOpacity(.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.trending_up_rounded, color: Color(0xffFF1493), size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c['trigger_name'] ?? "MLM Affiliate Referral", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                      const SizedBox(height: 3),
                                      Text("Tier ${c['tier_level']} Referral • ${c['created_at']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("₹${c['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff1E1E1E))),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isPaid ? const Color(0xff16C74A).withOpacity(.1) : const Color(0xffFF6B00).withOpacity(.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(c['status'] ?? 'Pending', style: TextStyle(color: isPaid ? const Color(0xff16C74A) : const Color(0xffFF6B00), fontSize: 11, fontWeight: FontWeight.w600)),
                                    ),
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

  Widget _headerStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.3)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}