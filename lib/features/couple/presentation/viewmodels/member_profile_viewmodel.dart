// ============================================================================
// MEMBER PROFILE VIEWMODEL
// ============================================================================
// Surnom et couleur de la personne connectée, dans les paramètres. Comme
// le reste de l'écran, chaque changement est enregistré aussitôt : la
// couleur au toucher, le surnom en quittant le champ.

import 'package:flutter/widgets.dart';
import '../../domain/entities/couple_failure.dart';
import '../../domain/entities/couple_member.dart';
import '../../domain/usecases/update_member_profile.dart';
import '../utils/couple_messages.dart';

class MemberProfileViewModel extends ChangeNotifier {
  final UpdateMemberProfile _updateMemberProfile;
  final String _coupleId;

  final TextEditingController nicknameController;

  // --- State : dernière version enregistrée ---
  CoupleMember _saved;
  int _selectedColor;
  bool _isSaving = false;
  String? _errorMessage;
  bool _isDisposed = false;

  MemberProfileViewModel({
    required UpdateMemberProfile updateMemberProfile,
    required String coupleId,
    required CoupleMember member,
  })  : _updateMemberProfile = updateMemberProfile,
        _coupleId = coupleId,
        _saved = member,
        _selectedColor = member.color,
        nicknameController = TextEditingController(text: member.nickname);

  // --- Getters ---
  int get selectedColor => _selectedColor;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> selectColor(int color) async {
    if (color == _selectedColor) return;
    _selectedColor = color;
    _notify();
    await _save();
  }

  // --- Appelé en quittant le champ ou à la validation du clavier ---
  Future<void> saveNickname() async {
    final validationError = validateNickname(nicknameController.text);
    if (validationError != null) {
      // --- Surnom vidé : on remet le précédent ---
      nicknameController.text = _saved.nickname;
      _errorMessage = validationError;
      _notify();
      return;
    }
    if (nicknameController.text.trim() == _saved.nickname) return;
    await _save();
  }

  Future<void> _save() async {
    final nickname = nicknameController.text.trim();
    final color = _selectedColor;

    _isSaving = true;
    _errorMessage = null;
    _notify();

    try {
      await _updateMemberProfile(
        coupleId: _coupleId,
        uid: _saved.uid,
        nickname: nickname,
        color: color,
      );
      _saved = _saved.copyWith(nickname: nickname, color: color);
    } on CoupleFailure catch (failure) {
      _errorMessage = coupleFailureMessage(failure.reason);
      _rollback();
    } catch (_) {
      _errorMessage = coupleFailureMessage(CoupleFailureReason.unknown);
      _rollback();
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  // --- Échec : on revient à ce qui est réellement enregistré ---
  void _rollback() {
    _selectedColor = _saved.color;
    nicknameController.text = _saved.nickname;
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    nicknameController.dispose();
    super.dispose();
  }
}
