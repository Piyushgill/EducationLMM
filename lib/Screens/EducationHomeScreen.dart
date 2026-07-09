import 'package:flutter/material.dart';
import 'package:thenew/services/Schooljoinus.dart';
import 'package:thenew/services/Student_joinus.dart';
import 'package:thenew/services/distributorjoinus.dart';
import 'package:thenew/services/franchisejoinus.dart';
import 'package:thenew/services/joinus.dart';
import 'package:thenew/Screens/ourprogram.dart';
import 'package:thenew/Screens/watchdemovideo.dart';

class EducationLLMHomeScreen extends StatelessWidget {
  const EducationLLMHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── HERO HEADER ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff3B82F6),
                      Color(0xffA855F7),
                      Color(0xffEC4899),
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
                    // ── Logo + Title row ──
                    Align(
                      alignment: Alignment.topLeft,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, top: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/image/k-logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Image.asset(
                                'assets/image/kofalt-global-title-logo.png',
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      "Transform Education",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Join India's leading education platform",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 28),

                    InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JoinUsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.15),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Get Started",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff2563EB),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xff2563EB),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── JOIN AS ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Join as",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JoinUsScreen(initialRole: "Distributor"))),
                child: _buildJoinCard(
                  title: "Distributor",
                  subtitle: "Build & manage networks",
                  gradient: const [Color(0xff60A5FA), Color(0xff2563EB)],
                  icon: Icons.trending_up_rounded,
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JoinUsScreen(initialRole: "Franchise Partner"))),
                child: _buildJoinCard(
                  title: "Franchise Partner",
                  subtitle: "Run education center",
                  gradient: const [Color(0xffC084FC), Color(0xffA855F7)],
                  icon: Icons.school_rounded,
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JoinUsScreen(initialRole: "Student"))),
                child: _buildJoinCard(
                  title: "Student",
                  subtitle: "Teach Yourself",
                  gradient: const [Color(0xff22C55E), Color(0xff00B63E)],
                  icon: Icons.person_outline_rounded,
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JoinUsScreen(initialRole: "School"))),
                child: _buildJoinCard(
                  title: "School",
                  subtitle: "Register your institution",
                  gradient: const [Color(0xffF59E0B), Color(0xffD97706)],
                  icon: Icons.domain_outlined,
                ),
              ),

              const SizedBox(height: 30),

              // ── OUR PROGRAMS ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Our Programs",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 22),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => ourprogramsScreen(
                                      scrollTo: "Abacus"))),
                          child: ProgramCard(
                            image:
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS7qqRHwPNe6A_GUXSWGJN3aO6w5sCdylhgHg&s",
                            title: "Abacus",
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => ourprogramsScreen(
                                      scrollTo: "Vadic Maths"))),
                          child: ProgramCard(
                            image:
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6FdUuNQdRwiCwvggqHWGYIUhlnJ9vQr9alTdD8qjTrQ&s",
                            title: "Vedic Maths",
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => ourprogramsScreen(
                                      scrollTo: "Phonics"))),
                          child: ProgramCard(
                            image:
                            "https://cdn-icons-png.flaticon.com/512/2436/2436636.png",
                            title: "Phonics",
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => ourprogramsScreen(
                                      scrollTo: "English"))),
                          child: ProgramCard(
                            image:
                            "https://cdn-icons-png.flaticon.com/512/3898/3898150.png",
                            title: "English",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── WHY CHOOSE US ──
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff2563EB), Color(0xff9333EA)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Why Choose Us?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatsWidget(number: "10K+", label: "Students"),
                        StatsWidget(number: "500+", label: "Centers"),
                        StatsWidget(number: "98%", label: "Success"),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ── WATCH DEMO ──
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => DemoVideoScreen())),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xff2563EB), Color(0xff9333EA)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.15),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Watch Demo Video",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinCard({
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}

class ProgramCard extends StatelessWidget {
  final String image;
  final String title;

  const ProgramCard({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff6f6f8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(image, height: 55, width: 55, fit: BoxFit.contain),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class StatsWidget extends StatelessWidget {
  final String number;
  final String label;

  const StatsWidget({super.key, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 16),
        ),
      ],
    );
  }
}