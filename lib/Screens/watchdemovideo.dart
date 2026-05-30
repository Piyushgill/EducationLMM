import 'package:flutter/material.dart';

class DemoVideoScreen extends StatelessWidget {
   DemoVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff2563EB),
                      Color(0xff9333EA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
SizedBox(height: 30),
Text(
                      "Watch Demo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
 SizedBox(height: 10),

                    Text(
                      "Explore our learning programs through demo classes and videos.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.92),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
 SizedBox(height: 30),

                    Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(28),
                        image: DecorationImage(
                          image: NetworkImage(
                            "https://images.unsplash.com/photo-1509062522246-3755977927d7",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

               SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
 Text(
                      "About Demo Class",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
 SizedBox(height: 16),
 Text(
                      "Our demo sessions help students and parents understand our teaching methodology, curriculum, and interactive learning experience.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        color: Colors.black87,
                      ),
                    ),
 SizedBox(height: 28),
                    buildFeature(
                      icon: Icons.play_circle_outline_rounded,
                      title: "Interactive Learning",
                      subtitle:
                      "Engaging live learning sessions",
                    ),
                    buildFeature(
                      icon: Icons.school_outlined,
                      title: "Expert Trainers",
                      subtitle:
                      "Learn from experienced mentors",
                    ),
                    buildFeature(
                      icon: Icons.workspace_premium_outlined,
                      title: "Premium Curriculum",
                      subtitle:
                      "Industry-leading education system",
                    ), SizedBox(height: 30),

                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
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
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),

                            SizedBox(width: 8),

                            Text(
                              "Watch Full Demo",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 35),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin:  EdgeInsets.only(bottom: 18),
      padding:  EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [

          Container(
            padding:  EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:  Color(0xffEEF2FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color:  Color(0xff2563EB),
              size: 30,
            ),
          ),

           SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}