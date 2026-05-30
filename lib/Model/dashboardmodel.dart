import 'package:flutter/material.dart';

class JoinModel {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;

  JoinModel({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });

  // FROM JSON
  factory JoinModel.fromJson(Map<String, dynamic> json) {
    return JoinModel(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      gradient: (json['gradient'] as List)
          .map((e) => Color(e))
          .toList(),
      icon: IconData(
        json['icon'] ?? Icons.error.codePoint,
        fontFamily: 'MaterialIcons',
      ),
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'gradient':
      gradient.map((e) => e.value).toList(),
      'icon': icon.codePoint,
    };
  }

  // COPY WITH
  JoinModel copyWith({
    String? title,
    String? subtitle,
    List<Color>? gradient,
    IconData? icon,
  }) {
    return JoinModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      gradient: gradient ?? this.gradient,
      icon: icon ?? this.icon,
    );
  }
}

// ================= JOIN LIST =================

List<JoinModel> joinList = [
  JoinModel(
    title: "Distributor",
    subtitle: "Build & manage networks",
    gradient: [
      const Color(0xff60A5FA),
      const Color(0xff2563EB),
    ],
    icon: Icons.trending_up_rounded,
  ),

  JoinModel(
    title: "Franchise Partner",
    subtitle: "Run education center",
    gradient: [
      const Color(0xffC084FC),
      const Color(0xffA855F7),
    ],
    icon: Icons.school_rounded,
  ),

  JoinModel(
    title: "School",
    subtitle: "Integrate programs",
    gradient: [
      const Color(0xff22C55E),
      const Color(0xff00B63E),
    ],
    icon: Icons.apartment_rounded,
  ),
];


// ================= PROGRAM MODEL =================

class HomeProgramModel {
  final String image;
  final String title;

  HomeProgramModel({
    required this.image,
    required this.title,
  });

  // FROM JSON
  factory HomeProgramModel.fromJson(
      Map<String, dynamic> json) {
    return HomeProgramModel(
      image: json['image'] ?? '',
      title: json['title'] ?? '',
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
    };
  }

  // COPY WITH
  HomeProgramModel copyWith({
    String? image,
    String? title,
  }) {
    return HomeProgramModel(
      image: image ?? this.image,
      title: title ?? this.title,
    );
  }
}

// ================= PROGRAM LIST =================

List<HomeProgramModel> homeProgramList = [
  HomeProgramModel(
    image:
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS7qqRHwPNe6A_GUXSWGJN3aO6w5sCdylhgHg&s",
    title: "Abacus",
  ),

  HomeProgramModel(
    image:
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6FdUuNQdRwiCwvggqHWGYIUhlnJ9vQr9alTdD8qjTrQ&s",
    title: "Vedic Maths",
  ),

  HomeProgramModel(
    image:
    "https://cdn-icons-png.flaticon.com/512/2436/2436636.png",
    title: "Phonics",
  ),

  HomeProgramModel(
    image:
    "https://cdn-icons-png.flaticon.com/512/3898/3898150.png",
    title: "English",
  ),
];

// ================= STATS MODEL =================

class StatsModel {
  final String number;
  final String label;

  StatsModel({
    required this.number,
    required this.label,
  });

  // FROM JSON
  factory StatsModel.fromJson(
      Map<String, dynamic> json) {
    return StatsModel(
      number: json['number'] ?? '',
      label: json['label'] ?? '',
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'label': label,
    };
  }

  // COPY WITH
  StatsModel copyWith({
    String? number,
    String? label,
  }) {
    return StatsModel(
      number: number ?? this.number,
      label: label ?? this.label,
    );
  }
}

// ================= STATS LIST =================

List<StatsModel> statsList = [
  StatsModel(
    number: "10K+",
    label: "Students",
  ),

  StatsModel(
    number: "500+",
    label: "Centers",
  ),

  StatsModel(
    number: "98%",
    label: "Success",
  ),
];