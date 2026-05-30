import 'package:flutter/material.dart';

class ProgramModel {
  final String title;
  final String subtitle;
  final String levels;
  final String duration;
  final Color color1;
  final Color color2;
  final IconData icon;
  final List<String> benefits;

  ProgramModel({
    required this.title,
    required this.subtitle,
    required this.levels,
    required this.duration,
    required this.color1,
    required this.color2,
    required this.icon,
    required this.benefits,
  });

  // FROM JSON
  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      levels: json['levels'] ?? '',
      duration: json['duration'] ?? '',
      color1: Color(json['color1'] ?? 0xffffffff),
      color2: Color(json['color2'] ?? 0xffffffff),
      icon: IconData(
        json['icon'] ?? Icons.error.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      benefits: List<String>.from(
        json['benefits'] ?? [],
      ),
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'levels': levels,
      'duration': duration,
      'color1': color1.value,
      'color2': color2.value,
      'icon': icon.codePoint,
      'benefits': benefits,
    };
  }

  // COPY WITH
  ProgramModel copyWith({
    String? title,
    String? subtitle,
    String? levels,
    String? duration,
    Color? color1,
    Color? color2,
    IconData? icon,
    List<String>? benefits,
  }) {
    return ProgramModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      levels: levels ?? this.levels,
      duration: duration ?? this.duration,
      color1: color1 ?? this.color1,
      color2: color2 ?? this.color2,
      icon: icon ?? this.icon,
      benefits: benefits ?? this.benefits,
    );
  }
}

// ================= PROGRAM LIST =================

List<ProgramModel> programList = [
  ProgramModel(
    title: "Abacus",
    subtitle: "Develop exceptional mental math abilities",
    levels: "8",
    duration: "4 Years",
    color1: const Color(0xff2563EB),
    color2: const Color(0xffE5E7EB),
    icon: Icons.calculate_rounded,
    benefits: [
      "Improves concentration",
      "Enhances calculation speed",
      "Boosts confidence",
      "Develops both brain hemispheres",
    ],
  ),

  ProgramModel(
    title: "Vedic Maths",
    subtitle: "Learn fast calculation techniques",
    levels: "8",
    duration: "4 Years",
    color1: const Color(0xff7C3AED),
    color2: const Color(0xffC4B5FD),
    icon: Icons.plus_one,
    benefits: [
      "Improves concentration",
      "Enhances calculation speed",
      "Boosts confidence",
      "Develops both brain hemispheres",
    ],
  ),

  ProgramModel(
    title: "Phonics",
    subtitle: "Build strong reading foundation",
    levels: "5",
    duration: "1.5 Years",
    color1: const Color(0xff16A34A),
    color2: const Color(0xff059669),
    icon: Icons.mic_none_rounded,
    benefits: [
      "Improves reading skills",
      "Develops pronunciation",
      "Builds vocabulary",
      "Boosts confidence",
    ],
  ),

  ProgramModel(
    title: "English",
    subtitle: "Enhance communication skills",
    levels: "5",
    duration: "1.5 Years",
    color1: const Color(0xffEA580C),
    color2: const Color(0xffFB923C),
    icon: Icons.language_rounded,
    benefits: [
      "Improves grammar",
      "Enhances communication",
      "Builds vocabulary",
      "Boosts confidence",
    ],
  ),
];