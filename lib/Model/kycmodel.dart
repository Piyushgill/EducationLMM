
class KycModel {
  final String aadhaarNumber;
  final String aadhaarFrontImage;
  final String aadhaarBackImage;
  final String panNumber;
  final String panCardImage;
  final String selfieImage;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final int currentStep;

  KycModel({
    required this.aadhaarNumber,
    required this.aadhaarFrontImage,
    required this.aadhaarBackImage,
    required this.panNumber,
    required this.panCardImage,
    required this.selfieImage,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.currentStep,
  });

  // FROM JSON
  factory KycModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return KycModel(
      aadhaarNumber:
      json['aadhaarNumber'] ?? '',
      aadhaarFrontImage:
      json['aadhaarFrontImage'] ?? '',
      aadhaarBackImage:
      json['aadhaarBackImage'] ?? '',
      panNumber: json['panNumber'] ?? '',
      panCardImage:
      json['panCardImage'] ?? '',
      selfieImage:
      json['selfieImage'] ?? '',
      accountNumber:
      json['accountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      bankName: json['bankName'] ?? '',
      currentStep:
      json['currentStep'] ?? 0,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'aadhaarNumber': aadhaarNumber,
      'aadhaarFrontImage':
      aadhaarFrontImage,
      'aadhaarBackImage':
      aadhaarBackImage,
      'panNumber': panNumber,
      'panCardImage': panCardImage,
      'selfieImage': selfieImage,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'currentStep': currentStep,
    };
  }

  // COPY WITH
  KycModel copyWith({
    String? aadhaarNumber,
    String? aadhaarFrontImage,
    String? aadhaarBackImage,
    String? panNumber,
    String? panCardImage,
    String? selfieImage,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    int? currentStep,
  }) {
    return KycModel(
      aadhaarNumber:
      aadhaarNumber ??
          this.aadhaarNumber,
      aadhaarFrontImage:
      aadhaarFrontImage ??
          this.aadhaarFrontImage,
      aadhaarBackImage:
      aadhaarBackImage ??
          this.aadhaarBackImage,
      panNumber:
      panNumber ?? this.panNumber,
      panCardImage:
      panCardImage ??
          this.panCardImage,
      selfieImage:
      selfieImage ??
          this.selfieImage,
      accountNumber:
      accountNumber ??
          this.accountNumber,
      ifscCode:
      ifscCode ?? this.ifscCode,
      bankName:
      bankName ?? this.bankName,
      currentStep:
      currentStep ??
          this.currentStep,
    );
  }
}