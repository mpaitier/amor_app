// ============================================================================
// SIGN IN VIEWMODEL
// ============================================================================
// État de l'écran de connexion : mode (connexion ou création de compte),
// champs du formulaire, chargement et messages. Ne navigue jamais : une
// fois connecté, c'est AuthSessionViewModel qui fait changer d'écran.

import 'package:flutter/widgets.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../utils/auth_messages.dart';

enum SignInMode { signIn, register }

class SignInViewModel extends ChangeNotifier {
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithEmail _signInWithEmail;
  final RegisterWithEmail _registerWithEmail;
  final SendPasswordReset _sendPasswordReset;

  // --- Champs du formulaire ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmationController = TextEditingController();

  // --- State ---
  SignInMode _mode = SignInMode.signIn;
  bool _isBusy = false;
  String? _errorMessage;
  String? _infoMessage;
  bool _isDisposed = false;

  SignInViewModel({
    required SignInWithGoogle signInWithGoogle,
    required SignInWithEmail signInWithEmail,
    required RegisterWithEmail registerWithEmail,
    required SendPasswordReset sendPasswordReset,
  })  : _signInWithGoogle = signInWithGoogle,
        _signInWithEmail = signInWithEmail,
        _registerWithEmail = registerWithEmail,
        _sendPasswordReset = sendPasswordReset;

  // --- Getters ---
  SignInMode get mode => _mode;
  bool get isRegistering => _mode == SignInMode.register;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;

  // --- Bascule connexion / création de compte ---
  void toggleMode() {
    if (_isBusy) return;
    _mode = isRegistering ? SignInMode.signIn : SignInMode.register;
    confirmationController.clear();
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  Future<void> continueWithGoogle() async {
    await _run(() async {
      await _signInWithGoogle();
    });
  }

  // --- Bouton principal : se connecter ou créer le compte selon le mode ---
  Future<void> submitEmail() async {
    final email = emailController.text;
    final password = passwordController.text;

    final validationError = validateEmail(email) ??
        validatePassword(password, isRegistering: isRegistering) ??
        (isRegistering
            ? validateConfirmation(password, confirmationController.text)
            : null);
    if (validationError != null) {
      _setMessages(error: validationError);
      return;
    }

    await _run(() async {
      if (isRegistering) {
        await _registerWithEmail(email: email, password: password);
      } else {
        await _signInWithEmail(email: email, password: password);
      }
    });
  }

  // --- Mot de passe oublié : utilise l'adresse déjà saisie ---
  Future<void> resetPassword() async {
    final email = emailController.text;
    final validationError = validateEmail(email);
    if (validationError != null) {
      _setMessages(error: validationError);
      return;
    }

    final sent = await _run(() => _sendPasswordReset(email));
    if (sent) {
      _setMessages(
        info: 'Un e-mail pour choisir un nouveau mot de passe vient de '
            'partir vers ${email.trim()}.',
      );
    }
  }

  // --- Enveloppe commune : chargement, messages, erreurs traduites.
  // --- Renvoie true si l'action a réussi ---
  Future<bool> _run(Future<void> Function() action) async {
    if (_isBusy) return false;
    _isBusy = true;
    _errorMessage = null;
    _infoMessage = null;
    _notify();

    try {
      await action();
      return true;
    } on AuthFailure catch (failure) {
      _errorMessage = authFailureMessage(failure.reason);
      return false;
    } catch (_) {
      _errorMessage = authFailureMessage(AuthFailureReason.unknown);
      return false;
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  void _setMessages({String? error, String? info}) {
    _errorMessage = error;
    _infoMessage = info;
    _notify();
  }

  // --- L'écran peut disparaître pendant l'appel (connexion réussie) ---
  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    emailController.dispose();
    passwordController.dispose();
    confirmationController.dispose();
    super.dispose();
  }
}
