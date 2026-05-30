import 'package:flutter/material.dart';

class SchoolJoinModel {
  final String schoolName;
  final String principalName;
  final String email;
  final String phone;
  final String address;
  final String totalStudents;
  final bool isAccepted;

  SchoolJoinModel({
    required this.schoolName,
    required this.principalName,
    required this.email,
    required this.phone,
    required this.address,
    required this.totalStudents,
    required this.isAccepted,
  });

  // FROM JSON
  factory SchoolJoinModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return SchoolJoinModel(
      schoolName: json['schoolName'] ?? '',
      principalName:
      json['principalName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      totalStudents:
      json['totalStudents'] ?? '',
      isAccepted:
      json['isAccepted'] ?? false,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'schoolName': schoolName,
      'principalName': principalName,
      'email': email,
      'phone': phone,
      'address': address,
      'totalStudents': totalStudents,
      'isAccepted': isAccepted,
    };
  }

  // COPY WITH
  SchoolJoinModel copyWith({
    String? schoolName,
    String? principalName,
    String? email,
    String? phone,
    String? address,
    String? totalStudents,
    bool? isAccepted,
  }) {
    return SchoolJoinModel(
      schoolName:
      schoolName ?? this.schoolName,
      principalName:
      principalName ??
          this.principalName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      totalStudents:
      totalStudents ??
          this.totalStudents,
      isAccepted:
      isAccepted ?? this.isAccepted,
    );
  }
}
