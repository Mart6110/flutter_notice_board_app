import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notice_board_app/screen/notice_board_screen.dart';
import 'package:flutter_notice_board_app/screen/pictures_screen.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_notice_board_app/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  debugPrint("Handling in Background: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("------------------------------------------------------------");
  print(fcmToken);
  print("------------------------------------------------------------");

  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

  final notificationService = NotificationService();

  notificationService.requestNotificationPermission();
  notificationService.firebaseInit();

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const CameraPage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'pictures',
          builder: (BuildContext context, GoRouterState state) {
            return const PicturesScreen(
              base64ImageList: [],
            );
          },
        ),
        GoRoute(
          path: 'notice',
          builder: (BuildContext context, GoRouterState state) {
            return const NoticeBoardScreen(base64ImageList: []);
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Camera App',
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  late final List<CameraDescription> _cameras;
  bool _isRecording = false;
  List<String> _base64ImageList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    // Initialize the camera with the first camera in the list
    await onNewCameraSelected(_cameras.first);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<XFile?> capturePhoto() async {
    final CameraController? cameraController = _controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      await cameraController.setFlashMode(FlashMode.off);
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<XFile?> captureVideo() async {
    final CameraController? cameraController = _controller;
    try {
      setState(() {
        _isRecording = true;
      });
      await cameraController?.startVideoRecording();
      await Future.delayed(const Duration(seconds: 5));
      final video = await cameraController?.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      return video;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  void _onTakePhotoPressed(BuildContext context) async {
    final xFile = await capturePhoto();

    if (xFile != null) {
      final imageBytes = await xFile.readAsBytes();

      final base64Image = await compute(base64Encode, imageBytes);

      setState(() {
        _base64ImageList.add(base64Image);
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPage(
            base64Image: base64Image,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraInitialized) {
      return Scaffold(
        body: Column(
          children: [
            CameraPreview(_controller!),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRecording)
                  ElevatedButton(
                    onPressed: () => _onTakePhotoPressed(context),
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo),
              label: 'Pictures',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note),
              label: 'Notice',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushNamed(context, '/');
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PicturesScreen(
                    base64ImageList: _base64ImageList,
                  ),
                ),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoticeBoardScreen(
                    base64ImageList: _base64ImageList,
                  ),
                ),
              );
            }
          },
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Future<void> onNewCameraSelected(CameraDescription description) async {
    final previousCameraController = _controller;

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }
    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller!.value.isInitialized;
      });
    }
  }
}

class PreviewPage extends StatefulWidget {
  final String? base64Image;

  const PreviewPage({Key? key, this.base64Image}) : super(key: key);

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late ImageProvider imageProvider;

  @override
  void initState() {
    super.initState();
    if (widget.base64Image != null) {
      final Uint8List decodedBytes = base64Decode(widget.base64Image!);
      imageProvider = MemoryImage(decodedBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.base64Image != null
            ? Image(image: imageProvider, fit: BoxFit.cover)
            : Container(),
      ),
    );
  }
}
