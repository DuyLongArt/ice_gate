import 'package:flutter/material.dart';
import 'package:ice_shield/initial_layer/CoreLogics/CustomAuthService.dart';
import 'package:ice_shield/initial_layer/CoreLogics/PasskeyAuthService.dart';
import 'package:ice_shield/data_layer/Protocol/User/RegistrationProtocol.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';
import 'package:signals/signals.dart';
import 'dart:async';

enum AuthStatus {
  init,
  checkingSession,
  unauthenticated,
  authenticating,
  registering,
  authenticated,
  failed,
  logout,
}

class AuthBlock {
  final CustomAuthService _authService;
  final SessionDAO _sessionDao;
  final PasskeyAuthService _passkeyService;
  final PersonManagementDAO _personDao;

  // --- Signals (State) ---
  final status = signal<AuthStatus>(AuthStatus.init);
  final jwt = signal<String?>(null);
  final error = signal<String?>(null);
  final username = signal<String?>(null);
  final user = signal<Map<String, dynamic>?>(null);

  AuthBlock({
    required CustomAuthService authService,
    required SessionDAO sessionDao,
    required PasskeyAuthService passkeyService,
    required PersonManagementDAO personDao,
  }) : _authService = authService,
       _sessionDao = sessionDao,
       _passkeyService = passkeyService,
       _personDao = personDao;

  /// Mock/Guest Login logic
  Future<void> loginAsGuest() async {
    status.value = AuthStatus.authenticating;
    error.value = null;
    print("👤 Logging in as Guest...");

    try {
      // Provide a mock JWT and fallback username
      jwt.value = "mock_guest_jwt_token";
      username.value = "Guest";

      // We still save it to the session DAO to allow the app to "remember" this guest session
      await _sessionDao.saveSession(jwt.value!, username.value);

      status.value = AuthStatus.authenticated;

      // fetchUser will attempt to call API, fail (since token is mock),
      // and then fall back to local DB user ID 1, which acts as our mock data.
      await fetchUser();

      print("✅ Guest login successful with mock data.");
    } catch (e) {
      print("❌ Guest login failed: $e");
      error.value = "Guest Access Error: ${e.toString()}";
      status.value = AuthStatus.unauthenticated;
    }
  }

  /// Passkey Login Flow
  Future<void> loginWithPasskey(BuildContext context) async {
    status.value = AuthStatus.authenticating;
    error.value = null;
    print("🔑 Authenticating with Passkey...");

    try {
      // 1. Get Challenge
      final challenge = await _authService.getPasskeyChallenge();
      // print("🔑 Challenge received: $challenge");

      // 2. Perform Passkey Assertion
      // Call the platform passkey service to sign the challenge
      final credential = await _passkeyService.loginRequest(
        challenge: challenge,
      );

      if (credential == null) {
        throw Exception("Passkey assertion canceled or failed");
      }

      // 3. Verify Assertion
      final data = await _authService.verifyPasskeyLogin(credential);

      final token = data['token'] ?? data['jwt'];
      if (token != null && token.toString().isNotEmpty) {
        jwt.value = token.toString();
        // Assume username returned or fetched next
        username.value = data['userName'] ?? "PasskeyUser";

        await _sessionDao.saveSession(jwt.value!, username.value);

        status.value = AuthStatus.authenticated;
        print("✅ Passkey Login successful.");

        await fetchUser();
      } else {
        throw Exception("Server returned no token for passkey");
      }
    } catch (e) {
      print("❌ Passkey Authentication failed: $e");
      error.value = "Passkey Error: ${e.toString()}";
      status.value = AuthStatus.unauthenticated;
    }
  }
  // --- Actions ---

  /// Step 1: Check for existing session (e.g. from cookies/local storage)
  /// In this Flutter app, we'll simulate cookie check or just go to auto-auth
  Future<void> checkSession(BuildContext context) async {
    status.value = AuthStatus.checkingSession;
    print("🔍 Step 1: Checking for existing session in database...");

    try {
      final session = await _sessionDao.getSession();
      if (session != null) {
        // print(
        //   "✅ Session found for ${session.username}. Token length: ${session.jwt.length}",
        // );
        jwt.value = session.jwt;
        username.value = session.username;
        // Mark as authenticated immediately so UI can update/redirect
        status.value = AuthStatus.authenticated;
        // print("🔄 Fetching user details for ${session.username}...");

        // Optionally verify token or fetch user details immediately
        await fetchUser();
        // print("✅ User details fetch attempt completed.");
      } else {
        print(
          "➡️ No session found in local DB, proceeding to auto-authentication fetch",
        );
        await fetchAutoJWT();
      }
    } catch (e) {
      print("❌ Error checking session: $e");
      await fetchAutoJWT();
    }
  }

  /// Step 2: Attempt to fetch JWT from API automatically (if possible/needed)
  /// Corresponds to onAuthen in XState
  Future<void> fetchAutoJWT() async {
    status.value = AuthStatus.authenticating;
    print("🔍 Step 2: Attempting to fetch JWT from API automatically...");

    try {
      // The machine logic says GET /backend/auth/login
      // We'll implement this in CustomAuthService if it doesn't exist
      // Since it's a mock/example in many cases, we'll try it
      // final data = await _authService.fetchSessionJWT(); // hypothetical

      // For now, let's assume it fails or returns unauthenticated to force manual login
      // unless we want to simulate success
      status.value = AuthStatus.unauthenticated;
      print(
        "⚠️ Auto-auth returned unauthenticated. Waiting for user credentials.",
      );
    } catch (e) {
      print("❌ Auto-auth fetch failed: $e");
      status.value = AuthStatus.unauthenticated;
    }
  }

  /// Step 5: Authenticate with user credentials
  /// Corresponds to authenticating in XState
  Future<void> login(
    String ident,
    String password,
    BuildContext context,
  ) async {
    status.value = AuthStatus.authenticating;
    error.value = null;
    print("🔐 Authenticating with user credentials: $ident");

    try {
      final data = await _authService.login(ident, password);

      // Expected response might have 'token' or 'jwt'
      final token = data['token'] ?? data['jwt'];

      if (token != null && token.toString().isNotEmpty) {
        jwt.value = token.toString();
        username.value = ident;

        // Persistent save to database
        await _sessionDao.saveSession(jwt.value!, username.value);

        status.value = AuthStatus.authenticated;
        print("✅ Login successful. JWT saved to database.");

        // Fetch full user profile
        await fetchUser();
      } else {
        throw Exception("Server returned no token");
      }
    } catch (e) {
      print("❌ Authentication failed: $e");
      error.value = e.toString();
      status.value = AuthStatus.unauthenticated;
    }
  }

  /// Registration logic
  Future<void> register(RegistrationPayload payload) async {
    status.value = AuthStatus.registering;
    error.value = null;
    // print("📝 Registering user: ${payload.userName}");

    try {
      // Machine uses POST /backend/auth/signup
      // We'll need to ensure CustomAuthService handles this
      // For now, let's assume login() is our main flow
      final data = await _authService.register(payload);

      final token = data['token'] ?? data['jwt'];
      if (token != null) {
        jwt.value = token.toString();
        username.value = payload.userName;

        // Persistent save
        await _sessionDao.saveSession(jwt.value!, username.value);

        status.value = AuthStatus.authenticated;
        print("✅ Registration successful.");
        await fetchUser();
      } else {
        // Some backends might not return a token on signup, requiring separate login
        status.value = AuthStatus.unauthenticated;
        print("✅ Registration successful, please login.");
      }
    } catch (e) {
      print("❌ Registration failed: $e");
      error.value = e.toString();
      status.value = AuthStatus.unauthenticated;
    }
  }

  /// Step 7 & Logout
  Future<void> logout() async {
    print("👋 Logging out...");
    final currentToken = jwt.value;

    // context.go("/login");
    // 1. Clear Local State
    jwt.value = null;
    username.value = null;
    error.value = null;
    status.value = AuthStatus.logout;

    // 2. Clear Database
    await _sessionDao.clearSession();

    // 3. Notify Backend (Fire and forget)
    if (currentToken != null) {
      unawaited(_authService.logout(currentToken));
    }

    // Auto-reinit after short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      status.value = AuthStatus.unauthenticated;
    });
  }

  /// Fetch full user profile from backend
  Future<void> fetchUser() async {
    final token = jwt.value;

    // Attempt standard fetch
    if (token != null) {
      try {
        final userData = await _authService.fetchCurrentUser(token);
        user.value = userData;
        if (userData['userName'] != null) {
          username.value = userData['userName'];
        }
        status.value = AuthStatus.authenticated;
        return;
      } catch (e) {
        print("⚠️ Failed to fetch user profile via API: $e");
        if (e.toString().contains('401') ||
            e.toString().contains('Unauthorized')) {
          await logout();
          return;
        }
        // Proceed to fallback
      }
    }

    // Fallback: Fetch ID 1 from local DB
    print("🔄 Attempting local fallback for User ID 1...");
    try {
      final localPerson = await _personDao.getPersonById(1);
      if (localPerson != null) {
        print("✅ Falling back to local user ID 1: ${localPerson.firstName}");

        // Construct a mock user map that mimics the API response
        final mockUserMap = {
          'id': localPerson.personID,
          'userName': localPerson.firstName,
          'firstName': localPerson.firstName,
          'lastName': localPerson.lastName,
          'email': 'offline@local', // Placeholder
          'role': 'admin',
        };

        user.value = mockUserMap;
        username.value = localPerson.firstName;
        status.value = AuthStatus.authenticated;
      } else {
        print("❌ Local user ID 1 not found in database.");
        // Only logout if we had a token and it failed, or maybe just go to unauth
        // If we are here, we failed both API and DB.
        if (token != null) await logout();
      }
    } catch (dbError) {
      print("❌ Local DB fallback failed: $dbError");
      if (token != null) await logout();
    }
  }
}
