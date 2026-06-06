import 'package:flutter/material.dart';

class BatchManagementScreen extends StatelessWidget {
  const BatchManagementScreen({super.key});

  static const List<Map<String, dynamic>> batches = [
    {
      'batch': 'Batch A',
      'centre': 'Centre Alpha',
      'program': 'Abacus',
      'students': 25,
      'time': 'Mon/Wed 10:00 AM',
      'status': 'Running'
    },
    {
      'batch': 'Batch B',
      'centre': 'Centre Beta',
      'program': 'Vedic Maths',
      'students': 22,
      'time': 'Tue/Thu 11:30 AM',
      'status': 'Running'
    },
    {
      'batch': 'Batch C',
      'centre': 'Centre Gamma',
      'program': 'Phonics',
      'students': 18,
      'time': 'Fri 9:00 AM',
      'status': 'Running'
    },
    {
      'batch': 'Batch D',
      'centre': 'Centre Alpha',
      'program': 'English',
      'students': 20,
      'time': 'Mon/Fri 2:00 PM',
      'status': 'Upcoming'
    },
    {
      'batch': 'Batch E',
      'centre': 'Centre Beta',
      'program': 'Abacus',
      'students': 15,
      'time': 'Wed/Sat 4:00 PM',
      'status': 'Running'
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
            title: "Batch Management",
            subtitle:
            "${batches.length} batches across 3 centres",
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: batches.length,
              itemBuilder: (context, index) {
                final batch = batches[index];
                final isRunning =
                    batch['status'] == "Running";

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
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
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xff2563EB)
                                  .withOpacity(.1),
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.groups_2_outlined,
                              color: Color(0xff2563EB),
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  batch['batch'],
                                  style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "${batch['centre']} • ${batch['program']}",
                                  style: TextStyle(
                                    color:
                                    Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: (isRunning
                                  ? const Color(
                                  0xff16C74A)
                                  : const Color(
                                  0xffFF6B00))
                                  .withOpacity(.1),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              batch['status'],
                              style: TextStyle(
                                color: isRunning
                                    ? const Color(
                                    0xff16C74A)
                                    : const Color(
                                    0xffFF6B00),
                                fontSize: 12,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          _infoChip(
                            Icons.groups_outlined,
                            "${batch['students']} Students",
                            const Color(0xff2563EB),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: _infoChip(
                              Icons.access_time_outlined,
                              batch['time'],
                              const Color(0xffFF6B00),
                            ),
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

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xff2563EB),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          "Add Batch",
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
            Color(0xff2563EB),
            Color(0xff7C3AED),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius:
                BorderRadius.circular(12),
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

  Widget _infoChip(
      IconData icon,
      String text,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}