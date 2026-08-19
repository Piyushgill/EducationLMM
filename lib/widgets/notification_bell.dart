import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Drop-in replacement for the static bell+red-dot Stack used in every
/// dashboard header. Fetches announcements published by Super Admin's
/// Content Manager and filters them by [role] (same rule as _visibleToRole:
/// visible if target_roles contains "All" or contains this role).
///
/// Usage (replace the old bell Stack with this):
///   const NotificationBell(role: "School")
///   const NotificationBell(role: "Franchise Partner")
///   const NotificationBell(role: "Distributor")
///   const NotificationBell(role: "Agent")
///   const NotificationBell(role: "Student")
class NotificationBell extends StatefulWidget {
  final String role;
  final Color iconColor;
  final double size;

  const NotificationBell({
    super.key,
    required this.role,
    this.iconColor = Colors.white,
    this.size = 48,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  List<dynamic> _circulars = [];
  bool _hasUnseen = false; // true only until the latest announcement is opened
  bool _isLoading = false;
  Set<int> _dismissedIds = {}; // ids the user removed from their own list

  @override
  void initState() {
    super.initState();
    _fetchCirculars();
  }

  bool _visibleToRole(dynamic targetRolesField) {
    List<String> roles;
    if (targetRolesField is List) {
      roles = targetRolesField.map((e) => e.toString()).toList();
    } else {
      roles = (targetRolesField?.toString().split(',') ?? const ["All"]);
    }
    return roles.contains("All") || roles.contains(widget.role);
  }

  Future<void> _fetchCirculars() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("https://apps.kofalt.in/api/get_circulars.php"),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final all = (data['data'] as List? ?? []);
          final filtered =
          all.where((c) => _visibleToRole(c['target_roles'])).toList();

          final prefs = await SharedPreferences.getInstance();
          final lastSeenId =
              prefs.getInt('last_seen_circular_id_${widget.role}') ?? 0;
          final dismissed = prefs
              .getStringList('dismissed_circulars_${widget.role}') ??
              const <String>[];

          // Only look at the single latest announcement's id. If it's newer
          // than the last one the user opened, show the dot; otherwise don't
          // — old announcements never bring the dot back.
          final latestId = filtered.isEmpty
              ? 0
              : filtered
              .map((c) => int.tryParse(c['id']?.toString() ?? '0') ?? 0)
              .fold<int>(0, (a, b) => a > b ? a : b);

          if (mounted) {
            setState(() {
              _circulars = filtered;
              _dismissedIds = dismissed.map((e) => int.tryParse(e) ?? -1).toSet();
              _hasUnseen = latestId > lastSeenId;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openDetail(Map<String, dynamic> c) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffFF6B00), Color(0xffE65100)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.campaign_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        c['title'] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['message'] ?? "",
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 15, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        Text(
                          (c['created_at'] ?? "").toString(),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF6B00),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeCircular(int id, StateSetter setSheetState) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = {..._dismissedIds, id};
    await prefs.setStringList(
      'dismissed_circulars_${widget.role}',
      updated.map((e) => e.toString()).toList(),
    );
    if (mounted) setState(() => _dismissedIds = updated);
    setSheetState(() {}); // refresh the open bottom sheet immediately
  }

  Future<void> _markAllSeen() async {
    if (_circulars.isEmpty) return;
    final maxId = _circulars
        .map((c) => int.tryParse(c['id']?.toString() ?? '0') ?? 0)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_seen_circular_id_${widget.role}', maxId);
    if (mounted) setState(() => _hasUnseen = false);
  }

  void _openList() {
    _markAllSeen();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (_, controller) => StatefulBuilder(
          builder: (context, setSheetState) {
            final visible = _circulars.where((c) {
              final id = int.tryParse(c['id']?.toString() ?? '0') ?? -1;
              return !_dismissedIds.contains(id);
            }).toList();

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Notifications",
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    )
                  else
                    Expanded(
                      child: visible.isEmpty
                          ? const Center(
                        child: Text(
                          "No announcements yet.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                          : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        itemBuilder: (_, i) {
                          final c = visible[i];
                          final id =
                              int.tryParse(c['id']?.toString() ?? '0') ??
                                  -1;
                          return Dismissible(
                            key: ValueKey('circular_$id'),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) =>
                                _removeCircular(id, setSheetState),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.white),
                            ),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                onTap: () => _openDetail(
                                    Map<String, dynamic>.from(c)),
                                leading: const Icon(
                                    Icons.campaign_outlined,
                                    color: Color(0xffFF6B00)),
                                title: Text(
                                  c['title'] ?? "",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  c['message'] ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      (c['created_at'] ?? "")
                                          .toString()
                                          .split(' ')
                                          .first,
                                      style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 11),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => _removeCircular(
                                          id, setSheetState),
                                      child: Icon(Icons.close_rounded,
                                          size: 16,
                                          color: Colors.grey.shade400),
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
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openList,
      child: Stack(
        children: [
          Container(
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.notifications_none_rounded,
                color: widget.iconColor, size: 26),
          ),
          if (_hasUnseen)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                height: 10,
                width: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}