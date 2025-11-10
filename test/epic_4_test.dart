/**
 * Epic 4 Tests - Cross-Platform & Reliability
 * Tests for platform service, responsive layouts, and enhanced offline functionality
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mind_wars/services/platform_service.dart';
import 'package:mind_wars/services/responsive_layout_service.dart';

void main() {
  group('Platform Service Tests', () {
    test('Platform type detection', () {
      final platformType = PlatformService.platformType;
      expect(platformType, isNotNull);
      expect(
        [PlatformType.ios, PlatformType.android, PlatformType.web, PlatformType.other]
            .contains(platformType),
        true,
      );
    });

    test('Minimum touch target size', () {
      final minSize = PlatformService.minTouchTargetSize;
      expect(minSize, greaterThanOrEqualTo(44.0)); // iOS minimum
      expect(minSize, lessThanOrEqualTo(48.0));    // Android minimum
    });

    test('Animation duration is valid', () {
      final duration = PlatformService.animationDuration;
      expect(duration.inMilliseconds, greaterThan(0));
      expect(duration.inMilliseconds, lessThanOrEqualTo(500));
    });

    test('Design guidelines are platform-specific', () {
      final guidelines = PlatformService.designGuidelines;
      expect(guidelines, isNotNull);
      expect(
        [DesignGuidelines.ios, DesignGuidelines.android, DesignGuidelines.generic]
            .contains(guidelines),
        true,
      );
    });

    test('Platform info model creation', () {
      final info = PlatformInfo(
        platform: 'android',
        version: '13',
        sdkInt: 33,
        manufacturer: 'Google',
        model: 'Pixel 7',
        isTablet: false,
      );

      expect(info.platform, 'android');
      expect(info.version, '13');
      expect(info.sdkInt, 33);
      expect(info.manufacturer, 'Google');
      expect(info.model, 'Pixel 7');
      expect(info.isTablet, false);
      expect(info.toString(), contains('Google'));
      expect(info.toString(), contains('Pixel 7'));
    });

    test('Platform info toJson', () {
      final info = PlatformInfo(
        platform: 'ios',
        version: '16.0',
        sdkInt: 0,
        manufacturer: 'Apple',
        model: 'iPhone 14',
        isTablet: false,
      );

      final json = info.toJson();
      expect(json['platform'], 'ios');
      expect(json['version'], '16.0');
      expect(json['manufacturer'], 'Apple');
      expect(json['model'], 'iPhone 14');
      expect(json['isTablet'], false);
    });
  });

  group('Responsive Layout Service Tests', () {
    testWidgets('Screen size detection - small screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Simulate small phone screen (5")
              final mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(360, 640),
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    final size = ResponsiveLayoutService.getScreenSize(context);
                    expect(size, ScreenSize.small);
                    expect(ResponsiveLayoutService.isSmallScreen(context), true);
                    expect(ResponsiveLayoutService.isTablet(context), false);
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('Screen size detection - tablet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Simulate tablet screen (10")
              final mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(1024, 768),
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    final size = ResponsiveLayoutService.getScreenSize(context);
                    expect(size, ScreenSize.extraLarge);
                    expect(ResponsiveLayoutService.isSmallScreen(context), false);
                    expect(ResponsiveLayoutService.isTablet(context), true);
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('Orientation detection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Portrait
              var mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(360, 640),
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    expect(ResponsiveLayoutService.isPortrait(context), true);
                    expect(ResponsiveLayoutService.isLandscape(context), false);
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('Responsive padding - phone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(360, 640),
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    final padding = ResponsiveLayoutService.getResponsivePadding(
                      context,
                      small: 16.0,
                      medium: 24.0,
                      large: 32.0,
                    );
                    expect(padding.left, 16.0);
                    expect(padding.right, 16.0);
                    expect(padding.top, 16.0);
                    expect(padding.bottom, 16.0);
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('Responsive padding - tablet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(1024, 768),
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    final padding = ResponsiveLayoutService.getResponsivePadding(
                      context,
                      small: 16.0,
                      medium: 24.0,
                      large: 32.0,
                    );
                    expect(padding.left, 32.0);
                    expect(padding.right, 32.0);
                    expect(padding.top, 32.0);
                    expect(padding.bottom, 32.0);
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('Responsive font size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(360, 640),
                textScaler: const TextScaler.linear(1.0),
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    final fontSize = ResponsiveLayoutService.getResponsiveFontSize(
                      context,
                      baseSize: 16.0,
                    );
                    expect(fontSize, greaterThan(0));
                    expect(fontSize, lessThanOrEqualTo(24.0));
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('Responsive font size with min/max constraints', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(360, 640),
                textScaler: const TextScaler.linear(2.0), // Large text scale
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    final fontSize = ResponsiveLayoutService.getResponsiveFontSize(
                      context,
                      baseSize: 16.0,
                      minSize: 12.0,
                      maxSize: 24.0,
                    );
                    expect(fontSize, greaterThanOrEqualTo(12.0));
                    expect(fontSize, lessThanOrEqualTo(24.0));
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('Grid columns - phone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(360, 640),
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    final columns = ResponsiveLayoutService.getGridColumns(
                      context,
                      phoneColumns: 2,
                      tabletColumns: 3,
                    );
                    expect(columns, 2);
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('Grid columns - tablet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(1024, 768),
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    final columns = ResponsiveLayoutService.getGridColumns(
                      context,
                      phoneColumns: 2,
                      tabletColumns: 3,
                    );
                    expect(columns, 3);
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('Touch target size minimum enforcement', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(360, 640),
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    // Test with size below minimum
                    final smallSize = ResponsiveLayoutService.getTouchTargetSize(
                      context,
                      baseSize: 30.0,
                    );
                    expect(smallSize, 48.0); // Should enforce minimum

                    // Test with size above minimum
                    final largeSize = ResponsiveLayoutService.getTouchTargetSize(
                      context,
                      baseSize: 60.0,
                    );
                    expect(largeSize, 60.0); // Should keep original
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('Adaptive value selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Phone
              var mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(360, 640),
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    final value = ResponsiveLayoutService.adaptiveValue<String>(
                      context,
                      phone: 'phone-value',
                      tablet: 'tablet-value',
                    );
                    expect(value, 'phone-value');
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('Context extension methods', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context).copyWith(
                size: const Size(360, 640),
              );

              return MediaQuery(
                data: mediaQuery,
                child: Builder(
                  builder: (context) {
                    expect(context.screenSize, ScreenSize.small);
                    expect(context.isPhone, true);
                    expect(context.isTablet, false);
                    expect(context.isPortrait, true);
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
    });
  });

  group('Screen Size Category Tests', () {
    test('Extra small screen detection', () {
      expect(ResponsiveLayoutService.breakpointSmall, 360.0);
    });

    test('Medium screen detection', () {
      expect(ResponsiveLayoutService.breakpointMedium, 600.0);
    });

    test('Large screen detection', () {
      expect(ResponsiveLayoutService.breakpointLarge, 840.0);
    });

    test('Extra large screen detection', () {
      expect(ResponsiveLayoutService.breakpointExtraLarge, 1024.0);
    });
  });
}
