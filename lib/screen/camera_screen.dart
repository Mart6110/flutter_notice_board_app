import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notice_board_app/screen/notice_board_screen.dart';
import 'package:flutter_notice_board_app/screen/pictures_screen.dart';
import 'package:flutter_notice_board_app/screen/preview_screen.dart';

// CameraScreen widget manages the camera functionality
class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

// CameraScreenState class manages the state of the CameraScreen widget
class CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller; // Camera controller instance
  bool _isCameraInitialized = false; // Flag indicating if camera is initialized
  late final List<CameraDescription> _cameras; // List of available cameras
  final List<String> _base64ImageList = []; // List of base64 encoded images

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose camera controller
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  // Initialize the camera
  Future<void> initCamera() async {
    _cameras = await availableCameras(); // Get available cameras
    await onNewCameraSelected(_cameras.first); // Initialize the first camera
  }

  // Switch to a new camera
  Future<void> onNewCameraSelected(CameraDescription description) async {
    final previousCameraController = _controller;

    // Instantiate the camera controller
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

    // Update the camera initialized flag
    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller!.value.isInitialized;
      });
    }
  }

  // Capture a photo
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
      debugPrint('Error occurred while taking picture: $e');
      return null;
    }
  }

  // Callback function when the 'Take Photo' button is pressed
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
          builder: (context) => PreviewScreen(
            base64Image: base64Image,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the camera screen UI
    if (_isCameraInitialized) {
      return Scaffold(
        body: Stack(
          children: [
            CameraPreview(_controller!), // Display the camera preview
            Positioned(
              bottom: 20.0,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: ElevatedButton(
                onPressed: () => _onTakePhotoPressed(context), // Take photo button
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.white,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                ),
              ),
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
            // Navigate to different screens based on bottom navigation bar selection
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
}
