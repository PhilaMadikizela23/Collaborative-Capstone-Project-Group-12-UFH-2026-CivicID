class UserProfile {
  final String name;
  final String dob;
  final String idNumber;
  final String nationality;
  final String gender;
  final String phone;
  final String email;
  final String address;
  final bool isVerified;

  // Registration identity verification
  final String? registrationSelfieBase64;
  final String identityVerificationStatus;
  final String? identityVerificationComment;
  final String? identityVerifiedBy;
  final DateTime? identityVerifiedAt;

  const UserProfile({
    required this.name,
    required this.dob,
    required this.idNumber,
    required this.nationality,
    required this.gender,
    required this.phone,
    required this.email,
    required this.address,
    this.isVerified = false,
    this.registrationSelfieBase64,
    this.identityVerificationStatus = 'Not Submitted',
    this.identityVerificationComment,
    this.identityVerifiedBy,
    this.identityVerifiedAt,
  });

  // ============================================================
  // PROFILE COMPLETION
  // ============================================================

  double get calculatedCompletion {
    const int totalFields = 8;

    int filledFields = 0;

    if (name.trim().isNotEmpty) {
      filledFields++;
    }

    if (dob.trim().isNotEmpty) {
      filledFields++;
    }

    if (idNumber.trim().isNotEmpty) {
      filledFields++;
    }

    if (nationality.trim().isNotEmpty) {
      filledFields++;
    }

    if (gender.trim().isNotEmpty) {
      filledFields++;
    }

    if (phone.trim().isNotEmpty) {
      filledFields++;
    }

    if (email.trim().isNotEmpty) {
      filledFields++;
    }

    if (address.trim().isNotEmpty) {
      filledFields++;
    }

    return filledFields / totalFields;
  }

  int get completionPercentage {
    return (calculatedCompletion * 100).round();
  }

  bool get isComplete {
    return calculatedCompletion == 1.0;
  }

  bool get hasRegistrationSelfie {
    return registrationSelfieBase64 != null &&
        registrationSelfieBase64!.trim().isNotEmpty;
  }

  bool get identityPending {
    return identityVerificationStatus == 'Pending Verification';
  }

  bool get identityRejected {
    return identityVerificationStatus == 'Rejected';
  }

  bool get identityNeedsMoreInformation {
    return identityVerificationStatus == 'More Information Required';
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  UserProfile copyWith({
    String? name,
    String? dob,
    String? idNumber,
    String? nationality,
    String? gender,
    String? phone,
    String? email,
    String? address,
    bool? isVerified,
    String? registrationSelfieBase64,
    String? identityVerificationStatus,
    String? identityVerificationComment,
    String? identityVerifiedBy,
    DateTime? identityVerifiedAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      idNumber: idNumber ?? this.idNumber,
      nationality: nationality ?? this.nationality,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      isVerified: isVerified ?? this.isVerified,
      registrationSelfieBase64:
      registrationSelfieBase64 ?? this.registrationSelfieBase64,
      identityVerificationStatus:
      identityVerificationStatus ?? this.identityVerificationStatus,
      identityVerificationComment:
      identityVerificationComment ?? this.identityVerificationComment,
      identityVerifiedBy:
      identityVerifiedBy ?? this.identityVerifiedBy,
      identityVerifiedAt:
      identityVerifiedAt ?? this.identityVerifiedAt,
    );
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory UserProfile.fromMap(
      Map<String, dynamic> map,
      ) {
    DateTime? verifiedAt;

    final rawVerifiedAt = map['identityVerifiedAt'];

    if (rawVerifiedAt is DateTime) {
      verifiedAt = rawVerifiedAt;
    } else if (rawVerifiedAt != null) {
      verifiedAt = DateTime.tryParse(
        rawVerifiedAt.toString(),
      );
    }

    return UserProfile(
      name: map['name']?.toString() ?? '',
      dob: map['dob']?.toString() ?? '',
      idNumber: map['idNumber']?.toString() ?? '',
      nationality: map['nationality']?.toString() ?? '',
      gender: map['gender']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      isVerified: map['isVerified'] == true,
      registrationSelfieBase64:
      map['registrationSelfieBase64']?.toString(),
      identityVerificationStatus:
      map['identityVerificationStatus']?.toString() ??
          'Not Submitted',
      identityVerificationComment:
      map['identityVerificationComment']?.toString(),
      identityVerifiedBy:
      map['identityVerifiedBy']?.toString(),
      identityVerifiedAt: verifiedAt,
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dob': dob,
      'idNumber': idNumber,
      'nationality': nationality,
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'isVerified': isVerified,
      'registrationSelfieBase64': registrationSelfieBase64,
      'identityVerificationStatus': identityVerificationStatus,
      'identityVerificationComment': identityVerificationComment,
      'identityVerifiedBy': identityVerifiedBy,
      'identityVerifiedAt': identityVerifiedAt?.toIso8601String(),
    };
  }

  // ============================================================
  // BASIC HELPERS
  // ============================================================

  bool get hasEmail => email.trim().isNotEmpty;
  bool get hasPhone => phone.trim().isNotEmpty;
  bool get hasAddress => address.trim().isNotEmpty;
  bool get hasIdNumber => idNumber.trim().isNotEmpty;

  // ============================================================
  // DISPLAY
  // ============================================================

  @override
  String toString() {
    return 'UserProfile('
        'name: $name, '
        'email: $email, '
        'isVerified: $isVerified, '
        'identityStatus: $identityVerificationStatus, '
        'completion: $completionPercentage%'
        ')';
  }
}
