import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notice_board_app/main.dart';
import 'package:flutter_notice_board_app/screen/notice_board_screen.dart';
import 'package:flutter_notice_board_app/screen/pictures_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_notice_board_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flutter Notice Board App Integration Test', () {
    late List<CameraDescription> cameras;

    setUp(() async {
      cameras = await availableCameras();
    });

    testWidgets('takes a photo and navigates to the preview page',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Pump the CameraPage widget
      await tester.pumpWidget(const MaterialApp(home: CameraPage()));
      await tester.pumpAndSettle();

      // Call the _onTakePhotoPressed callback
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(seconds: 3));

      // Check if the preview page is displayed
      expect(find.byType(PreviewPage), findsOneWidget);

      // Check if the image is displayed
      final Finder imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('navigates to the pictures screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Pump the CameraPage widget
      await tester.pumpWidget(const MaterialApp(home: CameraPage()));
      await tester.pumpAndSettle();

      // Tap the pictures button
      await tester.tap(find.byIcon(Icons.photo));
      await tester.pumpAndSettle();

      // Check if the pictures screen is displayed
      expect(find.byType(PicturesScreen), findsOneWidget);
    });

    testWidgets('navigates to the notice board screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Pump the CameraPage widget
      await tester.pumpWidget(const MaterialApp(home: CameraPage()));
      await tester.pumpAndSettle();

      // Tap the notice button
      await tester.tap(find.byIcon(Icons.note));
      await tester.pumpAndSettle();

      // Check if the notice board screen is displayed
      expect(find.byType(NoticeBoardScreen), findsOneWidget);
    });
  });
}
