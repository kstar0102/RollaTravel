import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:RollaTravel/src/routing/app_router.dart';

class RollaTravel extends ConsumerWidget {
  const RollaTravel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(1125, 2436),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final goRouter = ref.watch(goRouterProvider);
        return MaterialApp.router(
          routerConfig: goRouter,
          debugShowCheckedModeBanner: false,
          title: 'RollaTravel',
          color: Colors.white,
        );
      },
    );
  }
}
