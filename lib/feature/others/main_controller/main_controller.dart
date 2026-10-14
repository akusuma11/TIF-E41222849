import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:epic_story_app/core/services/firebase_service.dart';
import 'package:epic_story_app/core/services/google_auth_service.dart';
import 'package:epic_story_app/core/services/isar_service.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/core/utils/epic_snackbar.dart';
import 'package:epic_story_app/core/widgets/dialogs/loading_dialog.dart';
import 'package:epic_story_app/core/widgets/dialogs/reward_photo_viewer_dialog.dart';
import 'package:epic_story_app/domain/entities/children_entity.dart';
import 'package:epic_story_app/domain/usecases/book_usecase.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/flashcard_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MainController extends GetxController {
  final FirebaseService firebaseService = Get.find<FirebaseService>();
  final authService = Get.find<GoogleAuthService>();
  final isarService = Get.find<IsarService>();

  final RxBool _isLoadingPage = false.obs;
  int _loadingDialogToken = 0;

  bool get isLoadingPage => _isLoadingPage.value;

  var childrenData = Rxn<ChildrenEntity>();

  final ChildrenUsecase childrenUsecase;
  final FlashCardUsecase flashCardUsecase;
  final BookUsecase bookUsecase;

  MainController({
    required this.childrenUsecase,
    required this.flashCardUsecase,
    required this.bookUsecase,
  });

  @override
  void onInit() {
    super.onInit();
    // Safety net for hot-restart/resume where a modal barrier can remain visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hideLoadingPage(force: true);
    });
  }

  Future<bool> isConnectedToInternet() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      // Check if device has network connectivity
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // Additional check: try to reach a reliable server
        try {
          return true;
          // final result = await InternetAddress.lookup('google.com');
          // if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          //   EpicLog.debug('✅ Internet connection: Available');
          //   return true;
          // }
        } catch (e) {
          EpicLog.debug('❌ Internet connection: DNS lookup failed - $e');
          return false;
        }
      } else {
        EpicLog.debug('❌ Internet connection: No network connectivity');
        return false;
      }
    } catch (e) {
      EpicLog.debug('❌ Internet connection: Error checking connectivity - $e');
      return false;
    }
  }

  void showLoadingPage() {
    if (!_isLoadingPage.value && !(Get.isDialogOpen ?? false)) {
      _isLoadingPage.value = true;
      final token = ++_loadingDialogToken;
      try {
        Get.dialog(
          const UnconstrainedBox(
            child: Material(
              color: Colors.transparent,
              child: LoadingDialog(),
            ),
          ),
          barrierDismissible: false, // Prevent dismissing by tapping outside
          barrierColor: Colors.black.withOpacity(0.5),
          useSafeArea: true,
        );
        Future.delayed(
          const Duration(seconds: 10),
          () {
            if (_isLoadingPage.value && token == _loadingDialogToken) {
              hideLoadingPage();
            }
          },
        );
      } catch (e) {
        _isLoadingPage.value = false;
        EpicLog.debug('Error showing loading dialog: $e');
      }
    }
  }

  void hideLoadingPage({bool force = false}) {
    if (!_isLoadingPage.value && !force) return;

    _isLoadingPage.value = false;
    if (Get.isDialogOpen ?? false) {
      try {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        Get.back();
      } catch (e) {
        EpicLog.debug('Error closing loading dialog: $e');
      }
    }
  }

  void showRewardPhotoViewer({
    required List<String?> imageUrls,
    int initialIndex = 0,
  }) {
    final urls = imageUrls
        .whereType<String>()
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList(growable: false);

    if (urls.isEmpty) {
      EpicSnackBar.showWarningSnackBar(
        'Peringatan',
        'Gambar reward tidak tersedia.',
      );
      return;
    }

    final safeInitialIndex = initialIndex.clamp(0, urls.length - 1).toInt();

    Get.dialog(
      RewardPhotoViewerDialog(
        imageUrls: urls,
        initialIndex: safeInitialIndex,
        onDownload: downloadRewardImage,
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.85),
      useSafeArea: true,
    );
  }

  Future<void> downloadRewardImage(String imageUrl) async {
    if (!GetPlatform.isAndroid && !GetPlatform.isIOS) {
      EpicSnackBar.showWarningSnackBar(
        'Tidak Didukung',
        'Fitur simpan gambar hanya tersedia di Android/iOS.',
      );
      return;
    }

    try {
      EpicSnackBar.showPendingSnackBar(
        'Download',
        'Menyimpan gambar reward ke perangkat...',
        showLog: false,
      );

      final response = await Dio().get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        EpicSnackBar.showErrorSnackBar(
          'Gagal',
          'Gagal mengunduh gambar reward.',
        );
        return;
      }

      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final isGranted = await Gal.requestAccess();
        if (!isGranted) {
          EpicSnackBar.showWarningSnackBar(
            'Izin Ditolak',
            'Aplikasi butuh izin galeri untuk menyimpan gambar reward.',
          );
          return;
        }
      }

      final fileName = 'reward_${DateTime.now().millisecondsSinceEpoch}';
      await Gal.putImageBytes(
        Uint8List.fromList(bytes),
        name: fileName,
        album: 'Epic Story',
      );

      EpicSnackBar.showSuccessSnackBar(
        'Berhasil',
        'Gambar reward berhasil disimpan di galeri.',
        showLog: false,
      );
    } on MissingPluginException catch (e, s) {
      EpicLog.exception(e, s, this, 'downloadRewardImage - missing plugin');
      EpicSnackBar.showWarningSnackBar(
        'Perlu Restart Aplikasi',
        'Plugin simpan gambar belum aktif. Tutup aplikasi lalu jalankan ulang penuh.',
      );
    } on GalException catch (e, s) {
      EpicLog.exception(e, s, this, 'downloadRewardImage - gal exception');
      if (e.type == GalExceptionType.accessDenied) {
        EpicSnackBar.showWarningSnackBar(
          'Izin Ditolak',
          'Akses galeri ditolak. Izinkan akses galeri untuk menyimpan reward.',
        );
        return;
      }
      EpicSnackBar.showErrorSnackBar(
        'Gagal',
        'Tidak bisa menyimpan gambar reward. Coba lagi.',
      );
    } catch (e, s) {
      EpicLog.exception(e, s, this, 'downloadRewardImage');
      EpicSnackBar.showErrorSnackBar(
        'Gagal',
        'Terjadi kesalahan saat menyimpan gambar reward.',
      );
    }
  }

  Future<bool> loginGoogle({
    GoogleSignInAccount? googleSignIn,
  }) async {
    try {
      showLoadingPage();
      final bool isConnected = await isConnectedToInternet();

      if (!isConnected) {
        EpicLog.debug(
            'loginGoogle - Google Login Error: No internet connection');
        EpicSnackBar.showErrorSnackBar(
            "Failure", "Please check your internet connection.");
        return false;
      }

      GoogleSignInAccount? googleUser = googleSignIn;
      if (googleUser == null) {
        await authService.signOut();
        googleUser = await authService.signIn();
        if (googleUser == null) {
          EpicLog.debug(
              'loginGoogle - Google Login Error: User cancelled sign in');
          return false;
        }
      }

      if (!await firebaseService.loginWithGoogle(
          googleSignIn: googleUser, ignoreAnonymous: false)) {
        EpicLog.debug(
            'loginGoogle - Google Login Error: Firebase authentication failed');

        EpicSnackBar.showErrorSnackBar(
            "Failure", "Failed to authenticate with Firebase.");
      }

      await isarService.clearAllData();

      final remoteStudent = await childrenUsecase.getChildrenRemoteModel();
      childrenData.value = remoteStudent;

      EpicLog.debug('loginGoogle - Google Login: Login successful');
      return true;
    } catch (e, s) {
      EpicLog.exception(e, s, this,
          'loginGoogle - Error occurred while logging in with Google');
      return false;
    } finally {
      hideLoadingPage();
    }
  }

  Future<void> studentLogout() async {
    try {
      showLoadingPage();

      await Future.wait([
        childrenUsecase.logout(),
        firebaseService.logout(),
        authService.signOut(),
        isarService.clearAllData(),
      ]);

      EpicLog.debug('✅ Logout: User logged out successfully');
    } catch (e, s) {
      EpicLog.exception(e, s, this, 'studentLogout');
    } finally {
      hideLoadingPage();
    }
  }

  Future<void> testFetchFlashcardHistories({
    bool refreshLocal = false,
  }) async {
    try {
      EpicLog.debug('controller getFlashcardHistories');
      final histories = await childrenUsecase.testGetFlashcardHistories(
        refreshLocal: refreshLocal,
      );
      EpicLog.debug('controller getFlashcardHistories - result: $histories');
    } catch (e, s) {
      EpicLog.exception(e, s, this, 'testFetchFlashcardHistories');
    }
  }
}
