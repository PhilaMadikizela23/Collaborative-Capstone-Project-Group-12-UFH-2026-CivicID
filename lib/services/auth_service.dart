import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_service.dart';

class AuthService {
  final ProfileService _profileService = ProfileService();

  static const String _baseUrl = String.fromEnvironment(
    'CIVICID_API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static String? _lastRole;

  Future<bool> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        return false;
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();

      final String role = data['role'].toString();

      _lastRole = role;

      await prefs.setString(
        'civicid_access_token',
        data['accessToken'].toString(),
      );

      await prefs.setString(
        'civicid_token_type',
        data['tokenType'].toString(),
      );

      await prefs.setString(
        'civicid_role',
        role,
      );

      await prefs.setString(
        'civicid_email',
        data['email'].toString(),
      );

      if (data['userId'] is num) {
        await prefs.setInt(
          'civicid_user_id',
          (data['userId'] as num).toInt(),
        );
      }

      if (data['expiresAt'] != null) {
        await prefs.setString(
          'civicid_token_expires_at',
          data['expiresAt'].toString(),
        );
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  bool isAdmin(
    String email,
  ) {
    return _lastRole == 'ADMIN';
  }

  Future<void> register({
    required String name,
    required String surname,
    required String email,
    required String password,
    required String idNumber,
    required String dob,
    String phone = '',
    String gender = '',
  }) async {
    await Future.delayed(
      const Duration(seconds: 1),
    );

    final currentProfile =
        await _profileService.getProfile();

    final updatedProfile =
        currentProfile.copyWith(
      name: '$name $surname',
      email: email.trim(),
      idNumber: idNumber.trim(),
      dob: dob.trim(),
      phone: phone.trim(),
      gender: gender.trim(),
    );

    await _profileService.updateProfile(
      updatedProfile,
    );
  }

  Future<void> sendResetCode(
    String email,
  ) async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  Future<bool> verifyResetCode(
    String email,
    String code,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    return code == '1234';
  }

  Future<void> updatePassword(
    String email,
    String newPassword,
  ) async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('civicid_access_token');
    await prefs.remove('civicid_token_type');
    await prefs.remove('civicid_role');
    await prefs.remove('civicid_email');
    await prefs.remove('civicid_user_id');
    await prefs.remove('civicid_token_expires_at');

    _lastRole = null;
  }
}