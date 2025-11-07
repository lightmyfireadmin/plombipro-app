import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage user onboarding state
///
/// Tracks whether the user has completed the onboarding wizard
/// and stores user preferences related to onboarding
class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_completed';
  static const String _onboardingSkippedKey = 'onboarding_skipped';
  static const String _onboardingVersionKey = 'onboarding_version';

  // Current onboarding version - increment when wizard changes significantly
  static const int currentVersion = 1;

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_onboardingCompleteKey) ?? false;
    final version = prefs.getInt(_onboardingVersionKey) ?? 0;

    // If version is outdated, require re-onboarding
    return completed && version >= currentVersion;
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
    await prefs.setInt(_onboardingVersionKey, currentVersion);
    await prefs.remove(_onboardingSkippedKey); // Clear skip flag if exists
  }

  /// Skip onboarding (user chose to skip)
  static Future<void> skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSkippedKey, true);
    await prefs.setBool(_onboardingCompleteKey, true);
    await prefs.setInt(_onboardingVersionKey, currentVersion);
  }

  /// Check if user skipped onboarding
  static Future<bool> hasSkippedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSkippedKey) ?? false;
  }

  /// Reset onboarding state (for testing or re-onboarding)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompleteKey);
    await prefs.remove(_onboardingSkippedKey);
    await prefs.remove(_onboardingVersionKey);
  }

  /// Check if user should see onboarding
  static Future<bool> shouldShowOnboarding() async {
    return !(await hasCompletedOnboarding());
  }
}
