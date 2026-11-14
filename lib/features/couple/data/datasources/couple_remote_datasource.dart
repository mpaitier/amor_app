// ============================================================================
// COUPLE REMOTE DATA SOURCE
// ============================================================================
// Lecture de la relation dans Firestore, création et adhésion par les
// Cloud Functions createCouple et joinCouple. Chaque échec ressort en
// CoupleException portant le code brut.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/stream_switch_map.dart';
import '../models/couple_model.dart';

class CoupleRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  static const String _usersCollection = 'users';
  static const String _couplesCollection = 'couples';

  const CoupleRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })  : _firestore = firestore,
        _functions = functions;

  // --- users/{uid}.coupleId, puis le document de cette relation. Si
  // --- l'identifiant change, l'ancien document n'est plus écouté ---
  Stream<CoupleModel?> watchCurrentCouple(String uid) {
    final coupleIds = _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.data()?['coupleId'] as String?)
        .distinct();

    return switchMapStream<String?, CoupleModel?>(coupleIds, (coupleId) {
      if (coupleId == null || coupleId.isEmpty) {
        return Stream<CoupleModel?>.value(null);
      }
      return _firestore
          .collection(_couplesCollection)
          .doc(coupleId)
          .snapshots()
          .map((snapshot) =>
              snapshot.exists ? CoupleModel.fromFirestore(snapshot) : null);
    });
  }

  // --- La date part en "AAAA-MM-JJ" : seul le jour compte, et la
  // --- fonction le range à midi UTC pour qu'aucun fuseau ne le décale ---
  Future<String> createCouple({
    required String nickname,
    required int color,
    required DateTime relationshipStart,
  }) async {
    final data = await _call('createCouple', {
      'nickname': nickname,
      'color': color,
      'relationshipStart': dayString(relationshipStart),
    });
    return data['coupleId'] as String;
  }

  // --- 2023-12-12 ---
  static String dayString(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<String> joinCouple({
    required String code,
    required String nickname,
    required int color,
  }) async {
    final data = await _call('joinCouple', {
      'code': code,
      'nickname': nickname,
      'color': color,
    });
    return data['coupleId'] as String;
  }

  // --- Les règles Firestore n'autorisent un membre qu'à modifier son
  // --- propre profil ---
  Future<void> updateMemberProfile({
    required String coupleId,
    required String uid,
    required String nickname,
    required int color,
  }) async {
    try {
      await _firestore.collection(_couplesCollection).doc(coupleId).update({
        'profiles.$uid': {'nickname': nickname, 'color': color},
      });
    } on FirebaseException catch (e) {
      throw CoupleException(e.code);
    }
  }

  // --- Appel d'une fonction. La réponse arrive en Map<Object?, Object?> :
  // --- on la recopie en Map<String, dynamic> ---
  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> payload,
  ) async {
    try {
      final result = await _functions.httpsCallable(name).call(payload);
      final data = result.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      throw const CoupleException('internal');
    } on FirebaseFunctionsException catch (e) {
      throw CoupleException(e.code);
    }
  }
}
