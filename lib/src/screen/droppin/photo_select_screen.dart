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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestCameraPermission();
    });
  }

  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      logger.i("Camera permission already granted");
      await _initializeCamera(); // ✅ Initialize camera immediately
    } else {
      // ✅ Show explanation dialog before requesting permission on iOS
      bool userAgreed = await _showPermissionExplanationDialog();

      if (userAgreed) {
        status = await Permission.camera.request();
        if (status.isGranted) {
          logger.i("Camera permission granted after request");
          await _initializeCamera();
        } else if (status.isPermanentlyDenied) {
          _showCameraPermissionDialog(); // 🚨 Open settings dialog
        }
      }
    }
  }

  Future<bool> _showPermissionExplanationDialog() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Camera Access Required"),
              content: const Text(
                  "This app needs access to your camera to take photos for your profile and posts. Please allow camera access."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // ❌ User denies permission
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // ✅ User agrees
                  },
                  child: const Text("Allow"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showCameraPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Camera Permission Needed"),
          content: const Text(
              "You have permanently denied camera access. Please enable it in Settings to use this feature."),
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

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.low, // Reduce memory issues
          enableAudio: false,
        );

        _initializeControllerFuture = _cameraController!.initialize();
        await _initializeControllerFuture;
        setState(
            () {}); // Trigger a rebuild to ensure the FutureBuilder gets the updated future
      } else {
        logger.i('No cameras available');
      }
    } catch (e) {
      logger.i('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// **Capture Image from Camera**
  Future<void> _getImageFromCamera() async {
    if (_isCapturing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      logger.e("Camera not ready");
      return; // Prevent multiple captures & check if the camera is ready
    }

    setState(() => _isCapturing = true); // Prevent multiple captures

    try {
      await _initializeControllerFuture; // Ensure camera is initialized

      await _cameraController!.setFocusMode(FocusMode.auto);
      await _cameraController!.setExposureMode(ExposureMode.auto);
      await Future.delayed(
          const Duration(milliseconds: 1500)); // Increased delay

      // **Wait for focus & exposure to lock before capture**
      if (_cameraController!.value.focusMode != FocusMode.locked) {
        await _cameraController!.setFocusMode(FocusMode.locked);
      }
      if (_cameraController!.value.exposureMode != ExposureMode.locked) {
        await _cameraController!.setExposureMode(ExposureMode.locked);
      }

      // **Take Picture**
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
      setState(() => _isCapturing = false); // Reset capturing state
    }
  }

  Future<void> _getImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Handle the selected image
        logger.i('Image selected from gallery: ${pickedFile.path}');
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
      logger.i(e);
    }
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: _onWillPop,
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
                    alignment: Alignment.center, // Center contents in the stack
                    children: [
                      Container(
                        color: Colors.grey[
                            300], // Set the background to a light gray color
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return CameraPreview(_cameraController!);
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                      Positioned(
                        bottom:
                            20, // Position the button 20 pixels from the bottom of the Stack
                        child: ElevatedButton(
                          onPressed: _getImageFromCamera,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding:
                                const EdgeInsets.all(20), // Adjust button size
                            backgroundColor:
                                Colors.white, // Set button color if desired
                          ),
                          child: _isCapturing
                              ? const CircularProgressIndicator() // Show loader if capturing
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
                onPressed: _getImageFromGallery,
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
