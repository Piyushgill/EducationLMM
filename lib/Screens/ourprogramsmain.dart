// import 'package:flutter/material.dart';
// import'package:youtube_player_flutter/youtube_player_flutter.dart';
//
// class ourprogramsmainScreen extends StatelessWidget {
//   ourprogramsmainScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xfff5f5f5),
//
//       bottomNavigationBar: Container(
//         height: 80,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 10,
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: const [
//             BottomItem(
//               icon: Icons.home_outlined,
//               label: "Home",
//             ),
//             BottomItem(
//               icon: Icons.groups_2_outlined,
//               label: "Company",
//             ),
//             BottomItem(
//               icon: Icons.menu_book_rounded,
//               label: "Programs",
//               isSelected: true,
//             ),
//             BottomItem(
//               icon: Icons.star_border_rounded,
//               label: "Reviews",
//             ),
//             BottomItem(
//               icon: Icons.person_outline_rounded,
//               label: "Profile",
//             ),
//           ],
//         ),
//       ),
//
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Container(
//                 width: double.infinity,
//                 padding:  EdgeInsets.all(22),
//                 decoration:  BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(0xff2563EB),
//                       Color(0xffA020F0),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(28),
//                     bottomRight: Radius.circular(28),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                   //   onTap: () {
//                   //     Navigator.pop(context);
//                   //   },
//                   //   borderRadius: BorderRadius.circular(12),
//                   //   child:  Padding(
//                   //     padding: EdgeInsets.symmetric(
//                   //       vertical: 8,
//                   //       horizontal: 4,
//                   //     ),
//                   //     child: Row(
//                   //       children: [
//                   //         Icon(
//                   //           Icons.arrow_back_ios_new_rounded,
//                   //           size: 18,
//                   //         ),
//                   //
//                   //         SizedBox(width: 6),
//                   //
//                   //         Text(
//                   //           "Back",
//                   //           style: TextStyle(
//                   //             fontSize: 17,
//                   //             fontWeight: FontWeight.w500,
//                   //           ),
//                   //         ),
//                   //       ],
//                   //     ),
//                   //   ),
//                   // ),
//
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(.15),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: const Icon(
//                             Icons.menu_rounded,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                         ),
//
//                         Stack(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(.15),
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: const Icon(
//                                 Icons.notifications_none_rounded,
//                                 color: Colors.white,
//                                 size: 28,
//                               ),
//                             ),
//
//                             Positioned(
//                               right: 4,
//                               top: 4,
//                               child: Container(
//                                 height: 10,
//                                 width: 10,
//                                 decoration: const BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 28),
//
//                     Text(
//                       "Our Programs",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 34,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//
//                     SizedBox(height: 8),
//
//                     Text(
//                       "Comprehensive curriculum",
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(.9),
//                         fontSize: 18,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: 24),
//
//               // ABACUS CARD
//               ProgramCard(
//                 title: "Abacus",
//                 subtitle: "Develop exceptional mental math abilities",
//                 levels: "8",
//                 duration: "4 Years",
//                 color1: Color(0xff2563EB),
//                 color2: Color(0xffE5E7EB),
//                 icon: Icons.calculate_rounded,
//                 videoID: "https://youtu.be/pQpFebyALV0?si=uEW4gsOE4d_go9Jx",
//                 benefits: [
//                   "Improves concentration",
//                   "Enhances calculation speed",
//                   "Boosts confidence",
//                   "Develops both brain hemispheres",
//                 ],
//               ),
//
//               SizedBox(height: 22),
//               ProgramCard(
//                 title: "Vadic Maths",
//                 subtitle: "Develop exceptional mental math abilities",
//                 levels: "8",
//                 duration: "4 Years",
//                 color1: Color(0xff343EB),
//                 color2: Color(0xffE5E7EB),
//                 icon: Icons.plus_one,
//                 videoID: "https://youtu.be/pQpFebyALV0?si=uEW4gsOE4d_go9Jx",
//                 benefits: [
//                   "Improves concentration",
//                   "Enhances calculation speed",
//                   "Boosts confidence",
//                   "Develops both brain hemispheres",
//                 ],
//               ),
//               SizedBox(height: 22),
//               ProgramCard(
//                 title: "Phonics",
//                 subtitle: "Build strong reading foundation",
//                 levels: "5",
//                 duration: "1.5 Years",
//                 color1: Color(0xff16A34A),
//                 color2: Color(0xff059669),
//                 icon: Icons.mic_none_rounded,
//                 videoID: "https://www.youtube.com/live/5u55IhRGRAk?si=96dxZvGu2sBsn1PU",
//                 benefits: [
//                   "Improves reading skills",
//                   "Develops pronunciation",
//                   "Builds vocabulary",
//                   "Boosts confidence",
//                 ],
//               ),
//               SizedBox(height: 22),
//               ProgramCard(
//                 title: "English",
//                 subtitle: "Build strong reading foundation",
//                 levels: "5",
//                 duration: "1.5 Years",
//                 color1: Color(0xff16A34A),
//                 color2: Color(0xff059669),
//                 icon: Icons.mic_none_rounded,
//                 videoID: "https://youtu.be/pQpFebyALV0?si=uEW4gsOE4d_go9Jx",
//                 benefits: [
//                   "Improves reading skills",
//                   "Develops pronunciation",
//                   "Builds vocabulary",
//                   "Boosts confidence",
//                 ],
//               ),
//
//               SizedBox(height: 24),
//
//               // CTA SECTION
//               Container(
//                 margin:  EdgeInsets.symmetric(horizontal: 20),
//                 padding:  EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 30,
//                 ),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(28),
//                   gradient:  LinearGradient(
//                     colors: [
//                       Color(0xff2563EB),
//                       Color(0xffA020F0),
//                     ],
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//
//                     Text(
//                       "Ready to Get Started?",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//
//                     SizedBox(height: 16),
//
//                     Text(
//                       "Join thousands of students benefitting from our programs",
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(.92),
//                         fontSize: 18,
//                         height: 1.5,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 28),
//
//                     Container(
//                       padding:  EdgeInsets.symmetric(
//                         horizontal: 40,
//                         vertical: 18,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(22),
//                       ),
//                       child:  Text(
//                         "Enroll Now",
//                         style: TextStyle(
//                           color: Color(0xff2563EB),
//                           fontSize: 22,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// // Program card Method
// class ProgramCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String levels;
//   final String duration;
//   final Color color1;
//   final Color color2;
//   final IconData icon;
//   final List<String> benefits;
//   final String videoID;
//
//   const ProgramCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.levels,
//     required this.duration,
//     required this.color1,
//     required this.color2,
//     required this.icon,
//     required this.benefits,
//     required this.videoID,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin:  EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(26),
//       ),
//       child: Column(
//         children: [
//
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(26),
//                 topRight: Radius.circular(26),
//               ),
//               gradient: LinearGradient(
//                 colors: [
//                   color1,
//                   color2,
//                 ],
//               ),
//             ),
//             child: Column(
//               children: [
//
//                 Row(
//                   children: [
//
//                     Container(
//                       padding: EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(.2),
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                       child: Icon(
//                         icon,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                     ),
//
//                     SizedBox(width: 16),
//
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//
//                           Text(
//                             title,
//                             style:  TextStyle(
//                               color: Colors.white,
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 6),
//
//                           Text(
//                             subtitle,
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(.92),
//                               fontSize: 16,
//                               height: 1.4,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 22),
//                 Row(
//                   children: [
//                     Text(
//                       "Levels: $levels",
//                       style:  TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(width: 26),
//                     Text(
//                       "Duration: $duration",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // BENEFITS SECTION
//           Padding(
//             padding:  EdgeInsets.all(20),
//             child: Column(
//               children: [
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children:  [
//                     Text(
//                       "Key Benefits",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//
//                     Icon(Icons.keyboard_arrow_up_rounded),
//                   ],
//                 ),
//                 SizedBox(height: 18),
//
//                 Column(
//                   children: benefits.map((e) {
//                     return Padding(
//                       padding: EdgeInsets.only(bottom: 16),
//                       child: Row(
//                         children: [
//
//                           Container(
//                             height: 12,
//                             width: 12,
//                             decoration:  BoxDecoration(
//                               color: Color(0xff22C55E),
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                           SizedBox(width: 14),
//                           Expanded(
//                             child: Text(
//                               e,
//                               style:  TextStyle(
//                                 fontSize: 17,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ),
//                 SizedBox(height: 10),
//
//                 // VIDEO BOX
//                 Container(
//                   height: 220,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Color(0xff06122F),
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   child: Center(
//                     child: Icon(
//                       Icons.play_arrow_rounded,
//                       color: Colors.white,
//                       size: 70,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // BOTTOM NAV ITEM
// class BottomItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool isSelected;
//
//   const BottomItem({
//     super.key,
//     required this.icon,
//     required this.label,
//     this.isSelected = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           icon,
//           color: isSelected
//               ? Colors.blue
//               : Colors.grey,
//         ),
//         SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             color: isSelected
//                 ? Colors.blue
//                 : Colors.grey,
//             fontSize: 13,
//           ),
//         ),
//       ],
//     );
//   }
// }
// class YoutubeVideoBox extends StatefulWidget {
//   const YoutubeVideoBox({super.key});
//
//   @override
//   State<YoutubeVideoBox> createState() => _YoutubeVideoBoxState();
// }
//
// class _YoutubeVideoBoxState extends State<YoutubeVideoBox> {
//
//   late YoutubePlayerController controller;
//
//   @override
//   void initState() {
//     super.initState();
//
//     controller = YoutubePlayerController(
//       initialVideoId: 'dQw4w9WgXcQ',
//       flags: const YoutubePlayerFlags(
//         autoPlay: false,
//         mute: false,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(24),
//       child: YoutubePlayer(
//         controller: controller,
//         showVideoProgressIndicator: true,
//       ),
//     );
//   }
// }