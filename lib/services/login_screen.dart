import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isPasswordHidden = true;
  bool _rememberMe = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_emailController.text.trim().isEmpty) return "Please enter your email";
    if (!_emailController.text.contains('@')) return "Enter a valid email address";
    if (_passwordController.text.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  void _onLogin() {
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
    // TODO: handle login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── LOGO + HEADER ──
                  Center(
                    child: Column(
                      children: [
                        // gradient logo box
                        Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: const LinearGradient(
                              colors: [Color(0xff2563EB), Color(0xffA020F0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff2563EB).withOpacity(.28),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text("✨", style: TextStyle(fontSize: 34)),
                          ),
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sign in to continue your journey",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── EMAIL ──
                  _label("Email"),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _emailController,
                    hint: "Enter your email address",
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // ── PASSWORD ──
                  _label("Password"),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfff1f2f6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _isPasswordHidden,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _isPasswordHidden = !_isPasswordHidden),
                          icon: Icon(
                            _isPasswordHidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                        ),
                        hintText: "Enter your password",
                        hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── REMEMBER ME + FORGOT ──
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 22,
                              width: 22,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: _rememberMe
                                    ? const LinearGradient(
                                  colors: [Color(0xff2563EB), Color(0xffA020F0)],
                                )
                                    : null,
                                color: _rememberMe ? null : const Color(0xffe0e0e0),
                              ),
                              child: _rememberMe
                                  ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Remember me",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          // TODO: forgot password
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // ── LOGIN BUTTON ──
                  GestureDetector(
                    onTap: _onLogin,
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
                            color: const Color(0xff2563EB).withOpacity(.28),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── DIVIDER ──
                  // Row(
                  //   children: [
                  //     Expanded(child: Divider(color: Colors.grey.shade300)),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 14),
                  //       child: Text(
                  //         "or continue with",
                  //         style: TextStyle(
                  //           fontSize: 13,
                  //           color: Colors.grey.shade400,
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(child: Divider(color: Colors.grey.shade300)),
                  //   ],
                  // ),

                  const SizedBox(height: 24),

                  // ── SOCIAL BUTTONS ──
                  // Row(
                  //   children: [
                  //     Expanded(child: _socialButton("Google", "G", const Color(0xffEA4335))),
                  //     const SizedBox(width: 14),
                  //     Expanded(child: _socialButton("Apple", "", const Color(0xff111111))),
                  //   ],
                  // ),

                  const SizedBox(height: 40),

                  // ── SIGN UP LINK ──
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          children: [
                            TextSpan(
                              text: "Join Us",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff2563EB),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──
  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.black,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _socialButton(String label, String letterIcon, Color color) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // letter-based icon to avoid asset dependency
          Container(
            height: 26,
            width: 26,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                letterIcon,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}