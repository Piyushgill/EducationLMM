import 'package:flutter/material.dart';

class CentreDetailsScreen extends StatelessWidget {
  const CentreDetailsScreen({super.key});

  static const List<Map<String, dynamic>> centres = [
    {
      'name': 'Centre Alpha',
      'location': 'Connaught Place, Delhi',
      'students': 120,
      'batches': 5,
      'status': 'Active',
    },
    {
      'name': 'Centre Beta',
      'location': 'Lajpat Nagar, Delhi',
      'students': 140,
      'batches': 4,
      'status': 'Active',
    },
    {
      'name': 'Centre Gamma',
      'location': 'Janakpuri, Delhi',
      'students': 80,
      'batches': 3,
      'status': 'Active',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          _detailHeader(
            title: "Centre Details",
            subtitle: "All your centres",
            colors: const [
              Color(0xff7C3AED),
              Color(0xffDB2777),
            ],
            onBack: () => Navigator.pop(context),
            extra: [
              Row(
                children: [
                  _hStatWhite("Total", "3"),
                  const SizedBox(width: 16),
                  _hStatWhite("Students", "340"),
                  const SizedBox(width: 16),
                  _hStatWhite("Batches", "12"),
                ],
              ),
            ],
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: centres.length,
              itemBuilder: (context, index) {
                final centre = centres[index];

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xff7C3AED)
                                  .withOpacity(.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.store_mall_directory_outlined,
                              color: Color(0xff7C3AED),
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
                                  centre['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  centre['location'],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
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
                              color: const Color(0xff16C74A)
                                  .withOpacity(.1),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Active",
                              style: TextStyle(
                                color: Color(0xff16C74A),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          _infoChip(
                            Icons.groups_outlined,
                            "${centre['students']} Students",
                            const Color(0xff2563EB),
                          ),

                          const SizedBox(width: 16),

                          _infoChip(
                            Icons.calendar_view_week_outlined,
                            "${centre['batches']} Batches",
                            const Color(0xff7C3AED),
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

  Widget _detailHeader({
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onBack,
    List<Widget>? extra,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 50,
        bottom: 28,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        gradient: LinearGradient(colors: colors),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
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

          if (extra != null) ...[
            const SizedBox(height: 18),
            ...extra,
          ],
        ],
      ),
    );
  }

  Widget _hStatWhite(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(20),
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
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}