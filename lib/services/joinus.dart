import 'package:flutter/material.dart';
import 'package:thenew/services/kycverificationscreen.dart';
import 'package:thenew/services/login_screen.dart';

class Titleh1 extends StatelessWidget {
  final String title;
  final bool astrick;

  const Titleh1({super.key, required this.title, this.astrick = false});

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

// ── Role config ──────────────────────────────────────────────────────────────
class RoleConfig {
  final String label;
  final IconData icon;
  final String subtitle;
  final List<FieldConfig> extraFields; // role-specific fields (after phone)

  const RoleConfig({
    required this.label,
    required this.icon,
    required this.subtitle,
    required this.extraFields,
  });
}

class FieldConfig {
  final String key;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const FieldConfig({
    required this.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
  });
}

const Map<String, RoleConfig> kRoleConfigs = {
  "Student": RoleConfig(
    label: "Student",
    icon: Icons.school_outlined,
    subtitle: "Join as a student learner",
    extraFields: [
      FieldConfig(
        key: "school_name",
        label: "School Name",
        hint: "Enter your school name",
        icon: Icons.account_balance_outlined,
      ),
      FieldConfig(
        key: "class_grade",
        label: "Class / Grade",
        hint: "e.g. Class 10, Grade 12",
        icon: Icons.format_list_numbered_rounded,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
      ),
      FieldConfig(
        key: "dob",
        label: "Date of Birth",
        hint: "DD/MM/YYYY",
        icon: Icons.cake_outlined,
        keyboardType: TextInputType.datetime,
        textCapitalization: TextCapitalization.none,
      ),
    ],
  ),
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
      ),
      FieldConfig(
        key: "board_type",
        label: "Board / Affiliation",
        hint: "e.g. CBSE, ICSE, State Board",
        icon: Icons.menu_book_outlined,
        textCapitalization: TextCapitalization.characters,
      ),
      FieldConfig(
        key: "reg_number",
        label: "School Registration No.",
        hint: "Enter registration number",
        icon: Icons.confirmation_number_outlined,
        textCapitalization: TextCapitalization.characters,
      ),
      FieldConfig(
        key: "city",
        label: "City",
        hint: "Enter city name",
        icon: Icons.location_city_outlined,
      ),
    ],
  ),
  "Franchise Partner": RoleConfig(
    label: "Franchise Partner",
    icon: Icons.handshake_outlined,
    subtitle: "Become a franchise partner",
    extraFields: [
      FieldConfig(
        key: "business_name",
        label: "Business Name",
        hint: "Enter your business name",
        icon: Icons.business_outlined,
      ),
      FieldConfig(
        key: "gst_number",
        label: "GST Number",
        hint: "e.g. 22AAAAA0000A1Z5",
        icon: Icons.receipt_long_outlined,
        textCapitalization: TextCapitalization.characters,
      ),
      FieldConfig(
        key: "city",
        label: "City / Area",
        hint: "Enter your city",
        icon: Icons.map_outlined,
      ),
      FieldConfig(
        key: "experience",
        label: "Business Experience",
        hint: "e.g. 3 years in education",
        icon: Icons.work_outline_rounded,
        textCapitalization: TextCapitalization.sentences,
      ),
    ],
  ),
  "Distributor": RoleConfig(
    label: "Distributor",
    icon: Icons.local_shipping_outlined,
    subtitle: "Join as a distributor",
    extraFields: [
      FieldConfig(
        key: "business_name",
        label: "Business / Firm Name",
        hint: "Enter your firm name",
        icon: Icons.store_outlined,
      ),
      FieldConfig(
        key: "area",
        label: "Distribution Area",
        hint: "e.g. North Delhi, Pune",
        icon: Icons.pin_drop_outlined,
      ),
      FieldConfig(
        key: "experience",
        label: "Distribution Experience",
        hint: "e.g. 5 years in FMCG",
        icon: Icons.work_history_outlined,
        textCapitalization: TextCapitalization.sentences,
      ),
    ],
  ),
};

// ── Screen ───────────────────────────────────────────────────────────────────
class JoinUsScreen extends StatefulWidget {
  const JoinUsScreen({super.key});

  @override
  State<JoinUsScreen> createState() => _JoinUsScreenState();
}

class _JoinUsScreenState extends State<JoinUsScreen> {
  bool isChecked = false;
  bool isPasswordHidden = true;
  String selectedRole = "Distributor";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Dynamic extra-field controllers keyed by FieldConfig.key
  final Map<String, TextEditingController> _extraControllers = {};

  RoleConfig get _currentConfig => kRoleConfigs[selectedRole]!;

  @override
  void initState() {
    super.initState();
    _rebuildExtraControllers();
  }

  void _rebuildExtraControllers() {
    for (final c in _extraControllers.values) {
      c.dispose();
    }
    _extraControllers.clear();
    for (final field in _currentConfig.extraFields) {
      _extraControllers[field.key] = TextEditingController();
    }
  }

  void _onRoleChanged(String role) {
    setState(() {
      selectedRole = role;
      _rebuildExtraControllers();
    });
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) return "Please enter your full name";
    if (_emailController.text.trim().isEmpty) return "Please enter your email";
    if (!_emailController.text.contains('@')) return "Please enter a valid email";
    if (_phoneController.text.trim().length < 10) return "Please enter a valid phone number";
    if (_passwordController.text.length < 6) return "Password must be at least 6 characters";
    for (final field in _currentConfig.extraFields) {
      if (_extraControllers[field.key]!.text.trim().isEmpty) {
        return "Please enter ${field.label}";
      }
    }
    if (!isChecked) return "Please accept Terms & Conditions";
    return null;
  }

  void _onContinue() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Collect all form data to pass forward
    final Map<String, String> formData = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
    };
    for (final field in _currentConfig.extraFields) {
      formData[field.key] = _extraControllers[field.key]!.text.trim();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KycVerificationScreen(
          role: selectedRole,
          formData: formData,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    for (final c in _extraControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── BACK ──
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black54),
                      SizedBox(width: 6),
                      Text("Back", style: TextStyle(fontSize: 18, color: Colors.black54)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── LOGO ──
              Image.asset(
                'assets/image/k-logo.png',
                height: 64,
                width: 64,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 20),

              const Text(
                "Join Us",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),

              // Dynamic subtitle per role
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _currentConfig.subtitle,
                  key: ValueKey(selectedRole),
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 40),

              // ── ROLE SELECTOR ──
              const Titleh1(title: "I want to join as", astrick: true),
              const SizedBox(height: 12),
              _buildRoleDrawerTrigger(),

              const SizedBox(height: 20),

              // ── ROLE INFO CHIP ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildRoleInfoChip(key: ValueKey(selectedRole)),
              ),

              const SizedBox(height: 20),

              // ── COMMON FIELDS ──
              const Titleh1(title: "Full Name", astrick: true),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                hint: selectedRole == "School" ? "Enter School Name" : "Enter Your Full Name",
                icon: selectedRole == "School" ? Icons.domain_outlined : Icons.person_outline_rounded,
              ),

              const SizedBox(height: 16),

              const Titleh1(title: "Email", astrick: true),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emailController,
                hint: "Enter Email Address",
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
              ),

              const SizedBox(height: 16),

              const Titleh1(title: "Phone", astrick: true),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                hint: "Enter Phone Number",
                icon: Icons.call_outlined,
                keyboardType: TextInputType.phone,
                textCapitalization: TextCapitalization.none,
              ),

              const SizedBox(height: 16),

              // ── ROLE-SPECIFIC EXTRA FIELDS ──
              ...List.generate(_currentConfig.extraFields.length, (i) {
                final field = _currentConfig.extraFields[i];
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey("${selectedRole}_${field.key}"),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Titleh1(title: field.label, astrick: true),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _extraControllers[field.key]!,
                        hint: field.hint,
                        icon: field.icon,
                        keyboardType: field.keyboardType,
                        textCapitalization: field.textCapitalization,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              }),

              // ── PASSWORD ──
              const Titleh1(title: "Password", astrick: true),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xfff1f2f6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: isPasswordHidden,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => isPasswordHidden = !isPasswordHidden),
                      icon: Icon(
                        isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    hintText: "Enter Your Password",
                    hintStyle: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── TERMS ──
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xfff1f2f6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: Colors.blue,
                      onChanged: (value) => setState(() => isChecked = value!),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          "I agree to the Terms & Conditions and Privacy Policy",
                          style: TextStyle(fontSize: 16, height: 1.4, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── CONTINUE ──
              GestureDetector(
                onTap: _onContinue,
                child: Container(
                  height: 62,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xff2563EB), Color(0xffA020F0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.14),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Continue to KYC",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 34),

              // ── LOGIN LINK ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black54,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xff2563EB),
                        fontWeight: FontWeight.w600,
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

  // ── Role drawer trigger button ──
  Widget _buildRoleDrawerTrigger() {
    final config = _currentConfig;
    return GestureDetector(
      onTap: _openRoleDrawer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xfff1f2f6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffBFDBFE), width: 1.2),
        ),
        child: Row(
          children: [
            // Role icon in gradient circle
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff2563EB), Color(0xffA020F0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(config.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    config.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xffEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Change",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: Color(0xff2563EB)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Open role bottom sheet ──
  void _openRoleDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _RolePickerSheet(
        selectedRole: selectedRole,
        onRoleSelected: (role) {
          Navigator.pop(context);
          _onRoleChanged(role);
        },
      ),
    );
  }

  // ── Role info chip ──
  Widget _buildRoleInfoChip({Key? key}) {
    final Map<String, String> roleRequirements = {
      "Student": "Aadhaar + Selfie required",
      "School": "Aadhaar + PAN + Registration Cert + Bank required",
      "Franchise Partner": "Aadhaar + PAN + GST Certificate + Bank required",
      "Distributor": "Aadhaar + PAN + Bank Details required",
    };

    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xff2563EB), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "KYC: ${roleRequirements[selectedRole] ?? ''}",
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xff1D4ED8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff1f2f6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}

// ── Role Picker Bottom Sheet ─────────────────────────────────────────────────
class _RolePickerSheet extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleSelected;

  const _RolePickerSheet({
    required this.selectedRole,
    required this.onRoleSelected,
  });

  // Short description shown inside drawer for each role
  static const Map<String, String> _roleDescriptions = {
    "Student":
    "Enrol as a student and access courses, study material & progress tracking.",
    "School":
    "Register your institution to manage students, staff & curriculum.",
    "Franchise Partner":
    "Partner with us to open a franchise centre in your city.",
    "Distributor":
    "Distribute our products & earn commissions in your region.",
  };

  // Documents required — shown as small chips in the drawer
  static const Map<String, List<String>> _roleDocs = {
    "Student": ["Aadhaar", "Selfie"],
    "School": ["Aadhaar", "PAN", "Reg. Cert", "Bank"],
    "Franchise Partner": ["Aadhaar", "PAN", "GST Cert", "Bank"],
    "Distributor": ["Aadhaar", "PAN", "Bank"],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── drag handle ──
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // ── header ──
          const Text(
            "Choose Your Role",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Select the role that best describes you",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),

          // ── role tiles ──
          ...kRoleConfigs.entries.map((entry) {
            final role = entry.key;
            final config = entry.value;
            final isSelected = selectedRole == role;
            final docs = _roleDocs[role] ?? [];

            return GestureDetector(
              onTap: () => onRoleSelected(role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isSelected
                      ? const LinearGradient(
                    colors: [Color(0xff2563EB), Color(0xffA020F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: isSelected ? null : const Color(0xffF8FAFC),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.shade200,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: const Color(0xff2563EB).withOpacity(.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    )
                  ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // icon box
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.22)
                            : const Color(0xffEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        config.icon,
                        size: 24,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xff2563EB),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // role name + check
                          Row(
                            children: [
                              Text(
                                config.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // description
                          Text(
                            _roleDescriptions[role] ?? "",
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.85)
                                  : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // doc chips
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: docs.map((doc) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.18)
                                      : const Color(0xffEFF6FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  doc,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xff2563EB),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}