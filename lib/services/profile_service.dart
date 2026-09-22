import 'mock_data.dart';
import '../models/user_profile.dart';

class ProfileService {
  final MockData _mockData = MockData();

  Future<UserProfile> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockData.userProfile;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockData.userProfile = profile;
  }
}
