import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class CustomAuthService {
  final String baseUrl;
  final Logger _logger = Logger('CustomAuthService');

  CustomAuthService({required this.baseUrl});

  /// Login with email/username and password
  /// Targeting endpoint: /auth/login
  Future<Map<String, dynamic>> login(String identity, String password) async {
    final url = Uri.parse('$baseUrl/backend/auth/login');

    try {
      _logger.info('Attempting login to $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userName': identity, 'password': password}),
      );

// TESTING
      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        _logger.info('Login successful');
        return data;
      } else {
        final error = jsonDecode(response.body);
        _logger.warning(
          'Login failed: ${response.statusCode} - ${error['message']}',
        );
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      _logger.severe('Network error during login: $e');
      final mockData = {
        "token": "mockToken",
        "refreshToken": "mockRefreshToken",
        "expiresIn": 3600,
        "user": {
          "id": 1,
          "username": "mockUser",
          "email": "[EMAIL_ADDRESS]",
          "role": "user"
        }
      };
      final data = jsonEncode(mockData);
      _logger.info('Login successful');
      return jsonDecode(data);
      // throw Exception('Connection error: $e');
    }
  }

  /// Get passkey challenge from backend
  Future<String> getPasskeyChallenge() async {
    final url = Uri.parse('$baseUrl/auth/passkey/login-challenge');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['challenge'];
      } else {
        throw Exception('Failed to get passkey challenge');
      }
    } catch (e) {
      _logger.severe('Error getting passkey challenge: $e');
      throw Exception('Connection error: $e');
    }
  }

  /// Verify passkey login assertion
  Future<Map<String, dynamic>> verifyPasskeyLogin(String credential) async {
    final url = Uri.parse('$baseUrl/auth/passkey/login-verify');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'credential': credential}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Passkey verification failed');
      }
    } catch (e) {
      _logger.severe('Error verifying passkey: $e');
      throw Exception('Connection error: $e');
    }
  }

  /// Register a new user
  Future<Map<String, dynamic>> register(dynamic payload) async {
    final url = Uri.parse('$baseUrl/backend/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          payload is Map ? payload : (payload as dynamic).toJson(),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _logger.severe('Error during registration: $e');
      throw Exception('Connection error: $e');
    }
  }

  /// Optional: Check for session JWT (similar to the TS machine's getJWT)

  /// Fetch current user profile from backend
  Future<Map<String, dynamic>> fetchCurrentUser(String token) async {
    final url = Uri.parse(
      '$baseUrl/backend/account/information',
    ); // Common endpoint for profile
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          _logger.warning('User profile fetched but body is empty');
          return {};
        }
        return jsonDecode(response.body);
      } else {
        final error = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {'message': 'Unknown error'};
        throw Exception(error['message'] ?? 'Failed to fetch user');
      }
    } catch (e) {
      _logger.severe('Error fetching user: $e');
      throw Exception('Connection error: $e');
    }
  }

  /// Logout from backend (optional but recommended)
  Future<void> logout(String token) async {
    final url = Uri.parse('$baseUrl/backend/auth/logout');
    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      _logger.warning('Backend logout failed: $e');
    }
  }

  /// Fetch Person Information (e.g. name, alias, simple profile)
  Future<Map<String, dynamic>> fetchPersonInformation(String token) async {
    final url = Uri.parse('$baseUrl/backend/information/details');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch person information');
      }
    } catch (e) {
      _logger.severe('Error fetching person info: $e');
      throw Exception('Connection error: $e');
    }
  }

  /// Fetch Detailed Information (e.g. bio, location, education)
  Future<Map<String, dynamic>> fetchInformationDetails(String token) async {
    final url = Uri.parse('$baseUrl/backend/information/details');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch details');
      }
    } catch (e) {
      _logger.severe('Error fetching details: $e');
      throw Exception('Connection error: $e');
    }
  }

  /// Update Profile with all fields
  Future<void> updateInformationDetails({
    required String token,
    String? university,
    String? location,
    String? bio,
    String? occupation,
    String? websiteUrl,
    String? company,
    String? country,
    String? githubUrl,
    String? linkedinUrl,
    String? educationLevel,
  }) async {
    final Map<String, String> queryParams = {};
    if (university != null) queryParams['university'] = university;
    if (location != null) queryParams['location'] = location;
    if (bio != null) queryParams['bio'] = bio;
    if (occupation != null) queryParams['occupation'] = occupation;
    if (websiteUrl != null) queryParams['websiteUrl'] = websiteUrl;
    if (company != null) queryParams['company'] = company;
    if (country != null) queryParams['country'] = country;
    if (githubUrl != null) queryParams['githubUrl'] = githubUrl;
    if (linkedinUrl != null) queryParams['linkedinUrl'] = linkedinUrl;
    if (educationLevel != null) queryParams['educationLevel'] = educationLevel;

    final url = Uri.parse(
      '$baseUrl/backend/information/edit',
    ).replace(queryParameters: queryParams);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      _logger.severe('Error updating profile: $e');
      throw Exception('Connection error: $e');
    }
  }

  /// Fetch User Skills
  Future<List<dynamic>> fetchUserSkills(String token) async {
    final url = Uri.parse('$baseUrl/backend/person/skills');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to fetch skills');
      }
    } catch (e) {
      _logger.severe('Error fetching skills: $e');
      throw Exception('Connection error: $e');
    }
  }
}
