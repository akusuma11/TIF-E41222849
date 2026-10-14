import 'dart:ui';

import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/core/services/firebase_service.dart';
import 'package:epic_story_app/core/services/google_auth_service.dart';
import 'package:epic_story_app/core/services/isar_service.dart';
import 'package:epic_story_app/core/styles/epic_app_size.dart';
import 'package:epic_story_app/data/modules/book_module.dart';
import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/data/modules/flashcard_module.dart';
import 'package:epic_story_app/domain/usecases/book_usecase.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/flashcard_usecase.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/routes/epic_routes.dart';
// import 'animation_demo.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Menangkap error dari framework Flutter
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Menangkap error yang terjadi di luar Flutter (misal, dalam isolate)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await Future.wait([
    Get.putAsync(() async => GoogleAuthService()),
  ]);

  var firebaseApp = Firebase.app();
  await Get.putAsync<IsarService>(
    () async => await IsarService().init().timeout(const Duration(seconds: 20)),
  );
  await Get.putAsync<FirebaseService>(
    () async => await FirebaseService().init(firebaseApp: firebaseApp),
  );

  ChildrenModule();
  FlashCardModule();
  BookModule();

  Get.put<MainController>(MainController(
    childrenUsecase: Get.find<ChildrenUsecase>(),
    flashCardUsecase: Get.find<FlashCardUsecase>(),
    bookUsecase: Get.find<BookUsecase>(),
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    EpicSize.initialize(context);
    EpicAppSize.initialize(context);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Epic Story',
        initialRoute: EpicRoutes.initialRoute,
        getPages: EpicRoutes.routes,
        themeMode: ThemeMode.dark,
      ),
    );
  }
}
