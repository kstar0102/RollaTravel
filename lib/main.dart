import 'package:RollaTravel/src/utils/location.permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PermissionService().checkAndRequestLocationPermission();
  // await Firebase.initializeApp();
  runApp(const ProviderScope(child: RollaTravel()));
}
