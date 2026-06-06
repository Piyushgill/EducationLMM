import 'package:flutter/material.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() =>
      _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  int currentStep = 0;

  final List<String> steps = [
    "Documents",
    "Selfie",
    "Bank",
  ];

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

  // ================= APP BAR =================

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const Expanded(
            child: Text(
              "KYC Verification",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  // ================= STEP INDICATOR =================

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(
          steps.length,
              (index) {
            bool isActive = index <= currentStep;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isActive
                      ? const Color(0xff2563EB)
                      : Colors.grey.shade300,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ================= STEP 1 =================

  Widget _buildDocumentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Identity Documents",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Upload your Aadhaar and PAN card",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),

        _label("Aadhaar Number"),
        const SizedBox(height: 10),
        _textField(
          hint: "1234 5678 9012",
          icon: Icons.credit_card_outlined,
        ),

        const SizedBox(height: 24),

        _label("Upload Aadhaar"),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _uploadBox("Front"),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _uploadBox("Back"),
            ),
          ],
        ),

        const SizedBox(height: 26),

        _label("PAN Number"),
        const SizedBox(height: 10),
        _textField(
          hint: "ABCDE1234F",
          icon: Icons.description_outlined,
        ),

        const SizedBox(height: 24),

        _label("Upload PAN Card"),
        const SizedBox(height: 14),

        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_outlined,
                size: 42,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 10),
              Text(
                "Tap to upload",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= STEP 2 =================

  Widget _buildSelfieStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Live Photo",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Take a live selfie for verification",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 28),

        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [
                Color(0xff2563EB),
                Color(0xffC026D3),
              ],
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 70,
              ),
              SizedBox(height: 18),
              Text(
                "Take Selfie",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= STEP 3 =================

  Widget _buildBankStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bank Details",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter your bank account details",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),

        _label("Account Number"),
        const SizedBox(height: 10),
        _textField(
          hint: "1234567890",
          icon: Icons.account_balance_outlined,
        ),

        const SizedBox(height: 24),

        _label("IFSC Code"),
        const SizedBox(height: 10),
        _textField(
          hint: "SBIN0001234",
          icon: Icons.code_rounded,
        ),

        const SizedBox(height: 24),

        _label("Bank Name"),
        const SizedBox(height: 10),
        _textField(
          hint: "State Bank of India",
          icon: Icons.account_balance,
        ),

        const SizedBox(height: 30),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xffEFF6FF),
            border: Border.all(
              color: const Color(0xffBFDBFE),
            ),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 15,
                height: 1.5,
              ),
              children: const [
                TextSpan(
                  text: "Note: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1D4ED8),
                  ),
                ),
                TextSpan(
                  text:
                  "Your KYC will be verified by our admin team. You'll receive a notification once approved.",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= COMMON WIDGETS =================

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  Widget _textField({
    required String hint,
    required IconData icon,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: Colors.grey.shade500,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _uploadBox(String text) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_outlined,
            size: 40,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM BUTTON =================

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: GestureDetector(
        onTap: () {
          if (currentStep < 2) {
            setState(() {
              currentStep++;
            });
          }
        },
        child: Container(
          height: 64,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [
                Color(0xff2563EB),
                Color(0xffC026D3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              currentStep == 2 ? "Submit KYC" : "Next Step",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}