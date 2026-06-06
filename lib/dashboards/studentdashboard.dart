import 'package:flutter/material.dart';
import 'package:thenew/Screens/profilescreen.dart';

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
                builder: (_) => const Profilescreen(),
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
          // BottomNavigationBarItem(icon: Icon(Icons.person_outline),         activeIcon: Icon(Icons.person),        label: "Profile"),
        ],
      ),
    );
  }
}

// ============================================================
//  HOME TAB
// ============================================================

class _StudentHomeTab extends StatelessWidget {
  const _StudentHomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff10B981),
                    Color(0xff059669),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Color(0xff10B981),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Student Name",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Profilescreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {},
            ),
          ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(.2),
                    child: const Text(
                      "A",
                      style: TextStyle(
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

              const Text(
                "Hello, Anjali! 👋",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),


              const SizedBox(height: 16),
              // Progress card in header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.3))),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Current Level", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const Text("Level 3 - Abacus", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: const LinearProgressIndicator(value: 0.65, backgroundColor: Color(0x4DFFFFFF), valueColor: AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8)),
                    const SizedBox(height: 4),
                    const Text("65% Complete", style: TextStyle(color: Colors.white70, fontSize: 11)),
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
                  _quickStatCard("Tests Done",    "2",    const Color(0xff10B981)),
                  const SizedBox(width: 12),
                  _quickStatCard("Best Score",    "48/50", const Color(0xff0EA5E9)),
                  const SizedBox(width: 12),
                  _quickStatCard("Current Level", "3",    const Color(0xffA020F0)),
                ]),

                const SizedBox(height: 24),

                // PAST TEST RESULTS
                _sectionTitle("My Test Results"),
                const SizedBox(height: 12),
                _resultCard("Level 1", "48/50", "10 Jan 2025", "A+"),
                const SizedBox(height: 10),
                _resultCard("Level 2", "42/50", "25 Jan 2025", "A"),

                const SizedBox(height: 24),

                // QUICK START PRACTICE
                _sectionTitle("Quick Start Practice"),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PracticeTestScreen(level: 3))),
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
                        const Text("Continue Level 3", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
//  PRACTICE TAB — 8 Level Selector
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
            const Text("Abacus • 8 Levels • 50 Questions each", style: TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)]),
              child: Column(children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                  children: List.generate(8, (i) {
                    final isUnlocked = i < 3;
                    final isCurrent  = i == 2;
                    return GestureDetector(
                      onTap: isUnlocked ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeTestScreen(level: i + 1))) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrent ? const Color(0xff10B981) : isUnlocked ? const Color(0xff10B981).withOpacity(.1) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isCurrent ? const Color(0xff10B981) : Colors.transparent, width: 1.5),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(isUnlocked ? Icons.lock_open_rounded : Icons.lock_outlined, color: isCurrent ? Colors.white : isUnlocked ? const Color(0xff10B981) : Colors.grey, size: 22),
                          const SizedBox(height: 4),
                          Text("L${i + 1}", style: TextStyle(color: isCurrent ? Colors.white : isUnlocked ? const Color(0xff10B981) : Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                        ]),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PracticeTestScreen(level: 3))),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff10B981), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text("Start Level 3 Test", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ]),
            ),
          ]),
        )),
      ])),
    );
  }
}

// ============================================================
//  VIDEOS TAB
// ============================================================

class _VideosTab extends StatelessWidget {
  const _VideosTab();

  final List<Map<String, dynamic>> videos = const [
    {'title': 'Abacus Basics - Level 1',    'duration': '15 min', 'color': Color(0xff10B981)},
    {'title': 'Abacus Level 2 Techniques',  'duration': '18 min', 'color': Color(0xff059669)},
    {'title': 'Speed Calculation Tips',     'duration': '22 min', 'color': Color(0xff0EA5E9)},
    {'title': 'Level 3 Practice Methods',   'duration': '25 min', 'color': Color(0xffA020F0)},
    {'title': 'Mental Math Tricks',         'duration': '20 min', 'color': Color(0xffFF6B00)},
    {'title': 'Concentration Exercises',    'duration': '12 min', 'color': Color(0xff2563EB)},
    {'title': 'Level 4 Advanced',           'duration': '30 min', 'color': Color(0xffFF1493)},
    {'title': 'Exam Preparation Tips',      'duration': '17 min', 'color': Color(0xff16C74A)},
  ];

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
            const Text("Education Videos", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("${videos.length} videos available", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: videos.length,
          itemBuilder: (_, i) {
            final v = videos[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)]),
              child: Row(children: [
                Container(height: 48, width: 48, decoration: BoxDecoration(color: (v['color'] as Color).withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.play_circle_filled, color: v['color'] as Color, size: 30)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(v['duration']!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ])),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
              ]),
            );
          },
        )),
      ])),
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
//  PRACTICE TEST SCREEN — 50 Questions, 1 Screen, Submit
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

  List<Map<String, dynamic>> get questions => List.generate(50, (i) {
    final a = (i * 3 + widget.level * 2) % 20 + 1;
    final b = (i * 2 + widget.level)     % 15 + 1;
    final correct = a + b;
    final opts = [correct, correct + 3, correct - 2, correct + 5];
    opts.shuffle();
    return {'q': '$a + $b = ?', 'options': opts, 'answer': opts.indexOf(correct)};
  });

  void _submit() {
    int score = 0;
    final qs = questions;
    for (int i = 0; i < qs.length; i++) {
      if (_answers[i] == qs[i]['answer']) score++;
    }
    setState(() { _score = score; _submitted = true; });
  }

  String get _grade {
    if (_score >= 45) return "A+";
    if (_score >= 40) return "A";
    if (_score >= 30) return "B";
    return "C";
  }

  @override
  Widget build(BuildContext context) {
    final qs = questions;
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
                onPressed: () => setState(() { _answers.clear(); _submitted = false; _score = 0; }),
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