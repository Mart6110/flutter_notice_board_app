import 'package:flutter_notice_board_app/screen/camera_screen.dart';
import 'package:flutter_notice_board_app/screen/notice_board_screen.dart';
import 'package:flutter_notice_board_app/screen/pictures_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notice_board_app/main.dart' as app;



void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App should start and navigate to camera screen', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Check if the camera screen is initially displayed
    expect(find.byType(CameraScreen), findsOneWidget);

    // Tap on the "Pictures" bottom navigation bar item
    await tester.tap(find.byIcon(Icons.photo));
    await tester.pumpAndSettle();

    // Check if the PicturesScreen is displayed after navigation
    expect(find.byType(PicturesScreen), findsOneWidget);

    // Tap on the "Notice" bottom navigation bar item
    await tester.tap(find.byIcon(Icons.note));
    await tester.pumpAndSettle();

    // Check if the NoticeBoardScreen is displayed after navigation
    expect(find.byType(NoticeBoardScreen), findsOneWidget);
  });
}
