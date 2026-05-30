import 'package:flutter/material.dart';

class ProfileModel {
  final String fullName;
  final String shortName;
  final String role;
  final String email;
  final String phone;
  final bool hasNotification;

  ProfileModel({
    required this.fullName,
    required this.shortName,
    required this.role,
    required this.email,
    required this.phone,
    required this.hasNotification,
  });

  // FROM JSON
  factory ProfileModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProfileModel(
      fullName: json['fullName'] ?? '',
      shortName: json['shortName'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      hasNotification:
      json['hasNotification'] ?? false,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'shortName': shortName,
      'role': role,
      'email': email,
      'phone': phone,
      'hasNotification':
      hasNotification,
    };
  }

  // COPY WITH
  ProfileModel copyWith({
    String? fullName,
    String? shortName,
    String? role,
    String? email,
    String? phone,
    bool? hasNotification,
  }) {
    return ProfileModel(
      fullName:
      fullName ?? this.fullName,
      shortName:
      shortName ?? this.shortName,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hasNotification:
      hasNotification ??
          this.hasNotification,
    );
  }
}