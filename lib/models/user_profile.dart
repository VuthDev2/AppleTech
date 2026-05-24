import 'package:flutter/foundation.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.isAdmin = false,
    this.photoUrl,
  });

  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final bool isAdmin;
  final String? photoUrl;
}
