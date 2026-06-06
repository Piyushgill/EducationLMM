import 'package:flutter/material.dart';

class FeeCollectionScreen extends StatelessWidget {
  const FeeCollectionScreen({super.key});

  static const List<Map<String, String>> fees = [
    {
      'student': 'Anjali Mehta',
      'amount': '₹2,500',
      'due': '15 Feb 2025',
      'centre': 'Centre Alpha',
      'status': 'Paid'
    },
    {
      'student': 'Rahul Singh',
      'amount': '₹2,000',
      'due': '20 Feb 2025',
      'centre': 'Centre Beta',
      'status': 'Pending'
    },
    {
      'student': 'Priya Jain',
      'amount': '₹3,000',
      'due': '10 Feb 2025',
      'centre': 'Centre Alpha',
      'status': 'Overdue'
    },
    {
      'student': 'Karan Mehta',
      'amount': '₹2,500',
      'due': '25 Feb 2025',
      'centre': 'Centre Gamma',
      'status': 'Paid'
    },
    {
      'student': 'Nisha Sharma',
      'amount': '₹2,000',
      'due': '18 Feb 2025',
      'centre': 'Centre Beta',
      'status': 'Pending'
    },
    {
      'student': 'Arjun Patel',
      'amount': '₹3,500',
      'due': '05 Feb 2025',
      'centre': 'Centre Alpha',
      'status': 'Overdue'
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case "Paid":
        return const Color(0xff16C74A);
      case "Pending":
        return const Color(0xffFF6B00);
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          _detailHeader(
            context,
            title: "Fee Collection",
            subtitle: "Status across all centres",
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: fees.length,
              itemBuilder: (context, index) {
                final fee = fees[index];
                final color = _statusColor(fee['status']!);

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
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: color.withOpacity(.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.payments_outlined,
                          color: color,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fee['student']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${fee['centre']} • Due: ${fee['due']}",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            fee['amount']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              fee['status']!,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
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
            Color(0xff16C74A),
            Color(0xff059669),
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

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _HeaderStat(
                title: "Collected",
                value: "₹1.2L",
              ),
              _HeaderStat(
                title: "Pending",
                value: "₹45K",
              ),
              _HeaderStat(
                title: "Overdue",
                value: "₹8K",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String title;
  final String value;

  const _HeaderStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
}