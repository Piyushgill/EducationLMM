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
  // ---- Courses ----
  final List<String> _courses = const ["Vedic Maths", "Abacus", "English", "Phonics"];
  late String _selectedCourse = _courses.first;

  int _mainKitQty = 0;
  final Map<int, int> _levelQty = {for (var l in [2, 3, 4, 5, 6, 7, 8]) l: 0};

  // ---- Text controllers so quantity can be typed directly ----
  final TextEditingController _mainQtyController = TextEditingController(text: '0');
  final Map<int, TextEditingController> _levelQtyControllers = {
    for (var l in [2, 3, 4, 5, 6, 7, 8]) l: TextEditingController(text: '0'),
  };

  // ---- Search (kit list) ----
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ----------------------------------------------------------
  //  "FOR WHOM" — person / downline selector
  // ----------------------------------------------------------
  // NOTE: This assumes a GET endpoint that returns the list of people
  // (students / downline members) this buyer is allowed to order kits for.
  // Update the URL / response parsing below if your backend uses a
  // different path or a different JSON shape.
  List<Map<String, dynamic>> _peopleList = [];
  Map<String, dynamic>? _selectedPerson;
  bool _loadingPeople = false;
  String? _peopleError;

  final TextEditingController _personSearchController = TextEditingController();
  String _personSearchQuery = '';

  List<Map<String, dynamic>> get _filteredPeople {
    if (_personSearchQuery.isEmpty) return _peopleList;
    final q = _personSearchQuery.toLowerCase();
    return _peopleList.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final phone = (p['phone'] ?? '').toString().toLowerCase();
      final id = (p['id'] ?? '').toString().toLowerCase();
      return name.contains(q) || phone.contains(q) || id.contains(q);
    }).toList();
  }

  Future<void> _fetchPeopleList() async {
    setState(() {
      _loadingPeople = true;
      _peopleError = null;
    });
    try {
      final session = await SessionManager.getSession();
      if (session == null) {
        throw Exception("User session not found. Please log in.");
      }
      final buyerId = session['id'];

      // TODO: confirm this is the correct endpoint for fetching the list
      // of students/downline members this buyer can place a kit order for.
      final res = await http.get(
        Uri.parse("https://apps.kofalt.in/api/get_downline.php?buyer_id=$buyerId"),
      );

      if (res.statusCode != 200) {
        throw Exception("Failed to load list (${res.statusCode})");
      }

      final data = jsonDecode(res.body);
      final List<dynamic> list = data is List
          ? data
          : (data['users'] ?? data['downline'] ?? data['students'] ?? []);

      setState(() {
        _peopleList = list.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        _loadingPeople = false;
      });
    } catch (e) {
      setState(() {
        _peopleError = e.toString();
        _loadingPeople = false;
      });
    }
  }

  void _openPersonSelector() {
    _personSearchController.clear();
    _personSearchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Select Student / Member", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffF5F5F5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _personSearchController,
                            onChanged: (v) => setSheetState(() => _personSearchQuery = v.trim()),
                            decoration: InputDecoration(
                              hintText: "Search by name / phone",
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _loadingPeople
                            ? const Center(child: CircularProgressIndicator(color: Color(0xffFF6B00)))
                            : _peopleError != null
                            ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, color: Colors.grey.shade400, size: 42),
                                const SizedBox(height: 12),
                                Text(
                                  "Could not load list.\n$_peopleError",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _fetchPeopleList();
                                    setSheetState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffFF6B00),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text("Retry", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        )
                            : _filteredPeople.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_search_outlined, color: Colors.grey.shade300, size: 48),
                              const SizedBox(height: 12),
                              Text("No matches found", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                            ],
                          ),
                        )
                            : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: _filteredPeople.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (_, i) {
                            final person = _filteredPeople[i];
                            final name = (person['name'] ?? 'Unnamed').toString();
                            final phone = (person['phone'] ?? '').toString();
                            final isSelected = _selectedPerson != null && _selectedPerson!['id'] == person['id'];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xffFF6B00).withOpacity(.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.person_outline, color: Color(0xffFF6B00), size: 19),
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: phone.isNotEmpty
                                  ? Text(phone, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))
                                  : null,
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: Color(0xffFF6B00))
                                  : null,
                              onTap: () {
                                setState(() => _selectedPerson = person);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ---- Pricing (₹ per kit). TODO: replace with real prices / fetch from API if available ----
  final double _mainKitPrice = 999.0;
  final Map<int, double> _levelKitPrices = {
    2: 799.0,
    3: 799.0,
    4: 849.0,
    5: 849.0,
    6: 899.0,
    7: 899.0,
    8: 999.0,
  };

  final Map<String, IconData> _courseIcons = const {
    "Vedic Maths": Icons.calculate_outlined,
    "Abacus": Icons.grid_view_rounded,
    "English": Icons.menu_book_outlined,
    "Phonics": Icons.record_voice_over_outlined,
  };

  int get _totalItems => _mainKitQty + _levelQty.values.fold(0, (a, b) => a + b);

  double get _totalAmount {
    double total = _mainKitQty * _mainKitPrice;
    for (final entry in _levelQty.entries) {
      total += entry.value * (_levelKitPrices[entry.key] ?? 0);
    }
    return total;
  }

  String _formatAmount(double amount) => "₹${amount.toStringAsFixed(0)}";

  bool get _mainKitMatchesSearch {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return "new kit (main)".contains(q) ||
        "for new student enrollments".contains(q) ||
        "main".contains(q);
  }

  List<int> get _filteredLevels {
    if (_searchQuery.isEmpty) return _levelQty.keys.toList();
    final q = _searchQuery.toLowerCase();
    return _levelQty.keys.where((lvl) {
      return "level $lvl kit".toLowerCase().contains(q) ||
          "level $lvl".contains(q) ||
          "$lvl".contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchPeopleList();
  }

  @override
  void dispose() {
    _mainQtyController.dispose();
    for (final c in _levelQtyControllers.values) {
      c.dispose();
    }
    _searchController.dispose();
    _personSearchController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  //  QUANTITY HANDLERS
  // ----------------------------------------------------------
  void _changeMainQty(int delta) {
    setState(() {
      _mainKitQty = (_mainKitQty + delta).clamp(0, 99);
      _mainQtyController.text = _mainKitQty.toString();
    });
  }

  void _setMainQtyFromText(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) return;
    setState(() {
      _mainKitQty = parsed.clamp(0, 99);
    });
    if (_mainQtyController.text != _mainKitQty.toString()) {
      _mainQtyController.text = _mainKitQty.toString();
    }
  }

  void _changeLevelQty(int level, int delta) {
    setState(() {
      _levelQty[level] = (_levelQty[level]! + delta).clamp(0, 99);
      _levelQtyControllers[level]!.text = _levelQty[level].toString();
    });
  }

  void _setLevelQtyFromText(int level, String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) return;
    setState(() {
      _levelQty[level] = parsed.clamp(0, 99);
    });
    if (_levelQtyControllers[level]!.text != _levelQty[level].toString()) {
      _levelQtyControllers[level]!.text = _levelQty[level].toString();
    }
  }

  // ----------------------------------------------------------
  //  ORDER SUMMARY SHEET
  // ----------------------------------------------------------
  void _openOrderSummary() {
    if (_selectedPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pehle select karein ki kis student/member ke liye order kar rahe hain")),
      );
      _openPersonSelector();
      return;
    }

    final items = <Map<String, dynamic>>[];
    if (_mainKitQty > 0) {
      items.add({'name': 'New Kit (Main)', 'qty': _mainKitQty, 'price': _mainKitPrice});
    }
    for (final l in _levelQty.keys) {
      if (_levelQty[l]! > 0) {
        items.add({'name': 'Level $l Kit', 'qty': _levelQty[l], 'price': _levelKitPrices[l] ?? 0});
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
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
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xffFF6B00).withOpacity(.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_courseIcons[_selectedCourse] ?? Icons.school_outlined, size: 14, color: const Color(0xffFF6B00)),
                              const SizedBox(width: 6),
                              Text(
                                _selectedCourse,
                                style: const TextStyle(color: Color(0xffFF6B00), fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xff16C74A).withOpacity(.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: Color(0xff16C74A)),
                              const SizedBox(width: 6),
                              Text(
                                "For: ${_selectedPerson!['name'] ?? ''}",
                                style: const TextStyle(color: Color(0xff16C74A), fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
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
                        final subtotal = (it['qty'] as int) * (it['price'] as double);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(children: [
                            Container(
                              height: 38, width: 38,
                              decoration: BoxDecoration(color: const Color(0xffFF6B00).withOpacity(.1), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.inventory_2_outlined, color: Color(0xffFF6B00), size: 19),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  Text("x${it['qty']} • ${_formatAmount(it['price'])} each",
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(_formatAmount(subtotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ]),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(_formatAmount(_totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xffFF6B00))),
                      ],
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
    if (_selectedPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pehle select karein ki kis student/member ke liye order kar rahe hain")),
      );
      return;
    }

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
      final forId = _selectedPerson!['id'];
      final forName = _selectedPerson!['name'];

      final orders = <Future>[];
      if (_mainKitQty > 0) {
        orders.add(
            http.post(
              Uri.parse("https://apps.kofalt.in/api/order_kit.php"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "buyer_id": buyerId,
                "for_id": forId,
                "for_name": forName,
                "course": _selectedCourse,
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
                  "for_id": forId,
                  "for_name": forName,
                  "course": _selectedCourse,
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
        final placedCourse = _selectedCourse;
        final placedForName = _selectedPerson!['name'];
        setState(() {
          _mainKitQty = 0;
          _mainQtyController.text = '0';
          for (final l in _levelQty.keys) {
            _levelQty[l] = 0;
            _levelQtyControllers[l]!.text = '0';
          }
          _selectedPerson = null;
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
                  "For: $placedForName\nCourse: $placedCourse\nTotal items ordered: $placedItems\nMLM downline commissions distributed.",
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
  //  ORDER HISTORY
  //  NOTE: assumes a GET endpoint returning past orders for the buyer.
  //  Update the URL below if your backend uses a different path.
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> _fetchOrderHistory() async {
    final session = await SessionManager.getSession();
    if (session == null) {
      throw Exception("User session not found. Please log in.");
    }
    final buyerId = session['id'];

    final res = await http.get(
      Uri.parse("https://apps.kofalt.in/api/get_kit_orders.php?buyer_id=$buyerId"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load order history (${res.statusCode})");
    }

    final data = jsonDecode(res.body);
    final List<dynamic> list = data is List ? data : (data['orders'] ?? []);
    return list.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _showOrderHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Order History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchOrderHistory(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xffFF6B00)));
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline, color: Colors.grey.shade400, size: 42),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Could not load order history.\n${snapshot.error}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => setState(() {}),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffFF6B00),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text("Retry", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final orders = snapshot.data ?? [];
                        if (orders.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2_outlined, color: Colors.grey.shade300, size: 48),
                                const SizedBox(height: 12),
                                Text("No past orders yet", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (_, i) {
                            final o = orders[i];
                            final course = o['course']?.toString();
                            final level = o['level']?.toString() ?? '-';
                            final qty = o['quantity']?.toString() ?? '0';
                            final date = o['created_at']?.toString() ?? o['date']?.toString() ?? '';
                            final status = o['status']?.toString() ?? 'Placed';
                            final forName = o['for_name']?.toString();

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    height: 38, width: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffFF6B00).withOpacity(.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.history, color: Color(0xffFF6B00), size: 19),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course != null && course.isNotEmpty ? "$level • $course" : level,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        Text(
                                          "Qty: $qty${date.isNotEmpty ? ' • $date' : ''}"
                                              "${forName != null && forName.isNotEmpty ? ' • For: $forName' : ''}",
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff16C74A).withOpacity(.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(color: Color(0xff16C74A), fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
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
            onHistory: _showOrderHistory,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- For Whom selector ----
                  _label("For Whom"),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _openPersonSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedPerson != null ? const Color(0xff16C74A).withOpacity(.4) : Colors.grey.shade300,
                          width: 1.2,
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xff16C74A).withOpacity(.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _selectedPerson != null ? Icons.person : Icons.person_search_outlined,
                              color: const Color(0xff16C74A),
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedPerson != null
                                  ? (_selectedPerson!['name'] ?? 'Selected').toString()
                                  : (_loadingPeople ? "Loading list..." : "Select student / member"),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: _selectedPerson != null ? const Color(0xff1E1E1E) : Colors.grey.shade500,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---- Course selector ----
                  _label("Select Course"),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _courses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (ctx, i) {
                        final course = _courses[i];
                        final selected = course == _selectedCourse;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCourse = course),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xffFF6B00) : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: selected ? const Color(0xffFF6B00) : Colors.grey.shade300,
                              ),
                              boxShadow: selected
                                  ? []
                                  : [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 6)],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _courseIcons[course] ?? Icons.school_outlined,
                                  size: 16,
                                  color: selected ? Colors.white : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  course,
                                  style: TextStyle(
                                    color: selected ? Colors.white : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ---- Search bar ----
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value.trim()),
                      decoration: InputDecoration(
                        hintText: "Search kits (e.g. Level 3, Main)",
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                          icon: Icon(Icons.close, color: Colors.grey.shade400, size: 18),
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          }),
                          visualDensity: VisualDensity.compact,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  if (_mainKitMatchesSearch) ...[
                    _label("New Main Kit"),
                    const SizedBox(height: 10),
                    _kitCard(
                      name: "New Kit (Main)",
                      desc: "For new student enrollments",
                      price: _mainKitPrice,
                      color: const Color(0xffFF6B00),
                      qty: _mainKitQty,
                      controller: _mainQtyController,
                      onAdd: () => _changeMainQty(1),
                      onRemove: () => _changeMainQty(-1),
                      onTypedQty: _setMainQtyFromText,
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (_filteredLevels.isNotEmpty) ...[
                    _label("Level Kits (2-8)"),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredLevels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final lvl = _filteredLevels[i];
                        return _kitCard(
                          name: "Level $lvl Kit",
                          desc: "Advanced training modules",
                          price: _levelKitPrices[lvl] ?? 0,
                          color: const Color(0xffFF9500),
                          qty: _levelQty[lvl]!,
                          controller: _levelQtyControllers[lvl]!,
                          onAdd: () => _changeLevelQty(lvl, 1),
                          onRemove: () => _changeLevelQty(lvl, -1),
                          onTypedQty: (value) => _setLevelQtyFromText(lvl, value),
                        );
                      },
                    ),
                  ] else if (!_mainKitMatchesSearch) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off, color: Colors.grey.shade300, size: 42),
                            const SizedBox(height: 10),
                            Text("No kits match \"$_searchQuery\"", style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                  Text(_selectedCourse, style: const TextStyle(color: Color(0xffFF6B00), fontSize: 11, fontWeight: FontWeight.w600)),
                  Text("$_totalItems items", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(_formatAmount(_totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
    required VoidCallback onHistory,
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(.8), fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: "Order History",
            onPressed: onHistory,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E1E1E)));

  Widget _kitCard({
    required String name,
    required String desc,
    required double price,
    required Color color,
    required int qty,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    required ValueChanged<String> onTypedQty,
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
                const SizedBox(height: 2),
                Text(_formatAmount(price), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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
                // ---- editable quantity input ----
                SizedBox(
                  width: 34,
                  height: 26,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                    onChanged: onTypedQty,
                  ),
                ),
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