import '../models/user_profile.dart';
import '../models/document.dart';
import '../models/government_service.dart';
import '../models/application.dart';
import '../models/notification.dart';
import '../models/audit_event.dart';
import '../models/appointment.dart';

class MockData {
  static final MockData _instance = MockData._internal();
  factory MockData() => _instance;
  MockData._internal();

  UserProfile userProfile = UserProfile(
    name: "John Doe",
    dob: "1990-01-01",
    idNumber: "9001015000081",
    nationality: "South African",
    gender: "Male",
    phone: "+27 12 345 6789",
    email: "john.doe@example.com",
    address: "123 Main Street, Pretoria, 0001",
    isVerified: false,
  );

  List<Document> documents = [
    Document(
      id: "DOC001",
      type: "Identity Document",
      name: "National ID Card",
      status: "Verified",
      expiryDate: DateTime(2030, 12, 31),
      isRequired: true,
    ),
    Document(
      id: "DOC002",
      type: "Proof of Residence",
      name: "Utility Bill",
      status: "Verified",
      expiryDate: DateTime(2026, 06, 30),
      isRequired: true,
    ),
    Document(
      id: "DOC003",
      type: "Academic Certificate",
      name: "BSc Computer Science",
      status: "Verified",
      isRequired: false,
    ),
  ];

  List<GovernmentService> services = [
    GovernmentService(
      id: "SRV001",
      name: "Smart ID Application",
      category: "Home Affairs",
      description: "Apply for or manage your Smart ID.",
      requiredDocumentTypes: ["Identity Document", "Proof of Residence"],
    ),
    GovernmentService(
      id: "SRV002",
      name: "Passport",
      category: "Home Affairs",
      description: "Apply or renew your passport.",
      requiredDocumentTypes: ["Identity Document", "Passport Photo"],
    ),
    GovernmentService(
      id: "SRV003",
      name: "Driver's Licence",
      category: "Transport",
      description: "Renew your driver's licence.",
      requiredDocumentTypes: ["Identity Document", "Eye Test Result"],
    ),
    GovernmentService(
      id: "SRV004",
      name: "Birth Certificate",
      category: "Home Affairs",
      description: "Apply for a birth certificate.",
      requiredDocumentTypes: ["Identity Document", "Parents' Details"],
    ),
  ];

  List<Application> applications = [
    Application(
      id: "APP001",
      referenceNumber: "CID-2026-88123",
      serviceId: "SRV001",
      status: "Submitted",
      submissionDate: DateTime.now().subtract(const Duration(days: 2)),
      data: {"name": "Phila Madikizela", "idNumber": "1234567890123"},
      statusHistory: [
        StatusHistoryItem(status: "Draft", timestamp: DateTime.now().subtract(const Duration(days: 3))),
        StatusHistoryItem(status: "Submitted", timestamp: DateTime.now().subtract(const Duration(days: 2))),
      ],
    ),
  ];

  List<Appointment> appointments = [];

  List<AppNotification> notifications = [
    AppNotification(
      id: "NOT001",
      title: "Welcome to CivicID",
      message: "Your account has been successfully created.",
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    AppNotification(
      id: "NOT002",
      title: "Document Verified",
      message: "Your National ID Card has been verified.",
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    AppNotification(
      id: "NOT003",
      title: "Application Status Update",
      message: "Your Passport Renewal application is now Under Review.",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
  ];

  List<AuditEvent> auditEvents = [
    AuditEvent(
      id: "AUD001",
      eventType: "Login successful",
      description: "User logged in from device Pixel 6",
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    AuditEvent(
      id: "AUD002",
      eventType: "Profile updated",
      description: "User updated contact phone number",
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
    ),
    AuditEvent(
      id: "AUD003",
      eventType: "Document added",
      description: "New document 'Utility Bill' uploaded",
      timestamp: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    AuditEvent(
      id: "AUD004",
      eventType: "Application submitted",
      description: "Smart ID Application submitted successfully",
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];
}
