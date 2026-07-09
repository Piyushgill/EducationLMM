import 'package:flutter/material.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FranchiseKitOrderScreen extends StatefulWidget {
  const FranchiseKitOrderScreen({super.key});

  @override
  State<FranchiseKitOrderScreen> createState() => _FranchiseKitOrderScreenState();
}

class _FranchiseKitOrderScreenState extends State<FranchiseKitOrderScreen> {
  int _mainKitQty = 0;
  final Map<int, int> _levelQty = {for (var l in [2, 3, 4, 5, 6, 7, 8]) l: 0};

  int get _totalItems => _mainKitQty + _levelQty.values.fold(0, (a, b) => a + b);

  // ----------------------------------------------------------
  //  QUANTITY HANDLERS
  // ----------------------------------------------------------
  void _changeMainQty(int delta) => setState(() => _mainKitQty = (_mainKitQty + delta).clamp(0, 99));
  void _changeLevelQty(int level, int delta) => setState(() => _levelQty[level] = (_levelQty[level]! + delta).clamp(0, 99));

  // ----------------------------------------------------------
  //  ORDER SUMMARY SHEET
  // ----------------------------------------------------------
  void _openOrderSummary() {
    final items = <Map<String, dynamic>>[];
    if (_mainKitQty > 0) items.add({'name': 'New Kit (Main)', 'qty': _mainKitQty});
    for (final l in _levelQty.keys) {
      if (_levelQty[l]! > 0) items.add({'name': 'Level $l Kit', 'qty': _levelQty[l]});
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("$_totalItems items", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (_, i) {
                        final it = items[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(children: [
                            Container(
                              height: 38, width: 38,
                              decoration: BoxDecoration(color: const Color(0xffFF6B00).withOpacity(.1), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.inventory_2_outlined, color: Color(0xffFF6B00), size: 19),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(it['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                            Text("x${it['qty']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ]),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _placeOrder();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF6B00),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text("Confirm Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------------
  //  PLACE ORDER
  // ----------------------------------------------------------
  Future<void> _placeOrder() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xffFF6B00))),
    );

    try {
      final session = await SessionManager.getSession();
      if (session == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: User session not found. Please log in.")),
        );
        return;
      }
      final buyerId = session['id'];

      final orders = <Future>[];
      if (_mainKitQty > 0) {
        orders.add(
          http.post(
            Uri.parse("https://apps.kofalt.in/api/order_kit.php"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "buyer_id": buyerId,
              "level": "Level 1",
              "quantity": _mainKitQty,
            }),
          )
        );
      }
      for (final l in _levelQty.keys) {
        final qty = _levelQty[l]!;
        if (qty > 0) {
          orders.add(
            http.post(
              Uri.parse("https://apps.kofalt.in/api/order_kit.php"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "buyer_id": buyerId,
                "level": "Level $l",
                "quantity": qty,
              }),
            )
          );
        }
      }

      final responses = await Future.wait(orders);
      
      Navigator.pop(context); // Close loader

      bool allSuccess = true;
      for (final res in responses) {
        final data = jsonDecode((res as http.Response).body);
        if (data['status'] != 'success') {
          allSuccess = false;
        }
      }

      if (allSuccess) {
        final placedItems = _totalItems;
        setState(() {
          _mainKitQty = 0;
          for (final l in _levelQty.keys) {
            _levelQty[l] = 0;
          }
        });
        
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 64, width: 64,
                  decoration: BoxDecoration(color: const Color(0xff16C74A).withOpacity(.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: Color(0xff16C74A), size: 40),
                ),
                const SizedBox(height: 16),
                const Text("Order Placed!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  "Total items ordered: $placedItems\nMLM downline commissions distributed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF6B00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Some orders failed to process. Please check connection."), backgroundColor: Colors.red),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Network error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

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
            title: "Kit Ordering",
            subtitle: "Main kit + Level 2-8 kits",
            colors: const [Color(0xffFF6B00), Color(0xffFF9500)],
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("New Main Kit"),
                  const SizedBox(height: 10),
                  _kitCard(
                    name: "New Kit (Main)",
                    desc: "For new student enrollments",
                    color: const Color(0xffFF6B00),
                    qty: _mainKitQty,
                    onAdd: () => _changeMainQty(1),
                    onRemove: () => _changeMainQty(-1),
                  ),
                  const SizedBox(height: 24),
                  _label("Level Kits (2-8)"),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _levelQty.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final lvl = _levelQty.keys.elementAt(i);
                      return _kitCard(
                        name: "Level $lvl Kit",
                        desc: "Advanced training modules",
                        color: const Color(0xffFF9500),
                        qty: _levelQty[lvl]!,
                        onAdd: () => _changeLevelQty(lvl, 1),
                        onRemove: () => _changeLevelQty(lvl, -1),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _totalItems == 0
          ? null
          : Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10)],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Selected", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text("$_totalItems items", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              ElevatedButton(
                onPressed: _openOrderSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF6B00),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text("View Summary", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ──

  Widget _detailHeader({
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onBack,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: onBack),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(.8), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E)));

  Widget _kitCard({
    required String name,
    required String desc,
    required Color color,
    required int qty,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    final selected = qty > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? color.withOpacity(.4) : Colors.transparent, width: 1.4),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.inventory_2_outlined, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(desc, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          qty == 0
              ? GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
              child: const Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          )
              : Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepBtn(Icons.remove, color, onRemove),
                SizedBox(width: 28, child: Text("$qty", textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))),
                _stepBtn(Icons.add, color, onAdd),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 28,
      width: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 16),
    ),
  );
}