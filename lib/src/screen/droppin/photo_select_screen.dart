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
  FlashMode _currentFlashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCameraPermission();
    });
  }

  /// **Check and request camera permission correctly**
  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      logger.i("✅ Camera permission already granted");
      _initializeCamera();
    } else if (status.isDenied || status.isRestricted || status.isLimited) {
      logger.e("🚨 Camera permission denied or restricted");
      final newStatus = await Permission.camera.request();
      if (newStatus.isGranted) {
        _initializeCamera();
      } else {
        _showCameraPermissionDialog();
      }
    } else if (status.isPermanentlyDenied) {
      logger.e("🚨 Camera permission permanently denied");
      _showCameraPermissionDialog();
    }
  }

  /// **Show a settings dialog if the user permanently denies camera access**
  void _showCameraPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Camera Permission Needed",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "You have denied camera access. Please enable it in Settings to take a photo.",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await openAppSettings(); // ✅ Open app settings
                // ignore: use_build_context_synchronously
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text(
                "Open Settings",
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ❌ Cancel
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
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

        await _cameraController!.setFlashMode(FlashMode.auto);

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

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    // Cycle through flash modes
    FlashMode newFlashMode;
    if (_currentFlashMode == FlashMode.auto) {
      newFlashMode = FlashMode.always;
    } else if (_currentFlashMode == FlashMode.always) {
      newFlashMode = FlashMode.off;
    } else {
      newFlashMode = FlashMode.auto;
    }

    await _cameraController!.setFlashMode(newFlashMode);
    setState(() {
      _currentFlashMode = newFlashMode;
    });

    logger.i("⚡ Flash mode set to: $_currentFlashMode");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false, // Prevents popping by default
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            return; // Prevent pop action
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: vhh(context, 4)),
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/images/icons/logo.png', width: 90,
                    height: 80,),
              ),
              const Text(
                'Select photo to drop \non your map',
                style: TextStyle(
                    fontSize: 20, color: Colors.black, fontFamily: 'inter'),
                textAlign: TextAlign.center,
              ),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: vhh(context, 45),
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
                      Positioned(
                        top: 20,
                        right: 20,
                        child: IconButton(
                          icon: Icon(
                            _currentFlashMode == FlashMode.auto
                                ? Icons.flash_auto
                                : _currentFlashMode == FlashMode.always
                                    ? Icons.flash_on
                                    : Icons.flash_off,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _toggleFlash,
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
                  style: TextStyle(fontFamily: 'inter'),
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
