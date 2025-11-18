/// Build configuration utilities
/// 
/// This file helps identify which build variant is running
/// and provides build-specific configurations.

import 'package:flutter/foundation.dart';

class BuildConfig {
  // Build flavor detection
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'production',
  );

  // Build type
  static bool get isProduction => flavor == 'production';
  static bool get isAlpha => flavor == 'alpha';
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;

  // App identification
  static String get appName {
    if (isAlpha) return 'Mind Wars Alpha';
    return 'Mind Wars';
  }

  static String get packageName {
    const basePackage = 'com.mindwars.app';
    if (isAlpha) return '$basePackage.alpha';
    return basePackage;
  }

  // Build information
  static String get buildType {
    if (isAlpha) return 'Alpha';
    if (isDebug) return 'Debug';
    return 'Production';
  }

  static String get versionSuffix {
    if (isAlpha) return '-alpha';
    return '';
  }

  // Feature flags based on build type
  static bool get enableDebugLogging => isDebug || isAlpha;
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashReporting => isProduction || isAlpha;
  
  // API endpoints can be configured per flavor
  static String get apiBaseUrl {
    if (isAlpha) {
      return 'https://api-alpha.mindwars.app';
    }
    return 'https://api.mindwars.app';
  }

  static String get wsBaseUrl {
    // [2025-11-18 Feature] Updated Socket.io endpoint to use public domain
    // Uses war.e-mothership.com:4000 for WebSocket connections
    // Direct access without ADB port forwarding
    return 'http://war.e-mothership.com:4000';
  }

  // Display build information
  static String get buildInfo {
    final buffer = StringBuffer();
    buffer.writeln('Build Type: $buildType');
    buffer.writeln('App Name: $appName');
    buffer.writeln('Package: $packageName');
    buffer.writeln('Debug Mode: ${isDebug ? "Yes" : "No"}');
    buffer.writeln('Release Mode: ${isRelease ? "Yes" : "No"}');
    return buffer.toString();
  }

  // Print build info to console (useful for debugging)
  static void printBuildInfo() {
    if (enableDebugLogging) {
      debugPrint('=== Mind Wars Build Info ===');
      debugPrint(buildInfo);
      debugPrint('===========================');
    }
  }
}
