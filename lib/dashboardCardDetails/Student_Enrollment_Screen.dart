import 'package:flutter/material.dart';

class StudentEnrollmentScreen extends StatelessWidget {
  const StudentEnrollmentScreen({super.key});

  static const List<Map<String, dynamic>> students = [
    {
      'name': 'Anjali Mehta',
      'level': 'Level 3',
      'batch': 'Batch A',
      'centre': 'Centre Alpha',
      'status': 'Active'
    },
    {
      'name': 'Rahul Singh',
      'level': 'Level 1',
      'batch': 'Batch B',
      'centre': 'Centre Beta',
      'status': 'Active'
    },
    {
      'name': 'Priya Jain',
      'level': 'Level 5',
      'batch': 'Batch A',
      'centre': 'Centre Alpha',
      'status': 'Active'
    },
    {
      'name': 'Karan Mehta',
      'level': 'Level 2',
      'batch': 'Batch C',
      'centre': 'Centre Gamma',
      'status': 'Inactive'
    },
    {
      'name': 'Nisha Sharma',
      'level': 'Level 4',
      'batch': 'Batch B',
      'centre': 'Centre Beta',
      'status': 'Active'
    },
    {
      'name': 'Arjun Patel',
      'level': 'Level 6',
      'batch': 'Batch A',
      'centre': 'Centre Alpha',
      'status': 'Active'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      body: Column(
        children: [
          _detailHeader(
            context,
            title: "Student Enrollment",
            subtitle: "${students.length} students enrolled",
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final isActive = student['status'] == "Active";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                        const Color(0xffDB2777).withOpacity(.1),
                        child: Text(
                          student['name'][0],
                          style: const TextStyle(
                            color: Color(0xffDB2777),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              student['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              "${student['level']} • ${student['batch']} • ${student['centre']}",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: (isActive
                              ? const Color(0xff16C74A)
                              : Colors.red)
                              .withOpacity(.1),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(
                          student['status'],
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xff16C74A)
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add Student Logic
        },
        backgroundColor: const Color(0xffDB2777),
        icon: const Icon(
          Icons.person_add_outlined,
          color: Colors.white,
        ),
        label: const Text(
          "Add Student",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _detailHeader(
      BuildContext context, {
        required String title,
        required String subtitle,
      }) {
    return Container(
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
            Color(0xffDB2777),
            Color(0xff9D174D),
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
                color: Colors.white.withOpacity(.2),
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

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}