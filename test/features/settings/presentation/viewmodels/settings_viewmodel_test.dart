// ============================================================================
// TEST UNITAIRE : SettingsViewModel
// ============================================================================
// Les use cases sont réels, branchés sur un repository factice dont on
// pilote le flux avec un StreamController.

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/settings/domain/entities/couple_settings_entity.dart';
import 'package:amor_app/features/settings/domain/entities/special_day_style.dart';
import 'package:amor_app/features/settings/domain/repositories/couple_settings_repository.dart';
import 'package:amor_app/features/settings/domain/usecases/save_couple_settings.dart';
import 'package:amor_app/features/settings/domain/usecases/watch_couple_settings.dart';
import 'package:amor_app/features/settings/presentation/viewmodels/settings_viewmodel.dart';

class MockCoupleSettingsRepository extends Mock
    implements CoupleSettingsRepository {}

class _FakeCoupleSettingsEntity extends Fake implements CoupleSettingsEntity {}

void main() {
  late MockCoupleSettingsRepository mockRepository;
  late StreamController<CoupleSettingsEntity> settingsController;
  late SettingsViewModel viewModel;

  Future<void> flushStream() => Future<void>.delayed(Duration.zero);

  final tSettings = CoupleSettingsEntity(
    relationshipStart: DateTime(2023, 12, 12),
  );

  setUpAll(() {
    registerFallbackValue(_FakeCoupleSettingsEntity());
  });

  setUp(() {
    mockRepository = MockCoupleSettingsRepository();
    settingsController = StreamController<CoupleSettingsEntity>();
    when(() => mockRepository.watchSettings())
        .thenAnswer((_) => settingsController.stream);
    when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});

    viewModel = SettingsViewModel(
      watchCoupleSettings: WatchCoupleSettings(mockRepository),
      saveCoupleSettings: SaveCoupleSettings(mockRepository),
      now: DateTime(2026, 11, 13, 13, 23),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await settingsController.close();
  });

  CoupleSettingsEntity lastSaved() {
    return verify(() => mockRepository.saveSettings(captureAny()))
        .captured
        .last as CoupleSettingsEntity;
  }

  test('doit charger tant que le flux n\'a rien émis', () {
    expect(viewModel.isLoading, isTrue);
  });

  test('doit exposer les réglages reçus', () async {
    settingsController.add(tSettings.copyWith(showAnniversary: true));
    await flushStream();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.settings.showAnniversary, isTrue);
  });

  test('doit calculer les prochains jours spéciaux pour l\'aperçu', () async {
    settingsController.add(tSettings);
    await flushStream();

    expect(viewModel.nextAnniversary, DateTime(2026, 12, 12));
    expect(viewModel.nextAnniversaryNumber, 3);
    expect(viewModel.nextMonthAnniversary, DateTime(2026, 12, 12));
    expect(viewModel.nextMonthAnniversaryNumber, 36);
  });

  test('doit enregistrer aussitôt l\'affichage de l\'anniversaire', () async {
    settingsController.add(tSettings);
    await flushStream();

    await viewModel.setShowAnniversary(true);

    expect(viewModel.settings.showAnniversary, isTrue);
    expect(lastSaved().showAnniversary, isTrue);
  });

  test('doit enregistrer le style des mois-anniversaires', () async {
    settingsController.add(tSettings);
    await flushStream();
    const style = SpecialDayStyle(
      emoji: '🎁',
      backgroundColor: 0xFFD9EAFF,
      borderColor: 0xFF2F6FDE,
    );

    await viewModel.setMonthAnniversaryStyle(style);

    expect(lastSaved().monthAnniversaryStyle, style);
  });

  test('doit retirer l\'heure de la date de début', () async {
    settingsController.add(tSettings);
    await flushStream();

    await viewModel.setRelationshipStart(DateTime(2023, 11, 30, 22, 10));

    expect(lastSaved().relationshipStart, DateTime(2023, 11, 30));
  });

  test('doit exposer un message si l\'enregistrement échoue', () async {
    when(() => mockRepository.saveSettings(any()))
        .thenThrow(Exception('Firestore indisponible'));
    settingsController.add(tSettings);
    await flushStream();

    await viewModel.setShowMonthAnniversaries(true);

    expect(viewModel.errorMessage, contains('Enregistrement impossible'));
  });
}
