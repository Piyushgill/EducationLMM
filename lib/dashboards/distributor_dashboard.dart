import 'package:flutter/material.dart';
import 'package:thenew/Screens/EducationHomeScreen.dart';
import 'package:thenew/Screens/ourprogramsmain.dart';
import 'package:thenew/Screens/profilescreen.dart';
import 'package:thenew/dashboardCardDetails/Expected_Commission_Screen.dart';
import 'package:thenew/dashboardCardDetails/active_schools_screen.dart';
import 'package:thenew/dashboardCardDetails/commission_screen.dart';
import 'package:thenew/dashboardCardDetails/network_size_screen.dart';
import 'package:thenew/dashboardCardDetails/revenue_screen.dart';
import 'package:thenew/dashboardCardDetails/total_students_screen.dart';
import 'package:thenew/dashboardCardDetails/visitors_screen.dart';

class TrainingVideo {
  final String title;
  final String duration;
  final Color color;
  const TrainingVideo({
    required this.title,
    required this.duration,
    required this.color,
  });
}

class Testimonial {
  final String name;
  final String text;
  final int stars;
  const Testimonial({
    required this.name,
    required this.text,
    required this.stars,
  });
}

// ─────────────────────────────────────────────────────────────
//  FAKE API SERVICE  ← replace with your real HTTP calls
// ─────────────────────────────────────────────────────────────

class DashboardApiService {
  /// Replace the bodies of these two methods with your real API calls.
  /// e.g. final res = await http.get(Uri.parse('https://yourapi.com/videos'));

  static Future<List<TrainingVideo>> fetchVideos() async {
    await Future.delayed(const Duration(milliseconds: 900)); // simulate network
    // TODO: parse real JSON here
    return const [
      TrainingVideo(title: "Sales Techniques",
          duration: "12 min",
          color: Color(0xff2563EB)
      ),
      TrainingVideo(title: "How to Approach Schools",
          duration: "18 min", color: Color(0xffA020F0)
      ),
      TrainingVideo(title: "Objection Handling",
          duration: "25 min",
          color: Color(0xffFF6B00)
      ),
      TrainingVideo(title: "Closing Deals",
          duration: "15 min",
          color: Color(0xff16C74A)
      ),
    ];
  }

  static Future<List<Testimonial>> fetchTestimonials() async {
    await Future.delayed(const Duration(milliseconds: 1100)); // simulate network
    // TODO: parse real JSON here
    return const [
      Testimonial(name: "Rajesh Kumar",
          text: "This program has helped me grow my network tremendously.",
          stars: 5),
      Testimonial(name: "Priya Sharma",
          text: "Excellent training support and commission structure.",
          stars: 4),
    ];
  }

  static Future<List<TrainingVideo>> fetchvideos() async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate network
    return const [
      TrainingVideo(title: "Getting Started", duration: "5:20", color: Colors.blue),
      TrainingVideo(title: "Network Growth", duration: "12:45", color: Colors.purple),
      TrainingVideo(title: "Commission Guide", duration: "8:15", color: Colors.orange),
    ];
  }
}
void _confirmAndLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Logout"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx); // close dialog
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const EducationLLMHomeScreen()),
                  (route) => false, // pura stack clear
            );
          },
          child: const Text("Logout", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
// ─────────────────────────────────────────────────────────────
//  ROOT SCAFFOLD
// ─────────────────────────────────────────────────────────────

class DistributorDashboard extends StatefulWidget {
  const DistributorDashboard({super.key});

  @override
  State<DistributorDashboard> createState() => _DistributorDashboardState();
}

class _DistributorDashboardState extends State<DistributorDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const Profilescreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor:  Color(0xff2563EB),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedLabelStyle:  TextStyle(fontWeight: FontWeight.w600),
        items:  [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home"),
          // BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined),
          //     activeIcon: Icon(Icons.menu_book),
          //     label: "Programs"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profile"),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HOME TAB  (StatefulWidget so it can hold Future state)
// ─────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  // Futures are created ONCE in initState so they don't re-fire on rebuild
  late final Future<List<TrainingVideo>> _videosFuture;
  late final Future<List<Testimonial>>   _testimonialsFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture       = DashboardApiService.fetchVideos();
    _testimonialsFuture = DashboardApiService.fetchTestimonials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [Color(0xff2563EB), Color(0xffA020F0)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (ctx) => GestureDetector(
                          onTap: () => Scaffold.of(ctx).openDrawer(),
                          child: Container(
                            height: 48, width: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 48, width: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                          ),
                          Positioned(
                            right: 10, top: 10,
                            child: Container(
                              height: 10, width: 10,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Distributor",
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Welcome back!",
                        style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 16)),
                  ),
                ],
              ),
            ),

            // ── SCROLLABLE BODY ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Dashboard Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: .95,
                      children: [
                        DashboardCard(title: "Network Size",
                            value: "250",
                            icon: Icons.groups_2_outlined,
                            iconColor: const Color(0xff2563EB),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const NetworkSizeScreen())
                            )
                        ),
                        DashboardCard(title: "Active Schools",
                            value: "45",
                            icon: Icons.school_outlined,
                            iconColor: const Color(0xff16C74A),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ActiveSchoolsScreen())
                            )
                        ),
                        DashboardCard(title: "Total Students",
                            value: "1,250",
                            icon: Icons.groups_outlined,
                            iconColor: const Color(0xffA020F0),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const TotalStudentsScreen())
                            )
                        ),
                        DashboardCard(title: "Revenue",
                            value: "₹12.5L",
                            icon: Icons.currency_rupee_rounded,
                            iconColor: const Color(0xffFF6B00),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const RevenueScreen())
                            )
                        ),
                        DashboardCard(title: "Commission",
                            value: "₹1.87L",
                            icon: Icons.trending_up_rounded,
                            iconColor: const Color(0xffFF1493),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const CommissionScreen())
                            )
                        ),
                        DashboardCard(title: "Expected Commission",
                            value: "₹2.5L",
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: const Color(0xff16C74A),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ExpectedCommissionScreen())
                            )
                        ),
                        DashboardCard(title: "Visitors",
                            value: "3,450",
                            icon: Icons.remove_red_eye_outlined,
                            iconColor: const Color(0xff5B5BF6),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const VisitorsScreen())
                            )
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── TRAINING VIDEOS  ──────────────────────
                    _sectionTitle("Training Videos"),
                    const SizedBox(height: 12),
                    FutureBuilder<List<TrainingVideo>>(
                      future: _videosFuture,
                      builder: (context, snap) {
                        // Loading
                        if (snap.connectionState == ConnectionState.waiting) {
                          return _VideoShimmerRow();
                        }
                        // Error
                        if (snap.hasError) {
                          return _SectionError(
                            message: "Couldn't load videos",
                            onRetry: () => setState(() {}),
                          );
                        }
                        // Empty
                        final videos = snap.data ?? [];
                        if (videos.isEmpty) {
                          return _SectionEmpty(label: "No training videos yet");
                        }
                        // Data
                        return SizedBox(
                          height: 130,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: videos.length,
                            itemBuilder: (_, i) => _videoCard(
                              videos[i].title,
                              videos[i].duration,
                              videos[i].color,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── TESTIMONIALS ──────────────────────────
                    _sectionTitle("Testimonials"),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Testimonial>>(
                      future: _testimonialsFuture,
                      builder: (context, snap) {
                        // Loading
                        if (snap.connectionState == ConnectionState.waiting) {
                          return _TestimonialShimmer();
                        }
                        // Error
                        if (snap.hasError) {
                          return _SectionError(
                            message: "Couldn't load testimonials",
                            onRetry: () => setState(() {}),
                          );
                        }
                        // Empty
                        final list = snap.data ?? [];
                        if (list.isEmpty) {
                          return _SectionEmpty(label: "No testimonials yet");
                        }
                        // Data
                        return Column(
                          children: list
                              .map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _testimonialCard(t.name, t.text, t.stars),
                          ))
                              .toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── FAQ ───────────────────────────────────
                    _sectionTitle("FAQ"),
                    const SizedBox(height: 12),
                    _faqItem("How is commission calculated?",
                        "Commission is calculated based on total revenue generated from your network at applicable rates."),
                    _faqItem("When is commission paid?",
                        "Commission is credited to your account on the 7th of every month for the previous month."),
                    _faqItem("How to add a new school?",
                        "Contact the company support team or use the New Lead section to register a school."),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPER WIDGETS ─────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E)),
  );

  Widget _videoCard(String title, String duration, Color color) => Container(
    width: 160,
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.play_circle_filled, color: color, size: 34),
        const Spacer(),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(duration, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      ],
    ),
  );

  Widget _testimonialCard(String name, String text, int stars) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xff2563EB).withOpacity(.1),
              radius: 18,
              child: Text(name[0],
                  style: const TextStyle(color: Color(0xff2563EB), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            Row(children: List.generate(stars, (_) => const Icon(Icons.star, color: Color(0xffFFB800), size: 14))),
          ],
        ),
        const SizedBox(height: 10),
        Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
      ],
    ),
  );

  Widget _faqItem(String q, String a) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)],
    ),
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      iconColor: const Color(0xff2563EB),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Text(a, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ),
      ],
    ),
  );

  Widget _buildDrawer(BuildContext context) => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xff2563EB), Color(0xffA020F0)]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 30,
                child: Icon(Icons.person, size: 35, color: Color(0xff2563EB)),
              ),
              SizedBox(height: 10),
              Text("Distributor Name",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Distributor Account", style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        ListTile(leading: const Icon(Icons.dashboard_outlined), title: const Text('Dashboard'), onTap: () => Navigator.pop(context)),
        ListTile(leading: const Icon(Icons.settings_outlined),  title: const Text('Settings'),  onTap: () {}),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () => _confirmAndLogout(context),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  SHIMMER SKELETON WIDGETS
// ─────────────────────────────────────────────────────────────

/// Animated shimmer base
class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-1.0 + 2 * _anim.value, 0),
          end:   Alignment( 1.0 + 2 * _anim.value, 0),
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}

Widget _shimmerBox({double w = double.infinity, double h = 14, double r = 8}) => Container(
  width: w, height: h,
  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(r)),
);

/// Shimmer row for Training Videos
class _VideoShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, __) => _Shimmer(
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(w: 34, h: 34, r: 17),
                const Spacer(),
                _shimmerBox(h: 12),
                const SizedBox(height: 6),
                _shimmerBox(w: 60, h: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer cards for Testimonials
class _TestimonialShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
            (_) => _Shimmer(
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _shimmerBox(w: 36, h: 36, r: 18),
                    const SizedBox(width: 10),
                    _shimmerBox(w: 110, h: 12),
                  ],
                ),
                const SizedBox(height: 12),
                _shimmerBox(h: 11),
                const SizedBox(height: 6),
                _shimmerBox(w: 200, h: 11),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EMPTY & ERROR STATES
// ─────────────────────────────────────────────────────────────

class _SectionEmpty extends StatelessWidget {
  final String label;
  const _SectionEmpty({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 36),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _SectionError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(color: Colors.red.shade600, fontSize: 13)),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text("Retry", style: TextStyle(color: Color(0xff2563EB))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DASHBOARD CARD (unchanged public API)
// ─────────────────────────────────────────────────────────────

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48, width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: [iconColor, iconColor.withOpacity(.8)]),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
             Spacer(),
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
             SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E))),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}