import 'package:flutter/material.dart';

const List<String> _kLevels = [
  'Level 1', 'Level 2', 'Level 3', 'Level 4',
  'Level 5', 'Level 6', 'Level 7', 'Level 8',
];

const List<String> _kBatches = ['Batch A', 'Batch B', 'Batch C', 'Batch D'];

// ============================================================
//  STUDENT ENROLLMENT SCREEN
// ============================================================

class StudentEnrollmentScreen extends StatefulWidget {
  const StudentEnrollmentScreen({super.key});

  @override
  State<StudentEnrollmentScreen> createState() => _StudentEnrollmentScreenState();
}

class _StudentEnrollmentScreenState extends State<StudentEnrollmentScreen> {
  static const List<Map<String, dynamic>> _initialStudents = [
    {'name': 'Anjali Mehta', 'level': 'Level 3', 'batch': 'Batch A', 'centre': 'Centre Alpha', 'status': 'Active'},
    {'name': 'Rahul Singh',  'level': 'Level 1', 'batch': 'Batch B', 'centre': 'Centre Beta',  'status': 'Active'},
    {'name': 'Priya Jain',   'level': 'Level 5', 'batch': 'Batch A', 'centre': 'Centre Alpha', 'status': 'Active'},
    {'name': 'Karan Mehta',  'level': 'Level 2', 'batch': 'Batch C', 'centre': 'Centre Gamma', 'status': 'Inactive'},
    {'name': 'Nisha Sharma', 'level': 'Level 4', 'batch': 'Batch B', 'centre': 'Centre Beta',  'status': 'Active'},
    {'name': 'Arjun Patel',  'level': 'Level 6', 'batch': 'Batch A', 'centre': 'Centre Alpha', 'status': 'Active'},
  ];

  late List<Map<String, dynamic>> _students;
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _students = _initialStudents.map((s) {
      final copy = Map<String, dynamic>.from(s);
      copy['id'] = _nextId++;
      return copy;
    }).toList();
  }

  // ----------------------------------------------------------
  //  ADD / EDIT
  // ----------------------------------------------------------
  void _openStudentForm({Map<String, dynamic>? student}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StudentFormSheet(
        student: student,
        onSubmit: (data) {
          setState(() {
            if (student != null) {
              final idx = _students.indexWhere((s) => s['id'] == student['id']);
              if (idx != -1) _students[idx] = {...data, 'id': student['id']};
            } else {
              _students.add({...data, 'id': _nextId++});
            }
          });
        },
      ),
    );
  }

  // ----------------------------------------------------------
  //  DELETE
  // ----------------------------------------------------------
  Future<bool?> _confirmDelete(String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Remove Student"),
        content: Text("Are you sure you want to remove $name? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Remove", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(Map<String, dynamic> student) {
    setState(() => _students.removeWhere((s) => s['id'] == student['id']));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${student['name']} removed"), behavior: SnackBarBehavior.floating),
    );
  }

  // ----------------------------------------------------------
  //  DETAIL SHEET
  // ----------------------------------------------------------
  void _openStudentDetail(Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isActive = student['status'] == 'Active';
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  Row(children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xffDB2777).withOpacity(.1),
                      child: Text(student['name'][0], style: const TextStyle(color: Color(0xffDB2777), fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(student['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: (isActive ? const Color(0xff16C74A) : Colors.red).withOpacity(.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(student['status'], style: TextStyle(color: isActive ? const Color(0xff16C74A) : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ])),
                  ]),
                  const SizedBox(height: 24),
                  _detailRow(Icons.school_outlined, "Level", student['level']),
                  const SizedBox(height: 14),
                  _detailRow(Icons.groups_outlined, "Batch", student['batch']),
                  const SizedBox(height: 14),
                  _detailRow(Icons.location_on_outlined, "Centre", student['centre']),
                  const SizedBox(height: 28),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openStudentForm(student: student);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text("Edit"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xffDB2777),
                        side: const BorderSide(color: Color(0xffDB2777)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final confirmed = await _confirmDelete(student['name']);
                        if (confirmed == true) _deleteStudent(student);
                      },
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                      label: const Text("Delete", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    )),
                  ]),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) => Row(children: [
    Container(height: 40, width: 40, decoration: BoxDecoration(color: const Color(0xffDB2777).withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xffDB2777), size: 20)),
    const SizedBox(width: 12),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    ]),
  ]);

  // ----------------------------------------------------------
  //  BUILD
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          _detailHeader(
            context,
            title: "Student Enrollment",
            subtitle: "${_students.length} students enrolled",
          ),
          Expanded(
            child: _students.isEmpty
                ? _emptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final isActive = student['status'] == "Active";

                return Dismissible(
                  key: ValueKey(student['id']),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmDelete(student['name']),
                  onDismissed: (_) => _deleteStudent(student),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
                  ),
                  child: GestureDetector(
                    onTap: () => _openStudentDetail(student),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xffDB2777).withOpacity(.1),
                            child: Text(
                              student['name'][0],
                              style: const TextStyle(color: Color(0xffDB2777), fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 3),
                                Text(
                                  "${student['level']} • ${student['batch']} • ${student['centre']}",
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (isActive ? const Color(0xff16C74A) : Colors.red).withOpacity(.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              student['status'],
                              style: TextStyle(color: isActive ? const Color(0xff16C74A) : Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openStudentForm(),
        backgroundColor: const Color(0xffDB2777),
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text("Add Student", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
      const SizedBox(height: 12),
      Text("No students yet", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
      const SizedBox(height: 4),
      Text("Tap 'Add Student' to enroll someone", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
    ]),
  );

  Widget _detailHeader(
      BuildContext context, {
        required String title,
        required String subtitle,
      }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 50, bottom: 28),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
        gradient: LinearGradient(colors: [Color(0xffDB2777), Color(0xff9D174D)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}

// ============================================================
//  ADD / EDIT STUDENT FORM SHEET
// ============================================================

class _StudentFormSheet extends StatefulWidget {
  final Map<String, dynamic>? student;
  final void Function(Map<String, dynamic> data) onSubmit;
  const _StudentFormSheet({this.student, required this.onSubmit});

  @override
  State<_StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends State<_StudentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _centreCtrl;
  late String _level;
  late String _batch;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameCtrl = TextEditingController(text: s?['name'] ?? '');
    _centreCtrl = TextEditingController(text: s?['centre'] ?? '');
    _level = s?['level'] ?? _kLevels.first;
    _batch = s?['batch'] ?? _kBatches.first;
    _isActive = (s?['status'] ?? 'Active') == 'Active';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _centreCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit({
      'name': _nameCtrl.text.trim(),
      'level': _level,
      'batch': _batch,
      'centre': _centreCtrl.text.trim(),
      'status': _isActive ? 'Active' : 'Inactive',
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.student != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 16),
                Text(isEdit ? "Edit Student" : "Add Student", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                _fieldLabel("Full Name"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDecoration("e.g. Anjali Mehta", Icons.person_outline),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null,
                ),
                const SizedBox(height: 16),

                _fieldLabel("Level"),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _level,
                  decoration: _inputDecoration(null, Icons.school_outlined),
                  items: _kLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (v) => setState(() => _level = v!),
                ),
                const SizedBox(height: 16),

                _fieldLabel("Batch"),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _batch,
                  decoration: _inputDecoration(null, Icons.groups_outlined),
                  items: _kBatches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (v) => setState(() => _batch = v!),
                ),
                const SizedBox(height: 16),

                _fieldLabel("Centre"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _centreCtrl,
                  decoration: _inputDecoration("e.g. Centre Alpha", Icons.location_on_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Centre is required" : null,
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xffF5F5F5), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const Icon(Icons.toggle_on_outlined, color: Color(0xffDB2777), size: 20),
                    const SizedBox(width: 10),
                    const Expanded(child: Text("Active Status", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
                    Switch(value: _isActive, activeColor: const Color(0xffDB2777), onChanged: (v) => setState(() => _isActive = v)),
                  ]),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffDB2777),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(isEdit ? "Save Changes" : "Add Student", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String t) => Text(t, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600));

  InputDecoration _inputDecoration(String? hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: const Color(0xffDB2777), size: 20),
    filled: true,
    fillColor: const Color(0xffF5F5F5),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xffDB2777), width: 1.5)),
  );
}