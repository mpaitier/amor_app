// ============================================================================
// COUPLE SETTINGS ENTITY
// ============================================================================
// Réglages partagés par le couple : le jour où l'histoire a commencé, et
// l'affichage de l'anniversaire et des mois-anniversaires dans le
// calendrier. Modèle de domaine pur, sans Firestore ni Flutter.

import '../../../../core/constants/app_constants.dart';
import 'special_day_style.dart';

class CoupleSettingsEntity {
  // --- Styles proposés tant que rien n'a été choisi ---
  static const SpecialDayStyle defaultAnniversaryStyle = SpecialDayStyle(
    emoji: '💍',
    backgroundColor: 0xFFFFD9E2,
    borderColor: 0xFF703348,
  );
  static const SpecialDayStyle defaultMonthAnniversaryStyle = SpecialDayStyle(
    emoji: '❤️',
    backgroundColor: 0xFFFFFFFF,
    borderColor: 0xFFE91E63,
  );

  final DateTime relationshipStart;
  final bool showAnniversary;
  final SpecialDayStyle anniversaryStyle;
  final bool showMonthAnniversaries;
  final SpecialDayStyle monthAnniversaryStyle;

  const CoupleSettingsEntity({
    required this.relationshipStart,
    this.showAnniversary = false,
    this.anniversaryStyle = defaultAnniversaryStyle,
    this.showMonthAnniversaries = false,
    this.monthAnniversaryStyle = defaultMonthAnniversaryStyle,
  });

  // --- Réglages d'origine : la date de début reprend celle qui était
  // --- jusqu'ici écrite en dur dans app_constants.dart ---
  factory CoupleSettingsEntity.defaults() {
    return CoupleSettingsEntity(
      relationshipStart: DateTime(
        relationStartYear,
        relationStartMonth,
        relationStartDay,
      ),
    );
  }

  CoupleSettingsEntity copyWith({
    DateTime? relationshipStart,
    bool? showAnniversary,
    SpecialDayStyle? anniversaryStyle,
    bool? showMonthAnniversaries,
    SpecialDayStyle? monthAnniversaryStyle,
  }) {
    return CoupleSettingsEntity(
      relationshipStart: relationshipStart ?? this.relationshipStart,
      showAnniversary: showAnniversary ?? this.showAnniversary,
      anniversaryStyle: anniversaryStyle ?? this.anniversaryStyle,
      showMonthAnniversaries:
          showMonthAnniversaries ?? this.showMonthAnniversaries,
      monthAnniversaryStyle:
          monthAnniversaryStyle ?? this.monthAnniversaryStyle,
    );
  }

  // --- Jour du début, un mois donné. Un 31 est ramené au dernier jour des
  // --- mois plus courts, un 29 février au 28 ---
  DateTime _dayInMonth(int year, int month) {
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = relationshipStart.day > lastDayOfMonth
        ? lastDayOfMonth
        : relationshipStart.day;
    return DateTime(year, month, day);
  }

  // --- Rang d'un mois depuis l'an 0, pour compter les mois écoulés ---
  static int _serial(int year, int month) => year * 12 + (month - 1);

  // --- Nombre d'années fêtées ce jour-là, ou null si ce n'est pas un
  // --- anniversaire. Le jour du début lui-même n'en est pas un ---
  int? anniversaryNumberOn(DateTime day) {
    final years = day.year - relationshipStart.year;
    if (years < 1) return null;

    final anniversary = _dayInMonth(day.year, relationshipStart.month);
    final target = DateTime(day.year, day.month, day.day);
    return target == anniversary ? years : null;
  }

  // --- Nombre de mois fêtés ce jour-là, ou null si ce n'est pas un
  // --- mois-anniversaire ---
  int? monthAnniversaryNumberOn(DateTime day) {
    final months = _serial(day.year, day.month) -
        _serial(relationshipStart.year, relationshipStart.month);
    if (months < 1) return null;

    final target = DateTime(day.year, day.month, day.day);
    return target == _dayInMonth(day.year, day.month) ? months : null;
  }

  // --- Prochain anniversaire, à partir de `from` inclus ---
  DateTime nextAnniversary(DateTime from) {
    final fromDay = DateTime(from.year, from.month, from.day);
    final firstYear = relationshipStart.year + 1;
    final year = fromDay.year > firstYear ? fromDay.year : firstYear;

    final candidate = _dayInMonth(year, relationshipStart.month);
    if (!candidate.isBefore(fromDay)) return candidate;
    return _dayInMonth(year + 1, relationshipStart.month);
  }

  // --- Prochain mois-anniversaire, à partir de `from` inclus ---
  DateTime nextMonthAnniversary(DateTime from) {
    final fromDay = DateTime(from.year, from.month, from.day);
    final firstSerial =
        _serial(relationshipStart.year, relationshipStart.month) + 1;
    final fromSerial = _serial(fromDay.year, fromDay.month);
    final serial = fromSerial > firstSerial ? fromSerial : firstSerial;

    final candidate = _dayInMonth(serial ~/ 12, serial % 12 + 1);
    if (!candidate.isBefore(fromDay)) return candidate;
    return _dayInMonth((serial + 1) ~/ 12, (serial + 1) % 12 + 1);
  }
}
