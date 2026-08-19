import 'package:flutter/material.dart';
import 'package:thenew/services/joinus.dart';

class ourprogramsScreen extends StatefulWidget {
  final String? scrollTo; // "Abacus" | "Vadic Maths" | "Phonics" | "English"

  const ourprogramsScreen({super.key, this.scrollTo});

  @override
  State<ourprogramsScreen> createState() => _ourprogramsScreenState();
}

class _ourprogramsScreenState extends State<ourprogramsScreen> {
  final ScrollController _scrollController = ScrollController();

  // Key for each program card, used to auto-scroll to it
  final Map<String, GlobalKey> _keys = {
    "Abacus": GlobalKey(),
    "Vadic Maths": GlobalKey(),
    "Phonics": GlobalKey(),
    "English": GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    if (widget.scrollTo != null) {
      // wait for the frame to render, then scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSubject(widget.scrollTo!);
      });
    }
  }

  void _scrollToSubject(String subject) {
    final key = _keys[subject];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.05, // keeps the card near the top
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff2563EB),
                      Color(0xffA020F0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Back",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 28),
                    Text(
                      "Our Programs",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Comprehensive curriculum",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // ABACUS CARD
              ProgramCard(
                key: _keys["Abacus"],
                title: "Abacus",
                subtitle: "Develop exceptional mental math abilities",
                levels: "8",
                duration: "4 Years",
                color1: Color(0xff2563EB),
                color2: Color(0xff1D4ED8),
                icon: Icons.calculate_rounded,
                benefits: [
                  "Improves concentration",
                  "Enhances calculation speed",
                  "Boosts confidence",
                  "Develops both brain hemispheres",
                ],
              ),

              SizedBox(height: 22),
              ProgramCard(
                key: _keys["Vadic Maths"],
                title: "Vadic Maths",
                subtitle: "Develop exceptional mental math abilities",
                levels: "8",
                duration: "4 Years",
                color1: Color(0xffF59E0B),
                color2: Color(0xffD97706),
                icon: Icons.plus_one,
                benefits: [
                  "Improves concentration",
                  "Enhances calculation speed",
                  "Boosts confidence",
                  "Develops both brain hemispheres",
                ],
              ),
              SizedBox(height: 22),
              ProgramCard(
                key: _keys["Phonics"],
                title: "Phonics",
                subtitle: "Build strong reading foundation",
                levels: "5",
                duration: "1.5 Years",
                color1: Color(0xff16A34A),
                color2: Color(0xff059669),
                icon: Icons.mic_none_rounded,
                benefits: [
                  "Improves reading skills",
                  "Develops pronunciation",
                  "Builds vocabulary",
                  "Boosts confidence",
                ],
              ),
              SizedBox(height: 22),
              ProgramCard(
                key: _keys["English"],
                title: "English",
                subtitle: "Build strong reading foundation",
                levels: "5",
                duration: "1.5 Years",
                color1: Color(0xffDB2777),
                color2: Color(0xff9333EA),
                icon: Icons.mic_none_rounded,
                benefits: [
                  "Improves reading skills",
                  "Develops pronunciation",
                  "Builds vocabulary",
                  "Boosts confidence",
                ],
              ),

              SizedBox(height: 24),

              // CTA SECTION
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff2563EB),
                      Color(0xffA020F0),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Ready to Get Started?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Join thousands of students benefitting from our programs",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.92),
                        fontSize: 18,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 28),
                    InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinUsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Text(
                          "Enroll Now",
                          style: TextStyle(
                            color: Color(0xff2563EB),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Program card Method
class ProgramCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String levels;
  final String duration;
  final Color color1;
  final Color color2;
  final IconData icon;
  final List<String> benefits;

  const ProgramCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.levels,
    required this.duration,
    required this.color1,
    required this.color2,
    required this.icon,
    required this.benefits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(26),
              ),
              gradient: LinearGradient(
                colors: [
                  color1,
                  color2,
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(.92),
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22),
                Row(
                  children: [
                    Text(
                      "Levels: $levels",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 26),
                    Text(
                      "Duration: $duration",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // BENEFITS SECTION
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Key Benefits",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_up_rounded),
                  ],
                ),
                SizedBox(height: 18),
                Column(
                  children: benefits.map((e) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: Color(0xff22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),

                // VIDEO BOX
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xff06122F),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// BOTTOM NAV ITEM
class BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const BottomItem({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}