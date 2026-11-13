// ============================================================================
// TEST UNITAIRE : UpcomingSpecialDaysViewModel
// ============================================================================

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/settings/domain/entities/couple_settings_entity.dart';
import 'package:amor_app/features/settings/domain/repositories/couple_settings_repository.dart';
import 'package:amor_app/features/settings/domain/usecases/get_upcoming_special_days.dart';
import 'package:amor_app/features/settings/domain/usecases/watch_couple_settings.dart';
import 'package:amor_app/features/timeline/presentation/viewmodels/upcoming_special_days_viewmodel.dart';

class MockCoupleSettingsRepository extends Mock
    implements CoupleSettingsRepository {}

void main() {
  late MockCoupleSettingsRepository mockRepository;
  late StreamController<CoupleSettingsEntity> settingsController;
  late UpcomingSpecialDaysViewModel viewModel;

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  final tSettings = CoupleSettingsEntity(
    relationshipStart: DateTime(2023, 12, 12),
  );

  setUp(() {
    mockRepository = MockCoupleSettingsRepository();
    settingsController = StreamController<CoupleSettingsEntity>();
    when(() => mockRepository.watchSettings())
        .thenAnswer((_) => settingsController.stream);

    viewModel = UpcomingSpecialDaysViewModel(
      watchCoupleSettings: WatchCoupleSettings(mockRepository),
      getUpcomingSpecialDays: const GetUpcomingSpecialDays(),
      now: DateTime(2026, 12, 13, 9),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await settingsController.close();
  });

  test('ne doit rien annoncer avant de recevoir les réglages', () {
    expect(viewModel.upcoming, isEmpty);
    expect(viewModel.today, DateTime(2026, 12, 13));
  });

  test('doit annoncer les jours spéciaux affichés et prévenir la vue',
      () async {
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    settingsController.add(
      tSettings.copyWith(showAnniversary: true, showMonthAnniversaries: true),
    );
    await flush();

    expect(viewModel.upcoming.map((day) => day.title), [
      '37 mois',
      '4e anniversaire',
    ]);
    expect(notifications, 1);
  });

  test('doit retirer l\'annonce quand l\'affichage est coupé', () async {
    settingsController.add(tSettings.copyWith(showAnniversary: true));
    await flush();

    settingsController.add(tSettings);
    await flush();

    expect(viewModel.upcoming, isEmpty);
  });

  test('doit rester vide si les réglages ne se chargent pas', () async {
    settingsController.addError(Exception('Erreur réseau'));
    await flush();

    expect(viewModel.upcoming, isEmpty);
  });
}
