// ============================================================================
// COUPLE END VIEWMODEL
// ============================================================================
// Actions sur la demande d'arrêt de la relation : la faire, y répondre,
// l'annuler. L'état de la demande (qui a accepté) vient de la relation,
// suivie en temps réel par CoupleSessionViewModel. Quand la relation est
// supprimée, la session passe à needsCouple et GoRouter change d'écran.

import 'package:flutter/foundation.dart';
import '../../domain/entities/couple_failure.dart';
import '../../domain/usecases/cancel_couple_end.dart';
import '../../domain/usecases/request_couple_end.dart';
import '../../domain/usecases/respond_to_couple_end.dart';
import '../utils/couple_messages.dart';

class CoupleEndViewModel extends ChangeNotifier {
  final RequestCoupleEnd _requestCoupleEnd;
  final RespondToCoupleEnd _respondToCoupleEnd;
  final CancelCoupleEnd _cancelCoupleEnd;

  // --- State ---
  bool _isBusy = false;
  String? _errorMessage;
  bool _isDisposed = false;

  CoupleEndViewModel({
    required RequestCoupleEnd requestCoupleEnd,
    required RespondToCoupleEnd respondToCoupleEnd,
    required CancelCoupleEnd cancelCoupleEnd,
  })  : _requestCoupleEnd = requestCoupleEnd,
        _respondToCoupleEnd = respondToCoupleEnd,
        _cancelCoupleEnd = cancelCoupleEnd;

  // --- Getters ---
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  // --- Chaque action renvoie true si elle a abouti ---
  Future<bool> requestEnd() => _run(() => _requestCoupleEnd());

  Future<bool> accept() => _run(() => _respondToCoupleEnd(accept: true));

  Future<bool> decline() => _run(() => _respondToCoupleEnd(accept: false));

  Future<bool> cancel() => _run(() => _cancelCoupleEnd());

  Future<bool> _run(Future<void> Function() action) async {
    if (_isBusy) return false;
    _isBusy = true;
    _errorMessage = null;
    _notify();

    try {
      await action();
      return true;
    } on CoupleFailure catch (failure) {
      _errorMessage = coupleFailureMessage(failure.reason);
      return false;
    } catch (_) {
      _errorMessage = coupleFailureMessage(CoupleFailureReason.unknown);
      return false;
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  // --- L'écran peut disparaître pendant l'appel (relation supprimée) ---
  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
