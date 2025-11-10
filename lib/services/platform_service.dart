/**
 * Platform Service - Handles platform-specific features and optimizations
 * Supports iOS 14+ and Android 8+ (API 26)
 * Provides platform detection, device info, and platform-specific APIs
 */

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class PlatformService {
  static const MethodChannel _channel = MethodChannel('com.mindwars.app/platform');
  
  /// Platform type enum
  static PlatformType get platformType {
    if (kIsWeb) return PlatformType.web;
    if (Platform.isIOS) return PlatformType.ios;
    if (Platform.isAndroid) return PlatformType.android;
    return PlatformType.other;
  }
  
  /// Check if running on iOS
  static bool get isIOS => Platform.isIOS;
  
  /// Check if running on Android
  static bool get isAndroid => Platform.isAndroid;
  
  /// Check if running on mobile (iOS or Android)
  static bool get isMobile => isIOS || isAndroid;
  
  /// Check if running on tablet
  static bool isTablet = false;
  
  /// Get platform version (e.g., "iOS 14.0" or "Android 13")
  static Future<String> getPlatformVersion() async {
    try {
      final String version = await _channel.invokeMethod('getPlatformVersion');
      return version;
    } on PlatformException {
      return 'Unknown platform version';
    }
  }
  
  /// Get detailed platform information
  static Future<PlatformInfo> getPlatformInfo() async {
    try {
      final Map<dynamic, dynamic> info = await _channel.invokeMethod('getPlatformInfo');
      return PlatformInfo(
        platform: info['platform'] ?? 'unknown',
        version: info['version'] ?? 'unknown',
        sdkInt: info['sdkInt'] ?? 0,
        manufacturer: info['manufacturer'] ?? 'unknown',
        model: info['model'] ?? 'unknown',
        isTablet: info['isTablet'] ?? false,
      );
    } on PlatformException {
      return PlatformInfo(
        platform: platformType.name,
        version: 'unknown',
        sdkInt: 0,
        manufacturer: 'unknown',
        model: 'unknown',
        isTablet: false,
      );
    }
  }
  
  /// Initialize platform service
  static Future<void> initialize() async {
    final info = await getPlatformInfo();
    isTablet = info.isTablet;
  }
  
  /// Check if platform supports a specific feature
  static Future<bool> supportsFeature(String feature) async {
    try {
      final bool supported = await _channel.invokeMethod('supportsFeature', {'feature': feature});
      return supported;
    } on PlatformException {
      return false;
    }
  }
  
  /// Get platform-specific design guidelines
  static DesignGuidelines get designGuidelines {
    if (isIOS) {
      return DesignGuidelines.ios;
    } else if (isAndroid) {
      return DesignGuidelines.android;
    }
    return DesignGuidelines.generic;
  }
  
  /// Get minimum touch target size for platform
  static double get minTouchTargetSize {
    if (isIOS) {
      return 44.0; // iOS Human Interface Guidelines: 44pt
    } else if (isAndroid) {
      return 48.0; // Material Design: 48dp
    }
    return 48.0; // Default to Material Design
  }
  
  /// Get platform-specific haptic feedback
  static Future<void> hapticFeedback(HapticType type) async {
    try {
      switch (type) {
        case HapticType.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticType.selection:
          await HapticFeedback.selectionClick();
          break;
        case HapticType.success:
          // iOS has different feedback for success
          if (isIOS) {
            await HapticFeedback.mediumImpact();
          } else {
            await HapticFeedback.heavyImpact();
          }
          break;
        case HapticType.error:
          await HapticFeedback.vibrate();
          break;
      }
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }
  
  /// Get platform-specific animation duration
  static Duration get animationDuration {
    if (isIOS) {
      return const Duration(milliseconds: 300); // iOS standard
    } else if (isAndroid) {
      return const Duration(milliseconds: 250); // Material Design standard
    }
    return const Duration(milliseconds: 250);
  }
  
  /// Check if platform meets minimum requirements
  static Future<bool> meetsMinimumRequirements() async {
    if (isIOS) {
      // iOS 14.0+ required
      final version = await getPlatformVersion();
      final versionNumber = _extractVersionNumber(version);
      return versionNumber >= 14.0;
    } else if (isAndroid) {
      // Android 8.0 (API 26)+ required
      final info = await getPlatformInfo();
      return info.sdkInt >= 26;
    }
    return true; // Unknown platforms pass by default
  }
  
  /// Extract version number from version string
  static double _extractVersionNumber(String version) {
    final match = RegExp(r'(\d+\.?\d*)').firstMatch(version);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0.0;
    }
    return 0.0;
  }
  
  /// Get platform-specific safe area insets
  static EdgeInsets getSafeAreaInsets(MediaQueryData mediaQuery) {
    // Use actual device safe area insets
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }
}

/// Platform type enum
enum PlatformType {
  ios,
  android,
  web,
  other,
}

/// Design guidelines enum
enum DesignGuidelines {
  ios,      // Human Interface Guidelines
  android,  // Material Design 3
  generic,
}

/// Haptic feedback types
enum HapticType {
  light,
  medium,
  heavy,
  selection,
  success,
  error,
}

/// Platform information model
class PlatformInfo {
  final String platform;
  final String version;
  final int sdkInt;
  final String manufacturer;
  final String model;
  final bool isTablet;
  
  PlatformInfo({
    required this.platform,
    required this.version,
    required this.sdkInt,
    required this.manufacturer,
    required this.model,
    required this.isTablet,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'version': version,
      'sdkInt': sdkInt,
      'manufacturer': manufacturer,
      'model': model,
      'isTablet': isTablet,
    };
  }
  
  @override
  String toString() {
    return '$manufacturer $model ($platform $version)';
  }
}
