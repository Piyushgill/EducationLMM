import 'package:flutter/material.dart';

class DemoVideoModel {
  final String title;
  final String description;
  final String videoThumbnail;
  final String buttonTitle;

  DemoVideoModel({
    required this.title,
    required this.description,
    required this.videoThumbnail,
    required this.buttonTitle,
  });

  // FROM JSON
  factory DemoVideoModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return DemoVideoModel(
      title: json['title'] ?? '',
      description:
      json['description'] ?? '',
      videoThumbnail:
      json['videoThumbnail'] ?? '',
      buttonTitle:
      json['buttonTitle'] ?? '',
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'videoThumbnail':
      videoThumbnail,
      'buttonTitle': buttonTitle,
    };
  }

  // COPY WITH
  DemoVideoModel copyWith({
    String? title,
    String? description,
    String? videoThumbnail,
    String? buttonTitle,
  }) {
    return DemoVideoModel(
      title: title ?? this.title,
      description:
      description ??
          this.description,
      videoThumbnail:
      videoThumbnail ??
          this.videoThumbnail,
      buttonTitle:
      buttonTitle ??
          this.buttonTitle,
    );
  }
}

// ================= FEATURE MODEL =================

class DemoFeatureModel {
  final String title;
  final String subtitle;
  final IconData icon;

  DemoFeatureModel({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  // FROM JSON
  factory DemoFeatureModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return DemoFeatureModel(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      icon: IconData(
        json['icon'] ??
            Icons.error.codePoint,
        fontFamily: 'MaterialIcons',
      ),
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'icon': icon.codePoint,
    };
  }

  // COPY WITH
  DemoFeatureModel copyWith({
    String? title,
    String? subtitle,
    IconData? icon,
  }) {
    return DemoFeatureModel(
      title: title ?? this.title,
      subtitle:
      subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
    );
  }
}

// ================= DEMO DATA =================

DemoVideoModel demoVideoData =
DemoVideoModel(
  title: "Watch Demo",
  description:
  "Explore our learning programs through demo classes and videos.",
  videoThumbnail:
  "https://images.unsplash.com/photo-1509062522246-3755977927d7",
  buttonTitle: "Watch Full Demo",
);

// ================= FEATURE LIST =================

List<DemoFeatureModel> demoFeatureList = [
  DemoFeatureModel(
    icon: Icons.play_circle_outline_rounded,
    title: "Interactive Learning",
    subtitle:
    "Engaging live learning sessions",
  ),

  DemoFeatureModel(
    icon: Icons.school_outlined,
    title: "Expert Trainers",
    subtitle:
    "Learn from experienced mentors",
  ),

  DemoFeatureModel(
    icon: Icons.workspace_premium_outlined,
    title: "Premium Curriculum",
    subtitle:
    "Industry-leading education system",
  ),
];