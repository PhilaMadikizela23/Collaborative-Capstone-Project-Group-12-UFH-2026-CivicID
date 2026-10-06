import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_data.dart';
import '../models/application.dart';

class ApplicationService {
  final MockData _mockData = MockData();

  static const String _baseUrl = String.fromEnvironment(
    'CIVICID_API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  Future<List<Application>> getApplications() async {
    final token = await _accessToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/applications'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load applications: ${response.body}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Invalid applications response.');
    }

    return decoded
        .map(
          (item) => _fromSummary(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<Application> createApplication(
    String serviceId,
    Map<String, dynamic> data,
  ) async {
    final token = await _accessToken();

    final int backendServiceId =
        _backendServiceId(serviceId);

    final profileResponse = await http.get(
      Uri.parse('$_baseUrl/api/citizens/me/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (profileResponse.statusCode != 200) {
      throw Exception(
        'Complete your citizen profile before starting an application.',
      );
    }

    final Map<String, dynamic> profile =
        jsonDecode(profileResponse.body)
            as Map<String, dynamic>;

    final createResponse = await http.post(
      Uri.parse('$_baseUrl/api/applications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'serviceId': backendServiceId,
      }),
    );

    if (createResponse.statusCode != 201) {
      throw Exception(
        'Unable to create application: ${createResponse.body}',
      );
    }

    Map<String, dynamic> detail =
        jsonDecode(createResponse.body)
            as Map<String, dynamic>;

    if (serviceId == 'SRV002') {
      final String localPhone =
          (data['phone'] ?? '')
              .toString()
              .trim();

      final String profilePhone =
          (profile['phoneNumber'] ?? '')
              .toString()
              .trim();
              final String localAddress =
    (data['address'] ?? '')
        .toString()
        .trim();

final String profileAddress = [
  profile['addressLine1'],
  profile['addressLine2'],
  profile['city'],
  profile['province'],
  profile['postalCode'],
]
    .where(
      (value) =>
          value != null &&
          value.toString().trim().isNotEmpty,
    )
    .map(
      (value) => value.toString().trim(),
    )
    .join(', ');
      final application =
          Map<String, dynamic>.from(
        detail['application'],
      );

      final applicationId =
          application['applicationId'];

      final fieldValues = {
        'fullName':
            (data['name'] ?? '')
                .toString()
                .trim(),

        'idNumber':
            (data['idNumber'] ?? '')
                .toString()
                .trim(),

        'dateOfBirth':
            (data['dob'] ?? '')
                .toString()
                .trim(),

        'phoneNumber':
            localPhone.isNotEmpty
                ? localPhone
                : profilePhone,

        'residentialAddress':
    localAddress.isNotEmpty
        ? localAddress
        : profileAddress,
      };

      final saveResponse = await http.put(
        Uri.parse(
          '$_baseUrl/api/applications/'
          '$applicationId/fields',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fieldValues': fieldValues,
        }),
      );

      if (saveResponse.statusCode != 200) {
        throw Exception(
          'Unable to save application information: '
          '${saveResponse.body}',
        );
      }

      detail =
          jsonDecode(saveResponse.body)
              as Map<String, dynamic>;
    }

    return _fromDetail(
      detail,
      serviceId: serviceId,
      fallbackData: data,
    );
  }

  Future<Application> submitApplication(
    Application application,
  ) async {
    final token = await _accessToken();

    final applicationId =
        int.tryParse(application.id);

    if (applicationId == null) {
      throw Exception(
        'This application does not have a valid backend ID.',
      );
    }

    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/applications/'
        '$applicationId/submit',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to submit application: ${response.body}',
      );
    }

    final detail =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    return _fromDetail(
      detail,
      serviceId: application.serviceId,
      fallbackData: application.data,
    );
  }

  Future<void> updateApplicationStatus(
    String applicationId,
    String newStatus,
  ) async {
    final int index =
        _mockData.applications.indexWhere(
      (item) =>
          item.id == applicationId,
    );

    if (index == -1) {
      return;
    }

    final Application application =
        _mockData.applications[index];

    final List<StatusHistoryItem>
        updatedHistory =
        List<StatusHistoryItem>.from(
      application.statusHistory,
    )
          ..add(
            StatusHistoryItem(
              status: newStatus,
              timestamp: DateTime.now(),
            ),
          );

    _mockData.applications[index] =
        application.copyWith(
      status: newStatus,
      statusHistory: updatedHistory,
    );
  }

  Future<String> _accessToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString(
      'civicid_access_token',
    );

    if (token == null ||
        token.trim().isEmpty) {
      throw Exception(
        'You are not logged in.',
      );
    }

    return token;
  }

  int _backendServiceId(
    String serviceId,
  ) {
    switch (serviceId) {
      case 'SRV001':
        return 2;

      case 'SRV002':
        return 1;

      case 'SRV004':
        return 3;

      default:
        throw Exception(
          'This service is not connected to the backend yet.',
        );
    }
  }

  String _frontendServiceId(
    int backendServiceId,
  ) {
    switch (backendServiceId) {
      case 1:
        return 'SRV002';

      case 2:
        return 'SRV001';

      case 3:
        return 'SRV004';

      default:
        return backendServiceId.toString();
    }
  }

  Application _fromSummary(
    Map<String, dynamic> summary,
  ) {
    final int backendServiceId =
        (summary['serviceId'] as num)
            .toInt();

    return Application(
      id:
          summary['applicationId']
              .toString(),

      referenceNumber:
          summary['referenceNumber']
                  ?.toString() ??
              '',

      serviceId:
          _frontendServiceId(
        backendServiceId,
      ),

      status:
          summary['statusName']
                  ?.toString() ??
              summary['statusCode']
                  ?.toString() ??
              'Draft',

      submissionDate:
          _parseDateTime(
        summary['submittedAt'] ??
            summary['draftCreatedAt'],
      ),

      data: const {},

      statusHistory: const [],
    );
  }

  Application _fromDetail(
    Map<String, dynamic> detail, {
    required String serviceId,
    required Map<String, dynamic>
        fallbackData,
  }) {
    final summary =
        Map<String, dynamic>.from(
      detail['application'],
    );

    final data =
        Map<String, dynamic>.from(
      fallbackData,
    );

    final fields =
        detail['fields'] as List<dynamic>? ??
            const [];

    for (final item in fields) {
      final field =
          Map<String, dynamic>.from(
        item,
      );

      final key =
          field['fieldKey']
              ?.toString();

      final value =
          field['fieldValue'];

      if (key != null &&
          value != null) {
        data[key] = value;
      }
    }

    final history =
        (detail['statusHistory']
                    as List<dynamic>? ??
                const [])
            .map(
              (item) {
                final value =
                    Map<String, dynamic>.from(
                  item,
                );

                return StatusHistoryItem(
                  status:
                      value['toStatus']
                              ?.toString() ??
                          '',

                  timestamp:
                      _parseDateTime(
                    value['changedAt'],
                  ),
                );
              },
            )
            .toList();

    return Application(
      id:
          summary['applicationId']
              .toString(),

      referenceNumber:
          summary['referenceNumber']
                  ?.toString() ??
              '',

      serviceId:
          serviceId,

      status:
          summary['statusName']
                  ?.toString() ??
              summary['statusCode']
                  ?.toString() ??
              'Draft',

      submissionDate:
          _parseDateTime(
        summary['submittedAt'] ??
            summary['draftCreatedAt'],
      ),

      data:
          data,

      statusHistory:
          history,
    );
  }

  DateTime _parseDateTime(
    dynamic value,
  ) {
    if (value is DateTime) {
      return value;
    }

    if (value != null) {
      final parsed =
          DateTime.tryParse(
        value.toString(),
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }
}