import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication Service
/// Ensures proper auth state management and token transmission
class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Check if user is currently authenticated
  static bool get isAuthenticated {
    final session = _client.auth.currentSession;
    final user = _client.auth.currentUser;

    print('🔐 Auth Check:');
    print('  - Session exists: ${session != null}');
    print('  - User exists: ${user != null}');
    print('  - User ID: ${user?.id}');
    print('  - Access Token exists: ${session?.accessToken != null}');
    print('  - Token expires at: ${session?.expiresAt}');

    return session != null && user != null;
  }

  /// Get current user ID (returns null if not authenticated)
  static String? get currentUserId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      print('⚠️ WARNING: Attempted to get user ID but user is not authenticated!');
    }
    return userId;
  }

  /// Get current session
  static Session? get currentSession {
    return _client.auth.currentSession;
  }

  /// Get access token (for manual API calls if needed)
  static String? get accessToken {
    return _client.auth.currentSession?.accessToken;
  }

  /// Verify authentication before making API calls
  /// Throws exception if not authenticated
  static void requireAuth() {
    if (!isAuthenticated) {
      print('❌ FATAL: API call attempted without authentication!');
      print('   Stack trace:');
      print(StackTrace.current);
      throw Exception('User not authenticated. Please log in.');
    }
  }

  /// Refresh session if needed
  static Future<bool> refreshSessionIfNeeded() async {
    try {
      final session = _client.auth.currentSession;

      if (session == null) {
        print('⚠️ No session to refresh');
        return false;
      }

      // Check if token expires soon (within 5 minutes)
      final expiresAt = session.expiresAt;
      if (expiresAt != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final expiresIn = expiresAt - now;

        print('🔄 Token expires in: ${expiresIn}s');

        if (expiresIn < 300) { // Less than 5 minutes
          print('🔄 Refreshing token...');
          final response = await _client.auth.refreshSession();

          if (response.session != null) {
            print('✅ Token refreshed successfully');
            return true;
          } else {
            print('❌ Token refresh failed');
            return false;
          }
        }
      }

      return true; // Token is still valid
    } catch (e) {
      print('❌ Error refreshing session: $e');
      return false;
    }
  }

  /// Check auth state and log details (for debugging)
  static Future<Map<String, dynamic>> debugAuthState() async {
    final session = _client.auth.currentSession;
    final user = _client.auth.currentUser;

    return {
      'is_authenticated': isAuthenticated,
      'user_id': user?.id,
      'user_email': user?.email,
      'session_exists': session != null,
      'access_token_exists': session?.accessToken != null,
      'access_token_preview': session?.accessToken?.substring(0, 20),
      'refresh_token_exists': session?.refreshToken != null,
      'expires_at': session?.expiresAt,
      'expires_at_date': session?.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(session!.expiresAt! * 1000)
          : null,
      'token_type': session?.tokenType,
      'user_metadata': user?.userMetadata,
    };
  }

  /// Ensure user is authenticated before API call
  /// Returns user ID or throws
  static String ensureAuthenticated() {
    requireAuth();
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User ID is null despite being authenticated');
    }
    return userId;
  }

  /// Listen to auth state changes
  static Stream<AuthState> onAuthStateChange() {
    return _client.auth.onAuthStateChange;
  }

  /// Sign out and clear session
  static Future<void> signOut() async {
    await _client.auth.signOut();
    print('👋 User signed out');
  }
}
