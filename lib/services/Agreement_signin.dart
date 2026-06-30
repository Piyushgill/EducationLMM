import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:thenew/dashboards/franchisedashboard.dart';
import 'package:thenew/dashboards/schoolDashboard.dart';
import 'package:thenew/dashboards/studentdashboard.dart';
import '../dashboards/distributor_dashboard.dart';

// ─── Signature Painter ───────────────────────────────────────────────────────

class SignaturePainter extends CustomPainter {
  final List<List<Offset?>> strokes;

  SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff1D4ED8)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      final path = Path();
      bool started = false;
      for (final point in stroke) {
        if (point == null) {
          started = false;
        } else if (!started) {
          path.moveTo(point.dx, point.dy);
          started = true;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}

// ─── Agreement Signing Screen ─────────────────────────────────────────────────

class AgreementSigningScreen extends StatefulWidget {
  final String role;

  const AgreementSigningScreen({super.key, required this.role});

  @override
  State<AgreementSigningScreen> createState() =>
      _AgreementSigningScreenState();
}

class _AgreementSigningScreenState extends State<AgreementSigningScreen> {
  bool isAccepted = false;
  bool isSigned = false;
  bool _showSignaturePad = false;

  // Signature strokes — each inner list is one continuous stroke
  final List<List<Offset?>> _strokes = [];
  List<Offset?> _currentStroke = [];

  // Size of the drawing canvas inside the signature pad dialog.
  // We store this so we can correctly scale the signature into the
  // small preview box on the main screen instead of letting it overflow.
  Size _padCanvasSize = const Size(300, 200);

  // ── Signature pad handlers ──
  void _onPanStart(DragStartDetails d) {
    _currentStroke = [d.localPosition];
    setState(() => _strokes.add(_currentStroke));
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _currentStroke.add(d.localPosition));
  }

  void _onPanEnd(DragEndDetails _) {
    _currentStroke.add(null); // stroke separator
  }

  bool get _hasDrawn =>
      _strokes.any((s) => s.any((p) => p != null));

  void _clearSignature() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      isSigned = false;
    });
  }

  void _confirmSignature() {
    if (!isAccepted) {
      _showSnack("Accept the terms and conditions first", isError: true);
      return;
    }
    if (!_hasDrawn) {
      _showSnack("Sign in the signature box first", isError: true);
      return;
    }
    setState(() {
      isSigned = true;
      _showSignaturePad = false;
    });
    _showSnack("successfully save the Signature ✓", isError: false);
  }

  void _openSignaturePad() {
    if (!isAccepted) {
      _showSnack("Accept the terms and conditions first", isError: true);
      return;
    }
    setState(() => _showSignaturePad = true);
  }

  void _onSubmit() {
    if (!isAccepted || !isSigned) {
      _showSnack("Agreement sign karna zaroori hai", isError: true);
      return;
    }

    Widget screen;
    switch (widget.role) {
      case "Distributor":
        screen = const DistributorDashboard();
        break;
      case "Franchise Partner":
        screen = const FranchiseDashboard();
        break;
      case "School":
        screen = const SchoolDashboard();
        break;
      case "Student":
        screen = const StudentDashboard();
        break;
      default:
        screen = const DistributorDashboard();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
          (route) => false,
    );
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.verified_outlined,
              color: Colors.white,
              size: 17,
            ),
            const SizedBox(width: 10),
            Text(msg),
          ],
        ),
        backgroundColor:
        isError ? Colors.red.shade400 : const Color(0xff2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xffEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                            border:
                            Border.all(color: const Color(0xffBFDBFE)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_outline_rounded,
                                  color: Color(0xff2563EB), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                "Joining as: ${widget.role}",
                                style: const TextStyle(
                                  color: Color(0xff1D4ED8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        _sectionLabel("Agreement Terms"),
                        const SizedBox(height: 12),
                        _termsCard(),

                        const SizedBox(height: 20),

                        // Checkbox
                        GestureDetector(
                          onTap: () =>
                              setState(() => isAccepted = !isAccepted),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isAccepted
                                  ? const Color(0xffEFF6FF)
                                  : const Color(0xffF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: isAccepted
                                  ? Border.all(
                                  color: const Color(0xffBFDBFE))
                                  : Border.all(
                                  color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  margin: const EdgeInsets.only(top: 1),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(6),
                                    color: isAccepted
                                        ? const Color(0xff2563EB)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isAccepted
                                          ? const Color(0xff2563EB)
                                          : Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isAccepted
                                      ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 14)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.4,
                                          color: Colors.black87),
                                      children: [
                                        const TextSpan(
                                            text: "By submitting "),
                                        const TextSpan(
                                            text:
                                            " this form, you agree to the"),
                                        TextSpan(
                                          text: "Terms & Conditions .",
                                          style: TextStyle(
                                            color: isAccepted
                                                ? const Color(0xff2563EB)
                                                : Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        _sectionLabel("Signature"),
                        const SizedBox(height: 12),

                        // Signature display box
                        GestureDetector(
                          onTap: _openSignaturePad,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 130,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isSigned
                                  ? const Color(0xffEFF6FF)
                                  : const Color(0xffF8FAFC),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSigned
                                    ? const Color(0xff2563EB)
                                    : Colors.grey.shade300,
                                width: isSigned ? 1.5 : 1,
                              ),
                            ),
                            // Clip everything inside the box so the signature
                            // (drawn on a bigger canvas inside the pad) can
                            // never paint/overflow outside this rounded box.
                            clipBehavior: Clip.antiAlias,
                            child: isSigned
                                ? Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                // Show mini preview of drawn signature,
                                // scaled down (FittedBox) from the actual
                                // pad canvas size so proportions stay
                                // correct and nothing overflows.
                                SizedBox(
                                  height: 60,
                                  width: 200,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: SizedBox(
                                      width: _padCanvasSize.width,
                                      height: _padCanvasSize.height,
                                      child: CustomPaint(
                                        painter:
                                        SignaturePainter(_strokes),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.verified_rounded,
                                        color: Color(0xff2563EB),
                                        size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      "Signature Recorded",
                                      style: TextStyle(
                                        color: Color(0xff2563EB),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                                : Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(Icons.draw_outlined,
                                    color: Colors.grey.shade400,
                                    size: 34),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap to Sign",
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAccepted
                                      ? "Sign here"
                                      : "Accept the terms first",
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Clear + Re-sign buttons (only when signed)
                        if (isSigned)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _clearSignature,
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF1F5F9),
                                      borderRadius:
                                      BorderRadius.circular(14),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.restart_alt_rounded,
                                            color: Colors.grey, size: 16),
                                        SizedBox(width: 6),
                                        Text("Clear",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: _openSignaturePad,
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xff2563EB),
                                          Color(0xffA020F0),
                                        ],
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.draw_rounded,
                                            color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          "Re-Sign",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 28),

                        // Submit button
                        GestureDetector(
                          onTap: _onSubmit,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 62,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: (isAccepted && isSigned)
                                  ? const LinearGradient(
                                colors: [
                                  Color(0xff2563EB),
                                  Color(0xffA020F0),
                                ],
                              )
                                  : null,
                              color: (isAccepted && isSigned)
                                  ? null
                                  : Colors.grey.shade200,
                              boxShadow: (isAccepted && isSigned)
                                  ? [
                                BoxShadow(
                                  color:
                                  Colors.black.withOpacity(.14),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                "Go Submit & Dashboard",
                                style: TextStyle(
                                  color: (isAccepted && isSigned)
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── SIGNATURE PAD OVERLAY ──
        if (_showSignaturePad)
          GestureDetector(
            onTap: () {}, // block background taps
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  // Constrain the popup card so it never grows taller than
                  // the available screen space and never overflows.
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff2563EB), Color(0xffA020F0)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.draw_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Sign your own signature",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showSignaturePad = false),
                              child: Container(
                                height: 34,
                                width: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Drawing canvas — wrapped in Flexible + scroll so the
                      // whole card shrinks/scrolls instead of overflowing on
                      // small screens.
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Sign in the box below",
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: GestureDetector(
                                  onPanStart: _onPanStart,
                                  onPanUpdate: _onPanUpdate,
                                  onPanEnd: _onPanEnd,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Remember actual canvas size so the
                                      // preview on the main screen can be
                                      // scaled correctly instead of
                                      // overflowing its box.
                                      _padCanvasSize = Size(
                                          constraints.maxWidth, 200);
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFAFCFF),
                                          borderRadius:
                                          BorderRadius.circular(16),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: Stack(
                                          children: [
                                            // Baseline
                                            Positioned(
                                              bottom: 50,
                                              left: 20,
                                              right: 20,
                                              child: Container(
                                                height: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.25),
                                              ),
                                            ),
                                            // Hint text
                                            if (!_hasDrawn)
                                              Center(
                                                child: Text(
                                                  "sign here",
                                                  style: TextStyle(
                                                    color:
                                                    Colors.grey.shade300,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            // Drawn signature
                                            CustomPaint(
                                              painter: SignaturePainter(
                                                  _strokes),
                                              size: Size.infinite,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _clearSignature,
                                      child: Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffF1F5F9),
                                          borderRadius:
                                          BorderRadius.circular(14),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.restart_alt_rounded,
                                                color: Colors.grey,
                                                size: 16),
                                            SizedBox(width: 6),
                                            Text("Clear",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                    fontWeight:
                                                    FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: _confirmSignature,
                                      child: Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(14),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xff2563EB),
                                              Color(0xffA020F0),
                                            ],
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                                Icons.check_circle_rounded,
                                                color: Colors.white,
                                                size: 16),
                                            SizedBox(width: 6),
                                            Text(
                                              "Confirm",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
          left: 24, right: 24, top: 24, bottom: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff2563EB), Color(0xffA020F0)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            "Agreement",
            style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Review and sign so you can move forward",
            style: TextStyle(
                color: Colors.white.withOpacity(.9), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
    );
  }

  Widget _termsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _termRow(
            Icons.menu_book_outlined,
            "Terms & Conditions",
            "I have read all the terms and conditions written in this agreement.",
          ),
          _divider(),
          _termRow(
            Icons.business_center_outlined,
            "Company Policies",
            "I will follow all the company's policies, guidelines, and code of conduct",
          ),
          _divider(),
          _termRow(
            Icons.draw_outlined,
            "Legal Validity",
            "My electronic signature is legally valid and equivalent to a handwritten signature."
                "",
          ),
        ],
      ),
    );
  }

  Widget _termRow(IconData icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xffEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xff2563EB), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(height: 1, color: Colors.grey.shade100);
}