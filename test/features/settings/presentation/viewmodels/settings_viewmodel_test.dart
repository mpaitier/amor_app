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
import 'package:amor_app/features/gif/domain/repositories/gif_repository.dart';
import 'package:amor_app/features/gif/domain/usecases/get_random_gif.dart';

class MockCoupleSettingsRepository extends Mock
    implements CoupleSettingsRepository {}

class _FakeCoupleSettingsEntity extends Fake implements CoupleSettingsEntity {}

class MockGifRepository extends Mock implements GifRepository {}

void main() {
  late MockCoupleSettingsRepository mockRepository;
  late MockGifRepository mockGifRepository;
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
    mockGifRepository = MockGifRepository();
    when(() => mockGifRepository.getRandomGifUrl(any()))
        .thenAnswer((_) async => 'https://gif/anniversaire');

    viewModel = SettingsViewModel(
      watchCoupleSettings: WatchCoupleSettings(mockRepository),
      saveCoupleSettings: SaveCoupleSettings(mockRepository),
      getRandomGif: GetRandomGif(mockGifRepository),
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

  test('doit tirer un GIF à la première activation de l\'anniversaire',
      () async {
    settingsController.add(tSettings);
    await flushStream();

    await viewModel.setShowAnniversary(true);

    expect(viewModel.settings.anniversaryStyle.gifUrl, 'https://gif/anniversaire');
    expect(lastSaved().anniversaryStyle.gifUrl, 'https://gif/anniversaire');
    verify(() => mockGifRepository.getRandomGifUrl('hedgehog cute')).called(1);
  });

  test('ne doit pas tirer de nouveau GIF si l\'anniversaire en a déjà un', () async {
    settingsController.add(
      tSettings.copyWith(
        anniversaryStyle: CoupleSettingsEntity.defaultAnniversaryStyle
            .copyWith(gifUrl: 'https://gif/existant'),
      ),
    );
    await flushStream();

    await viewModel.setShowAnniversary(true);

    verifyNever(() => mockGifRepository.getRandomGifUrl(any()));
  });

  test('doit changer le GIF des mois-anniversaires à la demande', () async {
    settingsController.add(tSettings);
    await flushStream();

    await viewModel.drawMonthAnniversaryGif();

    expect(viewModel.isMonthAnniversaryGifLoading, isFalse);
    expect(lastSaved().monthAnniversaryStyle.gifUrl, 'https://gif/anniversaire');
  });

  test('doit garder le GIF si le tirage échoue', () async {
    when(() => mockGifRepository.getRandomGifUrl(any()))
        .thenAnswer((_) async => null);
    settingsController.add(tSettings);
    await flushStream();

    await viewModel.drawAnniversaryGif();

    expect(viewModel.isAnniversaryGifLoading, isFalse);
    verifyNever(() => mockRepository.saveSettings(any()));
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

  test('doit enregistrer le terme de recherche des GIF, nettoyé', () async {
    settingsController.add(tSettings);
    await flushStream();

    await viewModel.setGifSearchTerm('  penguin hug ');

    expect(viewModel.settings.gifSearchTerm, 'penguin hug');
    expect(lastSaved().gifSearchTerm, 'penguin hug');
  });

  test('doit reprendre le terme d\'origine pour un terme vide', () async {
    settingsController.add(tSettings.copyWith(gifSearchTerm: 'penguin'));
    await flushStream();

    await viewModel.setGifSearchTerm('   ');

    expect(lastSaved().gifSearchTerm, 'hedgehog cute');
  });

  test('ne doit pas réenregistrer un terme inchangé', () async {
    settingsController.add(tSettings);
    await flushStream();

    await viewModel.setGifSearchTerm('hedgehog cute');

    verifyNever(() => mockRepository.saveSettings(any()));
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
