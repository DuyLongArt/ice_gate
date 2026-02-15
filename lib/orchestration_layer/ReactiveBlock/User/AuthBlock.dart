import 'package:flutter/material.dart';
import 'package:ice_shield/initial_layer/DuyLongServices/CustomAuthService.dart';
// import 'package:ice_shield/initial_layer/Services/CustomAuthService.dart';
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

  // --- Signals (State) ---
  final status = signal<AuthStatus>(AuthStatus.init);
  final jwt = signal<String?>(null);
  final error = signal<String?>(null);
  final username = signal<String?>(null);
  final user = signal<Map<String, dynamic>?>(null);

  AuthBlock({
    required CustomAuthService authService,
    required SessionDAO sessionDao,
  }) : _authService = authService,
       _sessionDao = sessionDao;

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
  Future<void> login(String ident, String password, BuildContext context) async {
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

  /// Passkey Login Flow
  Future<void> loginWithPasskey(BuildContext context) async {
    status.value = AuthStatus.authenticating;
    error.value = null;
    print("🔑 Authenticating with Passkey...");

    try {
      // 1. Get Challenge
      final challenge = await _authService.getPasskeyChallenge();
      // print("🔑 Challenge received: $challenge");

      // 2. Perform Passkey Assertion (Platform specific logic would go here)
      // For now, we are simulating or passing the challenge back if testing
      // In a real app, you'd use a passkey plugin here like `fido2_plugin` or similar
      // to sign the challenge.

      // Assume we get a credential string from the platform:
      // final credential = await PlatformPasskey.getCredential(challenge);
      // For this implementation, we will assume a mock credential or that verifyPasskeyLogin
      // handles the next step. Since we don't have the platform plugin code here,
      // we will simulate the credential or call verify directly if the backend supports it.

      // NOTE: This part depends on actual device integration.
      // We will proceed to call verify with a placeholder or the challenge itself for testing.
      final credential = "mock_credential_for_challenge_$challenge";

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

  /// Fetch full user profile from backend
  Future<void> fetchUser() async {
    final token = jwt.value;
    if (token == null) return;

    // print("👤 Fetching user profile...");
    final userData = await _authService.fetchCurrentUser(token);
    // print("✅ User data fetched: $userData");
    try {
      final userData = await _authService.fetchCurrentUser(token);
      // print("✅ User data fetched: $userData");
      user.value = userData;
      // You could update other signals here if needed (e.g. email, role)
      if (userData['userName'] != null) {
        username.value = userData['userName'];
      }
      // Ensure we are in authenticated state after successful user fetch
      status.value = AuthStatus.authenticated;
    } catch (e) {
      print("⚠️ Failed to fetch user profile: $e");
      // Don't necessarily logout if profile fetch fails, unless it's a 401
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        await logout();
      }
    }
  }
}
