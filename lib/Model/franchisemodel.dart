import 'package:flutter/material.dart';

class FranchiseFormModel {
  final String ownerName;
  final String email;
  final String phone;
  final String centerName;
  final String city;
  final String experience;
  final bool isAccepted;

  FranchiseFormModel({
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.centerName,
    required this.city,
    required this.experience,
    required this.isAccepted,
  });

  // FROM JSON
  factory FranchiseFormModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return FranchiseFormModel(
      ownerName: json['ownerName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      centerName: json['centerName'] ?? '',
      city: json['city'] ?? '',
      experience: json['experience'] ?? '',
      isAccepted: json['isAccepted'] ?? false,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'centerName': centerName,
      'city': city,
      'experience': experience,
      'isAccepted': isAccepted,
    };
  }

  // COPY WITH
  FranchiseFormModel copyWith({
    String? ownerName,
    String? email,
    String? phone,
    String? centerName,
    String? city,
    String? experience,
    bool? isAccepted,
  }) {
    return FranchiseFormModel(
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      centerName:
      centerName ?? this.centerName,
      city: city ?? this.city,
      experience:
      experience ?? this.experience,
      isAccepted:
      isAccepted ?? this.isAccepted,
    );
  }
}

// ================= SAMPLE LIST =================

List<FranchiseFormModel>
franchiseFormList = [
  FranchiseFormModel(
    ownerName: "Piyush Gill",
    email: "piyush@gmail.com",
    phone: "9876543210",
    centerName: "Gill Education Center",
    city: "Delhi",
    experience:
    "3 years experience in coaching and education business",
    isAccepted: true,
  ),

  FranchiseFormModel(
    ownerName: "Rahul Sharma",
    email: "rahul@gmail.com",
    phone: "9876543211",
    centerName: "Bright Future Academy",
    city: "Mumbai",
    experience:
    "5 years experience in school management",
    isAccepted: true,
  ),

  FranchiseFormModel(
    ownerName: "Aman Verma",
    email: "aman@gmail.com",
    phone: "9876543212",
    centerName: "Success Point Institute",
    city: "Jaipur",
    experience:
    "Worked with multiple training institutes",
    isAccepted: false,
  ),
];