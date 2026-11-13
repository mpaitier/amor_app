// ============================================================================
// COUPLE SETTINGS MODEL
// ============================================================================
// Data Transfer Object : convertit le document Firestore des réglages en
// entité de domaine, et inversement. Chaque jour spécial est rangé dans sa
// propre map ("anniversary", "monthAnniversary").

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/couple_settings_entity.dart';
import '../../domain/entities/special_day_style.dart';

class CoupleSettingsModel extends CoupleSettingsEntity {
  const CoupleSettingsModel({
    required super.relationshipStart,
    super.showAnniversary,
    super.anniversaryStyle,
    super.showMonthAnniversaries,
    super.monthAnniversaryStyle,
  });

  // --- Construit le modèle depuis le document. Un champ absent reprend
  // --- la valeur d'origine ; un document absent donne les réglages
  // --- d'origine ---
  factory CoupleSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final defaults = CoupleSettingsEntity.defaults();
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return CoupleSettingsModel.fromEntity(defaults);

    final anniversary = _mapOf(data['anniversary']);
    final monthAnniversary = _mapOf(data['monthAnniversary']);
    final start = data['relationshipStart'];

    return CoupleSettingsModel(
      relationshipStart:
          start is Timestamp ? start.toDate() : defaults.relationshipStart,
      showAnniversary: anniversary['show'] ?? false,
      anniversaryStyle: _styleFrom(
        anniversary,
        CoupleSettingsEntity.defaultAnniversaryStyle,
      ),
      showMonthAnniversaries: monthAnniversary['show'] ?? false,
      monthAnniversaryStyle: _styleFrom(
        monthAnniversary,
        CoupleSettingsEntity.defaultMonthAnniversaryStyle,
      ),
    );
  }

  factory CoupleSettingsModel.fromEntity(CoupleSettingsEntity entity) {
    return CoupleSettingsModel(
      relationshipStart: entity.relationshipStart,
      showAnniversary: entity.showAnniversary,
      anniversaryStyle: entity.anniversaryStyle,
      showMonthAnniversaries: entity.showMonthAnniversaries,
      monthAnniversaryStyle: entity.monthAnniversaryStyle,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'relationshipStart': Timestamp.fromDate(relationshipStart),
      'anniversary': _specialDayToMap(showAnniversary, anniversaryStyle),
      'monthAnniversary':
          _specialDayToMap(showMonthAnniversaries, monthAnniversaryStyle),
    };
  }

  static Map<String, dynamic> _specialDayToMap(
    bool show,
    SpecialDayStyle style,
  ) {
    return {
      'show': show,
      'emoji': style.emoji,
      'backgroundColor': style.backgroundColor,
      'borderColor': style.borderColor,
    };
  }

  static Map<String, dynamic> _mapOf(Object? value) {
    return value is Map<String, dynamic> ? value : const {};
  }

  static SpecialDayStyle _styleFrom(
    Map<String, dynamic> data,
    SpecialDayStyle fallback,
  ) {
    return SpecialDayStyle(
      emoji: data['emoji'] ?? fallback.emoji,
      backgroundColor: data['backgroundColor'] ?? fallback.backgroundColor,
      borderColor: data['borderColor'] ?? fallback.borderColor,
    );
  }
}
