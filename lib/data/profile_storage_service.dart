part of '../main.dart';

/// Stores profile photos. Default [`FirestoreInlineProfileStorage`]: free on Firebase Spark.
abstract class ProfilePhotoStorage {
  Future<String> uploadProfilePhoto({
    required String uid,
    required Uint8List bytes,
    String contentType,
  });
}

/// Compresses to a small JPEG data URL stored in Firestore `photoUrl` (no paid storage).
class FirestoreInlineProfileStorage implements ProfilePhotoStorage {
  /// Stay well under Firestore's 1 MiB document limit (other profile fields too).
  static const int maxBytes = 450000;

  @override
  Future<String> uploadProfilePhoto({
    required String uid,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    if (bytes.length > maxBytes) {
      throw const AuthException(
        'Photo is too large. Use a smaller image or lower resolution (max ~400 KB).',
      );
    }

    final mime = contentType.startsWith('image/') ? contentType : 'image/jpeg';
    final encoded = base64Encode(bytes);
    return 'data:$mime;base64,$encoded';
  }

  static Uint8List? bytesFromPhotoUrl(String? photoUrl) {
    if (photoUrl == null || !photoUrl.startsWith('data:image')) return null;
    final comma = photoUrl.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(photoUrl.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }
}

/// Cloudflare R2 via auth-backend (`PROFILE_STORAGE=r2`).
class ApiProfileStorageService implements ProfilePhotoStorage {
  ApiProfileStorageService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    http.Client? client,
    String? baseUrl,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _client = client ?? http.Client(),
       _baseUrl = _normalizeBaseUrl(baseUrl ?? _defaultBaseUrl);

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final http.Client _client;
  final String _baseUrl;

  @override
  Future<String> uploadProfilePhoto({
    required String uid,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final token = await _firebaseAuth.currentUser?.getIdToken();
    if (token == null) {
      throw const AuthException('Please sign in again.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/users/me/profile-photo'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: 'avatar.jpg',
        ),
      );

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final photoUrl = decoded['photoUrl'] as String?;
      if (photoUrl == null || photoUrl.isEmpty) {
        throw BackendException(
          'Upload succeeded but no photo URL returned.',
          response.statusCode,
        );
      }
      return photoUrl;
    }

    throw BackendException(_errorMessage(response), response.statusCode);
  }

  static String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded['error']?.toString() ?? 'Photo upload failed.';
    } catch (_) {
      return 'Photo upload failed with status ${response.statusCode}.';
    }
  }

  static String _normalizeBaseUrl(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}

/// Firebase Storage — requires Blaze plan (`PROFILE_STORAGE=firebase`).
class FirebaseProfileStorageService implements ProfilePhotoStorage {
  FirebaseProfileStorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<String> uploadProfilePhoto({
    required String uid,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final ref = _storage.ref().child('users/$uid/profile/avatar.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }
}

ProfilePhotoStorage createProfilePhotoStorage() {
  switch (kProfileStorage) {
    case 'firebase':
      return FirebaseProfileStorageService();
    case 'r2':
      return ApiProfileStorageService();
    default:
      return FirestoreInlineProfileStorage();
  }
}
