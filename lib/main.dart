import 'package:RollaTravel/src/utils/location.permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/app.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PermissionService().checkAndRequestLocationPermission();
  await _requestCameraPermissionAtStartup();
  // await Firebase.initializeApp();
  runApp(const ProviderScope(child: RollaTravel()));
}

Future<void> _requestCameraPermissionAtStartup() async {
  await Permission.camera
      .request(); // Just request permission without storing the result
}
