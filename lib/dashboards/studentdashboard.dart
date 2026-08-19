import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thenew/services/login_screen.dart';
import 'package:thenew/dashboards/super_admin_dashboard.dart';
import 'package:thenew/Screens/EducationHomeScreen.dart';
import 'package:thenew/Screens/profilescreen.dart';

import 'package:thenew/widgets/notification_bell.dart';
// ============================================================
//  STUDENT DASHBOARD — Main Entry
// ============================================================

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const _StudentHomeTab(),
    const _PracticeTab(),
    const _VideosTab(),
    const _StudentProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StudentProfileScreen(),
              ),
            );
            return;
          }

          setState(() {
            _currentIndex = i;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff10B981),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),         activeIcon: Icon(Icons.home),         label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz_outlined),          activeIcon: Icon(Icons.quiz),          label: "Practice"),
          BottomNavigationBarItem(icon: Icon(Icons.play_lesson_outlined),   activeIcon: Icon(Icons.play_lesson),   label: "Videos"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),         activeIcon: Icon(Icons.person),        label: "Profile"),
        ],
      ),
    );
  }
}

// ============================================================
//  HOME TAB
// ============================================================

class _StudentHomeTab extends StatefulWidget {
  const _StudentHomeTab();

  @override
  State<_StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<_StudentHomeTab> {
  String _studentName = "Student";
  String _studentEmail = "";
  bool _isLoading = false;
  int _testsDone = 0;
  String _bestScore = "0/50";
  List<dynamic> _attempts = [];

  // --- Real progress state (was hardcoded before) ---
  int _currentLevel = 1;      // next level the student should attempt
  double _levelProgress = 0.0; // 0..1, fraction of the 8 levels passed

  @override
  void initState() {
    super.initState();
    _loadSessionAndData();
  }

  Future<void> _loadSessionAndData() async {
    final session = await SessionManager.getSession();
    if (session != null) {
      if (mounted) {
        setState(() {
          _studentName = session['name'] ?? "Student";
          _studentEmail = session['email'] ?? "";
        });
      }
      _fetchPracticeHistory(session['id']);
    }
  }

  Future<void> _fetchPracticeHistory(dynamic studentId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("https://apps.kofalt.in/api/get_practice_history.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"student_id": studentId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> list = data['data'];
          int best = 0;

          // A level counts as "passed" once the student scores 40/50 or
          // more on it (same passing bar used in the FAQ text below).
          const int passMark = 40;
          const int totalLevels = 8;
          final Set<int> passedLevels = {};

          for (var item in list) {
            final sc = item['score'] as int? ?? 0;
            final lvl = item['level'] as int? ?? 0;
            if (sc > best) best = sc;
            if (sc >= passMark && lvl > 0) passedLevels.add(lvl);
          }

          final int maxPassed = passedLevels.isEmpty
              ? 0
              : passedLevels.reduce((a, b) => a > b ? a : b);
          final int nextLevel = (maxPassed + 1).clamp(1, totalLevels);
          final double progress = passedLevels.length / totalLevels;

          if (mounted) {
            setState(() {
              _attempts = list;
              _testsDone = list.length;
              _bestScore = "$best/50";
              _currentLevel = nextLevel;
              _levelProgress = progress.clamp(0.0, 1.0);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching practice history: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openSettings(BuildContext context) {
    Navigator.pop(context); // close drawer first
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _SettingsScreen()),
    );
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
            onPressed: () async {
              final nav = Navigator.of(context);
              Navigator.pop(ctx); // close dialog
              final session = await SessionManager.getSession();
              if (session != null && session['is_impersonating'] == true) {
                await SessionManager.saveSession(
                  id: 1,
                  name: "Super Admin",
                  email: "admin@educationlmm.com",
                  phone: "9999999999",
                  role: "Super Admin",
                  kycStatus: "Approved",
                );
                nav.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SuperAdminDashboard()),
                      (route) => false,
                );
              } else {
                await SessionManager.clearSession();
                nav.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarLetter = _studentName.isNotEmpty ? _studentName.substring(0, 1).toUpperCase() : "S";
    final int progressPercent = (_levelProgress * 100).round();

    return Scaffold(
      drawer: Drawer(
        width: 280,
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff10B981), Color(0xff059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 78,
                          width: 78,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.18),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(.35), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              _studentName.isNotEmpty ? _studentName[0].toUpperCase() : "S",
                              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _studentName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _studentEmail.isNotEmpty ? _studentEmail : "Student Account",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white.withOpacity(.82), fontSize: 12),
                              ),
                              const SizedBox(height: 9),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.16),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "STUDENT",
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: .5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(children: [
                              Text("$_testsDone", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text("Tests", style: TextStyle(color: Colors.white.withOpacity(.75), fontSize: 10)),
                            ]),
                          ),
                          Container(height: 26, width: 1, color: Colors.white24),
                          Expanded(
                            child: Column(children: [
                              Text(_bestScore, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text("Best Score", style: TextStyle(color: Colors.white.withOpacity(.75), fontSize: 10)),
                            ]),
                          ),
                          Container(height: 26, width: 1, color: Colors.white24),
                          Expanded(
                            child: Column(children: [
                              Text("L$_currentLevel", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text("Level", style: TextStyle(color: Colors.white.withOpacity(.75), fontSize: 10)),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 6),
                      child: Text("MAIN MENU",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade400, letterSpacing: 1.2)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home, color: Color(0xff10B981)),
                      title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () => Navigator.pop(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person, color: Color(0xff10B981)),
                      title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentProfileScreen()));
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Color(0xff10B981)),
                      title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () => _openSettings(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Divider()),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 6),
                      child: Text("ACCOUNT",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade400, letterSpacing: 1.2)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                      onTap: () => _confirmAndLogout(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff10B981), Color(0xff059669)]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8), // Gap between menu and logo

                  Image.asset(
                    'assets/image/kmain.png',
                    height: 54,
                    width: 145,        // 👈 jitna bada chahiye utna badha do
                    fit: BoxFit.fill,  // 👈 yahi "stretch" effect deta hai
                  ),

                  const Spacer(),

                  const NotificationBell(role: "Student"),

                  const SizedBox(width: 10),

                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(.2),
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Student",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Hello, $_studentName! 👋",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 16),
              // Progress card in header — now driven by real attempt data
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.3))),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Current Level", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("Level $_currentLevel - Abacus", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _levelProgress,
                        backgroundColor: const Color(0x4DFFFFFF),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("$progressPercent% Complete", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ])),
                  const SizedBox(width: 16),
                  Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(.2), shape: BoxShape.circle), child: const Icon(Icons.emoji_events_outlined, color: Colors.white, size: 30)),
                ]),
              ),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // QUICK ACTION CARDS (no DashboardCards — student only has content)
                _sectionTitle("My Progress"),
                const SizedBox(height: 12),
                Row(children: [
                  _quickStatCard("Tests Done",    "$_testsDone",    const Color(0xff10B981)),
                  const SizedBox(width: 12),
                  _quickStatCard("Best Score",    _bestScore, const Color(0xff0EA5E9)),
                  const SizedBox(width: 12),
                  _quickStatCard("Current Level", "$_currentLevel",    const Color(0xffA020F0)),
                ]),

                const SizedBox(height: 24),

                // PAST TEST RESULTS
                _sectionTitle("My Test Results"),
                const SizedBox(height: 12),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xff10B981)))
                else if (_attempts.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: Text(
                        "No practice tests completed yet",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ..._attempts.map((attempt) {
                    final int lvl = attempt['level'] as int? ?? 1;
                    final int sc = attempt['score'] as int? ?? 0;
                    final String grade = sc >= 45 ? "A+" : (sc >= 40 ? "A" : "B");
                    final String dt = attempt['created_at'] != null ? attempt['created_at'].toString().split(' ')[0] : "Recently";
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _resultCard("Level $lvl", "$sc/50", dt, grade),
                    );
                  }).toList(),

                const SizedBox(height: 24),

                // QUICK START PRACTICE
                _sectionTitle("Quick Start Practice"),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeTestScreen(level: _currentLevel))),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xff10B981), Color(0xff059669)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      const Icon(Icons.play_circle_fill, color: Colors.white, size: 44),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Continue Level $_currentLevel", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("50 Questions • Abacus", style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 13)),
                      ])),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                    ]),
                  ),
                ),

                const SizedBox(height: 24),

                // EDUCATION VIDEOS PREVIEW
                _sectionTitle("Education Videos"),
                const SizedBox(height: 12),
                ...[
                  {'title': 'Abacus Basics - Level 1', 'duration': '15 min', 'color': const Color(0xff10B981)},
                  {'title': 'Speed Calculation Tips',  'duration': '22 min', 'color': const Color(0xff0EA5E9)},
                  {'title': 'Level 3 Techniques',      'duration': '18 min', 'color': const Color(0xffA020F0)},
                  {'title': 'Practice Methods',        'duration': '25 min', 'color': const Color(0xffFF6B00)},
                ].map((v) => _videoListCard(v['title'] as String, v['duration'] as String, v['color'] as Color)).toList(),

                const SizedBox(height: 24),

                // FAQ
                _sectionTitle("FAQ"),
                const SizedBox(height: 12),
                _faqItem("How many questions per test?",  "Each practice test has 50 questions. You need to answer all and submit to see your score summary."),
                _faqItem("How are levels unlocked?",      "Complete the current level test with a passing score of 40/50 or above to unlock the next level."),
                _faqItem("Can I retake a test?",          "Yes! You can retake any unlocked level test as many times as you want for practice."),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E)));

  Widget _quickStatCard(String label, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11), textAlign: TextAlign.center),
      ]),
    ),
  );

  Widget _resultCard(String level, String score, String date, String grade) {
    final Color gradeColor = grade == 'A+' ? const Color(0xff10B981) : const Color(0xff0EA5E9);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
      child: Row(children: [
        Container(height: 44, width: 44, decoration: BoxDecoration(color: gradeColor.withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(grade, style: TextStyle(color: gradeColor, fontWeight: FontWeight.bold, fontSize: 15)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(level, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text("Completed on $date", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ])),
        Text(score, style: TextStyle(color: gradeColor, fontWeight: FontWeight.bold, fontSize: 18)),
      ]),
    );
  }

  Widget _videoListCard(String title, String duration, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
    child: Row(children: [
      Container(height: 44, width: 44, decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.play_circle_filled, color: color, size: 28)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(duration, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ])),
      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
    ]),
  );

  Widget _faqItem(String q, String a) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)]),
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      iconColor: const Color(0xff10B981),
      children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 14), child: Text(a, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)))],
    ),
  );
}

// ============================================================
//  SIMPLE SETTINGS SCREEN (wired up from drawer)
// ============================================================

class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen();

  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  bool _notifications = true;
  bool _soundEffects = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, right: 24, top: 16, bottom: 28),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
              gradient: LinearGradient(colors: [Color(0xff10B981), Color(0xff059669)]),
            ),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                visualDensity: VisualDensity.compact,
              ),
              const Text("Settings", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _settingsTile(
                  icon: Icons.notifications_outlined,
                  title: "Notifications",
                  subtitle: "Get reminders for new tests and videos",
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                _settingsTile(
                  icon: Icons.volume_up_outlined,
                  title: "Sound Effects",
                  subtitle: "Play sounds on correct/incorrect answers",
                  value: _soundEffects,
                  onChanged: (v) => setState(() => _soundEffects = v),
                ),
                _settingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: "Dark Mode",
                  subtitle: "Switch to a darker theme",
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
      child: Row(children: [
        Container(height: 44, width: 44, decoration: BoxDecoration(color: const Color(0xff10B981).withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xff10B981))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ])),
        Switch(value: value, activeColor: const Color(0xff10B981), onChanged: onChanged),
      ]),
    );
  }
}

// ============================================================
//  PRACTICE TAB — 8 Level Selector (all levels unlocked)
// ============================================================

class _PracticeTab extends StatelessWidget {
  const _PracticeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            gradient: LinearGradient(colors: [Color(0xff10B981), Color(0xff059669)]),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Practice Tests", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Choose a category to begin practice", style: TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: kMathCategories.length,
            itemBuilder: (context, index) {
              final cat = kMathCategories[index];
              final isColored = cat.color != Colors.white;
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MathSubLevelScreen(categoryInfo: cat)),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cat.color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    cat.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isColored ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ])),
    );
  }
}
class MathSubLevelScreen extends StatelessWidget {
  final MathCategoryInfo categoryInfo;
  const MathSubLevelScreen({super.key, required this.categoryInfo});

  static const List<Color> _rowColors = [
    Color(0xff1E9EE0), Colors.white, Color(0xffEC1E79),
    Color(0xff1E9EE0), Colors.white, Color(0xffEC1E79),
  ];

  @override
  Widget build(BuildContext context) {
    final isTitleColored = categoryInfo.color != Colors.white;
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            gradient: LinearGradient(colors: [Color(0xff10B981), Color(0xff059669)]),
          ),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 40, width: 40,
                decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(categoryInfo.title.replaceAll('\n', ' '),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                width: 220,
                padding: const EdgeInsets.symmetric(vertical: 16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: categoryInfo.color,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                alignment: Alignment.center,
                child: Text(
                  categoryInfo.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isTitleColored ? Colors.white : Colors.black87),
                ),
              ),
              ...List.generate(kColRowOptions.length, (i) {
                final opt = kColRowOptions[i];
                final color = _rowColors[i % _rowColors.length];
                final isColored = color != Colors.white;
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MathPracticeScreen(categoryInfo: categoryInfo, option: opt)),
                  ),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: color, border: Border.all(color: Colors.grey.shade300)),
                    alignment: Alignment.center,
                    child: Text(
                      opt.label,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isColored ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ])),
    );
  }
}
class MathPracticeScreen extends StatefulWidget {
  final MathCategoryInfo categoryInfo;
  final ColRowOption option;
  const MathPracticeScreen({super.key, required this.categoryInfo, required this.option});

  @override
  State<MathPracticeScreen> createState() => _MathPracticeScreenState();
}

class _MathPracticeScreenState extends State<MathPracticeScreen> {
  static const int _totalQuestions = 50;
  static const int _secondsPerQuestion = 20;

  late final List<MathQuestion> _questions;
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;
  final _ansCtrl = TextEditingController();
  bool? _isCorrect;
  int _score = 0;

  Timer? _timer;
  int _secondsLeft = _secondsPerQuestion;

  @override
  void initState() {
    super.initState();
    _questions = List.generate(
      _totalQuestions,
          (_) => MathQuestionGenerator.generate(widget.categoryInfo.category, widget.option.columns, widget.option.rows),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ansCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
      });
      if (_secondsLeft <= 0) {
        t.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    if (_isCorrect != null) return; // already answered
    final q = _questions[_currentIndex];
    setState(() {
      _isCorrect = false; // time out = counted wrong
    });
    // Small delay so user sees "Time's up" state, then unlocks the Next button (already shown)
  }

  void _checkAnswer() {
    if (_isCorrect != null) return; // prevent double-submit
    final entered = _ansCtrl.text.trim();
    if (entered.isEmpty) return;
    _timer?.cancel();
    final q = _questions[_currentIndex];
    final correct = double.tryParse(entered) != null && double.tryParse(q.answer) != null
        ? (double.parse(entered) - double.parse(q.answer)).abs() < 0.01
        : entered == q.answer;
    setState(() {
      _isCorrect = correct;
      if (correct) _score++;
    });
  }

  void _next() {
    _timer?.cancel();
    if (_currentIndex < _totalQuestions - 1) {
      setState(() {
        _currentIndex++;
        _ansCtrl.clear();
        _isCorrect = null;
      });
      _pageCtrl.animateToPage(_currentIndex, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      _startTimer();
    } else {
      _showSummary();
    }
  }

  void _showSummary() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.emoji_events, color: Color(0xffEC1E79), size: 48),
          const SizedBox(height: 12),
          Text("Score: $_score / $_totalQuestions", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  Color get _timerColor {
    if (_secondsLeft <= 5) return Colors.red;
    if (_secondsLeft <= 10) return Colors.orange;
    return const Color(0xff10B981);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F0F5),
      body: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: const Color(0xffEC1E79), borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.option.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 28),
              ],
            ),
          ),

          // ── Progress + Timer Row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Question ${_currentIndex + 1} of $_totalQuestions",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: _timerColor),
                    const SizedBox(width: 4),
                    Text(
                      "${_secondsLeft}s",
                      style: TextStyle(color: _timerColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Timer progress bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _secondsLeft / _secondsPerQuestion,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
              ),
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _totalQuestions,
              itemBuilder: (context, index) {
                final q = _questions[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(9, (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text("${i + 1}", style: TextStyle(color: Colors.grey.shade300, fontSize: 13)),
                      )),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xffEC1E79), borderRadius: BorderRadius.circular(24)),
                      child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      width: 210,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xffFDF3D0),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                      ),
                      child: Column(
                        children: q.lines.map((l) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(l, style: const TextStyle(fontSize: 26, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Ans.", style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 14),
                        Container(
                          width: 130,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _isCorrect == null ? Colors.grey.shade300 : (_isCorrect! ? Colors.green : Colors.red),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _ansCtrl,
                            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            textAlign: TextAlign.center,
                            enabled: _isCorrect == null,
                            onSubmitted: (_) => _checkAnswer(),
                            decoration: const InputDecoration(border: InputBorder.none),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    if (_isCorrect == null)
                      GestureDetector(
                        onTap: _checkAnswer,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Check answer", style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 14),
                            Container(
                              width: 130, height: 44,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade300)),
                              alignment: Alignment.center,
                              child: const Icon(Icons.check, color: Color(0xff10B981)),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(children: [
                        Text(
                          _isCorrect!
                              ? "Correct! 🎉"
                              : (_ansCtrl.text.trim().isEmpty
                              ? "⏱ Time's up! Answer: ${q.answer}"
                              : "Wrong — Answer: ${q.answer}"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isCorrect! ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff10B981),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            _currentIndex == _totalQuestions - 1 ? "Finish" : "Next Question",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ============================================================
//  VIDEOS TAB
// ============================================================

class _VideosTab extends StatefulWidget {
  const _VideosTab();

  @override
  State<_VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<_VideosTab> {
  bool _isLoading = false;
  List<dynamic> _courses = [];

  Future<void> _fetchVideos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("https://apps.kofalt.in/api/admin/get_courses.php"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _courses = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching videos: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allLessons = [];
    for (final course in _courses) {
      final String courseTitle = course['title'] ?? "";
      final List<dynamic> chapters = course['chapters'] ?? [];
      for (final ch in chapters) {
        allLessons.add({
          'course_title': courseTitle,
          'title': ch['title'] ?? "",
          'chapter_number': ch['chapter_number'] ?? 1,
          'resource_url': ch['resource_url'] ?? "",
        });
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            gradient: LinearGradient(colors: [Color(0xff10B981), Color(0xff059669)]),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Education Videos", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("${allLessons.length} lessons available", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xff10B981)))
              : allLessons.isEmpty
              ? const Center(child: Text("No video lessons published yet.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: allLessons.length,
            itemBuilder: (_, i) {
              final lesson = allLessons[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
                child: Row(children: [
                  Container(
                      height: 48, width: 48,
                      decoration: BoxDecoration(color: const Color(0xff10B981).withOpacity(.1), borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.play_circle_filled, color: Color(0xff10B981), size: 30)
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Ch ${lesson['chapter_number']}: ${lesson['title']}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(lesson['course_title'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ])),
                  IconButton(
                    onPressed: () {
                      if (lesson['resource_url'] != null && lesson['resource_url'].isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Playing lesson: ${lesson['resource_url']}")),
                        );
                      }
                    },
                    icon: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
                    visualDensity: VisualDensity.compact,
                  ),
                ]),
              );
            },
          ),
        ),
      ])),
    );
  }
}

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState
    extends State<StudentProfileScreen> {

  static const Color primary = Color(0xff10B981);
  static const Color primaryDark = Color(0xff059669);

  String name = "Student";
  String email = "";
  String phone = "";
  String role = "Student";
  String kycStatus = "Pending";

  int testsDone = 0;
  int bestScore = 0;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final session =
      await SessionManager.getSession();

      if (session == null) return;

      setState(() {
        name =
            session['name']?.toString() ??
                "Student";

        email =
            session['email']?.toString() ??
                "";

        phone =
            session['phone']?.toString() ??
                "";

        role =
            session['role']?.toString() ??
                "Student";

        kycStatus =
            session['kyc_status']?.toString() ??
                "Pending";
      });

      final studentId =
      session['id'];

      final response =
      await http.post(
        Uri.parse(
          "https://apps.kofalt.in/api/get_practice_history.php",
        ),
        headers: {
          "Content-Type":
          "application/json",
        },
        body: jsonEncode({
          "student_id": studentId,
        }),
      );

      if (response.statusCode == 200) {
        final data =
        jsonDecode(
          response.body,
        );

        if (data['status'] ==
            'success' &&
            data['data'] != null) {

          final List<dynamic> attempts =
          data['data'];

          int best = 0;

          for (final item in attempts) {

            final score =
                int.tryParse(
                  item['score']
                      .toString(),
                ) ??
                    0;

            if (score > best) {
              best = score;
            }
          }

          testsDone =
              attempts.length;

          bestScore =
              best;
        }
      }

    } catch (e) {
      debugPrint(
        "Student profile error: $e",
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Color get kycColor {
    switch (kycStatus.toLowerCase()) {
      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  IconData get kycIcon {
    switch (kycStatus.toLowerCase()) {
      case "approved":
        return Icons.verified_rounded;

      case "rejected":
        return Icons.cancel_rounded;

      default:
        return Icons.pending_rounded;
    }
  }

  Future<void> logout() async {

    final confirm =
    await showDialog<bool>(
      context: context,

      builder: (ctx) =>
          AlertDialog(
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                18,
              ),
            ),

            title:
            const Text(
              "Logout",
              style:
              TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            content:
            const Text(
              "Are you sure you want to logout?",
            ),

            actions: [

              TextButton(
                onPressed: () =>
                    Navigator.pop(
                      ctx,
                      false,
                    ),
                child:
                const Text(
                  "Cancel",
                ),
              ),

              TextButton(
                onPressed: () =>
                    Navigator.pop(
                      ctx,
                      true,
                    ),
                child:
                const Text(
                  "Logout",
                  style:
                  TextStyle(
                    color:
                    Colors.red,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    await SessionManager.clearSession();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (_) =>
        const LoginScreen(),
      ),

          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    final initial =
    name.isNotEmpty
        ? name
        .trim()[0]
        .toUpperCase()
        : "S";

    return Scaffold(
      backgroundColor:
      const Color(0xffF5F7FA),

      body: SafeArea(
        child:
        RefreshIndicator(
          color:
          primary,

          onRefresh:
          loadProfile,

          child:
          SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            child:
            Column(
              children: [

                // HEADER
                Container(
                  width:
                  double.infinity,

                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    20,
                    18,
                    20,
                    34,
                  ),

                  decoration:
                  const BoxDecoration(
                    gradient:
                    LinearGradient(
                      colors: [
                        primary,
                        primaryDark,
                      ],
                    ),

                    borderRadius:
                    BorderRadius.only(
                      bottomLeft:
                      Radius.circular(
                        30,
                      ),
                      bottomRight:
                      Radius.circular(
                        30,
                      ),
                    ),
                  ),

                  child:
                  Column(
                    children: [

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                        children: [

                          _button(
                            Icons
                                .arrow_back_ios_new_rounded,
                                () =>
                                Navigator.pop(
                                  context,
                                ),
                          ),

                          const Text(
                            "Profile",
                            style:
                            TextStyle(
                              color:
                              Colors.white,
                              fontSize:
                              20,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          _button(
                            Icons.settings_outlined,
                                () {},
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // AVATAR
                      Container(
                        width:
                        92,
                        height:
                        92,

                        decoration:
                        BoxDecoration(
                          color:
                          Colors.white,
                          shape:
                          BoxShape.circle,
                          border:
                          Border.all(
                            color:
                            Colors.white,
                            width:
                            3,
                          ),
                        ),

                        child:
                        Center(
                          child:
                          Text(
                            initial,
                            style:
                            const TextStyle(
                              color:
                              primary,
                              fontSize:
                              38,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Text(
                        name,
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                          fontSize:
                          20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        email.isEmpty
                            ? "Email not available"
                            : email,

                        style:
                        const TextStyle(
                          color:
                          Colors.white70,
                          fontSize:
                          12,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal:
                          13,
                          vertical:
                          6,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          Colors.white24,
                          borderRadius:
                          BorderRadius
                              .circular(
                            20,
                          ),
                        ),

                        child:
                        Text(
                          role,
                          style:
                          const TextStyle(
                            color:
                            Colors.white,
                            fontSize:
                            11,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // STATS
                Transform.translate(
                  offset:
                  const Offset(
                    0,
                    -22,
                  ),

                  child:
                  Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal:
                      18,
                    ),

                    child:
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        vertical:
                        18,
                      ),

                      decoration:
                      BoxDecoration(
                        color:
                        Colors.white,
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black
                                .withOpacity(
                              .07,
                            ),
                            blurRadius:
                            14,
                            offset:
                            const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),

                      child:
                      Row(
                        children: [

                          _stat(
                            Icons
                                .quiz_outlined,
                            "Tests",
                            "$testsDone",
                          ),

                          _divider(),

                          _stat(
                            Icons
                                .emoji_events_outlined,
                            "Best Score",
                            "$bestScore/50",
                          ),

                          _divider(),

                          _stat(
                            Icons
                                .school_outlined,
                            "Role",
                            "Student",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    18,
                    0,
                    18,
                    30,
                  ),

                  child:
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      _title(
                        "PERSONAL INFORMATION",
                      ),

                      _info(
                        Icons
                            .person_outline_rounded,
                        "Full Name",
                        name,
                      ),

                      _info(
                        Icons
                            .email_outlined,
                        "Email Address",
                        email,
                      ),

                      _info(
                        Icons
                            .phone_outlined,
                        "Phone Number",
                        phone,
                      ),

                      _info(
                        Icons
                            .school_outlined,
                        "Account Role",
                        role,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _title(
                        "ACCOUNT STATUS",
                      ),

                      _status(),

                      const SizedBox(
                        height: 20,
                      ),

                      _title(
                        "ACCOUNT",
                      ),

                      _action(
                        Icons
                            .lock_outline_rounded,
                        "Change Password",
                      ),

                      _action(
                        Icons
                            .notifications_none_rounded,
                        "Notifications",
                      ),

                      _action(
                        Icons
                            .help_outline_rounded,
                        "Help & Support",
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _logout(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _button(
      IconData icon,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(
        12,
      ),
      child:
      Container(
        width: 42,
        height: 42,
        decoration:
        BoxDecoration(
          color:
          Colors.white24,
          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),
        child:
        Icon(
          icon,
          color:
          Colors.white,
          size:
          19,
        ),
      ),
    );
  }

  Widget _stat(
      IconData icon,
      String title,
      String value,
      ) {
    return Expanded(
      child:
      Column(
        children: [

          Icon(
            icon,
            color:
            primary,
            size:
            21,
          ),

          const SizedBox(
            height:
            5,
          ),

          Text(
            value,
            style:
            const TextStyle(
              fontSize:
              14,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height:
            2,
          ),

          Text(
            title,
            style:
            TextStyle(
              color:
              Colors.grey.shade500,
              fontSize:
              10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width:
      1,
      height:
      42,
      color:
      Colors.grey.shade200,
    );
  }

  Widget _title(String text) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom:
        12,
      ),
      child:
      Text(
        text,
        style:
        TextStyle(
          color:
          Colors.grey.shade500,
          fontSize:
          10,
          fontWeight:
          FontWeight.bold,
          letterSpacing:
          1,
        ),
      ),
    );
  }

  Widget _info(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom:
        10,
      ),
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),
      child:
      Row(
        children: [

          Container(
            width:
            42,
            height:
            42,
            decoration:
            BoxDecoration(
              color:
              primary.withOpacity(
                .10,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child:
            Icon(
              icon,
              color:
              primary,
            ),
          ),

          const SizedBox(
            width:
            12,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [

                Text(
                  title,
                  style:
                  TextStyle(
                    color:
                    Colors.grey
                        .shade500,
                    fontSize:
                    10,
                  ),
                ),

                const SizedBox(
                  height:
                  3,
                ),

                Text(
                  value.isEmpty
                      ? "Not available"
                      : value,
                  style:
                  const TextStyle(
                    fontSize:
                    13,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _status() {
    return Container(
      padding:
      const EdgeInsets.all(
        15,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),
      child:
      Row(
        children: [

          Container(
            width:
            44,
            height:
            44,
            decoration:
            BoxDecoration(
              color:
              kycColor.withOpacity(
                .10,
              ),
              borderRadius:
              BorderRadius.circular(
                13,
              ),
            ),
            child:
            Icon(
              kycIcon,
              color:
              kycColor,
            ),
          ),

          const SizedBox(
            width:
            12,
          ),

          const Expanded(
            child:
            Text(
              "KYC Verification",
              style:
              TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),

          Text(
            kycStatus,
            style:
            TextStyle(
              color:
              kycColor,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(
      IconData icon,
      String title,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom:
        10,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),
      child:
      ListTile(
        leading:
        Container(
          width:
          40,
          height:
          40,
          decoration:
          BoxDecoration(
            color:
            primary.withOpacity(
              .10,
            ),
            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),
          child:
          Icon(
            icon,
            color:
            primary,
            size:
            20,
          ),
        ),
        title:
        Text(
          title,
          style:
          const TextStyle(
            fontSize:
            13,
            fontWeight:
            FontWeight.w600,
          ),
        ),
        trailing:
        Icon(
          Icons
              .arrow_forward_ios_rounded,
          size:
          13,
          color:
          Colors.grey.shade400,
        ),
        onTap:
            () {},
      ),
    );
  }

  Widget _logout() {
    return InkWell(
      onTap:
      logout,
      borderRadius:
      BorderRadius.circular(
        16,
      ),
      child:
      Container(
        width:
        double.infinity,
        padding:
        const EdgeInsets
            .symmetric(
          vertical:
          15,
        ),
        decoration:
        BoxDecoration(
          color:
          const Color(
            0xffFEF2F2,
          ),
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          border:
          Border.all(
            color:
            const Color(
              0xffFECACA,
            ),
          ),
        ),
        child:
        const Row(
          mainAxisAlignment:
          MainAxisAlignment
              .center,
          children: [

            Icon(
              Icons
                  .logout_rounded,
              color:
              Colors.red,
            ),

            SizedBox(
              width:
              8,
            ),

            Text(
              "Logout",
              style:
              TextStyle(
                color:
                Colors.red,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// STUB PROFILE TAB
class _StudentProfileTab extends StatelessWidget {
  const _StudentProfileTab();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xffF5F5F5),
    body: SafeArea(child: Column(children: [
      Container(
        width: double.infinity, padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)), gradient: LinearGradient(colors: [Color(0xff10B981), Color(0xff059669)])),
        child: const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
      ),
      const Expanded(child: Center(child: Text("Coming Soon", style: TextStyle(color: Colors.grey, fontSize: 16)))),
    ])),
  );
}

// ============================================================
//  PRACTICE TEST SCREEN — 50 Questions, randomized per attempt
// ============================================================

class PracticeTestScreen extends StatefulWidget {
  final int level;
  const PracticeTestScreen({super.key, required this.level});

  @override
  State<PracticeTestScreen> createState() => _PracticeTestScreenState();
}

class _PracticeTestScreenState extends State<PracticeTestScreen> {
  final Map<int, int> _answers = {};
  bool _submitted = false;
  int _score = 0;

  // Bumped every time the user retries -> changes the random seed below,
  // so a fresh attempt gets a different set of questions instead of the
  // exact same a+b values every time.
  int _attempt = 0;

  // Cached so the SAME question set is used for both the question list
  // and the result summary within one attempt (not regenerated on every
  // setState rebuild).
  late List<Map<String, dynamic>> _questions = _generateQuestions();

  List<Map<String, dynamic>> _generateQuestions() {
    // Seed combines level + attempt number + a random salt so every retry
    // (and the very first attempt too) gets a freshly shuffled question set.
    final seed = widget.level * 10007 +
        _attempt * 977 +
        DateTime.now().millisecondsSinceEpoch % 100000;
    final rnd = Random(seed);

    return List.generate(50, (i) {
      final a = rnd.nextInt(10 + widget.level * 2) + 1;
      final b = rnd.nextInt(8 + widget.level * 2) + 1;
      final correct = a + b;

      final optionSet = <int>{correct};
      while (optionSet.length < 4) {
        final delta = rnd.nextInt(9) - 4; // -4..+4
        final candidate = correct + delta;
        if (delta != 0 && candidate > 0) {
          optionSet.add(candidate);
        }
      }
      final opts = optionSet.toList()..shuffle(rnd);

      return {'q': '$a + $b = ?', 'options': opts, 'answer': opts.indexOf(correct)};
    });
  }

  void _submit() async {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i]['answer']) score++;
    }
    setState(() {
      _score = score;
      _submitted = true;
    });

    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final studentId = session['id'];
        await http.post(
          Uri.parse("https://apps.kofalt.in/api/submit_quiz.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "student_id": studentId,
            "level": widget.level,
            "score": score
          }),
        );
      }
    } catch (e) {
      debugPrint("Error submitting score: $e");
    }
  }

  void _retry() {
    setState(() {
      _attempt++; // new attempt -> new seed -> new (swapped) questions
      _answers.clear();
      _submitted = false;
      _score = 0;
      _questions = _generateQuestions();
    });
  }

  String get _grade {
    if (_score >= 45) return "A+";
    if (_score >= 40) return "A";
    if (_score >= 30) return "B";
    return "C";
  }

  @override
  Widget build(BuildContext context) {
    final qs = _questions;
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(children: [
        // HEADER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 24, right: 24, top: 52, bottom: 20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            gradient: LinearGradient(colors: [Color(0xff10B981), Color(0xff059669)]),
          ),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(height: 40, width: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text("Level ${widget.level} Practice Test", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              if (!_submitted) Text("${_answers.length}/50 answered", style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
            if (_submitted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.emoji_events, color: Colors.white, size: 30),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Your Score", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text("$_score / 50", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(width: 20),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Grade", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(_grade, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  ]),
                ]),
              ),
            ],
          ]),
        ),

        // QUESTIONS or SUMMARY
        Expanded(
          child: _submitted
              ? _buildSummary(qs)
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: qs.length,
            itemBuilder: (_, i) {
              final q = qs[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(height: 28, width: 28, decoration: BoxDecoration(color: const Color(0xff10B981).withOpacity(.12), borderRadius: BorderRadius.circular(8)), child: Center(child: Text("${i + 1}", style: const TextStyle(color: Color(0xff10B981), fontWeight: FontWeight.bold, fontSize: 12)))),
                    const SizedBox(width: 10),
                    Text(q['q'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                  const SizedBox(height: 12),
                  ...List.generate(4, (oi) {
                    final isSelected = _answers[i] == oi;
                    return GestureDetector(
                      onTap: () => setState(() => _answers[i] = oi),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xff10B981).withOpacity(.1) : const Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? const Color(0xff10B981) : Colors.transparent, width: 1.5),
                        ),
                        child: Row(children: [
                          Container(
                            height: 20, width: 20,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? const Color(0xff10B981) : Colors.white, border: Border.all(color: isSelected ? const Color(0xff10B981) : Colors.grey.shade300)),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
                          ),
                          const SizedBox(width: 10),
                          Text("${(q['options'] as List)[oi]}", style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontSize: 14)),
                        ]),
                      ),
                    );
                  }),
                ]),
              );
            },
          ),
        ),

        // BOTTOM BUTTONS
        if (!_submitted)
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _answers.length == 50 ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff10B981),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _answers.length == 50 ? "Submit Test" : "Answer all questions (${_answers.length}/50)",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        if (_submitted)
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: _retry,
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Color(0xff10B981)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text("Retry", style: TextStyle(color: Color(0xff10B981), fontWeight: FontWeight.bold, fontSize: 15)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff10B981), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              )),
            ]),
          ),
      ]),
    );
  }

  Widget _buildSummary(List<Map<String, dynamic>> qs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: qs.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              const Text("Result Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _sumStat("Correct", "$_score",        const Color(0xff16C74A)),
                _sumStat("Wrong",   "${50 - _score}", Colors.red),
                _sumStat("Score",   "$_score%",       const Color(0xff10B981)),
              ]),
            ]),
          );
        }
        final qi = i - 1;
        final q = qs[qi];
        final isCorrect = _answers[qi] == q['answer'];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCorrect ? const Color(0xff16C74A).withOpacity(.05) : Colors.red.withOpacity(.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isCorrect ? const Color(0xff16C74A).withOpacity(.3) : Colors.red.withOpacity(.3)),
          ),
          child: Row(children: [
            Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? const Color(0xff16C74A) : Colors.red, size: 22),
            const SizedBox(width: 10),
            Text("Q${qi + 1}: ${q['q']}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const Spacer(),
            Text("Ans: ${(q['options'] as List)[q['answer']]}", style: TextStyle(color: isCorrect ? const Color(0xff16C74A) : Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        );
      },
    );
  }

  Widget _sumStat(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
    Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
  ]);
}
// ============================================================
//  MATH PRACTICE ENGINE
// ============================================================

enum MathCategory {
  addition, addSub, mix, decimalAdd, decimalSub, negativeAnswers,
  multiplication, decimalMultiplication, division, decimalDivision,
  squareRoot, square, cubeRoot, cube, mixAll,
}

class MathCategoryInfo {
  final String title;
  final MathCategory category;
  final Color color;
  const MathCategoryInfo(this.title, this.category, this.color);
}

// Order & colors match the reference grid exactly (white/pink/blue pattern)
const List<MathCategoryInfo> kMathCategories = [
  MathCategoryInfo("ADDITION", MathCategory.addition, Colors.white),
  MathCategoryInfo("ADDITION/\nSUBTRACTION", MathCategory.addSub, Color(0xffEC1E79)),
  MathCategoryInfo("MIX", MathCategory.mix, Colors.white),
  MathCategoryInfo("Decimal\naddition", MathCategory.decimalAdd, Color(0xffEC1E79)),
  MathCategoryInfo("Decimal\nSUBTRACTION", MathCategory.decimalSub, Color(0xff1E9EE0)),
  MathCategoryInfo("+/- Negative\nanswers", MathCategory.negativeAnswers, Colors.white),
  MathCategoryInfo("MULTIPLICATION", MathCategory.multiplication, Color(0xff1E9EE0)),
  MathCategoryInfo("DECIMAL\nMULTIPLICATION", MathCategory.decimalMultiplication, Colors.white),
  MathCategoryInfo("DIVISION", MathCategory.division, Color(0xffEC1E79)),
  MathCategoryInfo("DECIMAL\nDIVISION", MathCategory.decimalDivision, Color(0xffEC1E79)),
  MathCategoryInfo("SQUARE\nROOT", MathCategory.squareRoot, Color(0xff1E9EE0)),
  MathCategoryInfo("SQUARE", MathCategory.square, Colors.white),
  MathCategoryInfo("CUBE ROOT", MathCategory.cubeRoot, Colors.white),
  MathCategoryInfo("CUBE", MathCategory.cube, Color(0xffEC1E79)),
  MathCategoryInfo("MIX ALL", MathCategory.mixAll, Color(0xff1E9EE0)),
];

class ColRowOption {
  final int columns;
  final int rows;
  const ColRowOption(this.columns, this.rows);
  String get label => "$columns COLUMN $rows ROWS";
}

const List<ColRowOption> kColRowOptions = [
  ColRowOption(1, 4),
  ColRowOption(2, 5),
  ColRowOption(3, 6),
  ColRowOption(4, 4),
  ColRowOption(5, 4),
  ColRowOption(5, 5),
];

class MathQuestion {
  final List<String> lines;   // display lines e.g. ["2345","+6355","+8289","+4362"]
  final String answer;        // correct answer as string
  MathQuestion({required this.lines, required this.answer});
}

class MathQuestionGenerator {
  static final Random _rnd = Random();

  static int _randInt(int digits) {
    if (digits <= 1) return 1 + _rnd.nextInt(9);
    final min = pow(10, digits - 1).toInt();
    final max = pow(10, digits).toInt() - 1;
    return min + _rnd.nextInt(max - min + 1);
  }

  static MathQuestion generate(MathCategory cat, int columns, int rows) {
    switch (cat) {
      case MathCategory.addition:
        return _addSub(columns, rows, allowNeg: false);
      case MathCategory.addSub:
      case MathCategory.mix:
        return _addSub(columns, rows, allowNeg: true);
      case MathCategory.negativeAnswers:
        return _addSub(columns, rows, allowNeg: true, forceNegAnswer: true);
      case MathCategory.decimalAdd:
        return _addSub(columns, rows, allowNeg: false, decimal: true);
      case MathCategory.decimalSub:
        return _addSub(columns, rows, allowNeg: true, decimal: true);
      case MathCategory.multiplication:
        return _multiply(columns, rows, decimal: false);
      case MathCategory.decimalMultiplication:
        return _multiply(columns, rows, decimal: true);
      case MathCategory.division:
        return _divide(columns, decimal: false);
      case MathCategory.decimalDivision:
        return _divide(columns, decimal: true);
      case MathCategory.square:
        return _square(columns);
      case MathCategory.squareRoot:
        return _squareRoot(columns);
      case MathCategory.cube:
        return _cube(columns);
      case MathCategory.cubeRoot:
        return _cubeRoot(columns);
      case MathCategory.mixAll:
        const opts = [
          MathCategory.addition, MathCategory.addSub, MathCategory.multiplication,
          MathCategory.division, MathCategory.square, MathCategory.squareRoot,
          MathCategory.cube, MathCategory.cubeRoot,
        ];
        return generate(opts[_rnd.nextInt(opts.length)], columns, rows);
    }
  }

  static MathQuestion _addSub(int columns, int rows, {required bool allowNeg, bool forceNegAnswer = false, bool decimal = false}) {
    for (int attempt = 0; attempt < 25; attempt++) {
      final lines = <String>[];
      double total = 0;
      for (int i = 0; i < rows; i++) {
        int intPart = _randInt(columns);
        double val = decimal ? double.parse("$intPart.${1 + _rnd.nextInt(9)}") : intPart.toDouble();
        bool neg = allowNeg && i > 0 && _rnd.nextBool();
        total += neg ? -val : val;
        final prefix = i == 0 ? "" : (neg ? "-" : "+");
        lines.add("$prefix${decimal ? val.toStringAsFixed(1) : val.toStringAsFixed(0)}");
      }
      if (forceNegAnswer && total >= 0) continue;
      if (!forceNegAnswer && !allowNeg && total < 0) continue;
      final ans = decimal ? total.toStringAsFixed(1) : total.round().toString();
      return MathQuestion(lines: lines, answer: ans);
    }
    // fallback
    return MathQuestion(lines: ["1", "+1"], answer: "2");
  }

  static MathQuestion _multiply(int columns, int rows, {required bool decimal}) {
    final useRows = rows > 2 ? 2 : rows; // keep product manageable
    final lines = <String>[];
    double total = 1;
    for (int i = 0; i < useRows; i++) {
      int intPart = _randInt(columns > 2 ? 2 : columns);
      double val = decimal ? double.parse("$intPart.${1 + _rnd.nextInt(9)}") : intPart.toDouble();
      total *= val;
      lines.add(i == 0 ? "${decimal ? val.toStringAsFixed(1) : val.toStringAsFixed(0)}" : "×${decimal ? val.toStringAsFixed(1) : val.toStringAsFixed(0)}");
    }
    final ans = decimal ? total.toStringAsFixed(2) : total.round().toString();
    return MathQuestion(lines: lines, answer: ans);
  }

  static MathQuestion _divide(int columns, {required bool decimal}) {
    final divisor = _randInt(columns > 1 ? columns : 2).clamp(2, 999999);
    final quotient = decimal
        ? double.parse("${1 + _rnd.nextInt(20)}.${1 + _rnd.nextInt(9)}")
        : (1 + _rnd.nextInt(50)).toDouble();
    final dividend = divisor * quotient;
    final lines = [
      decimal ? dividend.toStringAsFixed(2) : dividend.round().toString(),
      "÷$divisor",
    ];
    final ans = decimal ? quotient.toStringAsFixed(1) : quotient.round().toString();
    return MathQuestion(lines: lines, answer: ans);
  }

  static MathQuestion _square(int columns) {
    final n = _randInt(columns > 3 ? 3 : columns);
    return MathQuestion(lines: ["$n²"], answer: "${n * n}");
  }

  static MathQuestion _squareRoot(int columns) {
    final base = _randInt(columns > 3 ? 3 : columns).clamp(1, 999);
    final sq = base * base;
    return MathQuestion(lines: ["√$sq"], answer: "$base");
  }

  static MathQuestion _cube(int columns) {
    final n = _randInt(columns > 2 ? 2 : columns).clamp(1, 99);
    return MathQuestion(lines: ["$n³"], answer: "${n * n * n}");
  }

  static MathQuestion _cubeRoot(int columns) {
    final base = _randInt(columns > 2 ? 2 : columns).clamp(1, 99);
    final cb = base * base * base;
    return MathQuestion(lines: ["∛$cb"], answer: "$base");
  }
}