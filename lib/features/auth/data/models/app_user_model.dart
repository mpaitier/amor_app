// ============================================================================
// APP USER MODEL
// ============================================================================
// Passerelle entre le User de Firebase Auth et l'entité AppUser.

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    super.email,
    super.displayName,
  });

  factory AppUserModel.fromFirebaseUser(User user) {
    return AppUserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
    );
  }
}
