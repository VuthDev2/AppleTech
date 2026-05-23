part of '../main.dart';

Future<bool> ensurePhotoLibraryPermission() async {
  if (kIsWeb) return true;

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      final photos = await Permission.photos.request();
      if (photos.isGranted || photos.isLimited) return true;
      final storage = await Permission.storage.request();
      return storage.isGranted;
    case TargetPlatform.iOS:
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    default:
      return true;
  }
}

Future<XFile?> pickProfileImage(ImagePicker picker) async {
  final allowed = await ensurePhotoLibraryPermission();
  if (!allowed) {
    throw const PhotoPermissionException();
  }

  return picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 512,
    imageQuality: 70,
    requestFullMetadata: false,
  );
}

class PhotoPermissionException implements Exception {
  const PhotoPermissionException();

  @override
  String toString() =>
      'Photo access was denied. Allow photos in Settings and try again.';
}
