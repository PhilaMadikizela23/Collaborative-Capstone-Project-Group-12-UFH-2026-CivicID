import 'profile_service.dart';

class AuthService {
  final ProfileService _profileService =
  ProfileService();

  static const String _adminEmail =
      'admin@civicid.app';

  static const String _adminPassword =
      'admin123';

  // ============================================================
  // LOGIN
  // ============================================================

  Future<bool> login(
      String email,
      String password,
      ) async {
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );

    final String cleanEmail =
    email.trim().toLowerCase();

    // ADMIN LOGIN
    if (cleanEmail == _adminEmail) {
      return password == _adminPassword;
    }

    // MOCK CITIZEN LOGIN
    return cleanEmail.isNotEmpty &&
        password.isNotEmpty;
  }

  // ============================================================
  // ADMIN CHECK
  // ============================================================

  bool isAdmin(
      String email,
      ) {
    return email.trim().toLowerCase() ==
        _adminEmail;
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> register({
    required String name,
    required String surname,
    required String email,
    required String password,
    required String idNumber,
    required String dob,

    // PHONE + GENDER
    String phone = '',
    String gender = '',
  }) async {
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );

    final currentProfile =
    await _profileService.getProfile();

    final updatedProfile =
    currentProfile.copyWith(
      name:
      '$name $surname',

      email:
      email.trim(),

      idNumber:
      idNumber.trim(),

      dob:
      dob.trim(),

      phone:
      phone.trim(),

      gender:
      gender.trim(),
    );

    await _profileService.updateProfile(
      updatedProfile,
    );
  }

  // ============================================================
  // PASSWORD RESET
  // ============================================================

  Future<void> sendResetCode(
      String email,
      ) async {
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );

    // Prototype only.
  }

  Future<bool> verifyResetCode(
      String email,
      String code,
      ) async {
    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );

    return code == '1234';
  }

  Future<void> updatePassword(
      String email,
      String newPassword,
      ) async {
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );

    // Prototype only.
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );
  }
}