// ============================================================================
// COUPLE SETUP VIEWMODEL
// ============================================================================
// Écran affiché à une personne connectée qui n'a pas encore de relation :
// en créer une, ou en rejoindre une avec un code. Ne navigue jamais : une
// fois la relation enregistrée, CoupleSessionViewModel fait changer
// d'écran.

import 'package:flutter/widgets.dart';
import '../../domain/entities/couple_failure.dart';
import '../../domain/usecases/create_couple.dart';
import '../../domain/usecases/join_couple.dart';
import '../models/member_color_palette.dart';
import '../models/pending_invite.dart';
import '../utils/couple_messages.dart';

enum CoupleSetupMode { create, join }

class CoupleSetupViewModel extends ChangeNotifier {
  final CreateCouple _createCouple;
  final JoinCouple _joinCouple;
  final PendingInvite _pendingInvite;

  // --- Champs du formulaire ---
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  // --- State ---
  late CoupleSetupMode _mode;
  int _selectedColor = MemberColorPalette.defaultColor;
  bool _isBusy = false;
  String? _errorMessage;
  bool _isDisposed = false;

  CoupleSetupViewModel({
    required CreateCouple createCouple,
    required JoinCouple joinCouple,
    required PendingInvite pendingInvite,
  })  : _createCouple = createCouple,
        _joinCouple = joinCouple,
        _pendingInvite = pendingInvite {
    // --- Arrivé par un lien : on part directement sur "Rejoindre" ---
    _mode = CoupleSetupMode.create;
    _applyPendingInvite();
    _pendingInvite.addListener(_onPendingInviteChanged);
  }

  // --- Getters ---
  CoupleSetupMode get mode => _mode;
  bool get isJoining => _mode == CoupleSetupMode.join;
  int get selectedColor => _selectedColor;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  void selectMode(CoupleSetupMode mode) {
    if (_isBusy || mode == _mode) return;
    _mode = mode;
    _errorMessage = null;
    _notify();
  }

  void selectColor(int color) {
    if (_isBusy) return;
    _selectedColor = color;
    _notify();
  }

  Future<void> submit() async {
    final nickname = nicknameController.text;
    final validationError = validateNickname(nickname) ??
        (isJoining ? validateInviteCode(codeController.text) : null);
    if (validationError != null) {
      _errorMessage = validationError;
      _notify();
      return;
    }

    _isBusy = true;
    _errorMessage = null;
    _notify();

    try {
      if (isJoining) {
        await _joinCouple(
          code: codeController.text,
          nickname: nickname,
          color: _selectedColor,
        );
      } else {
        await _createCouple(nickname: nickname, color: _selectedColor);
      }
      _pendingInvite.clear();
    } on CoupleFailure catch (failure) {
      _errorMessage = coupleFailureMessage(failure.reason);
    } catch (_) {
      _errorMessage = coupleFailureMessage(CoupleFailureReason.unknown);
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  // --- Lien d'invitation reçu, avant ou pendant l'affichage de l'écran ---
  void _applyPendingInvite() {
    final code = _pendingInvite.code;
    if (code == null) return;
    codeController.text = code;
    _mode = CoupleSetupMode.join;
  }

  void _onPendingInviteChanged() {
    if (_isBusy) return;
    _applyPendingInvite();
    _notify();
  }

  // --- L'écran peut disparaître pendant l'appel (relation créée) ---
  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pendingInvite.removeListener(_onPendingInviteChanged);
    nicknameController.dispose();
    codeController.dispose();
    super.dispose();
  }
}
