import 'package:flutter/material.dart';

class ActiveSchoolsScreen extends StatefulWidget {
  const ActiveSchoolsScreen({super.key});

  @override
  State<ActiveSchoolsScreen> createState() => _ActiveSchoolsScreenState();
}

class _ActiveSchoolsScreenState extends State<ActiveSchoolsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> schools = [
    {'name': 'Sunrise Public School', 'location': 'Delhi', 'students': 120, 'orderDate': '12 Jan 2025', 'status': 'Active', 'programs': 3},
    {'name': 'Delhi Convent School', 'location': 'Noida', 'students': 85, 'orderDate': '18 Jan 2025', 'status': 'Active', 'programs': 2},
    {'name': 'Modern Academy', 'location': 'Gurgaon', 'students': 200, 'orderDate': '05 Feb 2025', 'status': 'Active', 'programs': 4},
    {'name': 'Green Valley School', 'location': 'Faridabad', 'students': 60, 'orderDate': '22 Jan 2025', 'status': 'Inactive', 'programs': 1},
    {'name': 'Harmony International', 'location': 'Ghaziabad', 'students': 150, 'orderDate': '10 Feb 2025', 'status': 'Active', 'programs': 3},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'All'
        ? schools
        : schools.where((s) => s['status'] == _selectedFilter).toList();

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
                colors: [Color(0xff16C74A), Color(0xff0D9E38)],
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
                Row(
                  children: [
                    Container(
                      height: 52, width: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.school_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Active Schools", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("When Order Placed", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Text("45", style: TextStyle(color: Color(0xff16C74A), fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: ['All', 'Active', 'Inactive'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xff16C74A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // School Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final s = filtered[index];
                final isActive = s['status'] == 'Active';
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 46, width: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xff16C74A).withOpacity(.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.school_outlined, color: Color(0xff16C74A), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text(s['location'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xff16C74A).withOpacity(.1) : Colors.red.withOpacity(.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(s['status'], style: TextStyle(color: isActive ? const Color(0xff16C74A) : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _infoItem(Icons.groups_outlined, "${s['students']} Students", const Color(0xff2563EB)),
                          const SizedBox(width: 7),
                          _infoItem(Icons.menu_book_outlined, "${s['programs']} Programs", const Color(0xffA020F0)),
                          const SizedBox(width: 2),
                          _infoItem(Icons.calendar_today_outlined, s['orderDate'], const Color(0xffFF6B00)),
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

  Widget _infoItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}