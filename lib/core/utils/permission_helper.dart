// ignore_for_file: avoid_print

import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestGalleryPermission() async {
    try {
      print('===== Requesting Gallery Permission =====');

      if (Platform.isAndroid) {
        print('Android device detected');

        print('Trying Permission.photos...');
        PermissionStatus photosStatus = await Permission.photos.request();
        print('Photos permission status: $photosStatus');

        if (photosStatus.isGranted) {
          print('✓ Photos permission granted');
          return true;
        }

        print('Trying Permission.storage...');
        PermissionStatus storageStatus = await Permission.storage.request();
        print('Storage permission status: $storageStatus');

        if (storageStatus.isGranted) {
          print('✓ Storage permission granted');
          return true;
        }

        print('✗ All permissions denied');
        return false;
      }

      print('iOS device detected');
      return await Permission.photos.request().isGranted;
    } catch (e) {
      print('Permission error: $e');
      return false;
    }
  }

  static Future<bool> requestCameraPermission() async {
    try {
      print('===== Requesting Camera Permission =====');
      PermissionStatus status = await Permission.camera.request();
      print('Camera permission status: $status');
      return status.isGranted;
    } catch (e) {
      print('Camera permission error: $e');
      return false;
    }
  }
}
