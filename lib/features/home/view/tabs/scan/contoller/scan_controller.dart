// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends ChangeNotifier {
  final ImagePicker _picker;

  ScanController({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  File? selectedImage;
  bool isLoading = false;

  Future<void> clearImage() async {
    selectedImage = null;
    notifyListeners();
  }

  Future<_PickResult> takePhoto() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (image == null) return _PickResult.cancelled();

        selectedImage = File(image.path);
        notifyListeners();
        return _PickResult.success('Photo captured successfully!');
      } catch (e) {
        return _PickResult.error('Failed to capture photo: $e');
      }
    }

    if (status.isPermanentlyDenied) {
      return _PickResult.permissionDenied(
        title: 'Camera Access Denied',
        message: 'Please enable camera access in Settings to take photos.',
        permission: Permission.camera,
      );
    }

    return _PickResult.error('Camera permission is required to take photos.');
  }

  Future<_PickResult> pickFromGallery() async {
    PermissionStatus status;
    if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (image == null) return _PickResult.cancelled();

        selectedImage = File(image.path);
        notifyListeners();
        return _PickResult.success('Image selected from gallery!');
      } catch (e) {
        return _PickResult.error('Failed to select image: $e');
      }
    }

    final permission = Platform.isIOS ? Permission.photos : Permission.storage;

    if (status.isPermanentlyDenied) {
      return _PickResult.permissionDenied(
        title: 'Gallery Access Denied',
        message: 'Please enable gallery access in Settings to select images.',
        permission: permission,
      );
    }

    return _PickResult.error('Gallery access permission is required.');
  }

  Future<void> analyze() async {
    if (selectedImage == null) return;

    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    isLoading = false;
    notifyListeners();
  }
}

class _PickResult {
  final bool ok;
  final bool cancelled;
  final String? message;

  final bool permissionDialog;
  final String? title;
  final Permission? permission;

  const _PickResult._({
    required this.ok,
    required this.cancelled,
    this.message,
    this.permissionDialog = false,
    this.title,
    this.permission,
  });

  factory _PickResult.success(String msg) =>
      _PickResult._(ok: true, cancelled: false, message: msg);

  factory _PickResult.error(String msg) =>
      _PickResult._(ok: false, cancelled: false, message: msg);

  factory _PickResult.cancelled() =>
      const _PickResult._(ok: false, cancelled: true);

  factory _PickResult.permissionDenied({
    required String title,
    required String message,
    required Permission permission,
  }) =>
      _PickResult._(
        ok: false,
        cancelled: false,
        message: message,
        permissionDialog: true,
        title: title,
        permission: permission,
      );
}
