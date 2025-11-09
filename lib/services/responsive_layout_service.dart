/**
 * Responsive Layout Service - Handles responsive UI across different screen sizes
 * Supports 5" to 12" screens with portrait and landscape orientations
 * Provides adaptive layouts, font sizes, and touch targets
 */

import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class ResponsiveLayoutService {
  /// Screen size breakpoints (in logical pixels)
  static const double breakpointSmall = 360.0;    // 5" phones (portrait)
  static const double breakpointMedium = 600.0;   // Large phones / small tablets
  static const double breakpointLarge = 840.0;    // Tablets (portrait)
  static const double breakpointExtraLarge = 1024.0; // Tablets (landscape) / Large tablets
  
  /// Get current screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < breakpointSmall) {
      return ScreenSize.extraSmall;
    } else if (width < breakpointMedium) {
      return ScreenSize.small;
    } else if (width < breakpointLarge) {
      return ScreenSize.medium;
    } else if (width < breakpointExtraLarge) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }
  
  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  /// Check if screen is small (phone)
  static bool isSmallScreen(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.extraSmall || size == ScreenSize.small;
  }
  
  /// Check if screen is tablet-sized
  static bool isTablet(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.medium || 
           size == ScreenSize.large || 
           size == ScreenSize.extraLarge;
  }
  
  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double? small,
    double? medium,
    double? large,
  }) {
    final screenSize = getScreenSize(context);
    double padding;
    
    switch (screenSize) {
      case ScreenSize.extraSmall:
      case ScreenSize.small:
        padding = small ?? 16.0;
        break;
      case ScreenSize.medium:
        padding = medium ?? 24.0;
        break;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        padding = large ?? 32.0;
        break;
    }
    
    return EdgeInsets.all(padding);
  }
  
  /// Get responsive horizontal padding
  static double getHorizontalPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.extraSmall:
      case ScreenSize.small:
        return 16.0;
      case ScreenSize.medium:
        return 24.0;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return 32.0;
    }
  }
  
  /// Get responsive vertical padding
  static double getVerticalPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.extraSmall:
      case ScreenSize.small:
        return 16.0;
      case ScreenSize.medium:
        return 20.0;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return 24.0;
    }
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    required double baseSize,
    double? minSize,
    double? maxSize,
  }) {
    final screenSize = getScreenSize(context);
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    double scaleFactor;
    switch (screenSize) {
      case ScreenSize.extraSmall:
        scaleFactor = 0.9;
        break;
      case ScreenSize.small:
        scaleFactor = 1.0;
        break;
      case ScreenSize.medium:
        scaleFactor = 1.1;
        break;
      case ScreenSize.large:
        scaleFactor = 1.2;
        break;
      case ScreenSize.extraLarge:
        scaleFactor = 1.3;
        break;
    }
    
    double fontSize = baseSize * scaleFactor * textScaleFactor;
    
    // Apply min/max constraints
    if (minSize != null && fontSize < minSize) {
      fontSize = minSize;
    }
    if (maxSize != null && fontSize > maxSize) {
      fontSize = maxSize;
    }
    
    return fontSize;
  }
  
  /// Get number of columns for grid layout
  static int getGridColumns(BuildContext context, {
    int? phoneColumns,
    int? tabletColumns,
  }) {
    if (isTablet(context)) {
      return tabletColumns ?? 3;
    } else {
      return phoneColumns ?? 2;
    }
  }
  
  /// Get responsive grid spacing
  static double getGridSpacing(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.extraSmall:
      case ScreenSize.small:
        return 8.0;
      case ScreenSize.medium:
        return 12.0;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return 16.0;
    }
  }
  
  /// Get responsive card width
  static double getCardWidth(BuildContext context, {double maxWidth = 400.0}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = getHorizontalPadding(context);
    
    if (isTablet(context)) {
      return math.min(maxWidth, (screenWidth - padding * 2) / 2);
    } else {
      return screenWidth - padding * 2;
    }
  }
  
  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isTablet(context)) {
      return math.min(600.0, screenWidth * 0.8);
    } else {
      return screenWidth * 0.9;
    }
  }
  
  /// Get touch target size (minimum 48dp for accessibility)
  static double getTouchTargetSize(BuildContext context, {double baseSize = 48.0}) {
    return math.max(baseSize, 48.0); // Ensure minimum 48dp
  }
  
  /// Get responsive icon size
  static double getIconSize(BuildContext context, {double baseSize = 24.0}) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.extraSmall:
        return baseSize * 0.9;
      case ScreenSize.small:
        return baseSize;
      case ScreenSize.medium:
        return baseSize * 1.1;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return baseSize * 1.2;
    }
  }
  
  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isTablet(context)) {
      return 64.0;
    } else {
      return 56.0;
    }
  }
  
  /// Get responsive bottom navigation bar height
  static double getBottomNavHeight(BuildContext context) {
    return 56.0; // Standard height for bottom navigation
  }
  
  /// Check if screen width is sufficient for multi-column layout
  static bool canShowMultiColumn(BuildContext context, {int minColumns = 2}) {
    final screenSize = getScreenSize(context);
    return screenSize != ScreenSize.extraSmall;
  }
  
  /// Get content max width for centered layouts
  static double getContentMaxWidth(BuildContext context) {
    if (isTablet(context)) {
      return 1200.0;
    } else {
      return 600.0;
    }
  }
  
  /// Adaptive value based on screen size
  static T adaptiveValue<T>(
    BuildContext context, {
    required T phone,
    required T tablet,
  }) {
    if (isTablet(context)) {
      return tablet;
    } else {
      return phone;
    }
  }
  
  /// Get screen diagonal size in inches (approximate)
  static double getScreenDiagonalInches(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    
    // Assume 160 dpi as baseline (mdpi on Android)
    final widthInches = (size.width * pixelRatio) / 160;
    final heightInches = (size.height * pixelRatio) / 160;
    
    return math.sqrt(widthInches * widthInches + heightInches * heightInches);
  }
  
  /// Check if device is likely a phone (5-7 inches)
  static bool isPhoneSized(BuildContext context) {
    final diagonal = getScreenDiagonalInches(context);
    return diagonal >= 5.0 && diagonal <= 7.0;
  }
  
  /// Check if device is likely a tablet (7+ inches)
  static bool isTabletSized(BuildContext context) {
    final diagonal = getScreenDiagonalInches(context);
    return diagonal > 7.0;
  }
  
  /// Get safe area insets with responsive adjustments
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return EdgeInsets.only(
      top: math.max(padding.top, 0),
      bottom: math.max(padding.bottom, 0),
      left: math.max(padding.left, 0),
      right: math.max(padding.right, 0),
    );
  }
}

/// Screen size categories
enum ScreenSize {
  extraSmall,  // < 360dp (very small phones)
  small,       // 360-600dp (phones)
  medium,      // 600-840dp (large phones / small tablets)
  large,       // 840-1024dp (tablets)
  extraLarge,  // > 1024dp (large tablets)
}

/// Extension on BuildContext for easier access
extension ResponsiveContext on BuildContext {
  /// Get screen size
  ScreenSize get screenSize => ResponsiveLayoutService.getScreenSize(this);
  
  /// Check if tablet
  bool get isTablet => ResponsiveLayoutService.isTablet(this);
  
  /// Check if phone
  bool get isPhone => !isTablet;
  
  /// Check if landscape
  bool get isLandscape => ResponsiveLayoutService.isLandscape(this);
  
  /// Check if portrait
  bool get isPortrait => ResponsiveLayoutService.isPortrait(this);
  
  /// Get responsive padding
  EdgeInsets getResponsivePadding({double? small, double? medium, double? large}) {
    return ResponsiveLayoutService.getResponsivePadding(
      this,
      small: small,
      medium: medium,
      large: large,
    );
  }
  
  /// Get responsive font size
  double getResponsiveFontSize(double baseSize, {double? minSize, double? maxSize}) {
    return ResponsiveLayoutService.getResponsiveFontSize(
      this,
      baseSize: baseSize,
      minSize: minSize,
      maxSize: maxSize,
    );
  }
}
