import 'package:flutter/material.dart';

class JoinUsModel {
  final String role;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final bool isTermsAccepted;

  JoinUsModel({
    required this.role,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.isTermsAccepted,
  });

  // FROM JSON
  factory JoinUsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return JoinUsModel(
      role: json['role'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
      isTermsAccepted:
      json['isTermsAccepted'] ?? false,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'isTermsAccepted':
      isTermsAccepted,
    };
  }

  // COPY WITH
  JoinUsModel copyWith({
    String? role,
    String? fullName,
    String? email,
    String? phone,
    String? password,
    bool? isTermsAccepted,
  }) {
    return JoinUsModel(
      role: role ?? this.role,
      fullName:
      fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password:
      password ?? this.password,
      isTermsAccepted:
      isTermsAccepted ??
          this.isTermsAccepted,
    );
  }
}