import 'package:flutter_test/flutter_test.dart';
import 'package:civic_id/models/user_profile.dart';
import 'package:civic_id/models/document.dart';
import 'package:civic_id/models/government_service.dart';
import 'package:civic_id/models/application.dart';
import 'package:civic_id/utils/checkers.dart';

void main() {
  group('CompletenessChecker Tests', () {
    final mockService = GovernmentService(
      id: 'passport',
      name: 'Passport',
      category: 'Home Affairs',
      description: 'Passport application',
      requiredDocumentTypes: ['Identity Document', 'Proof of Address'],
    );

    test('Should detect incomplete application when documents missing', () {
      final documents = [
        Document(id: '1', type: 'Identity Document', name: 'ID Card', status: 'Verified', expiryDate: DateTime(2030, 1, 1), isRequired: true),
      ];

      final app = Application(
        id: 'app1',
        referenceNumber: 'REF1',
        serviceId: 'passport',
        status: 'Draft',
        submissionDate: DateTime.now(),
        data: {'name': 'John Doe'},
        statusHistory: [],
      );

      final isComplete = CompletenessChecker.isApplicationComplete(
        application: app,
        service: mockService,
        userDocuments: documents,
      );
      
      expect(isComplete, isFalse); // Missing Proof of Address
    });

    test('Should return true when all documents verified', () {
      final documents = [
        Document(id: '1', type: 'Identity Document', name: 'ID Card', status: 'Verified', expiryDate: DateTime(2030, 1, 1), isRequired: true),
        Document(id: '2', type: 'Proof of Address', name: 'Bill', status: 'Verified', expiryDate: DateTime(2030, 1, 1), isRequired: true),
      ];

      final app = Application(
        id: 'app1',
        referenceNumber: 'REF1',
        serviceId: 'passport',
        status: 'Draft',
        submissionDate: DateTime.now(),
        data: {'name': 'John Doe'},
        statusHistory: [],
      );

      final isComplete = CompletenessChecker.isApplicationComplete(
        application: app,
        service: mockService,
        userDocuments: documents,
      );
      
      expect(isComplete, isTrue);
    });
  });

  group('ConsistencyChecker Tests', () {
    final mockProfile = UserProfile(
      name: 'John Doe',
      dob: '1990-01-01',
      idNumber: '9001015000081',
      nationality: 'South African',
      gender: 'Male',
      phone: '0123456789',
      email: 'john@example.com',
      address: '123 Test St',
    );

    test('Should detect name inconsistency', () {
      final app = Application(
        id: 'app1',
        referenceNumber: 'REF1',
        serviceId: 'passport',
        status: 'Draft',
        submissionDate: DateTime.now(),
        data: {'name': 'Jon Doe'},
        statusHistory: [],
      );
      
      final inconsistencies = ConsistencyChecker.compareWithProfile(
        application: app,
        profile: mockProfile,
      );
      expect(inconsistencies, contains('Name does not match profile'));
    });

    test('Should return empty list when data matches', () {
      final app = Application(
        id: 'app1',
        referenceNumber: 'REF1',
        serviceId: 'passport',
        status: 'Draft',
        submissionDate: DateTime.now(),
        data: {'name': 'John Doe'},
        statusHistory: [],
      );
      
      final inconsistencies = ConsistencyChecker.compareWithProfile(
        application: app,
        profile: mockProfile,
      );
      expect(inconsistencies, isEmpty);
    });
  });
}
