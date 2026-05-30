import 'package:flutter/material.dart';

class DistributorFormModel {
  final String fullName;
  final String email;
  final String phone;
  final String city;
  final String businessExperience;
  final bool isAccepted;

  DistributorFormModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.businessExperience,
    required this.isAccepted,
  });

  // FROM JSON
  factory DistributorFormModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return DistributorFormModel(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      city: json['city'] ?? '',
      businessExperience:
      json['businessExperience'] ?? '',
      isAccepted: json['isAccepted'] ?? false,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'city': city,
      'businessExperience':
      businessExperience,
      'isAccepted': isAccepted,
    };
  }

  // COPY WITH
  DistributorFormModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? city,
    String? businessExperience,
    bool? isAccepted,
  }) {
    return DistributorFormModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      businessExperience:
      businessExperience ??
          this.businessExperience,
      isAccepted:
      isAccepted ?? this.isAccepted,
    );
  }
}