import 'package:flutter/material.dart';

const List<String> _kCentres = ['Centre Alpha', 'Centre Beta', 'Centre Gamma'];
const List<String> _kPrograms = ['Abacus', 'Vedic Maths', 'Phonics', 'English'];

// ============================================================
//  BATCH MANAGEMENT SCREEN
// ============================================================

class BatchManagementScreen extends StatefulWidget {
  const BatchManagementScreen({super.key});

  @override
  State<BatchManagementScreen> createState() => _BatchManagementScreenState();
}

class _BatchManagementScreenState extends State<BatchManagementScreen> {
  static const List<Map<String, dynamic>> _initialBatches = [
    {'batch': 'Batch A', 'centre': 'Centre Alpha', 'program': 'Abacus',      'students': 25, 'time': 'Mon/Wed 10:00 AM', 'status': 'Running'},
    {'batch': 'Batch B', 'centre': 'Centre Beta',  'program': 'Vedic Maths', 'students': 22, 'time': 'Tue/Thu 11:30 AM', 'status': 'Running'},
    {'batch': 'Batch C', 'centre': 'Centre Gamma', 'program': 'Phonics',     'students': 18, 'time': 'Fri 9:00 AM',      'status': 'Running'},
    {'batch': 'Batch D', 'centre': 'Centre Alpha', 'program': 'English',     'students': 20, 'time': 'Mon/Fri 2:00 PM',  'status': 'Upcoming'},
    {'batch': 'Batch E', 'centre': 'Centre Beta',  'program': 'Abacus',      'students': 15, 'time': 'Wed/Sat 4:00 PM',  'status': 'Running'},
  ];

  late List<Map<String, dynamic>> _batches;
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _batches = _initialBatches.map((b) {
      final copy = Map<String, dynamic>.from(b);
      copy['id'] = _nextId++;
      return copy;
    }).toList();
  }

  int get _centreCount => _batches.map((b) => b['centre']).toSet().length;

  // ----------------------------------------------------------
  //  ADD / EDIT
  // ----------------------------------------------------------
  void _openBatchForm({Map<String, dynamic>? batch}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BatchFormSheet(
        batch: batch,
        onSubmit: (data) {
          setState(() {
            if (batch != null) {
              final idx = _batches.indexWhere((b) => b['id'] == batch['id']);
              if (idx != -1) _batches[idx] = {...data, 'id': batch['id']};
            } else {
              _batches.add({...data, 'id': _nextId++});
            }
          });
        },
      ),
    );
  }

  // ----------------------------------------------------------
  //  DELETE
  // ----------------------------------------------------------
  Future<bool?> _confirmDelete(String batchName) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Remove Batch"),
        content: Text("Are you sure you want to remove $batchName? This action cannot be undone."),
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

  void _deleteBatch(Map<String, dynamic> batch) {
    setState(() => _batches.removeWhere((b) => b['id'] == batch['id']));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${batch['batch']} removed"), behavior: SnackBarBehavior.floating),
    );
  }

  // ----------------------------------------------------------
  //  DETAIL SHEET
  // ----------------------------------------------------------
  void _openBatchDetail(Map<String, dynamic> batch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isRunning = batch['status'] == 'Running';
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
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
                    Container(
                      height: 52, width: 52,
                      decoration: BoxDecoration(color: const Color(0xff2563EB).withOpacity(.1), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.groups_2_outlined, color: Color(0xff2563EB), size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(batch['batch'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isRunning ? const Color(0xff16C74A) : const Color(0xffFF6B00)).withOpacity(.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          batch['status'],
                          style: TextStyle(color: isRunning ? const Color(0xff16C74A) : const Color(0xffFF6B00), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ])),
                  ]),
                  const SizedBox(height: 24),
                  _detailRow(Icons.location_on_outlined, "Centre", batch['centre']),
                  const SizedBox(height: 14),
                  _detailRow(Icons.menu_book_outlined, "Program", batch['program']),
                  const SizedBox(height: 14),
                  _detailRow(Icons.groups_outlined, "Students", "${batch['students']}"),
                  const SizedBox(height: 14),
                  _detailRow(Icons.access_time_outlined, "Schedule", batch['time']),
                  const SizedBox(height: 28),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openBatchForm(batch: batch);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text("Edit"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff2563EB),
                        side: const BorderSide(color: Color(0xff2563EB)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final confirmed = await _confirmDelete(batch['batch']);
                        if (confirmed == true) _deleteBatch(batch);
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
    Container(height: 40, width: 40, decoration: BoxDecoration(color: const Color(0xff2563EB).withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xff2563EB), size: 20)),
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
            title: "Batch Management",
            subtitle: "${_batches.length} batches across $_centreCount centres",
          ),
          Expanded(
            child: _batches.isEmpty
                ? _emptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: _batches.length,
              itemBuilder: (context, index) {
                final batch = _batches[index];
                final isRunning = batch['status'] == "Running";

                return Dismissible(
                  key: ValueKey(batch['id']),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmDelete(batch['batch']),
                  onDismissed: (_) => _deleteBatch(batch),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
                  ),
                  child: GestureDetector(
                    onTap: () => _openBatchDetail(batch),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(color: const Color(0xff2563EB).withOpacity(.1), borderRadius: BorderRadius.circular(14)),
                                child: const Icon(Icons.groups_2_outlined, color: Color(0xff2563EB), size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(batch['batch'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text(
                                      "${batch['centre']} • ${batch['program']}",
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: (isRunning ? const Color(0xff16C74A) : const Color(0xffFF6B00)).withOpacity(.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  batch['status'],
                                  style: TextStyle(
                                    color: isRunning ? const Color(0xff16C74A) : const Color(0xffFF6B00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
                              _infoChip(Icons.groups_outlined, "${batch['students']} Students", const Color(0xff2563EB)),
                              const SizedBox(width: 14),
                              Expanded(child: _infoChip(Icons.access_time_outlined, batch['time'], const Color(0xffFF6B00))),
                              Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade400),
                            ],
                          ),
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
        onPressed: () => _openBatchForm(),
        backgroundColor: const Color(0xff2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Batch", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.groups_2_outlined, size: 64, color: Colors.grey.shade300),
      const SizedBox(height: 12),
      Text("No batches yet", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
      const SizedBox(height: 4),
      Text("Tap 'Add Batch' to create one", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
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
        gradient: LinearGradient(colors: [Color(0xff2563EB), Color(0xff7C3AED)]),
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

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  ADD / EDIT BATCH FORM SHEET
// ============================================================

class _BatchFormSheet extends StatefulWidget {
  final Map<String, dynamic>? batch;
  final void Function(Map<String, dynamic> data) onSubmit;
  const _BatchFormSheet({this.batch, required this.onSubmit});

  @override
  State<_BatchFormSheet> createState() => _BatchFormSheetState();
}

class _BatchFormSheetState extends State<_BatchFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _batchNameCtrl;
  late TextEditingController _studentsCtrl;
  late TextEditingController _timeCtrl;
  late String _centre;
  late String _program;
  late bool _isRunning;

  @override
  void initState() {
    super.initState();
    final b = widget.batch;
    _batchNameCtrl = TextEditingController(text: b?['batch'] ?? '');
    _studentsCtrl = TextEditingController(text: b != null ? "${b['students']}" : '');
    _timeCtrl = TextEditingController(text: b?['time'] ?? '');
    _centre = b?['centre'] ?? _kCentres.first;
    _program = b?['program'] ?? _kPrograms.first;
    _isRunning = (b?['status'] ?? 'Running') == 'Running';
  }

  @override
  void dispose() {
    _batchNameCtrl.dispose();
    _studentsCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit({
      'batch': _batchNameCtrl.text.trim(),
      'centre': _centre,
      'program': _program,
      'students': int.tryParse(_studentsCtrl.text.trim()) ?? 0,
      'time': _timeCtrl.text.trim(),
      'status': _isRunning ? 'Running' : 'Upcoming',
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.batch != null;
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
                Text(isEdit ? "Edit Batch" : "Add Batch", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                _fieldLabel("Batch Name"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _batchNameCtrl,
                  decoration: _inputDecoration("e.g. Batch F", Icons.groups_2_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Batch name is required" : null,
                ),
                const SizedBox(height: 16),

                _fieldLabel("Centre"),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _centre,
                  decoration: _inputDecoration(null, Icons.location_on_outlined),
                  items: _kCentres.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _centre = v!),
                ),
                const SizedBox(height: 16),

                _fieldLabel("Program"),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _program,
                  decoration: _inputDecoration(null, Icons.menu_book_outlined),
                  items: _kPrograms.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => _program = v!),
                ),
                const SizedBox(height: 16),

                _fieldLabel("Number of Students"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _studentsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("e.g. 20", Icons.groups_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Student count is required";
                    if (int.tryParse(v.trim()) == null) return "Enter a valid number";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _fieldLabel("Schedule"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _timeCtrl,
                  decoration: _inputDecoration("e.g. Mon/Wed 10:00 AM", Icons.access_time_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Schedule is required" : null,
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xffF5F5F5), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const Icon(Icons.toggle_on_outlined, color: Color(0xff2563EB), size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_isRunning ? "Running" : "Upcoming", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
                    Switch(value: _isRunning, activeColor: const Color(0xff2563EB), onChanged: (v) => setState(() => _isRunning = v)),
                  ]),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(isEdit ? "Save Changes" : "Add Batch", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
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
    prefixIcon: Icon(icon, color: const Color(0xff2563EB), size: 20),
    filled: true,
    fillColor: const Color(0xffF5F5F5),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xff2563EB), width: 1.5)),
  );
}