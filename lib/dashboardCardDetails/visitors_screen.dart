import 'package:flutter/material.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  String _selectedTab = 'All';

  final List<Map<String, dynamic>> visitors = [
    {'name': 'Mrs. Anjali Mehta', 'school': 'Sunrise Public School', 'time': '10:30 AM', 'date': 'Today', 'type': 'School Visit', 'status': 'Converted'},
    {'name': 'Mr. Rakesh Gupta', 'school': 'Interest Inquiry', 'time': '11:00 AM', 'date': 'Today', 'type': 'New Lead', 'status': 'Pending'},
    {'name': 'Mrs. Pooja Agarwal', 'school': 'Modern Academy', 'time': '2:00 PM', 'date': 'Yesterday', 'type': 'Demo Request', 'status': 'Converted'},
    {'name': 'Mr. Sanjay Tiwari', 'school': 'Demo Inquiry', 'time': '3:30 PM', 'date': 'Yesterday', 'type': 'New Lead', 'status': 'Not Interested'},
    {'name': 'Mrs. Kavita Singh', 'school': 'Green Valley School', 'time': '11:30 AM', 'date': '20 Feb', 'type': 'School Visit', 'status': 'Converted'},
    {'name': 'Mr. Deepak Rana', 'school': 'Product Inquiry', 'time': '4:00 PM', 'date': '20 Feb', 'type': 'New Lead', 'status': 'Pending'},
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Converted': return const Color(0xff16C74A);
      case 'Pending': return const Color(0xffFF6B00);
      case 'Not Interested': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'School Visit': return const Color(0xff2563EB);
      case 'New Lead': return const Color(0xffA020F0);
      case 'Demo Request': return const Color(0xff5B5BF6);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final converted = visitors.where((v) => v['status'] == 'Converted').length;
    final pending = visitors.where((v) => v['status'] == 'Pending').length;

    List<Map<String, dynamic>> filtered = _selectedTab == 'All'
        ? visitors
        : visitors.where((v) => v['status'] == _selectedTab).toList();

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
                colors: [Color(0xff5B5BF6), Color(0xff3535C8)],
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
                Row(
                  children: [
                    Container(
                      height: 52, width: 52,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Visits", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("All visitors & leads", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Text("3,450", style: TextStyle(color: Color(0xff5B5BF6), fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _headerChip(Icons.check_circle_outline, "Converted", "$converted"),
                    const SizedBox(width: 5),
                    _headerChip(Icons.pending_outlined, "Pending", "$pending"),
                    const SizedBox(width: 5),
                    _headerChip(Icons.cancel_outlined, "Not Interested", "1"),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: ['All', 'Converted', 'Pending', 'Not Interested'].map((tab) {
                final isSelected = _selectedTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = tab),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xff5B5BF6) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
                    ),
                    child: Text(tab, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 11)),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final v = filtered[index];
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
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: _typeColor(v['type']).withOpacity(.1),
                        child: Text(v['name'].toString().substring(4, 5), style: TextStyle(color: _typeColor(v['type']), fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _typeColor(v['type']).withOpacity(.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(v['type'], style: TextStyle(color: _typeColor(v['type']), fontSize: 10, fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(width: 6),
                                Text("${v['date']} ${v['time']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 8 )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(v['status']).withOpacity(.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(v['status'], style: TextStyle(color: _statusColor(v['status']), fontSize: 11, fontWeight: FontWeight.w600)),
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

  Widget _headerChip(IconData icon, String label, String count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}