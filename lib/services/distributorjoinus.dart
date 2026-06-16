import 'package:flutter/material.dart';
import 'package:thenew/dashboards/distributor_dashboard.dart';

class DistributorJoinScreen extends StatefulWidget {
  const DistributorJoinScreen({super.key});

  @override
  State<DistributorJoinScreen> createState() =>
      _DistributorJoinScreenState();
}

class _DistributorJoinScreenState
    extends State<DistributorJoinScreen> {
  bool isChecked = true;

  final TextEditingController nameController =
  TextEditingController();
  final TextEditingController emailController =
  TextEditingController();
  final TextEditingController phoneController =
  TextEditingController();
  final TextEditingController cityController =
  TextEditingController();
  final TextEditingController experienceController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BACK BUTTON
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Back",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff2563EB),
                      Color(0xff9333EA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Distributor\nJoin Us",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Become our official distributor and grow with India's leading education platform.",
                      style: TextStyle(
                        color:
                        Colors.white.withOpacity(.92),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              buildTitle("Full Name"),
              const SizedBox(height: 12),
              buildField(
                controller: nameController,
                hint: "Enter your full name",
                icon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 24),

              buildTitle("Email Address"),
              const SizedBox(height: 12),
              buildField(
                controller: emailController,
                hint: "Enter your email Address",
                icon: Icons.mail_outline_rounded,
              ),

              const SizedBox(height: 24),

              buildTitle("Phone Number"),
              const SizedBox(height: 12),
              buildField(
                controller: phoneController,
                hint: "Enter your phone number",
                icon: Icons.call_outlined,
              ),

              const SizedBox(height: 24),

              buildTitle("City"),
              const SizedBox(height: 12),
              buildField(
                controller: cityController,
                hint: "Enter your city",
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 24),

              buildTitle("Business Experience"),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: experienceController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText:
                    "Write about your business experience...",
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                    const Expanded(
                      child: Padding(
                        padding:
                        EdgeInsets.only(top: 12),
                        child: Text(
                          "I agree to the Terms & Conditions and Privacy Policy.",
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              InkWell(
                borderRadius:
                BorderRadius.circular(20),
                onTap: () {
                  if (!isChecked) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please accept Terms & Conditions first",
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const DistributorDashboard(),
                    ),
                  );
                },
                child: Container(
                  height: 62,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff2563EB),
                        Color(0xff9333EA),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                        Colors.black.withOpacity(.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Submit Application",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
          ),
          contentPadding:
          const EdgeInsets.symmetric(
            vertical: 20,
          ),
        ),
      ),
    );
  }
}