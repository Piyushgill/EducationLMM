import 'package:flutter/material.dart';

class CommissionScreen extends StatelessWidget {
  const CommissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> commissions = [
      {'school': 'Modern Academy', 'revenue': 63000, 'rate': '15%', 'commission': 9450, 'month': 'Feb 2025', 'status': 'Received'},
      {'school': 'Harmony International', 'revenue': 58000, 'rate': '15%', 'commission': 8700, 'month': 'Feb 2025', 'status': 'Pending'},
      {'school': 'Excellence Academy', 'revenue': 45000, 'rate': '12%', 'commission': 5400, 'month': 'Feb 2025', 'status': 'Received'},
      {'school': 'Sunrise Public School', 'revenue': 32000, 'rate': '12%', 'commission': 3840, 'month': 'Jan 2025', 'status': 'Received'},
      {'school': 'Delhi Convent School', 'revenue': 27000, 'rate': '10%', 'commission': 2700, 'month': 'Jan 2025', 'status': 'Received'},
    ];

    final totalEarned = commissions.fold(0, (sum, c) => sum + (c['commission'] as int));
    final totalPending = commissions.where((c) => c['status'] == 'Pending').fold(0, (sum, c) => sum + (c['commission'] as int));

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
                    _headerStat("Total Earned", "₹1.87L"),
                    const SizedBox(width: 12),
                    _headerStat("Pending", "₹8,700"),
                    const SizedBox(width: 12),
                    _headerStat("Expected", "₹2.5L"),
                  ],
                ),
              ],
            ),
          ),

          // Progress Bar Section
          Padding(
            padding: const EdgeInsets.all(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Target Progress", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const Text("₹1.87L / ₹2.5L", style: TextStyle(color: Color(0xffFF1493), fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.748,
                      backgroundColor: const Color(0xffFF1493).withOpacity(.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xffFF1493)),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("74.8% of monthly target achieved", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Commission Breakup", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${commissions.length} entries", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: commissions.length,
              itemBuilder: (context, index) {
                final c = commissions[index];
                final isReceived = c['status'] == 'Received';
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
                            Text(c['school'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 3),
                            Text("Revenue: ₹${c['revenue']} @ ${c['rate']} • ${c['month']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("₹${c['commission']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff1E1E1E))),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isReceived ? const Color(0xff16C74A).withOpacity(.1) : const Color(0xffFF6B00).withOpacity(.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(c['status'], style: TextStyle(color: isReceived ? const Color(0xff16C74A) : const Color(0xffFF6B00), fontSize: 11, fontWeight: FontWeight.w600)),
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