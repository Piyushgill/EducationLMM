import 'package:flutter/material.dart';
import 'package:thenew/services/kycverificationscreen.dart';


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

class JoinUsScreen extends StatefulWidget {
  const JoinUsScreen({super.key});

  @override
  State<JoinUsScreen> createState() => _JoinUsScreenState();
}

class _JoinUsScreenState extends State<JoinUsScreen> {
  bool isChecked = true;
  bool isPasswordHidden = true;
  String selectedRole = "Distributor";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _onContinue() {
    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please accept Terms & Conditions"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KycVerificationScreen(role: selectedRole),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Colors.black54),
                      SizedBox(width: 6),
                      Text("Back",
                          style: TextStyle(
                              fontSize: 18, color: Colors.black54)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── LOGO ──
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xff2563EB), Color(0xffA020F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.12),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text("✨",
                      style: TextStyle(fontSize: 30)),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Join Us",
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              const Text(
                "Start your journey with us",
                style:
                TextStyle(fontSize: 18, color: Colors.black54),
              ),

              const SizedBox(height: 40),

              // ── ROLE ──
              const Titleh1(title: "I want to join as", astrick: true),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xfff1f2f6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    menuMaxHeight: 250,
                    icon: const Icon(
                        Icons.keyboard_arrow_down_rounded),
                    items: [
                      "Distributor",
                      "School",
                      "Franchise Partner",
                      "Student",
                    ].map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: const TextStyle(fontSize: 18)),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedRole = value!),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── FULL NAME ──
              const Titleh1(title: "Full Name", astrick: true),
              const SizedBox(height: 12),
              _buildTextField(
                  controller: _nameController,
                  hint: "Enter Your Name",
                  icon: Icons.person_outline_rounded),

              const SizedBox(height: 12),

              // ── EMAIL ──
              const Titleh1(title: "Email", astrick: true),
              const SizedBox(height: 12),
              _buildTextField(
                  controller: _emailController,
                  hint: "Enter Your Email Address",
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress),

              const SizedBox(height: 12),

              // ── PHONE ──
              const Titleh1(title: "Phone", astrick: true),
              const SizedBox(height: 12),
              _buildTextField(
                  controller: _phoneController,
                  hint: "Enter Your Phone Number",
                  icon: Icons.call_outlined,
                  keyboardType: TextInputType.phone),

              const SizedBox(height: 12),

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
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 20),
                    prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.grey),
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                              () => isPasswordHidden = !isPasswordHidden),
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    hintText: "Enter Your Password",
                    hintStyle: const TextStyle(
                        fontSize: 18, color: Colors.black87),
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
                      onChanged: (value) =>
                          setState(() => isChecked = value!),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          "I agree to the Terms & Conditions and Privacy Policy",
                          style: TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              color: Colors.black87),
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
                      colors: [
                        Color(0xff2563EB),
                        Color(0xffA020F0)
                      ],
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
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 34),

              // ── LOGIN LINK ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                        fontSize: 17, color: Colors.black54),
                  ),
                  Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 17,
                        color: Color(0xff2563EB),
                        fontWeight: FontWeight.w600),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff1f2f6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 20),
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}