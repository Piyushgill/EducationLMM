import 'package:flutter/material.dart';

class DistributorJoinScreen extends StatefulWidget {
   DistributorJoinScreen({super.key});

  @override
  State<DistributorJoinScreen> createState() =>
      _DistributorJoinScreenState();
}

class _DistributorJoinScreenState
    extends State<DistributorJoinScreen> {

  bool isChecked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xfff5f5f5),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:  EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // BACK BUTTON
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child:  Row(
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

               SizedBox(height: 35),

              // HEADER
              Container(
                width: double.infinity,
                padding:  EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient:  LinearGradient(
                    colors: [
                      Color(0xff2563EB),
                      Color(0xff9333EA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      padding:  EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:  Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),

                     SizedBox(height: 24),
                    Text(
                      "Distributor\nJoin Us",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                     SizedBox(height: 12),
                    Text(
                      "Become our official distributor and grow with India's leading education platform.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.92),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35),
              buildTitle("Full Name"),
 SizedBox(height: 12),
              buildField(
                hint: "Enter your full name",
                icon: Icons.person_outline_rounded,
              ),
           SizedBox(height: 24),
              buildTitle("Email Address"),
 SizedBox(height: 12),
              buildField(
                hint: "Enter your email Address",
                icon: Icons.mail_outline_rounded,
              ),
 SizedBox(height: 24),
              buildTitle("Phone Number"),
 SizedBox(height: 12),
              buildField(
                hint: "Enter your phone number",
                icon: Icons.call_outlined,
              ),
SizedBox(height: 24),
              buildTitle("City"),
 SizedBox(height: 12),
              buildField(
                hint: "Enter your city",
                icon: Icons.location_on_outlined,
              ),
 SizedBox(height: 24),
              buildTitle("Business Experience"),
SizedBox(height: 12),
              Container(
                padding:  EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:  TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText:
                    "Write about your business experience...",
                  ),
                ),
              ), SizedBox(height: 24),
              Container(
                padding:  EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
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
Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
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
              ), SizedBox(height: 30),
              Container(
                height: 62,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient:  LinearGradient(
                    colors: [
                      Color(0xff2563EB),
                      Color(0xff9333EA),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.15),
                      blurRadius: 10,
                      offset:  Offset(0, 5),
                    ),
                  ],
                ),
                child:  Center(
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
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      style:  TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget buildField({
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
          ),
          contentPadding:  EdgeInsets.symmetric(
            vertical: 20,
          ),
        ),
      ),
    );
  }
}