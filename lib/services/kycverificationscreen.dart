import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thenew/services/Agreement_signin.dart';

class KycVerificationScreen extends StatefulWidget {
  final String role;

  const KycVerificationScreen({super.key, required this.role});

  @override
  State<KycVerificationScreen> createState() =>
      _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  int currentStep = 0;
  final List<String> steps = ["Documents", "Selfie", "Bank"];

  // Document step
  final TextEditingController _aadhaarCtrl = TextEditingController();
  final TextEditingController _panCtrl = TextEditingController();
  File? _aadhaarFront;
  File? _aadhaarBack;
  File? _panCard;

  // Selfie step
  File? _selfieImage;
  bool _isCameraOpen = false;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _cameraReady = false;

  // Bank step
  final TextEditingController _accountCtrl = TextEditingController();
  final TextEditingController _ifscCtrl = TextEditingController();
  final TextEditingController _bankNameCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _cameraController?.dispose();
    _aadhaarCtrl.dispose();
    _panCtrl.dispose();
    _accountCtrl.dispose();
    _ifscCtrl.dispose();
    _bankNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final XFile? picked =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      if (type == 'aadhaar_front') _aadhaarFront = File(picked.path);
      if (type == 'aadhaar_back') _aadhaarBack = File(picked.path);
      if (type == 'pan') _panCard = File(picked.path);
    });
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    // Prefer front camera for selfie
    CameraDescription? frontCam;
    for (var cam in _cameras!) {
      if (cam.lensDirection == CameraLensDirection.front) {
        frontCam = cam;
        break;
      }
    }

    _cameraController = CameraController(
      frontCam ?? _cameras!.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  Future<void> _openCamera() async {
    setState(() {
      _isCameraOpen = true;
      _cameraReady = false;
    });
    await _initCamera();
  }

  Future<void> _takeSelfie() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final XFile photo = await _cameraController!.takePicture();
      await _cameraController!.dispose();
      _cameraController = null;
      setState(() {
        _selfieImage = File(photo.path);
        _isCameraOpen = false;
        _cameraReady = false;
      });
    } catch (e) {
      debugPrint("Capture error: $e");
    }
  }

  void _closeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    setState(() {
      _isCameraOpen = false;
      _cameraReady = false;
    });
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0:
        if (_aadhaarCtrl.text.trim().isEmpty) {
          _showError("Important to Feed Aadhaar number");
          return false;
        }
        if (_aadhaarFront == null || _aadhaarBack == null) {
          _showError("Keep upload aadhaar front and back");
          return false;
        }
        if (_panCtrl.text.trim().isEmpty) {
          _showError("Important to Feed PAN number ");
          return false;
        }
        if (_panCard == null) {
          _showError("Upload PAN card");
          return false;
        }
        return true;
      case 1:
        if (_selfieImage == null) {
          _showError("Take selfie");
          return false;
        }
        return true;
      case 2:
        if (_accountCtrl.text.trim().isEmpty ||
            _ifscCtrl.text.trim().isEmpty ||
            _bankNameCtrl.text.trim().isEmpty) {
          _showError("Feed all bank details");
          return false;
        }
        return true;
      default:
        return true;
    }
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
                    if (currentStep == 0) _buildDocumentsStep(),
                    if (currentStep == 1) _buildSelfieStep(),
                    if (currentStep == 2) _buildBankStep(),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
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
          // Step badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${currentStep + 1}/3",
              style: const TextStyle(
                color: Color(0xff2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: List.generate(steps.length, (index) {
          bool isDone = index < currentStep;
          bool isActive = index == currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isDone || isActive
                    ? const LinearGradient(
                  colors: [Color(0xff2563EB), Color(0xffA020F0)],
                )
                    : null,
                color: isDone || isActive ? null : Colors.grey.shade200,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── STEP 1: Documents ──
  Widget _buildDocumentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Identity Documents",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("upload Aadhaar and PAN card",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
        const SizedBox(height: 28),

        _label("Aadhaar Number"),
        const SizedBox(height: 10),
        _textField(
          controller: _aadhaarCtrl,
          hint: "1234 5678 9012",
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 22),

        _label("Upload Aadhaar Card"),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _uploadBox("Front", _aadhaarFront, 'aadhaar_front')),
            const SizedBox(width: 14),
            Expanded(child: _uploadBox("Back", _aadhaarBack, 'aadhaar_back')),
          ],
        ),
        const SizedBox(height: 24),

        _label("PAN Number"),
        const SizedBox(height: 10),
        _textField(
          controller: _panCtrl,
          hint: "ABCDE1234F",
          icon: Icons.description_outlined,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 22),

        _label("Upload PAN Card "),
        const SizedBox(height: 12),
        _uploadBox("PAN Card", _panCard, 'pan', height: 160),
      ],
    );
  }

  // ── STEP 2: Selfie ──
  Widget _buildSelfieStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Live Photo",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Take a live selfie for verification",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
        const SizedBox(height: 28),

        // Camera / selfie preview
        if (_isCameraOpen) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 380,
              width: double.infinity,
              child: _cameraReady && _cameraController != null
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_cameraController!),
                  // Oval face guide overlay
                  Center(
                    child: Container(
                      width: 200,
                      height: 260,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 2.5),
                      ),
                    ),
                  ),
                  // Close button top right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: _closeCamera,
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              )
                  : Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_cameraReady)
            GestureDetector(
              onTap: _takeSelfie,
              child: Center(
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xff2563EB), width: 3),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xff2563EB), Color(0xffA020F0)],
                      ),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
        ] else if (_selfieImage != null) ...[
          // Show captured selfie
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Image.file(
                  _selfieImage!,
                  height: 320,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Retake button overlay
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: _openCamera,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text("Retake",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Success badge
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 14),
                        SizedBox(width: 5),
                        Text("Selfie Ready",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Tap to open camera
          GestureDetector(
            onTap: _openCamera,
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
                    child: const Icon(Icons.camera_alt_outlined,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 20),
                  const Text("Open Camera",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Tap For live Selfie",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tips card
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
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xff1D4ED8))),
                const SizedBox(height: 10),
                _tip(Icons.wb_sunny_outlined, "Sit in good light"),
                _tip(Icons.face_outlined, "Keep your face in the center of the frame"),
                _tip(Icons.block_outlined, "Do not wear glasses or a mask"),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _tip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xff2563EB)),
          const SizedBox(width: 8),
          Text(text,
              style:
              const TextStyle(fontSize: 13, color: Color(0xff374151))),
        ],
      ),
    );
  }

  // ── STEP 3: Bank ──
  Widget _buildBankStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bank Details",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Please enter your bank account details",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
        const SizedBox(height: 28),

        _label("Account Number"),
        const SizedBox(height: 10),
        _textField(
          controller: _accountCtrl,
          hint: "1234567890",
          icon: Icons.account_balance_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 22),

        _label("IFSC Code"),
        const SizedBox(height: 10),
        _textField(
          controller: _ifscCtrl,
          hint: "SBIN0001234",
          icon: Icons.code_rounded,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 22),

        _label("Bank Name"),
        const SizedBox(height: 10),
        _textField(
          controller: _bankNameCtrl,
          hint: "State Bank of India",
          icon: Icons.account_balance,
        ),
        const SizedBox(height: 28),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xffEFF6FF),
            border: Border.all(color: const Color(0xffBFDBFE)),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                  color: Colors.grey.shade800, fontSize: 14, height: 1.5),
              children: const [
                TextSpan(
                  text: "Note: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1D4ED8)),
                ),
                TextSpan(
                  text:
                  "Your KYC will be verified by the admin team. You will receive a notification once it is approved.",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── COMMON WIDGETS ──
  Widget _label(String text) {
    return Text(text,
        style:
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 15));
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
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
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
          hintText: hint,
          hintStyle:
          TextStyle(color: Colors.grey.shade400, fontSize: 15),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _uploadBox(String label, File? file, String type,
      {double height = 140}) {
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
            color: hasFile
                ? const Color(0xff2563EB)
                : Colors.grey.shade300,
            width: hasFile ? 1.5 : 1,
          ),
          color: hasFile
              ? const Color(0xffEFF6FF)
              : const Color(0xffFAFAFA),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasFile
            ? Stack(
          fit: StackFit.expand,
          children: [
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
                    const Icon(Icons.edit_outlined,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text("Change $label",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file_outlined,
                size: 34, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text("Tap to upload",
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: GestureDetector(
        onTap: () {
          if (!_validateCurrentStep()) return;
          if (currentStep < 2) {
            setState(() => currentStep++);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AgreementSigningScreen(role: widget.role),
              ),
            );
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
              currentStep == 2 ? "Submit KYC" : "Next Step",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
          ),
        ),
      ),
    );
  }
}