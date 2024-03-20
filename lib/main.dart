import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_notice_board_app/firebase_options.dart';
import 'package:flutter_notice_board_app/screen/camera_screen.dart';
import 'package:flutter_notice_board_app/screen/notice_board_screen.dart';
import 'package:flutter_notice_board_app/screen/pictures_screen.dart';
import 'package:flutter_notice_board_app/services/notification_service.dart';
import 'package:go_router/go_router.dart';

void main() async {
  // Ensure that Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase app with default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Retrieve the FCM token for the device
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("------------------------------------------------------------");
  print(fcmToken);
  print("------------------------------------------------------------");

  // Register a background message handler for Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

  // Initialize notification service for handling push notifications
  final notificationService = NotificationService();

  // Request permission for receiving notifications
  notificationService.requestNotificationPermission();

  // Initialize Firebase for handling notifications
  notificationService.firebaseInit();

  // Run the app with MyApp widget as the root widget
  runApp(const MyApp());
}

// MyApp widget is the root widget of the app
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router is used for routing with GoRouter
    return MaterialApp.router(
      title: 'Flutter Camera App',
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

// Background message handler for Firebase Messaging
Future<void> _backgroundHandler(RemoteMessage message) async {
  debugPrint("Handling in Background: ${message.messageId}");
}

// Router configuration for GoRouter
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const CameraScreen(); // Initial route: CameraScreen
      },
      routes: [
        GoRoute(
          path: 'pictures',
          builder: (context, state) {
            return const PicturesScreen(base64ImageList: []); // Nested route: PicturesScreen
          },
        ),
        GoRoute(
          path: 'notice',
          builder: (context, state) {
            return const NoticeBoardScreen(base64ImageList: []); // Nested route: NoticeBoardScreen
          },
        ),
      ],
    ),
  ],
);
