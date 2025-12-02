// This is a basic Flutter widget test for CollegePro app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:collegepro/main.dart';

void main() {
  // Setup for all tests
  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();
  });

  // Clean up after all tests
  tearDownAll(() async {
    await Hive.close();
  });

  group('CollegePro App Tests', () {
    testWidgets('App starts without crashing when Firebase is initialized', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const FinalYearProjectFinderApp(
        firebaseInitialized: true,
        securityInitialized: true,
      ));

      // Wait for the widget tree to settle
      await tester.pumpAndSettle();

      // Verify that the app starts without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Verify that the app has proper title
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, equals('CollegePro'));
    });
    
    testWidgets('App handles Firebase initialization failure gracefully', (WidgetTester tester) async {
      // Build our app with Firebase initialization failed
      await tester.pumpWidget(const FinalYearProjectFinderApp(
        firebaseInitialized: false,
        securityInitialized: false,
      ));

      // Wait for the widget tree to settle
      await tester.pumpAndSettle();

      // Verify that the app still starts and shows MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Verify that the app has proper title even when Firebase fails
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, equals('CollegePro'));
    });

    testWidgets('App has all required providers', (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(const FinalYearProjectFinderApp(
        firebaseInitialized: true,
        securityInitialized: true,
      ));

      // Wait for the widget tree to settle
      await tester.pumpAndSettle();

      // Verify that MultiProvider exists
      expect(find.byType(MultiProvider), findsOneWidget);
      
      // Verify that the app builds without throwing exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('App has proper theme configuration', (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(const FinalYearProjectFinderApp(
        firebaseInitialized: true,
        securityInitialized: true,
      ));

      // Wait for the widget tree to settle
      await tester.pumpAndSettle();

      // Get the MaterialApp widget
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      
      // Verify theme mode is set to system
      expect(materialApp.themeMode, equals(ThemeMode.system));
      
      // Verify that both light and dark themes are provided
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
      
      // Verify debug banner is disabled
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('App handles security initialization states', (WidgetTester tester) async {
      // Test with security initialized
      await tester.pumpWidget(const FinalYearProjectFinderApp(
        firebaseInitialized: true,
        securityInitialized: true,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);

      // Test with security not initialized
      await tester.pumpWidget(const FinalYearProjectFinderApp(
        firebaseInitialized: true,
        securityInitialized: false,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
