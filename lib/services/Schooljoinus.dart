import 'package:flutter/material.dart';

class SchoolJoinScreen extends StatefulWidget {
   SchoolJoinScreen({super.key});

  @override
  State<SchoolJoinScreen> createState() =>
      _SchoolJoinScreenState();
}

class _SchoolJoinScreenState
    extends State<SchoolJoinScreen> {

  bool isChecked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
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
              ),
 SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding:  EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient:  LinearGradient(
                    colors: [
                      Color(0xff16A34A),
                      Color(0xff22C55E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.12),
                      blurRadius: 12,
                      offset:  Offset(0, 5),
                    ),
                  ],
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
                        Icons.apartment_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                      SizedBox(height: 26),

                     Text(
                      "School\nJoin Us",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Partner with us and integrate smart learning programs into your school.",
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
              buildTitle("School Name"),
             SizedBox(height: 12),
              buildField(
                hint: "Enter school name",
                icon: Icons.school_outlined,
              ),
 SizedBox(height: 24),
              buildTitle("Principal Name"),
SizedBox(height: 12),
              buildField(
                hint: "Enter principal name",
                icon: Icons.person_outline_rounded,
              ),
 SizedBox(height: 24),
              buildTitle("Email Address"),
 SizedBox(height: 12),
              buildField(
                hint: "Enter School Email Address",
                icon: Icons.mail_outline_rounded,
              ),
SizedBox(height: 24),
              buildTitle("Phone Number"),
SizedBox(height: 12),
              buildField(
                hint: "Enter Phone Number",
                icon: Icons.call_outlined,
              ),
 SizedBox(height: 24),
              buildTitle("School Address"),
 SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText:
                    "Enter complete school address...",
                  ),
                ),
              ),
              SizedBox(height: 24),
              buildTitle("Number of Students"),
              SizedBox(height: 12),
              buildField(
                hint: "Approximate number of students",
                icon: Icons.groups_rounded,
              ),
                SizedBox(height: 24),
              Container(
                padding:  EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Checkbox(
                      value: isChecked,
                      activeColor: Colors.green,
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
              ),
              SizedBox(height: 32),
              Container(
                height: 62,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff16A34A),
                      Color(0xff22C55E),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.15),
                      blurRadius: 12,
                      offset:Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Apply For School Partnership",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
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