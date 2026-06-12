import 'package:flutter/material.dart';
import 'package:thenew/services/Schooljoinus.dart';
import 'package:thenew/services/Student_joinus.dart';
import 'package:thenew/services/distributorjoinus.dart';
import 'package:thenew/services/franchisejoinus.dart';
import 'package:thenew/services/joinus.dart';
import 'package:thenew/Screens/ourprogram.dart';
import 'package:thenew/Screens/watchdemovideo.dart';

class EducationLLMHomeScreen extends StatelessWidget {
   EducationLLMHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xfff5f5f7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:  EdgeInsets.all(22),
                decoration:  BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff3B82F6),
                      Color(0xffA855F7),
                      Color(0xffEC4899),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:  EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.12),
                            blurRadius: 10,
                            offset:  Offset(0, 4),
                          )
                        ],
                      ),
                      child:  Icon(
                        Icons.school_rounded,
                        size: 32,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 28),
                     Text(
                      "Transform Education",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Join India's leading education platform",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 28),
                    InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JoinUsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding:  EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.15),
                              blurRadius: 12,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Get Started",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff2563EB),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xff2563EB),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Join as",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ), SizedBox(height: 18),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>DistributorJoinScreen(),
                    ),
                  );
                },
                child: _buildJoinCard(
                  title: "Distributor",
                  subtitle: "Build & manage networks",
                  gradient:  [Color(0xff60A5FA),
                    Color(0xff2563EB),
                  ],
                  icon: Icons.trending_up_rounded,
                ),
              ),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>FranchiseJoinScreen(),
                ),
              );
            },
            child: _buildJoinCard(
                title: "Franchise Partner",
                subtitle: "Run education center",
                gradient: [
                  Color(0xffC084FC),
                  Color(0xffA855F7),
                ],
                icon: Icons.school_rounded,
              ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>StudentSignUpScreen(),
                ),
              );
            },
            child: _buildJoinCard(
                title: "Student",
                subtitle: "Tech Your Self",
                gradient:  [Color(0xff22C55E), Color(0xff00B63E),
                ],
                icon: Icons.apartment_rounded,
              ),
          ),
              SizedBox(height: 30),

              // PROGRAMS
              Container(
                width: double.infinity,
                padding:  EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      "Our Programs",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 22),

                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                 ourprogramsScreen(),
                              ),
                            );
                          },
                          child:ProgramCard(
                            image:
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS7qqRHwPNe6A_GUXSWGJN3aO6w5sCdylhgHg&s",
                            title: "Abacus",
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>ourprogramsScreen(),
                              ),
                            );
                          },
                          child: ProgramCard(
                            image:
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6FdUuNQdRwiCwvggqHWGYIUhlnJ9vQr9alTdD8qjTrQ&s",
                            title: "Vedic Maths",
                          ),
                        ),

                        InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>ourprogramsScreen(),
                              ),
                            );
                          },
                          child:ProgramCard(
                            image:
                            "https://cdn-icons-png.flaticon.com/512/2436/2436636.png",
                            title: "Phonics",
                          ),
                        ),

                        InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>ourprogramsScreen(),
                              ),
                            );
                          },
                          child:ProgramCard(
                            image:
                            "https://cdn-icons-png.flaticon.com/512/3898/3898150.png",
                            title: "English",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding:  EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration:  BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff2563EB),
                      Color(0xff9333EA),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      "Why Choose Us?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatsWidget(
                          number: "10K+",
                          label: "Students",
                        ),
                        StatsWidget(
                          number: "500+",
                          label: "Centers",
                        ),
                        StatsWidget(
                          number: "98%",
                          label: "Success",
                        ),
                      ],
                    ),
                  ],
                ),
              ), SizedBox(height: 30),

              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                       DemoVideoScreen(),
                    ),
                  );
                },

                child: Container(
                  margin:  EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  padding:  EdgeInsets.symmetric(vertical: 18),
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
                        blurRadius: 12,
                        offset:  Offset(0, 5),
                      )
                    ],
                  ),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),

                      SizedBox(width: 8),

                      Text(
                        "Watch Demo Video",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinCard({
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(.3),
            blurRadius: 14,
            offset:Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding:EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 15,
            ),
          ),
SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }
}
class ProgramCard extends StatelessWidget {
  final String image;
  final String title;

  const ProgramCard({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:  Color(0xfff6f6f8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            image,
            height: 55,
            width: 55,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 14),
          Text(
            title,
            style:TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class StatsWidget extends StatelessWidget {
  final String number;
  final String label;

  const StatsWidget({
    super.key,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style:TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
         SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(.9),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}