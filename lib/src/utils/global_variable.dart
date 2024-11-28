// lib/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isTripStartedProvider = StateProvider<bool>((ref) => false);

class GlobalVariables {
  static int? userId;
  static String? userName;
  static String? realName;
  static String? bio;
  static String? happyPlace;
  static String? odometer;
  static String? garage;
  static String? garageLogoUrl;
  static String? userImageUrl;
  static int? tripCount;
  static String? followingIds;
  static List<dynamic>? dropPinsData;
}
