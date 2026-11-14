// ============================================================================
// ACCOUNT VIEWMODEL
// ============================================================================
// Suppression du compte depuis les paramètres. Une fois le compte supprimé,
// la session se ferme et GoRouter renvoie vers l'écran de connexion.

import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/usecases/delete_account.dart';
import '../utils/auth_messages.dart';

class AccountViewModel extends ChangeNotifier {
  final DeleteAccount _deleteAccount;

  // --- State ---
  bool _isDeleting = false;
  String? _errorMessage;
  bool _isDisposed = false;

  AccountViewModel({required DeleteAccount deleteAccount})
      : _deleteAccount = deleteAccount;

  // --- Getters ---
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  // --- Renvoie true si le compte a été supprimé ---
  Future<bool> deleteAccount() async {
    if (_isDeleting) return false;
    _isDeleting = true;
    _errorMessage = null;
    _notify();

    try {
      await _deleteAccount();
      return true;
    } on AuthFailure catch (failure) {
      _errorMessage = authFailureMessage(failure.reason);
      return false;
    } catch (_) {
      _errorMessage = authFailureMessage(AuthFailureReason.unknown);
      return false;
    } finally {
      _isDeleting = false;
      _notify();
    }
  }

  // --- L'écran disparaît dès que la session se ferme ---
  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
