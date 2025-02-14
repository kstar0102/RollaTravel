import 'package:RollaTravel/src/screen/droppin/take_picture_screen.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';

class PhotoSelectScreen extends StatefulWidget {
  const PhotoSelectScreen({super.key});

  @override
  PhotoSelectScreenState createState() => PhotoSelectScreenState();
}

class PhotoSelectScreenState extends State<PhotoSelectScreen> {
  final int _currentIndex = 3;
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  final logger = Logger();
  final ImagePicker _picker = ImagePicker();
  bool _isCapturing = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestCameraPermission();
    });
  }

  /// **Requests camera permission and initializes camera**
  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      logger.i("✅ Camera permission granted");
      await _initializeCamera();
    } else if (status.isPermanentlyDenied) {
      _showCameraPermissionDialog(); // 🚨 Open settings dialog if permanently denied
    }
  }

  /// **Show a settings dialog if the user permanently denies camera access**
  void _showCameraPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Camera Permission Needed"),
          content: const Text(
              "You have denied camera access. Please enable it in Settings to take a photo."),
          actions: [
            TextButton(
              onPressed: () async {
                await openAppSettings(); // ✅ Open settings
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Open Settings"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ❌ Cancel
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  /// **Initializes the camera safely**
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset
              .medium, // Better quality while avoiding performance issues
          enableAudio: false,
        );

        _initializeControllerFuture = _cameraController!.initialize();
        await _initializeControllerFuture;

        setState(() {
          _isCameraInitialized = true;
        });

        logger.i("📷 Camera initialized successfully");
      } else {
        logger.e("🚨 No cameras available");
      }
    } catch (e) {
      logger.e("❌ Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// **Capture Image from Camera**
  Future<void> _capturePhoto() async {
    if (_isCapturing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      logger.e("🚨 Camera not ready");
      return; // Prevent multiple captures
    }

    setState(() => _isCapturing = true); // Prevent multiple captures

    try {
      await _initializeControllerFuture; // Ensure camera is initialized

      // Wait for focus & exposure before capturing
      await _cameraController!.setFocusMode(FocusMode.locked);
      await _cameraController!.setExposureMode(ExposureMode.locked);

      // Capture image
      final image = await _cameraController!.takePicture();
      logger.i('📸 Image captured at: ${image.path}');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TakePictureScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      logger.e('🚨 Error capturing image: $e');
      _initializeCamera();
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  /// **Pick Image from Gallery**
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        logger.i('📷 Image selected from gallery: ${pickedFile.path}');
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TakePictureScreen(imagePath: pickedFile.path),
            ),
          );
        }
      }
    } catch (e) {
      logger.e("❌ Error selecting image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async => false,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/images/icons/logo.png', height: 100),
              ),
              const Text(
                'Select photo to drop \non your map',
                style: TextStyle(
                    fontSize: 20, color: Colors.black, fontFamily: 'Kadaw'),
                textAlign: TextAlign.center,
              ),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: vhh(context, 50),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Gray placeholder if camera is not initialized
                      Container(
                        color: Colors.grey[300],
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      // Camera preview
                      if (_isCameraInitialized)
                        CameraPreview(_cameraController!)
                      else
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      // Capture Button
                      Positioned(
                        bottom: 20,
                        child: ElevatedButton(
                          onPressed: _capturePhoto,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            backgroundColor: Colors.white,
                          ),
                          child: _isCapturing
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.camera_alt,
                                  size: 30, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: const Text(
                  'Photo Library',
                  style: TextStyle(fontFamily: 'Kadaw'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
