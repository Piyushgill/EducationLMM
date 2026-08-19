import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thenew/services/kycverificationscreen.dart';
import 'package:thenew/services/login_screen.dart';


// ══════════════════════════════════════════════════════════════════════════════
// TITLE WIDGET
// ══════════════════════════════════════════════════════════════════════════════

class Titleh1 extends StatelessWidget {
  final String title;
  final bool astrick;

  const Titleh1({
    super.key,
    required this.title,
    this.astrick = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        if (astrick)
          const Text(
            " *",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
      ],
    );
  }
}


// ══════════════════════════════════════════════════════════════════════════════
// ROLE CONFIG
// ══════════════════════════════════════════════════════════════════════════════

class RoleConfig {
  final String label;
  final IconData icon;
  final String subtitle;
  final List<FieldConfig> extraFields;

  const RoleConfig({
    required this.label,
    required this.icon,
    required this.subtitle,
    required this.extraFields,
  });
}


// ══════════════════════════════════════════════════════════════════════════════
// FIELD CONFIG
// ══════════════════════════════════════════════════════════════════════════════

class FieldConfig {
  final String key;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool required;

  const FieldConfig({
    required this.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
    this.required = true,
  });
}


// ══════════════════════════════════════════════════════════════════════════════
// ALL ROLE CONFIGURATIONS
// ══════════════════════════════════════════════════════════════════════════════

const Map<String, RoleConfig> kRoleConfigs = {
  // ──────────────────────────────────────────────────────────────────────────
  // STUDENT
  // ──────────────────────────────────────────────────────────────────────────

  "Student": RoleConfig(
    label: "Student",
    icon: Icons.person,
    subtitle: "Join as a Student learner",
    extraFields: [
      FieldConfig(
        key: "school_name",
        label: "School Name",
        hint: "Enter your school name",
        icon: Icons.account_balance_outlined,
        required: false,
      ),

      FieldConfig(
        key: "class_grade",
        label: "Class / Grade",
        hint: "e.g. Class 10, Grade 12",
        icon: Icons.format_list_numbered_rounded,
        textCapitalization: TextCapitalization.sentences,
        required: false,
      ),

      FieldConfig(
        key: "dob",
        label: "Date of Birth",
        hint: "DD/MM/YYYY",
        icon: Icons.cake_outlined,
        keyboardType: TextInputType.datetime,
        textCapitalization: TextCapitalization.none,
        required: true,
      ),
    ],
  ),

  // ──────────────────────────────────────────────────────────────────────────
  // SCHOOL
  // ──────────────────────────────────────────────────────────────────────────

  "School": RoleConfig(
    label: "School",
    icon: Icons.domain_outlined,
    subtitle: "Register your institution",
    extraFields: [
      FieldConfig(
        key: "principal_name",
        label: "Principal Name",
        hint: "Enter principal's full name",
        icon: Icons.person_pin_outlined,
        required: false,
      ),

      FieldConfig(
        key: "board_type",
        label: "Board / Affiliation",
        hint: "e.g. CBSE, ICSE, State Board",
        icon: Icons.menu_book_outlined,
        textCapitalization: TextCapitalization.characters,
        required: false,
      ),

      FieldConfig(
        key: "reg_number",
        label: "School Registration No.",
        hint: "Enter registration number",
        icon: Icons.confirmation_number_outlined,
        textCapitalization: TextCapitalization.characters,
        required: false,
      ),

      FieldConfig(
        key: "city",
        label: "City",
        hint: "Enter city name",
        icon: Icons.location_city_outlined,
        required: true,
      ),
    ],
  ),

  // ──────────────────────────────────────────────────────────────────────────
  // FRANCHISE PARTNER
  // ──────────────────────────────────────────────────────────────────────────

  "Franchise Partner": RoleConfig(
    label: "Franchise Partner",
    icon: Icons.school_rounded,
    subtitle: "Become a franchise partner",
    extraFields: [
      FieldConfig(
        key: "business_name",
        label: "Business Name",
        hint: "Enter your business name",
        icon: Icons.business_outlined,
        required: false,
      ),

      FieldConfig(
        key: "gst_number",
        label: "GST Number",
        hint: "e.g. 22AAAAA0000A1Z5",
        icon: Icons.receipt_long_outlined,
        textCapitalization: TextCapitalization.characters,
        required: false,
      ),

      FieldConfig(
        key: "city",
        label: "City / Area",
        hint: "Enter your city",
        icon: Icons.map_outlined,
        required: true,
      ),

      FieldConfig(
        key: "experience",
        label: "Business Experience",
        hint: "Years of experience",
        icon: Icons.work_outline_rounded,
        keyboardType: TextInputType.number,
        textCapitalization: TextCapitalization.none,
        required: false,
      ),
    ],
  ),

  // ──────────────────────────────────────────────────────────────────────────
  // DISTRIBUTOR
  // ──────────────────────────────────────────────────────────────────────────

  "Distributor": RoleConfig(
    label: "Distributor",
    icon: Icons.trending_up_outlined,
    subtitle: "Join as a Distributor",
    extraFields: [
      // OPTIONAL
      FieldConfig(
        key: "business_name",
        label: "Business / Firm Name",
        hint: "Enter your firm name",
        icon: Icons.store_outlined,
        required: false,
      ),

      // MANDATORY
      FieldConfig(
        key: "area",
        label: "Distribution Area",
        hint: "e.g. North Delhi, Pune",
        icon: Icons.pin_drop_outlined,
        required: true,
      ),

      // OPTIONAL
      FieldConfig(
        key: "experience",
        label: "Experience in Education Field",
        hint: "Years of experience",
        icon: Icons.work_history_outlined,
        keyboardType: TextInputType.number,
        textCapitalization: TextCapitalization.none,
        required: false,
      ),
    ],
  ),
};


// ══════════════════════════════════════════════════════════════════════════════
// JOIN US SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class JoinUsScreen extends StatefulWidget {
  final String? initialRole;

  const JoinUsScreen({
    super.key,
    this.initialRole,
  });

  @override
  State<JoinUsScreen> createState() => _JoinUsScreenState();
}


// ══════════════════════════════════════════════════════════════════════════════
// STATE
// ══════════════════════════════════════════════════════════════════════════════

class _JoinUsScreenState extends State<JoinUsScreen> {
  bool isChecked = false;

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  String selectedRole = "Distributor";

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  final Map<String, TextEditingController> _extraControllers = {};

  // Stores KYC data when user comes back from KYC.
  Map<String, dynamic>? _savedKycData;

  RoleConfig get _currentConfig =>
      kRoleConfigs[selectedRole]!;


  // ════════════════════════════════════════════════════════════════════════════
  // INIT
  // ════════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();

    if (widget.initialRole != null &&
        kRoleConfigs.containsKey(widget.initialRole)) {
      selectedRole = widget.initialRole!;
    }

    _rebuildExtraControllers();
  }


  // ════════════════════════════════════════════════════════════════════════════
  // REBUILD ROLE FIELDS
  // ════════════════════════════════════════════════════════════════════════════

  void _rebuildExtraControllers() {
    for (final controller in _extraControllers.values) {
      controller.dispose();
    }

    _extraControllers.clear();

    for (final field in _currentConfig.extraFields) {
      _extraControllers[field.key] =
          TextEditingController();
    }
  }


  // ════════════════════════════════════════════════════════════════════════════
  // ROLE CHANGE
  // ════════════════════════════════════════════════════════════════════════════

  void _onRoleChanged(String role) {
    setState(() {
      selectedRole = role;

      _rebuildExtraControllers();

      // Different role = different KYC requirements.
      _savedKycData = null;
    });
  }


  // ════════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ════════════════════════════════════════════════════════════════════════════

  String? _validate() {
    if (_nameController.text.trim().isEmpty) {
      return "Please enter your full name";
    }

    if (_emailController.text.trim().isEmpty) {
      return "Please enter your email";
    }

    if (!_emailController.text.contains('@')) {
      return "Please enter a valid email";
    }

    final phone = _phoneController.text.trim();

    if (phone.length != 10) {
      return "Phone number must be exactly 10 digits";
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      return "Please enter a valid 10-digit phone number";
    }

    if (_passwordController.text.length < 6) {
      return "Password must be at least 6 characters";
    }

    if (_passwordController.text !=
        _confirmPasswordController.text) {
      return "Passwords do not match";
    }

    // ONLY required fields are validated.
    for (final field in _currentConfig.extraFields) {
      if (field.required &&
          _extraControllers[field.key]!
              .text
              .trim()
              .isEmpty) {
        return "Please enter ${field.label}";
      }
    }

    if (!isChecked) {
      return "Please accept Terms & Conditions";
    }

    return null;
  }


  // ════════════════════════════════════════════════════════════════════════════
  // CONTINUE TO KYC
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _onContinue() async {
    final error = _validate();

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      return;
    }

    // Collect common data.
    final Map<String, String> formData = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "password": _passwordController.text,
      "role": selectedRole,
    };

    // Collect role-specific data.
    for (final field in _currentConfig.extraFields) {
      formData[field.key] =
          _extraControllers[field.key]!.text.trim();
    }

    // Open KYC and preserve previous KYC data.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KycVerificationScreen(
          role: selectedRole,
          formData: formData,

          inialKycData: _savedKycData,
        ),
      ),
    );

    // KYC returns its current data.
    if (result is Map<String, dynamic>) {
      setState(() {
        _savedKycData = result;
      });
    }
  }


  // ════════════════════════════════════════════════════════════════════════════
  // ROLE-WISE TERMS
  // ════════════════════════════════════════════════════════════════════════════

  String _getTermsForRole() {
    switch (selectedRole) {
      case "Student":
        return """
STUDENT TERMS & CONDITIONS

1. Accurate Information

You must provide accurate personal and educational information during registration.

2. KYC Verification

Any documents submitted for KYC verification must be genuine and belong to you.

3. Account Security

You are responsible for keeping your account credentials secure and must not share your password with others.

4. Verification

Your registration is subject to verification and approval.

5. False Information

Providing false information or fraudulent documents may result in rejection or suspension of your account.

6. Platform Usage

You agree to use the platform responsibly and comply with applicable platform rules and policies.

7. Acceptance

By submitting the registration form, you confirm that the information provided by you is correct and agree to these Terms & Conditions.
""";

      case "School":
        return """
SCHOOL TERMS & CONDITIONS

1. Authorised Registration

The person registering the school must be authorised to represent the institution.

2. School Information

School name, principal information, board, registration number, city and other information must be accurate.

3. Documents

All submitted school and KYC documents must be genuine, valid and readable.

4. KYC Verification

School registration is subject to successful verification and approval.

5. Student Information

The school must handle student information responsibly and must not misuse or disclose it without proper authorisation.

6. Account Security

The school is responsible for protecting its account credentials.

7. False Information

False information or fraudulent documents may result in rejection or suspension.

8. Acceptance

By submitting the registration form, you confirm that you are authorised to register the institution and agree to these Terms & Conditions.
""";

      case "Franchise Partner":
        return """
FRANCHISE PARTNER TERMS & CONDITIONS

1. Business Information

All business and personal information provided during registration must be accurate.

2. Business Documents

Submitted identity, GST, business and banking documents must be genuine and valid.

3. Verification

Registration does not guarantee franchise approval. Approval is subject to verification.

4. Business Conduct

The applicant must comply with applicable laws and platform policies.

5. Fraudulent Information

Fraudulent information or documents may result in rejection, suspension or termination.

6. Account Security

The applicant is responsible for maintaining account security and protecting login credentials.

7. Partnership

Submitting the registration form does not by itself create a franchise partnership. Partnership is subject to separate approval and applicable agreements.

8. Acceptance

By submitting the registration form, you confirm that all information and documents provided are genuine and agree to these Terms & Conditions.
""";

      case "Distributor":
        return """
DISTRIBUTOR TERMS & CONDITIONS

1. Accurate Information

All personal and business information provided during registration must be accurate.

2. Optional Business Information

Business / Firm Name is optional. If provided, the information must be accurate and genuine.

3. Distribution Area

Distribution Area is required and must accurately represent the area in which you intend to conduct authorised distribution activities.

4. Optional Experience

Experience in Education Field is optional. If provided, the information must be accurate.

5. KYC Verification

All submitted KYC documents must be genuine, valid and belong to the applicant or registered business where applicable.

6. Verification

Distributor registration is subject to verification and approval.

7. Fraudulent Information

Fraudulent information or documents may result in rejection or suspension.

8. Business Conduct

The Distributor must follow applicable laws, platform policies and authorised business procedures.

9. Acceptance

By submitting the registration form, you confirm that the information and documents provided are genuine and accurate and agree to these Terms & Conditions.
""";

      default:
        return """
GENERAL TERMS & CONDITIONS

1. All information provided during registration must be accurate and genuine.

2. Registration is subject to verification and approval.

3. Submitted documents must be genuine and valid.

4. Fraudulent information or documents may result in rejection or suspension.

5. You are responsible for maintaining account security.

6. By registering, you agree to the applicable Terms & Conditions.
""";
    }
  }


  // ════════════════════════════════════════════════════════════════════════════
  // TERMS POPUP
  // ════════════════════════════════════════════════════════════════════════════

  void _showTermsAndConditions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height:
          MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  18,
                  12,
                  14,
                ),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xffEFF6FF),
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xff2563EB),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Terms & Conditions",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            "$selectedRole Registration",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                              Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      icon:
                      const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Text(
                    _getTermsForRole(),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.65,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              SafeArea(
                top: false,
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    15,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xff2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "I Understand",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // ════════════════════════════════════════════════════════════════════════════
  // PRIVACY POLICY
  // ════════════════════════════════════════════════════════════════════════════

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height:
          MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  18,
                  12,
                  14,
                ),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xffEFF6FF),
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.privacy_tip_outlined,
                        color: Color(0xff2563EB),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      icon:
                      const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: const Text(
                    """
PRIVACY POLICY

1. Information We Collect

We may collect information provided during registration, including your name, email address, phone number and role-specific information.

2. KYC Information

Depending on your selected role, we may collect KYC documents such as Aadhaar, PAN, GST documents, registration certificates, selfie, signature and bank details.

3. Use of Information

The information may be used for account creation, identity verification, KYC processing, account management and providing platform services.

4. Data Security

Reasonable measures are taken to protect the information submitted through the platform.

5. Information Sharing

Your information may be accessed by authorised personnel for verification and legitimate platform operations.

6. User Responsibility

You are responsible for ensuring that the information and documents submitted by you are accurate and genuine.

7. KYC Processing

KYC information may be reviewed for identity and eligibility verification before account approval.

8. Account Management

Information may be used to manage your account, provide services and communicate important account-related updates.

9. Contact

If you have questions regarding this Privacy Policy, please contact the platform support team.
""",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.65,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              SafeArea(
                top: false,
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    15,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xff2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "I Understand",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // ════════════════════════════════════════════════════════════════════════════
  // ROLE REQUIREMENT CHIP
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildRoleInfoChip({
    Key? key,
  }) {
    final Map<String, String>
    roleRequirements = {
      "Student":
      "Aadhaar + Selfie required",

      "School":
      "Aadhaar + PAN + Selfie + Registration Certificate + Bank required",

      "Franchise Partner":
      "Aadhaar + PAN + GST Certificate + Selfie + Bank required",

      "Distributor":
      "Aadhaar + PAN + Selfie + Bank Details required",
    };

    return Container(
      key: key,
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffEFF6FF),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffBFDBFE),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xff2563EB),
            size: 18,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              "KYC: ${roleRequirements[selectedRole] ?? ''}",
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xff1D4ED8),
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ════════════════════════════════════════════════════════════════════════════
  // ROLE SELECTOR
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildRoleDrawerTrigger() {
    final config = _currentConfig;

    return GestureDetector(
      onTap: _openRoleDrawer,
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 250),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xfff1f2f6),
          borderRadius:
          BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xffBFDBFE),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                gradient:
                const LinearGradient(
                  colors: [
                    Color(0xff2563EB),
                    Color(0xffA020F0),
                  ],
                ),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Icon(
                config.icon,
                color: Colors.white,
                size: 20,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    config.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    config.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                      Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color:
                const Color(0xffEFF6FF),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    "Change",
                    style: TextStyle(
                      fontSize: 12,
                      color:
                      Color(0xff2563EB),
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  SizedBox(width: 4),

                  Icon(
                    Icons
                        .keyboard_arrow_down_rounded,
                    size: 16,
                    color:
                    Color(0xff2563EB),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ════════════════════════════════════════════════════════════════════════════
  // ROLE BOTTOM SHEET
  // ════════════════════════════════════════════════════════════════════════════

  void _openRoleDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _RolePickerSheet(
          selectedRole: selectedRole,
          onRoleSelected: (role) {
            Navigator.pop(context);
            _onRoleChanged(role);
          },
        );
      },
    );
  }


  // ════════════════════════════════════════════════════════════════════════════
  // TEXT FIELD
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
    TextCapitalization
    textCapitalization =
        TextCapitalization.words,
  }) {
    final bool isPhone =
        keyboardType == TextInputType.phone;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff1f2f6),
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization:
        textCapitalization,
        maxLength:
        isPhone ? 10 : null,
        buildCounter: isPhone
            ? (
            context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) {
          return null;
        }
            : null,
        inputFormatters: isPhone
            ? [
          FilteringTextInputFormatter
              .digitsOnly,
        ]
            : null,
        decoration:
        InputDecoration(
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(
            vertical: 20,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
          ),
          hintText: hint,
          hintStyle:
          const TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }


  // ════════════════════════════════════════════════════════════════════════════
  // DISPOSE
  // ════════════════════════════════════════════════════════════════════════════

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    for (final controller
    in _extraControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }


  // ════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              // ──────────────────────────────────────────────────────────────
              // BACK
              // ──────────────────────────────────────────────────────────────

              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius:
                BorderRadius.circular(10),
                child: const Padding(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .arrow_back_ios_new_rounded,
                        size: 20,
                        color: Colors.black54,
                      ),

                      SizedBox(width: 6),

                      Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 18,
                          color:
                          Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ──────────────────────────────────────────────────────────────
              // LOGO
              // ──────────────────────────────────────────────────────────────

              Image.asset(
                'assets/image/k-logo.png',
                height: 64,
                width: 64,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 20),

              // ──────────────────────────────────────────────────────────────
              // TITLE
              // ──────────────────────────────────────────────────────────────

              const Text(
                "Join Us",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight:
                  FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              AnimatedSwitcher(
                duration:
                const Duration(
                  milliseconds: 250,
                ),
                child: Text(
                  _currentConfig.subtitle,
                  key: ValueKey(
                    selectedRole,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ──────────────────────────────────────────────────────────────
              // ROLE
              // ──────────────────────────────────────────────────────────────

              const Titleh1(
                title: "I want to join as",
                astrick: true,
              ),

              const SizedBox(height: 12),

              _buildRoleDrawerTrigger(),

              const SizedBox(height: 20),

              // ──────────────────────────────────────────────────────────────
              // ROLE INFO
              // ──────────────────────────────────────────────────────────────

              AnimatedSwitcher(
                duration:
                const Duration(
                  milliseconds: 300,
                ),
                child:
                _buildRoleInfoChip(
                  key: ValueKey(
                    selectedRole,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ──────────────────────────────────────────────────────────────
              // FULL NAME
              // ──────────────────────────────────────────────────────────────

              const Titleh1(
                title: "Full Name",
                astrick: true,
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller:
                _nameController,
                hint: selectedRole ==
                    "School"
                    ? "Enter School Name"
                    : "Enter Your Full Name",
                icon: selectedRole ==
                    "School"
                    ? Icons
                    .domain_outlined
                    : Icons
                    .person_outline_rounded,
              ),

              const SizedBox(height: 16),

              // ──────────────────────────────────────────────────────────────
              // EMAIL
              // ──────────────────────────────────────────────────────────────

              const Titleh1(
                title: "Email",
                astrick: true,
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller:
                _emailController,
                hint:
                "Enter Email Address",
                icon:
                Icons.mail_outline_rounded,
                keyboardType:
                TextInputType
                    .emailAddress,
                textCapitalization:
                TextCapitalization.none,
              ),

              const SizedBox(height: 16),

              // ──────────────────────────────────────────────────────────────
              // PHONE
              // ──────────────────────────────────────────────────────────────

              const Titleh1(
                title: "Phone",
                astrick: true,
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller:
                _phoneController,
                hint:
                "Enter Phone Number",
                icon:
                Icons.call_outlined,
                keyboardType:
                TextInputType.phone,
                textCapitalization:
                TextCapitalization.none,
              ),

              const SizedBox(height: 16),

              // ──────────────────────────────────────────────────────────────
              // DYNAMIC ROLE FIELDS
              // ──────────────────────────────────────────────────────────────

              ...List.generate(
                _currentConfig
                    .extraFields.length,
                    (index) {
                  final field =
                  _currentConfig
                      .extraFields[index];

                  Widget inputWidget;

                  // ─────────────────────────────────────────────────────────
                  // DOB
                  // ─────────────────────────────────────────────────────────

                  if (field.key == "dob") {
                    inputWidget =
                        InkWell(
                          onTap: () async {
                            FocusScope.of(
                              context,
                            ).unfocus();

                            final DateTime?
                            pickedDate =
                            await showDatePicker(
                              context:
                              context,
                              initialDate:
                              DateTime.now()
                                  .subtract(
                                const Duration(
                                  days:
                                  365 *
                                      10,
                                ),
                              ),
                              firstDate:
                              DateTime(1900),
                              lastDate:
                              DateTime.now(),
                              builder:
                                  (context,
                                  child) {
                                return Theme(
                                  data: Theme.of(
                                    context,
                                  ).copyWith(
                                    colorScheme:
                                    const ColorScheme
                                        .light(
                                      primary:
                                      Color(
                                        0xff2563EB,
                                      ),
                                      onPrimary:
                                      Colors
                                          .white,
                                      onSurface:
                                      Colors
                                          .black87,
                                    ),
                                  ),
                                  child:
                                  child!,
                                );
                              },
                            );

                            if (pickedDate !=
                                null) {
                              final String
                              formatted =
                                  "${pickedDate.year.toString().padLeft(4, '0')}-"
                                  "${pickedDate.month.toString().padLeft(2, '0')}-"
                                  "${pickedDate.day.toString().padLeft(2, '0')}";

                              setState(() {
                                _extraControllers[
                                field
                                    .key]!
                                    .text =
                                    formatted;
                              });
                            }
                          },
                          borderRadius:
                          BorderRadius
                              .circular(
                            18,
                          ),
                          child:
                          AbsorbPointer(
                            child:
                            _buildTextField(
                              controller:
                              _extraControllers[
                              field.key]!,
                              hint:
                              "Select Date of Birth",
                              icon:
                              field.icon,
                              keyboardType:
                              TextInputType
                                  .none,
                            ),
                          ),
                        );
                  }

                  // ─────────────────────────────────────────────────────────
                  // CLASS / GRADE
                  // ─────────────────────────────────────────────────────────

                  else if (field.key ==
                      "class_grade") {
                    final String?
                    currentValue =
                    _extraControllers[
                    field.key]!
                        .text
                        .isEmpty
                        ? null
                        : _extraControllers[
                    field.key]!
                        .text;

                    inputWidget =
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 16,
                          ),
                          decoration:
                          BoxDecoration(
                            color: const Color(
                              0xfff1f2f6,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),
                          ),
                          child:
                          DropdownButtonFormField<
                              String>(
                            value:
                            currentValue,
                            hint: Row(
                              children: [
                                Icon(
                                  field.icon,
                                  color:
                                  Colors
                                      .grey,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  field.hint,
                                  style:
                                  const TextStyle(
                                    color:
                                    Colors
                                        .grey,
                                    fontSize:
                                    16,
                                  ),
                                ),
                              ],
                            ),
                            decoration:
                            const InputDecoration(
                              border:
                              InputBorder
                                  .none,
                              contentPadding:
                              EdgeInsets
                                  .zero,
                            ),
                            icon:
                            const Icon(
                              Icons
                                  .arrow_drop_down,
                              color:
                              Colors.grey,
                            ),
                            items: [
                              "Nursery",
                              "LKG",
                              "UKG",
                              "1st",
                              "2nd",
                              "3rd",
                              "4th",
                              "5th",
                              "6th",
                              "7th",
                              "8th",
                              "9th",
                              "10th",
                              "11th",
                              "12th",
                            ].map(
                                  (String grade) {
                                return DropdownMenuItem<
                                    String>(
                                  value: grade,
                                  child: Text(
                                    grade,
                                    style:
                                    const TextStyle(
                                      fontSize:
                                      16,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged:
                                (value) {
                              if (value !=
                                  null) {
                                setState(() {
                                  _extraControllers[
                                  field
                                      .key]!
                                      .text =
                                      value;
                                });
                              }
                            },
                          ),
                        );
                  }

                  // ─────────────────────────────────────────────────────────
                  // NORMAL FIELD
                  // ─────────────────────────────────────────────────────────

                  else {
                    inputWidget =
                        _buildTextField(
                          controller:
                          _extraControllers[
                          field.key]!,
                          hint:
                          field.hint,
                          icon:
                          field.icon,
                          keyboardType:
                          field
                              .keyboardType,
                          textCapitalization:
                          field
                              .textCapitalization,
                        );
                  }

                  return AnimatedSwitcher(
                    duration:
                    const Duration(
                      milliseconds: 300,
                    ),
                    child: Column(
                      key: ValueKey(
                        "${selectedRole}_${field.key}",
                      ),
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Titleh1(
                          title:
                          field.label,
                          astrick:
                          field.required,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        inputWidget,

                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ──────────────────────────────────────────────────────────────
              // PASSWORD
              // ──────────────────────────────────────────────────────────────

              const Titleh1(
                title: "Password",
                astrick: true,
              ),

              const SizedBox(height: 12),

              Container(
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xfff1f2f6,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),
                child: TextField(
                  controller:
                  _passwordController,
                  obscureText:
                  isPasswordHidden,
                  decoration:
                  InputDecoration(
                    border:
                    InputBorder.none,
                    contentPadding:
                    const EdgeInsets
                        .symmetric(
                      vertical: 20,
                    ),
                    prefixIcon:
                    const Icon(
                      Icons
                          .lock_outline_rounded,
                      color:
                      Colors.grey,
                    ),
                    suffixIcon:
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordHidden =
                          !isPasswordHidden;
                        });
                      },
                      icon: Icon(
                        isPasswordHidden
                            ? Icons
                            .visibility_off_outlined
                            : Icons
                            .visibility_outlined,
                        color:
                        Colors.grey,
                      ),
                    ),
                    hintText:
                    "Enter Your Password",
                    hintStyle:
                    const TextStyle(
                      fontSize: 18,
                      color:
                      Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ──────────────────────────────────────────────────────────────
              // CONFIRM PASSWORD
              // ──────────────────────────────────────────────────────────────

              const Titleh1(
                title:
                "Confirm Password",
                astrick: true,
              ),

              const SizedBox(height: 12),

              Container(
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xfff1f2f6,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),
                child: TextField(
                  controller:
                  _confirmPasswordController,
                  obscureText:
                  isConfirmPasswordHidden,
                  decoration:
                  InputDecoration(
                    border:
                    InputBorder.none,
                    contentPadding:
                    const EdgeInsets
                        .symmetric(
                      vertical: 20,
                    ),
                    prefixIcon:
                    const Icon(
                      Icons
                          .lock_outline_rounded,
                      color:
                      Colors.grey,
                    ),
                    suffixIcon:
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordHidden =
                          !isConfirmPasswordHidden;
                        });
                      },
                      icon: Icon(
                        isConfirmPasswordHidden
                            ? Icons
                            .visibility_off_outlined
                            : Icons
                            .visibility_outlined,
                        color:
                        Colors.grey,
                      ),
                    ),
                    hintText:
                    "Confirm Your Password",
                    hintStyle:
                    const TextStyle(
                      fontSize: 18,
                      color:
                      Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ──────────────────────────────────────────────────────────────
              // TERMS + PRIVACY
              // ──────────────────────────────────────────────────────────────

              Container(
                padding:
                const EdgeInsets.all(
                  14,
                ),
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xfff1f2f6,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor:
                      const Color(
                        0xff2563EB,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          5,
                        ),
                      ),
                      onChanged:
                          (value) {
                        setState(() {
                          isChecked =
                              value ??
                                  false;
                        });
                      },
                    ),

                    const SizedBox(
                      width: 4,
                    ),

                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets
                            .only(
                          top: 11,
                        ),
                        child:
                        Wrap(
                          children: [
                            const Text(
                              "I agree to the ",
                              style:
                              TextStyle(
                                fontSize:
                                16,
                                height:
                                1.4,
                                color:
                                Colors
                                    .black87,
                              ),
                            ),

                            GestureDetector(
                              onTap:
                              _showTermsAndConditions,
                              child:
                              const Text(
                                "Terms & Conditions",
                                style:
                                TextStyle(
                                  fontSize:
                                  16,
                                  height:
                                  1.4,
                                  color:
                                  Color(
                                    0xff2563EB,
                                  ),
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                  decoration:
                                  TextDecoration
                                      .underline,
                                ),
                              ),
                            ),

                            const Text(
                              " and ",
                              style:
                              TextStyle(
                                fontSize:
                                16,
                                height:
                                1.4,
                                color:
                                Colors
                                    .black87,
                              ),
                            ),

                            GestureDetector(
                              onTap:
                              _showPrivacyPolicy,
                              child:
                              const Text(
                                "Privacy Policy",
                                style:
                                TextStyle(
                                  fontSize:
                                  16,
                                  height:
                                  1.4,
                                  color:
                                  Color(
                                    0xff2563EB,
                                  ),
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                  decoration:
                                  TextDecoration
                                      .underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ──────────────────────────────────────────────────────────────
              // CONTINUE TO KYC
              // ──────────────────────────────────────────────────────────────

              GestureDetector(
                onTap: _onContinue,
                child: Container(
                  height: 62,
                  width: double.infinity,
                  decoration:
                  BoxDecoration(
                    borderRadius:
                    BorderRadius
                        .circular(
                      20,
                    ),
                    gradient:
                    const LinearGradient(
                      colors: [
                        Color(0xff2563EB),
                        Color(0xffA020F0),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withOpacity(
                          .14,
                        ),
                        blurRadius: 10,
                        offset:
                        const Offset(
                          0,
                          5,
                        ),
                      ),
                    ],
                  ),
                  child:
                  const Center(
                    child: Text(
                      "Continue to KYC",
                      style:
                      TextStyle(
                        color:
                        Colors.white,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 34),

              // ──────────────────────────────────────────────────────────────
              // LOGIN
              // ──────────────────────────────────────────────────────────────

              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style:
                    TextStyle(
                      fontSize: 17,
                      color:
                      Colors.black54,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const LoginScreen(),
                        ),
                      );
                    },
                    child:
                    const Text(
                      "Login",
                      style:
                      TextStyle(
                        fontSize: 17,
                        color:
                        Color(
                          0xff2563EB,
                        ),
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


// ══════════════════════════════════════════════════════════════════════════════
// ROLE PICKER BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _RolePickerSheet extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String>
  onRoleSelected;

  const _RolePickerSheet({
    required this.selectedRole,
    required this.onRoleSelected,
  });


  static const Map<String, String>
  _roleDescriptions = {
    "Student":
    "Enrol as a student and access courses, study material & progress tracking.",

    "School":
    "Register your institution to manage students, staff & curriculum.",

    "Franchise Partner":
    "Partner with us to open a franchise centre in your city.",

    "Distributor":
    "Distribute our products & earn commissions in your region.",
  };


  static const Map<String, List<String>>
  _roleDocs = {
    "Student": [
      "Aadhaar",
      "Selfie",
    ],

    "School": [
      "Aadhaar",
      "PAN",
      "Selfie",
      "Regn. Cert",
      "Bank",
    ],

    "Franchise Partner": [
      "Aadhaar",
      "PAN",
      "Selfie",
      "GST Cert",
      "Bank",
    ],

    "Distributor": [
      "Aadhaar",
      "PAN",
      "Selfie",
      "Bank",
    ],
  };


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
      const BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      padding:
      const EdgeInsets.fromLTRB(
        24,
        0,
        24,
        32,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            // ────────────────────────────────────────────────────────────────
            // DRAG HANDLE
            // ────────────────────────────────────────────────────────────────

            Center(
              child: Container(
                margin:
                const EdgeInsets.only(
                  top: 12,
                  bottom: 20,
                ),
                height: 4,
                width: 40,
                decoration:
                BoxDecoration(
                  color:
                  Colors.grey.shade300,
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
              ),
            ),

            // ────────────────────────────────────────────────────────────────
            // HEADER
            // ────────────────────────────────────────────────────────────────

            const Text(
              "Choose Your Role",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Select the role that best describes you",
              style: TextStyle(
                fontSize: 14,
                color:
                Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 20),

            // ────────────────────────────────────────────────────────────────
            // ROLE TILES
            // ────────────────────────────────────────────────────────────────

            ...kRoleConfigs.entries.map(
                  (entry) {
                final role =
                    entry.key;

                final config =
                    entry.value;

                final bool isSelected =
                    selectedRole ==
                        role;

                final docs =
                    _roleDocs[
                    role] ??
                        [];

                return GestureDetector(
                  onTap: () {
                    onRoleSelected(
                      role,
                    );
                  },
                  child:
                  AnimatedContainer(
                    duration:
                    const Duration(
                      milliseconds:
                      200,
                    ),
                    margin:
                    const EdgeInsets
                        .only(
                      bottom: 12,
                    ),
                    padding:
                    const EdgeInsets
                        .all(
                      16,
                    ),
                    decoration:
                    BoxDecoration(
                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),
                      gradient:
                      isSelected
                          ? const LinearGradient(
                        colors: [
                          Color(
                              0xff2563EB),
                          Color(
                              0xffA020F0),
                        ],
                        begin:
                        Alignment
                            .topLeft,
                        end:
                        Alignment
                            .bottomRight,
                      )
                          : null,
                      color: isSelected
                          ? null
                          : const Color(
                        0xffF8FAFC,
                      ),
                      border:
                      Border.all(
                        color: isSelected
                            ? Colors
                            .transparent
                            : Colors
                            .grey
                            .shade200,
                      ),
                      boxShadow:
                      isSelected
                          ? [
                        BoxShadow(
                          color: const Color(
                              0xff2563EB)
                              .withOpacity(
                            .28,
                          ),
                          blurRadius:
                          14,
                          offset:
                          const Offset(
                            0,
                            6,
                          ),
                        ),
                      ]
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [

                        // Icon
                        Container(
                          height: 48,
                          width: 48,
                          decoration:
                          BoxDecoration(
                            color: isSelected
                                ? Colors
                                .white
                                .withOpacity(
                              0.22,
                            )
                                : const Color(
                              0xffEFF6FF,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              14,
                            ),
                          ),
                          child: Icon(
                            config.icon,
                            size: 24,
                            color: isSelected
                                ? Colors
                                .white
                                : const Color(
                              0xff2563EB,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [

                              Row(
                                children: [
                                  Text(
                                    config.label,
                                    style:
                                    TextStyle(
                                      fontSize:
                                      16,
                                      fontWeight:
                                      FontWeight
                                          .w700,
                                      color: isSelected
                                          ? Colors
                                          .white
                                          : Colors
                                          .black87,
                                    ),
                                  ),

                                  const Spacer(),

                                  if (isSelected)
                                    const Icon(
                                      Icons
                                          .check_circle_rounded,
                                      color:
                                      Colors.white,
                                      size:
                                      20,
                                    ),
                                ],
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                _roleDescriptions[
                                role] ??
                                    "",
                                style:
                                TextStyle(
                                  fontSize:
                                  12,
                                  height:
                                  1.4,
                                  color: isSelected
                                      ? Colors
                                      .white
                                      .withOpacity(
                                    0.85,
                                  )
                                      : Colors
                                      .grey
                                      .shade500,
                                ),
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Wrap(
                                spacing: 6,
                                runSpacing:
                                6,
                                children:
                                docs.map(
                                      (doc) {
                                    return Container(
                                      padding:
                                      const EdgeInsets
                                          .symmetric(
                                        horizontal:
                                        10,
                                        vertical:
                                        4,
                                      ),
                                      decoration:
                                      BoxDecoration(
                                        color: isSelected
                                            ? Colors
                                            .white
                                            .withOpacity(
                                          0.18,
                                        )
                                            : const Color(
                                          0xffEFF6FF,
                                        ),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          20,
                                        ),
                                      ),
                                      child:
                                      Text(
                                        doc,
                                        style:
                                        TextStyle(
                                          fontSize:
                                          11,
                                          fontWeight:
                                          FontWeight
                                              .w600,
                                          color: isSelected
                                              ? Colors
                                              .white
                                              : const Color(
                                            0xff2563EB,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}