import 'dart:ui' as ui;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:thenew/dashboards/franchisedashboard.dart';
import 'package:thenew/dashboards/schoolDashboard.dart';
import 'package:thenew/dashboards/studentdashboard.dart';
import 'package:thenew/services/session_manager.dart';
import 'package:thenew/services/kyc_status_screen.dart';
import '../dashboards/distributor_dashboard.dart';
import 'package:flutter/gestures.dart';

// ─── In-memory draft store ───────────────────────────────────────────────────
// Keeps the checkbox + signature state alive for each role even if the
// caller (the previous KYC form screen) does not capture/replay the value
// returned from Navigator.pop(). This acts as a safety-net so that going
// back to the previous KYC screen and returning to this Agreement screen
// later in the same app session restores exactly where the user left off.
class _AgreementDraftStore {
  static final Map<String, Map<String, dynamic>> _drafts = {};

  static void save(String role, Map<String, dynamic> data) {
    _drafts[role] = data;
  }

  static Map<String, dynamic>? load(String role) {
    return _drafts[role];
  }

  static void clear(String role) {
    _drafts.remove(role);
  }
}

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
  final Map<String, String> formData;
  final Map<String, dynamic> kycData;
  final Map<String, dynamic>? initialAgreementData;
  final bool isPostSignupKyc;
  final int userId;

  const AgreementSigningScreen({
    super.key,
    required this.role,
    required this.formData,
    required this.kycData,
    this.initialAgreementData,
    this.isPostSignupKyc = false,
    this.userId = 0,
  });

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

  // ── Restore previous state if user came back from a later screen ──
  @override
  void initState() {
    super.initState();
    // Prefer data explicitly passed back by the caller. If the caller
    // didn't pass anything (e.g. it navigated here fresh), fall back to
    // whatever was last saved in the in-memory draft store for this role,
    // so checkbox + signature survive a trip back to the previous KYC screen.
    final data = widget.initialAgreementData ?? _AgreementDraftStore.load(widget.role);
    if (data != null) {
      isAccepted = data['isAccepted'] ?? false;
      isSigned = data['isSigned'] ?? false;

      final sizeMap = data['padCanvasSize'];
      if (sizeMap != null) {
        _padCanvasSize = Size(
          (sizeMap['width'] as num).toDouble(),
          (sizeMap['height'] as num).toDouble(),
        );
      }

      final strokesData = data['strokes'] as List<dynamic>?;
      if (strokesData != null) {
        for (final stroke in strokesData) {
          final List<Offset?> s = (stroke as List<dynamic>).map((p) {
            if (p == null) return null;
            final m = p as Map<String, dynamic>;
            return Offset(
                (m['dx'] as num).toDouble(), (m['dy'] as num).toDouble());
          }).toList();
          _strokes.add(s);
        }
      }
    }
  }

  // ── Snapshot current state so it can be passed back on pop ──
  Map<String, dynamic> _currentAgreementData() {
    return {
      'isAccepted': isAccepted,
      'isSigned': isSigned,
      'padCanvasSize': {
        'width': _padCanvasSize.width,
        'height': _padCanvasSize.height,
      },
      'strokes': _strokes
          .map((stroke) => stroke
          .map((p) => p == null ? null : {'dx': p.dx, 'dy': p.dy})
          .toList())
          .toList(),
    };
  }

  // ── Persist current state into the in-memory draft store ──
  // Called after every meaningful state change so the checkbox and
  // signature are never lost, regardless of how the user navigates away
  // (back button, gesture, or the caller simply not re-passing the data).
  void _saveDraft() {
    _AgreementDraftStore.save(widget.role, _currentAgreementData());
  }

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
    _saveDraft();
  }
  Map<String, List<Map<String, String>>> get _roleTerms => {
    "Student": [
      {
        "title": "1. Student Registration",
        "text":
        "By registering as a Student, you confirm that the personal, school and academic information provided by you is accurate and belongs to you."
      },
      {
        "title": "2. Information Provided",
        "text":
        "You have provided your School Name, Class/Grade and Date of Birth. You agree to keep this information accurate and updated."
      },
      {
        "title": "3. KYC Verification",
        "text":
        "You are required to provide Aadhaar details and a selfie for identity verification. KYC information must be genuine and valid."
      },
      {
        "title": "4. Student Account",
        "text":
        "The account is intended for educational use. You must not share your login credentials or allow another person to use your account."
      },
      {
        "title": "5. Data Privacy",
        "text":
        "Your personal, academic and KYC information will be used for verification, account management and providing platform services."
      },
      {
        "title": "6. Account Suspension",
        "text":
        "Kofalt Global may suspend or terminate the account if false information, fraudulent documents or misuse of the platform is detected."
      },
    ],

    "School": [
      {
        "title": "1. School Registration",
        "text":
        "By registering as a School, you confirm that you are authorised to provide information on behalf of the institution."
      },
      {
        "title": "2. Institution Details",
        "text":
        "You have provided the Principal Name, Board/Affiliation, School Registration Number and City. All information must be accurate and verifiable."
      },
      {
        "title": "3. KYC Verification",
        "text":
        "School verification requires Aadhaar, PAN, School Registration Certificate and Bank Details as applicable to the submitted registration."
      },
      {
        "title": "4. Documents",
        "text":
        "All uploaded documents must be genuine, readable and valid. Submission of forged or misleading documents may result in rejection or account suspension."
      },
      {
        "title": "5. Data Privacy",
        "text":
        "School, representative and KYC information will be used for verification, institutional account management and platform-related services."
      },
      {
        "title": "6. Account Responsibility",
        "text":
        "The authorised representative is responsible for maintaining the accuracy of the school's information and account credentials."
      },
    ],

    "Franchise Partner": [
      {
        "title": "1. Franchise Partnership",
        "text":
        "By registering as a Franchise Partner, you express your interest in joining the Kofalt Global franchise network and agree to provide accurate business information."
      },
      {
        "title": "2. Business Information",
        "text":
        "You have provided your Business Name, GST Number, City/Area and Business Experience. These details must be accurate and verifiable."
      },
      {
        "title": "3. KYC Verification",
        "text":
        "Franchise Partner verification requires Aadhaar, PAN, GST Certificate and Bank Details as applicable to the registration."
      },
      {
        "title": "4. Business Documents",
        "text":
        "All business and identity documents submitted for verification must be genuine, valid and belong to the applicant or registered business."
      },
      {
        "title": "5. Commission & Payouts",
        "text":
        "Any commission or payout associated with the franchise program is subject to applicable verification, eligibility and Kofalt Global policies."
      },
      {
        "title": "6. Data Privacy",
        "text":
        "Business, personal, financial and KYC information will be used for verification, partnership management and platform operations."
      },
      {
        "title": "7. Termination",
        "text":
        "Kofalt Global may suspend or terminate a franchise account in case of fraudulent information, invalid documents or violation of applicable platform policies."
      },
    ],

    "Distributor": [
      {
        "title": "1. Distributor Registration",
        "text":
        "By registering as a Distributor, you confirm that the business and personal information submitted during registration is accurate."
      },
      {
        "title": "2. Business Information",
        "text":
        "You have provided your Business/Firm Name, Distribution Area and Experience in the Education Field. These details must be accurate and verifiable."
      },
      {
        "title": "3. KYC Verification",
        "text":
        "Distributor verification requires Aadhaar, PAN and Bank Details as applicable to the registration."
      },
      {
        "title": "4. Distribution Responsibility",
        "text":
        "The Distributor is responsible for maintaining accurate business information and complying with applicable Kofalt Global policies."
      },
      {
        "title": "5. Commission & Payouts",
        "text":
        "Any commission or payout is subject to verification, eligibility and the applicable distributor program terms and policies."
      },
      {
        "title": "6. Data Privacy",
        "text":
        "Personal, business, financial and KYC information will be used for verification, account management and platform services."
      },
      {
        "title": "7. Termination",
        "text":
        "Kofalt Global may suspend or terminate the account if false information, fraudulent documents or policy violations are detected."
      },
    ],
  };
  void _showTermsPopup() {
    final terms =
        _roleTerms[widget.role] ??
            _roleTerms["Distributor"]!;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 40,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight:
            MediaQuery.of(context).size.height * .80,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  12,
                  18,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff2563EB),
                      Color(0xffA020F0),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Terms & Conditions",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Role
              Container(
                margin: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  4,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xffBFDBFE),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: Color(0xff2563EB),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Agreement for ${widget.role}",
                      style: const TextStyle(
                        color: Color(0xff1D4ED8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Terms
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: terms.map((term) {
                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 18,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              term["title"]!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                FontWeight.bold,
                                color:
                                Colors.black87,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              term["text"]!,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color:
                                Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    _saveDraft();
    _showSnack("successfully save the Signature ✓", isError: false);
  }

  void _openSignaturePad() {
    if (!isAccepted) {
      _showSnack("Accept the terms and conditions first", isError: true);
      return;
    }
    setState(() => _showSignaturePad = true);
  }

  Future<File?> _saveSignatureAsFile() async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, _padCanvasSize.width, _padCanvasSize.height));

      // Paint background white
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, _padCanvasSize.width, _padCanvasSize.height), bgPaint);

      final paint = Paint()
        ..color = const Color(0xff1D4ED8)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      for (final stroke in _strokes) {
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

      final picture = recorder.endRecording();
      final img = await picture.toImage(_padCanvasSize.width.toInt(), _padCanvasSize.height.toInt());
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
      if (pngBytes == null) return null;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes.buffer.asUint8List());
      return file;
    } catch (e) {
      debugPrint("Error saving signature image: $e");
      return null;
    }
  }

  void _onSubmit() async {
    if (!isAccepted || !isSigned) {
      _showSnack("Agreement sign karna zaroori hai", isError: true);
      return;
    }

    // Show Loader Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xff2563EB)),
                SizedBox(height: 18),
                Text(
                  "Submitting KYC & Registering...",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final sigFile = await _saveSignatureAsFile();

      final url = widget.isPostSignupKyc
          ? Uri.parse("https://apps.kofalt.in/api/submit_kyc.php")
          : Uri.parse("https://apps.kofalt.in/api/signup.php");

      final Map<String, dynamic> requestBody = {};

      if (widget.isPostSignupKyc) {
        requestBody['user_id'] = widget.userId;
      }

      // Add common form fields
      widget.formData.forEach((key, value) {
        requestBody[key] = value;
      });

      // Add KYC text and file fields
      for (final entry in widget.kycData.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value == null) continue;
        if (value is String) {
          requestBody[key] = value;
        } else if (value is File) {
          final bytes = await value.readAsBytes();
          requestBody['${key}_base64'] = base64Encode(bytes);
          requestBody['${key}_ext'] = value.path.split('.').last;
        }
      }

      // Add signature file
      if (sigFile != null) {
        final bytes = await sigFile.readAsBytes();
        requestBody['signature_base64'] = base64Encode(bytes);
        requestBody['signature_ext'] = 'png';
      }

      // Log fields being sent for verification
      debugPrint("Sending registration to: ${url.toString()}");
      requestBody.forEach((k, v) {
        if (k.endsWith('_base64')) {
          debugPrint("Base64 Field: $k (Length: ${v.toString().length} characters)");
        } else {
          debugPrint("Field: $k = $v");
        }
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 60));

      final responseBody = response.body;

      // Close Loader Dialog
      if (mounted) Navigator.pop(context);

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(responseBody);
      } catch (e) {
        debugPrint("Server Raw Response (HTML): $responseBody");
        final String cleanResponse = responseBody.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
        final String excerpt = cleanResponse.length > 120 ? cleanResponse.substring(0, 120) + "..." : cleanResponse;
        if (mounted) {
          _showSnack("Server Error: $excerpt", isError: true);
        }
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == 'success') {
          if (widget.isPostSignupKyc) {
            // Update session's KYC status to Pending
            final session = await SessionManager.getSession();
            if (session != null) {
              await SessionManager.saveSession(
                id: session['id'],
                name: session['name'],
                email: session['email'],
                phone: session['phone'],
                role: session['role'],
                kycStatus: 'Pending',
                isImpersonating: session['isImpersonating'] ?? false,
              );
            }
            _AgreementDraftStore.clear(widget.role);
            if (mounted) {
              _showSnack("KYC Submitted Successfully!", isError: false);
              // Pop back to profile screen and refresh
              Navigator.pop(context, true); // Pop AgreementSigningScreen
              Navigator.pop(context, true); // Pop KycVerificationScreen
            }
            return;
          }

          // Success! Save session locally (normal signup path)
          final user = responseData['user'];
          final int userId = user['id'] is int
              ? user['id']
              : int.tryParse(user['id'].toString()) ?? 0;

          await SessionManager.saveSession(
            id: userId,
            name: user['name'],
            email: user['email'],
            phone: user['phone'],
            role: user['role'],
            kycStatus: user['kyc_status'],
          );

          // Registration succeeded — clear the saved draft for this role
          _AgreementDraftStore.clear(widget.role);

          if (mounted) {
            _showSnack("KYC Submitted Successfully!", isError: false);

            // Navigate to KYC status blocking page
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => KycStatusScreen(userSession: user),
              ),
                  (route) => false,
            );
          }
        } else {
          _showSnack(responseData['message'] ?? "Registration failed", isError: true);
        }
      } else {
        _showSnack(responseData['message'] ?? "Server returned error ${response.statusCode}", isError: true);
      }
    } catch (e) {
      // Close Loader Dialog if open
      if (mounted) {
        Navigator.pop(context);
        _showSnack("Connection error: $e", isError: true);
      }
    }
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _saveDraft();
        Navigator.pop(context, _currentAgreementData());
      },
      child: Stack(
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
                            onTap: () {
                              setState(() => isAccepted = !isAccepted);
                              _saveDraft();
                            },
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
                                              color: isAccepted ? const Color(0xff2563EB) : Colors.black,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()..onTap = _showTermsPopup,
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
      ),
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
                onTap: () {
                  _saveDraft();
                  Navigator.pop(context, _currentAgreementData());
                },
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