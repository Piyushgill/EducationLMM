import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thenew/services/Agreement_signin.dart';

// ── Role-based KYC config ────────────────────────────────────────────────────

enum KycDocType {
  aadhaar,   // Aadhaar number + front + back
  pan,       // PAN number + image
  gst,       // GST number + certificate image
  schoolReg, // School registration number + certificate image
  selfie,    // Live selfie
  bank,      // Account + IFSC + bank name
}

class KycStepConfig {
  final String title;
  final String subtitle;
  final List<KycDocType> docs;

  const KycStepConfig({
    required this.title,
    required this.subtitle,
    required this.docs,
  });
}

// Role → list of KYC steps
const Map<String, List<KycStepConfig>> kRoleKycSteps = {
  "Student": [
    KycStepConfig(
      title: "Identity",
      subtitle: "Upload your Aadhaar card",
      docs: [KycDocType.aadhaar],
    ),
    KycStepConfig(
      title: "Selfie",
      subtitle: "Take a live photo for verification",
      docs: [KycDocType.selfie],
    ),
  ],
  "School": [
    KycStepConfig(
      title: "Documents",
      subtitle: "Aadhaar, PAN & Registration",
      docs: [KycDocType.aadhaar, KycDocType.pan, KycDocType.schoolReg],
    ),
    KycStepConfig(
      title: "Selfie",
      subtitle: "Principal's live photo",
      docs: [KycDocType.selfie],
    ),
    KycStepConfig(
      title: "Bank",
      subtitle: "School bank account details",
      docs: [KycDocType.bank],
    ),
  ],
  "Franchise Partner": [
    KycStepConfig(
      title: "Documents",
      subtitle: "Aadhaar, PAN & GST",
      docs: [KycDocType.aadhaar, KycDocType.pan, KycDocType.gst],
    ),
    KycStepConfig(
      title: "Selfie",
      subtitle: "Take a live photo for verification",
      docs: [KycDocType.selfie],
    ),
    KycStepConfig(
      title: "Bank",
      subtitle: "Business bank account details",
      docs: [KycDocType.bank],
    ),
  ],
  "Distributor": [
    KycStepConfig(
      title: "Documents",
      subtitle: "Aadhaar & PAN card",
      docs: [KycDocType.aadhaar, KycDocType.pan],
    ),
    KycStepConfig(
      title: "Selfie",
      subtitle: "Take a live photo for verification",
      docs: [KycDocType.selfie],
    ),
    KycStepConfig(
      title: "Bank",
      subtitle: "Your bank account details",
      docs: [KycDocType.bank],
    ),
  ],
  "Agent": [
    KycStepConfig(
      title: "Documents",
      subtitle: "Aadhaar & PAN card",
      docs: [KycDocType.aadhaar, KycDocType.pan],
    ),
    KycStepConfig(
      title: "Selfie",
      subtitle: "Take a live photo for verification",
      docs: [KycDocType.selfie],
    ),
    KycStepConfig(
      title: "Bank",
      subtitle: "Your bank account details",
      docs: [KycDocType.bank],
    ),
  ],
};

// ── Screen ───────────────────────────────────────────────────────────────────

class KycVerificationScreen extends StatefulWidget {
  final String role;
  final Map<String, String> formData;
  final Map<String, dynamic>? inialKycData;
  final bool isPostSignupKyc;
  final int userId;

  const KycVerificationScreen({
    super.key,
    required this.role,
    required this.formData,
    this.inialKycData,
    this.isPostSignupKyc = false,
    this.userId = 0,
  });

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  int currentStep = 0;
  Map<String, dynamic>? _savedAgreementData;

  List<KycStepConfig> get _steps => kRoleKycSteps[widget.role] ?? kRoleKycSteps["Distributor"]!;
  KycStepConfig get _currentStepConfig => _steps[currentStep];

  // ── Document data ──
  // Aadhaar
  final TextEditingController _aadhaarCtrl = TextEditingController();
  File? _aadhaarFront;
  File? _aadhaarBack;

  // PAN
  final TextEditingController _panCtrl = TextEditingController();
  File? _panCard;

  // GST
  final TextEditingController _gstCtrl = TextEditingController();
  File? _gstCert;

  // School Registration
  final TextEditingController _schoolRegCtrl = TextEditingController();
  File? _schoolRegCert;

  // Selfie
  File? _selfieImage;

  // Bank
  final TextEditingController _accountCtrl = TextEditingController();
  final TextEditingController _ifscCtrl = TextEditingController();
  final TextEditingController _bankNameCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _aadhaarCtrl.dispose();
    _panCtrl.dispose();
    _gstCtrl.dispose();
    _schoolRegCtrl.dispose();
    _accountCtrl.dispose();
    _ifscCtrl.dispose();
    _bankNameCtrl.dispose();
    super.dispose();
  }

  // ── Image picking ──
  Future<void> _pickImage(String type) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60, // Compress to 60%
      maxWidth: 1080,   // Max width constraint
      maxHeight: 1080,  // Max height constraint
    );
    if (picked == null) return;
    setState(() {
      if (type == 'aadhaar_front') _aadhaarFront = File(picked.path);
      if (type == 'aadhaar_back') _aadhaarBack = File(picked.path);
      if (type == 'pan') _panCard = File(picked.path);
      if (type == 'gst_cert') _gstCert = File(picked.path);
      if (type == 'school_reg') _schoolRegCert = File(picked.path);
    });
  }


  // ── Selfie Capture using System Camera ──
  Future<void> _captureSelfie() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 60, // Compress to 60%
        maxWidth: 1080,   // Max width constraint
        maxHeight: 1080,  // Max height constraint
      );
      if (picked != null) {
        setState(() {
          _selfieImage = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint("Selfie capture error: $e");
    }
  }
  // ── Validation ──
  bool _validateStep() {
    final docs = _currentStepConfig.docs;

    for (final doc in docs) {
      switch (doc) {
        case KycDocType.aadhaar:
          final cleanAadhaar = _aadhaarCtrl.text.replaceAll(' ', '');
          if (cleanAadhaar.isEmpty) {
            _showError("Please enter Aadhaar number");
            return false;
          }
          if (cleanAadhaar.length != 12 || !RegExp(r'^\d{12}$').hasMatch(cleanAadhaar)) {
            _showError("Aadhaar number must be exactly 12 digits");
            return false;
          }
          if (_aadhaarFront == null || _aadhaarBack == null) {
            _showError("Please upload Aadhaar front & back");
            return false;
          }
          break;

        case KycDocType.pan:
          final panVal = _panCtrl.text.trim().toUpperCase();
          if (panVal.isEmpty) {
            _showError("Please enter PAN number");
            return false;
          }
          if (panVal.length != 10 || !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(panVal)) {
            _showError("Enter a valid 10-character PAN (e.g. ABCDE1234F)");
            return false;
          }
          if (_panCard == null) {
            _showError("Please upload PAN card image");
            return false;
          }
          break;

        case KycDocType.gst:
          final gstVal = _gstCtrl.text.trim().toUpperCase();
          if (gstVal.isEmpty) {
            _showError("Please enter GST number");
            return false;
          }
          if (gstVal.length != 15 || !RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$').hasMatch(gstVal)) {
            _showError("Enter a valid 15-character GST (e.g. 22AAAAA0000A1Z5)");
            return false;
          }
          if (_gstCert == null) {
            _showError("Please upload GST certificate");
            return false;
          }
          break;

        case KycDocType.schoolReg:
          if (_schoolRegCtrl.text.trim().isEmpty) {
            _showError("Please enter School Registration number");
            return false;
          }
          if (_schoolRegCert == null) {
            _showError("Please upload Registration certificate");
            return false;
          }
          break;

        case KycDocType.selfie:
          if (_selfieImage == null) {
            _showError("Please take a selfie");
            return false;
          }
          break;

        case KycDocType.bank:
          final accountVal = _accountCtrl.text.trim();
          final ifscVal = _ifscCtrl.text.trim().toUpperCase();
          if (accountVal.isEmpty) {
            _showError("Please enter account number");
            return false;
          }
          if (accountVal.length < 9 || accountVal.length > 18 || !RegExp(r'^\d+$').hasMatch(accountVal)) {
            _showError("Account number must be between 9 and 18 digits");
            return false;
          }
          if (ifscVal.isEmpty) {
            _showError("Please enter IFSC code");
            return false;
          }
          if (ifscVal.length != 11 || !RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifscVal)) {
            _showError("Enter a valid 11-character IFSC (e.g. SBIN0001234)");
            return false;
          }
          if (_bankNameCtrl.text.trim().isEmpty) {
            _showError("Please enter bank name");
            return false;
          }
          break;
      }
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    // Step title & subtitle
                    Text(
                      _currentStepConfig.title,
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentStepConfig.subtitle,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                    const SizedBox(height: 28),
                    // Role badge
                    _buildRoleBadge(),
                    const SizedBox(height: 24),
                    // Dynamic doc widgets
                    ..._currentStepConfig.docs.map(_buildDocWidget),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge() {
    final Map<String, IconData> roleIcons = {
      "Student": Icons.school_outlined,
      "School": Icons.domain_outlined,
      "Franchise Partner": Icons.handshake_outlined,
      "Distributor": Icons.local_shipping_outlined,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2563EB), Color(0xffA020F0)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(roleIcons[widget.role] ?? Icons.person_outline, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            widget.role,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDocWidget(KycDocType doc) {
    switch (doc) {
      case KycDocType.aadhaar:
        return _buildAadhaarSection();
      case KycDocType.pan:
        return _buildPanSection();
      case KycDocType.gst:
        return _buildGstSection();
      case KycDocType.schoolReg:
        return _buildSchoolRegSection();
      case KycDocType.selfie:
        return _buildSelfieSection();
      case KycDocType.bank:
        return _buildBankSection();
    }
  }

  // ── Aadhaar ──
  Widget _buildAadhaarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.credit_card_outlined, "Aadhaar Card"),
        const SizedBox(height: 14),
        _label("Aadhaar Number"),
        const SizedBox(height: 10),
        _textField(
          controller: _aadhaarCtrl,
          hint: "1234 5678 9012",
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [AadhaarFormatter()],
        ),
        const SizedBox(height: 16),
        _label("Upload Aadhaar Card"),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _uploadBox("Front", _aadhaarFront, 'aadhaar_front')),
          const SizedBox(width: 14),
          Expanded(child: _uploadBox("Back", _aadhaarBack, 'aadhaar_back')),
        ]),
        const SizedBox(height: 28),
      ],
    );
  }

  // ── PAN ──
  Widget _buildPanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.description_outlined, "PAN Card"),
        const SizedBox(height: 14),
        _label("PAN Number"),
        const SizedBox(height: 10),
        _textField(
          controller: _panCtrl,
          hint: "ABCDE1234F",
          icon: Icons.description_outlined,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            UpperCaseTextFormatter(),
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: 16),
        _label("Upload PAN Card"),
        const SizedBox(height: 12),
        _uploadBox("PAN Card", _panCard, 'pan', height: 160),
        const SizedBox(height: 28),
      ],
    );
  }

  // ── GST ──
  Widget _buildGstSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.receipt_long_outlined, "GST Certificate"),
        const SizedBox(height: 14),
        _label("GST Number"),
        const SizedBox(height: 10),
        _textField(
          controller: _gstCtrl,
          hint: "22AAAAA0000A1Z5",
          icon: Icons.receipt_long_outlined,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            UpperCaseTextFormatter(),
            LengthLimitingTextInputFormatter(15),
          ],
        ),
        const SizedBox(height: 16),
        _label("Upload GST Certificate"),
        const SizedBox(height: 12),
        _uploadBox("GST Certificate", _gstCert, 'gst_cert', height: 160),
        const SizedBox(height: 28),
      ],
    );
  }

  // ── School Registration ──
  Widget _buildSchoolRegSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.school_outlined, "School Registration"),
        const SizedBox(height: 14),
        _label("Registration Number"),
        const SizedBox(height: 10),
        _textField(controller: _schoolRegCtrl, hint: "SCH/2024/001234",
            icon: Icons.confirmation_number_outlined,
            textCapitalization: TextCapitalization.characters),
        const SizedBox(height: 16),
        _label("Upload Registration Certificate"),
        const SizedBox(height: 12),
        _uploadBox("Registration Cert", _schoolRegCert, 'school_reg', height: 160),
        const SizedBox(height: 28),
      ],
    );
  }

  // ── Bank ──
  Widget _buildBankSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.account_balance_outlined, "Bank Details"),
        const SizedBox(height: 14),
        _label("Account Number"),
        const SizedBox(height: 10),
        _textField(
          controller: _accountCtrl,
          hint: "1234567890",
          icon: Icons.account_balance_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(18),
          ],
        ),
        const SizedBox(height: 16),
        _label("IFSC Code"),
        const SizedBox(height: 10),
        _textField(
          controller: _ifscCtrl,
          hint: "SBIN0001234",
          icon: Icons.code_rounded,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            UpperCaseTextFormatter(),
            LengthLimitingTextInputFormatter(11),
          ],
        ),
        const SizedBox(height: 16),
        _label("Bank Name"),
        const SizedBox(height: 10),
        _textField(controller: _bankNameCtrl, hint: "State Bank of India",
            icon: Icons.account_balance),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xffEFF6FF),
            border: Border.all(color: const Color(0xffBFDBFE)),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.5),
              children: const [
                TextSpan(
                  text: "Note: ",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1D4ED8)),
                ),
                TextSpan(
                  text: "Your KYC will be verified by our admin team. You will receive a notification once approved.",
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  // ── Selfie ──
  Widget _buildSelfieSection() {
    Widget mainCard;
    if (_selfieImage != null) {
      mainCard = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(children: [
          Image.file(_selfieImage!, height: 320, width: double.infinity, fit: BoxFit.cover),
          Positioned(
            bottom: 14,
            right: 14,
            child: GestureDetector(
              onTap: _captureSelfie,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text("Retake",
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text("Selfie Ready",
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ]),
      );
    } else {
      mainCard = GestureDetector(
        onTap: _captureSelfie,
        child: Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff2563EB), Color(0xffA020F0)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text("Open Camera",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Tap for live selfie",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return Column(children: [
      mainCard,
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffEFF6FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffBFDBFE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tips for a good selfie",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xff1D4ED8))),
            const SizedBox(height: 10),
            _tip(Icons.wb_sunny_outlined, "Sit in good light"),
            _tip(Icons.face_outlined, "Keep your face centred in the frame"),
            _tip(Icons.block_outlined, "Do not wear glasses or a mask"),
          ],
        ),
      ),
    ]);
  }

  // ── App bar ──
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
        const Expanded(
          child: Text(
            "KYC Verification",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xffEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${currentStep + 1}/${_steps.length}",
            style: const TextStyle(
              color: Color(0xff2563EB),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ]),
    );
  }

  // ── Step indicator ──
  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: List.generate(_steps.length, (index) {
          bool isDone = index < currentStep;
          bool isActive = index == currentStep;
          return Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isDone || isActive
                        ? const LinearGradient(colors: [Color(0xff2563EB), Color(0xffA020F0)])
                        : null,
                    color: isDone || isActive ? null : Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _steps[index].title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive
                        ? const Color(0xff2563EB)
                        : isDone
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Bottom button ──
  Widget _buildBottomButton() {
    final isLast = currentStep == _steps.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: GestureDetector(
        onTap: () async {
          if (!_validateStep()) return;
          if (!isLast) {
            setState(() => currentStep++);
          } else {
            final Map<String, dynamic> kycData = {
              "aadhaar_number": _aadhaarCtrl.text.replaceAll(' ', ''),
              "aadhaar_front": _aadhaarFront,
              "aadhaar_back": _aadhaarBack,
              "pan_number": _panCtrl.text.trim(),
              "pan_image": _panCard,
              "gst_number_doc": _gstCtrl.text.trim(),
              "gst_cert": _gstCert,
              "school_reg_number": _schoolRegCtrl.text.trim(),
              "school_reg_cert": _schoolRegCert,
              "selfie": _selfieImage,
              "bank_account": _accountCtrl.text.trim(),
              "bank_ifsc": _ifscCtrl.text.trim(),
              "bank_name": _bankNameCtrl.text.trim(),
            };
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AgreementSigningScreen(
                  role: widget.role,
                  formData: widget.formData,
                  kycData: kycData,
                  initialAgreementData: _savedAgreementData,
                  isPostSignupKyc: widget.isPostSignupKyc,
                  userId: widget.userId,
                ),
              ),
            );

            if (result is Map<String, dynamic>) {
              setState(() {
                _savedAgreementData = result;
              });
            }
          }
        },
        child: Container(
          height: 62,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xff2563EB), Color(0xffA020F0)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              isLast ? "Submit KYC" : "Next Step",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──
  Widget _sectionHeader(IconData icon, String title) {
    return Row(children: [
      Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xff2563EB), Color(0xffA020F0)]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
      const SizedBox(width: 12),
      Text(title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87)),
    ]);
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15));
  }

  Widget _tip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 15, color: const Color(0xff2563EB)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: Color(0xff374151))),
      ]),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _uploadBox(String label, File? file, String type, {double height = 140}) {
    bool hasFile = file != null;
    return GestureDetector(
      onTap: () => _pickImage(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFile ? const Color(0xff2563EB) : Colors.grey.shade300,
            width: hasFile ? 1.5 : 1,
          ),
          color: hasFile ? const Color(0xffEFF6FF) : const Color(0xffFAFAFA),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasFile
            ? Stack(fit: StackFit.expand, children: [
          Image.file(file, fit: BoxFit.cover),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xff2563EB).withOpacity(0.85),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_outlined, color: Colors.white, size: 13),
                  const SizedBox(width: 4),
                  Text("Change $label",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ])
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file_outlined, size: 34, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text("Tap to upload",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class AadhaarFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 12 digits
    final String cleanText = text.substring(0, text.length > 12 ? 12 : text.length);
    
    final buffer = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      buffer.write(cleanText[i]);
      // Add space after 4th and 8th characters, but not at the end
      if ((i == 3 || i == 7) && i != cleanText.length - 1) {
        buffer.write(' ');
      }
    }
    
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}