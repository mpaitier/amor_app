// ============================================================================
// COUPLE MODEL
// ============================================================================
// Passerelle entre le document couples/{coupleId} et l'entité. Le document
// range les uid dans "members" (l'ordre d'arrivée) et les profils dans une
// map "profiles" indexée par uid.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/couple_end_request.dart';
import '../../domain/entities/couple_entity.dart';
import '../../domain/entities/couple_member.dart';

class CoupleModel extends CoupleEntity {
  // --- Couleur d'un membre dont le profil manque encore ---
  static const int fallbackColor = 0xFF703348;

  const CoupleModel({
    required super.id,
    required super.members,
    required super.inviteCode,
    super.endRequest,
  });

  factory CoupleModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final memberIds = (data['members'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList();
    final profiles = data['profiles'] is Map
        ? Map<String, dynamic>.from(data['profiles'] as Map)
        : const <String, dynamic>{};

    return CoupleModel(
      id: doc.id,
      inviteCode: data['inviteCode'] as String? ?? '',
      members: [
        for (final uid in memberIds) _memberFrom(uid, profiles[uid]),
      ],
      endRequest: _endRequestFrom(data['endRequest']),
    );
  }

  // --- Map "endRequest" écrite par les fonctions. null sans demande ---
  static CoupleEndRequest? _endRequestFrom(Object? raw) {
    if (raw is! Map) return null;
    final data = Map<String, dynamic>.from(raw);
    final requestedBy = data['requestedBy'];
    if (requestedBy is! String) return null;
    final requestedAt = data['requestedAt'];
    return CoupleEndRequest(
      requestedBy: requestedBy,
      requestedAt: requestedAt is Timestamp ? requestedAt.toDate() : null,
      acceptedBy: _stringList(data['acceptedBy']),
      declinedBy: _stringList(data['declinedBy']),
    );
  }

  static List<String> _stringList(Object? raw) {
    return raw is List ? raw.whereType<String>().toList() : const [];
  }

  static CoupleMember _memberFrom(String uid, Object? rawProfile) {
    final profile = rawProfile is Map
        ? Map<String, dynamic>.from(rawProfile)
        : const <String, dynamic>{};
    final color = profile['color'];
    return CoupleMember(
      uid: uid,
      nickname: profile['nickname'] as String? ?? '',
      color: color is int ? color : fallbackColor,
    );
  }
}
