import 'package:flutter/material.dart';
import 'package:thenew/Screens/kycverificationscreen.dart';

class JoinUsScreen extends StatefulWidget {
   JoinUsScreen({super.key});

  @override
  State<JoinUsScreen> createState() => _JoinUsScreenState();
}

class _JoinUsScreenState extends State<JoinUsScreen> {
  bool isChecked = true;
  bool isPasswordHidden = true;

  String selectedRole = "Distributor";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xfff5f5f5),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:  EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {

                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child:  Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Colors.black54,
                          ),

                          SizedBox(width: 6),

                          Text(
                            "Back",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
SizedBox(height: 20),
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient:  LinearGradient(
                    colors: [
                      Color(0xff2563EB),
                      Color(0xffA020F0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.12),
                      blurRadius: 10,
                      offset:  Offset(0, 5),
                    ),
                  ],
                ),
                child:  Center(
                  child: Text(
                    "✨",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Join Us",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
 SizedBox(height: 8),
 Text(
                "Start your journey with us",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
SizedBox(height: 40),

               Text(
                "I want to join as",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
SizedBox(height: 12),

              // DROPDOWN
              Container(

                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: Color(0xfff1f2f6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    menuMaxHeight: 250,
                    icon:  Icon(
                      Icons.keyboard_arrow_down_rounded,
                    ),
                    items: [
                      "Distributor",
                      "School",
                      "Franchise Partner",
                      "Student",
                      "Admin",
                    ].map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style:TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ),
              ),SizedBox(height: 12),
               Text(
                "Full Name",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ), SizedBox(height: 12),
              buildTextField(
                hint: "Enter Your Name",
                icon: Icons.person_outline_rounded,
              ), SizedBox(height: 12),
 Text(
                "Email",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
SizedBox(height: 12),

              buildTextField(
                hint: "Enter Your Email Address",
                icon: Icons.mail_outline_rounded,
              ),
 SizedBox(height: 12),
              Text(
                "Phone",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
SizedBox(height: 12),
              buildTextField(
                hint: "Enter Your Phone Number",
                icon: Icons.call_outlined,
              ),
             SizedBox(height: 12),
              Text(
                "Password",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color:  Color(0xfff1f2f6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  obscureText: isPasswordHidden,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding:  EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    prefixIcon:  Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    hintText: "Enter Your Password",
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
SizedBox(height: 24),

              // TERMS
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:  Color(0xfff1f2f6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Checkbox(
                      value: isChecked,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ), SizedBox(width: 4),
 Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          "I agree to the Terms & Conditions and Privacy Policy",
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ), SizedBox(height: 28),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KycVerificationScreen(),
                    ),
                  );
                },

                child: Container(
                  height: 62,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff2563EB),
                        Color(0xffA020F0),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
 SizedBox(height: 34),

              // LOGIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black54,
                    ),
                  ),

                  Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 17,
                      color: Color(0xff2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xfff1f2f6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:  EdgeInsets.symmetric(
            vertical: 20,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
          ),
          hintText: hint,
          hintStyle:  TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}