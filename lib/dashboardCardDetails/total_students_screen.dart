import 'package:flutter/material.dart';

class TotalStudentsScreen extends StatefulWidget {
  const TotalStudentsScreen({super.key});

  @override
  State<TotalStudentsScreen> createState() => _TotalStudentsScreenState();
}

class _TotalStudentsScreenState extends State<TotalStudentsScreen> {
  String _selectedSchool = 'All Schools';

  final List<Map<String, dynamic>> schoolData = [
    {'school': 'Sunrise Public School', 'students': 120, 'level': 'Level 1-3', 'location': 'Delhi'},
    {'school': 'Delhi Convent School', 'students': 85, 'level': 'Level 2-4', 'location': 'Noida'},
    {'school': 'Modern Academy', 'students': 200, 'level': 'Level 1-5', 'location': 'Gurgaon'},
    {'school': 'Green Valley School', 'students': 60, 'level': 'Level 1-2', 'location': 'Faridabad'},
    {'school': 'Harmony International', 'students': 150, 'level': 'Level 3-6', 'location': 'Ghaziabad'},
    {'school': 'Lotus Academy', 'students': 95, 'level': 'Level 1-4', 'location': 'Greater Noida'},
    {'school': 'Bright Future School', 'students': 130, 'level': 'Level 2-5', 'location': 'Delhi'},
    {'school': 'Star Kids School', 'students': 70, 'level': 'Level 1-3', 'location': 'Noida'},
    {'school': 'Rainbow School', 'students': 110, 'level': 'Level 1-4', 'location': 'Gurgaon'},
    {'school': 'Excellence Academy', 'students': 180, 'level': 'Level 2-6', 'location': 'Faridabad'},
  ];

  @override
  Widget build(BuildContext context) {
    final total = schoolData.fold(0, (sum, s) => sum + (s['students'] as int));

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
                colors: [Color(0xffA020F0), Color(0xff7B10BF)],
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
                      child: const Icon(Icons.groups_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Students", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Across all schools", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Text("1,250", style: TextStyle(color: Color(0xffA020F0), fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary Stats
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _summaryCard("Total Schools", "10", const Color(0xff2563EB)),
                const SizedBox(width: 12),
                _summaryCard("Avg per School", "125", const Color(0xffA020F0)),
                const SizedBox(width: 12),
                _summaryCard("Max in School", "200", const Color(0xff16C74A)),
              ],
            ),
          ),

          // List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Text("School-wise Breakdown", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
                const Spacer(),
                Text("${schoolData.length} schools", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // School List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: schoolData.length,
              itemBuilder: (context, index) {
                final s = schoolData[index];
                final percentage = ((s['students'] as int) / total * 100).toStringAsFixed(1);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40, width: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xffA020F0).withOpacity(.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text("${index + 1}", style: const TextStyle(color: Color(0xffA020F0), fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s['school'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                Text("${s['location']} • ${s['level']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${s['students']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xffA020F0))),
                              Text("$percentage%", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (s['students'] as int) / 200,
                          backgroundColor: const Color(0xffA020F0).withOpacity(.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xffA020F0)),
                          minHeight: 6,
                        ),
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

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}