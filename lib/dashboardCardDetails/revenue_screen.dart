import 'package:flutter/material.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  String _selectedPeriod = 'This Month';

  final List<Map<String, dynamic>> invoices = [
    {'school': 'Modern Academy', 'amount': 45000, 'date': '12 Feb 2025', 'status': 'Paid', 'invoice': 'INV-001'},
    {'school': 'Sunrise Public School', 'amount': 32000, 'date': '10 Feb 2025', 'status': 'Paid', 'invoice': 'INV-002'},
    {'school': 'Harmony International', 'amount': 58000, 'date': '08 Feb 2025', 'status': 'Pending', 'invoice': 'INV-003'},
    {'school': 'Delhi Convent School', 'amount': 27000, 'date': '05 Feb 2025', 'status': 'Paid', 'invoice': 'INV-004'},
    {'school': 'Excellence Academy', 'amount': 63000, 'date': '02 Feb 2025', 'status': 'Paid', 'invoice': 'INV-005'},
    {'school': 'Green Valley School', 'amount': 18000, 'date': '28 Jan 2025', 'status': 'Overdue', 'invoice': 'INV-006'},
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid': return const Color(0xff16C74A);
      case 'Pending': return const Color(0xffFF6B00);
      case 'Overdue': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                colors: [Color(0xffFF6B00), Color(0xffFF9500)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 44, width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Revenue Generated", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Total Invoices: 150 Bills", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 20),
                // Revenue Cards
                Row(
                  children: [
                    _revenueCard("Total Revenue", "₹12.5L"),
                    const SizedBox(width: 12),
                    _revenueCard("This Month", "₹2.4L"),
                    const SizedBox(width: 12),
                    _revenueCard("Pending", "₹58K"),
                  ],
                ),
              ],
            ),
          ),

          // Filter
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: ['This Month', 'Last Month', 'All Time'].map((p) {
                final isSelected = _selectedPeriod == p;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = p),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xffFF6B00) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
                    ),
                    child: Text(
                      p,
                      style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Invoices", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${invoices.length} invoices", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final inv = invoices[index];
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
                          color: const Color(0xffFF6B00).withOpacity(.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.receipt_long_outlined, color: Color(0xffFF6B00), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(inv['school'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 3),
                            Text("${inv['invoice']} • ${inv['date']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("₹${(inv['amount'] as int) >= 1000 ? '${((inv['amount'] as int) / 1000).toStringAsFixed(0)}K' : inv['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff1E1E1E))),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor(inv['status']).withOpacity(.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(inv['status'], style: TextStyle(color: _statusColor(inv['status']), fontSize: 11, fontWeight: FontWeight.w600)),
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

  Widget _revenueCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.3)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}