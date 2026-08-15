import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService._();

  static const String baseUrl = 'http://10.0.2.2:5000';

  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String mobile,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullName': fullName,
        'mobile': mobile,
        'password': password,
        'role': role,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Something went wrong',
    );
  }
  static Future<Map<String, dynamic>> login({
    required String mobile,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mobile': mobile,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Login failed',
    );
  }
  static Future<Map<String, dynamic>> createOrganization({
  required String token,
  required String name,
  required String businessType,
  required String address,
  required double latitude,
  required double longitude,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/organizations'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'name': name,
      'businessType': businessType,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return data;
  }

  throw Exception(
    data['message'] ?? 'Workspace creation failed',
  );
}
  static Future<Map<String, dynamic>> getMyOrganization({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/organizations/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    if (response.statusCode == 404) {
      return {
        'success': false,
        'organization': null,
      };
    }

    throw Exception(
      data['message'] ?? 'Failed to fetch workspace',
    );
  }
  static Future<Map<String, dynamic>> joinOrganization({
    required String fullName,
    required String mobile,
    required String password,
    required String inviteCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/employees/join'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullName': fullName,
        'mobile': mobile,
        'password': password,
        'inviteCode': inviteCode,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Failed to join organization',
    );
  }
  static Future<int> getEmployeeCount({
  required String token,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/employees/count'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data['employeeCount'] ?? 0;
  }

  throw Exception(
    data['message'] ?? 'Failed to fetch employee count',
  );
}
static Future<Map<String, dynamic>> markAttendance({
  required String token,
  required double latitude,
  required double longitude,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/attendance/mark'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'latitude': latitude,
      'longitude': longitude,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return data;
  }

  throw Exception(
    data['message'] ?? 'Failed to mark attendance',
  );
}
static Future<Map<String, dynamic>> getTodayStats({
  required String token,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/attendance/today-stats'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return data;
  }

  throw Exception(
    data['message'] ?? 'Failed to fetch attendance statistics',
  );
}
static Future<Map<String, dynamic>> getEmployeeHistory({
  required String token,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/attendance/employee-history'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data;
  }

  throw Exception(
    data['message'] ?? 'Failed to fetch attendance history',
  );
}


static Future<Map<String, dynamic>> getEmployerDayHistory({
  required String token,
  String? date,
}) async {
  final uri = date == null
      ? Uri.parse('$baseUrl/api/attendance/day-history')
      : Uri.parse(
          '$baseUrl/api/attendance/day-history?date=$date',
        );

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data;
  }

  throw Exception(
    data['message'] ?? 'Failed to fetch day attendance',
  );
}


static Future<Map<String, dynamic>> getEmployerEmployeeHistory({
  required String token,
  required int employeeId,
}) async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/api/attendance/employee/$employeeId/history',
    ),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data;
  }

  throw Exception(
    data['message'] ?? 'Failed to fetch employee history',
  );
}

static Future<Map<String, dynamic>> getEmployees({
  required String token,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/employees/all'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data;
  }

  throw Exception(
    data['message'] ?? 'Failed to fetch employees',
  );
}
}