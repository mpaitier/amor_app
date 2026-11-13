// ============================================================================
// TEST UNITAIRE : AddEditImportantDateViewModel
// ============================================================================
// Les use cases sont réels, branchés sur un repository factice.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/important_dates/domain/entities/important_date_entity.dart';
import 'package:amor_app/features/important_dates/domain/repositories/important_date_repository.dart';
import 'package:amor_app/features/important_dates/domain/usecases/add_important_date.dart';
import 'package:amor_app/features/important_dates/domain/usecases/update_important_date.dart';
import 'package:amor_app/features/important_dates/presentation/models/important_date_palette.dart';
import 'package:amor_app/features/important_dates/presentation/viewmodels/add_edit_important_date_viewmodel.dart';

class MockImportantDateRepository extends Mock
    implements ImportantDateRepository {}

// --- Fake utilisé uniquement pour enregistrer une valeur de repli auprès
// --- de mocktail (nécessaire pour matcher any() sur un type non natif) ---
class _FakeImportantDateEntity extends Fake implements ImportantDateEntity {}

void main() {
  late MockImportantDateRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(_FakeImportantDateEntity());
  });

  setUp(() {
    mockRepository = MockImportantDateRepository();
  });

  AddEditImportantDateViewModel buildViewModel({
    ImportantDateEntity? dateToEdit,
    DateTime? initialDate,
  }) {
    final viewModel = AddEditImportantDateViewModel(
      addImportantDate: AddImportantDate(mockRepository),
      updateImportantDate: UpdateImportantDate(mockRepository),
      dateToEdit: dateToEdit,
      initialDate: initialDate,
      now: DateTime(2026, 11, 13, 12, 56),
    );
    addTearDown(viewModel.dispose);
    return viewModel;
  }

  final tExisting = ImportantDateEntity(
    id: 'date_42',
    title: 'Anniversaire de Lulu',
    date: DateTime(2026, 12, 28),
    emoji: '🎂',
    recurrence: ImportantDateRecurrence.monthly,
    backgroundColor: 0xFFE6D9FF,
    borderColor: 0xFF7B4FD6,
  );

  group('état initial', () {
    test('doit proposer des valeurs par défaut en création', () {
      final viewModel = buildViewModel(
        initialDate: DateTime(2026, 12, 28, 18, 30),
      );

      expect(viewModel.isEditing, isFalse);
      expect(viewModel.titleController.text, isEmpty);
      expect(viewModel.selectedDate, DateTime(2026, 12, 28));
      expect(viewModel.today, DateTime(2026, 11, 13));
      expect(viewModel.selectedEmoji, ImportantDatePalette.emojis.first);
      expect(viewModel.recurrence, ImportantDateRecurrence.none);
      expect(viewModel.repeats, isFalse);
      expect(
        viewModel.backgroundColor,
        ImportantDateEntity.defaultBackgroundColor,
      );
      expect(viewModel.borderColor, ImportantDateEntity.defaultBorderColor);
    });

    test('doit reprendre la date existante en modification', () {
      final viewModel = buildViewModel(dateToEdit: tExisting);

      expect(viewModel.isEditing, isTrue);
      expect(viewModel.titleController.text, 'Anniversaire de Lulu');
      expect(viewModel.selectedDate, DateTime(2026, 12, 28));
      expect(viewModel.selectedEmoji, '🎂');
      expect(viewModel.recurrence, ImportantDateRecurrence.monthly);
      expect(viewModel.repeats, isTrue);
      expect(viewModel.backgroundColor, 0xFFE6D9FF);
      expect(viewModel.borderColor, 0xFF7B4FD6);
    });
  });

  group('saisie', () {
    test('doit retirer l\'heure du jour choisi', () {
      final viewModel = buildViewModel();

      viewModel.setDate(DateTime(2027, 2, 14, 21, 15));

      expect(viewModel.selectedDate, DateTime(2027, 2, 14));
    });

    test('doit prévenir la vue à chaque changement', () {
      final viewModel = buildViewModel();
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      viewModel.setEmoji('🎄');
      viewModel.setRepeats(true);
      viewModel.setBackgroundColor(0xFFD9F2E0);
      viewModel.setBorderColor(0xFF2E8B57);

      expect(viewModel.selectedEmoji, '🎄');
      expect(viewModel.repeats, isTrue);
      expect(viewModel.backgroundColor, 0xFFD9F2E0);
      expect(viewModel.borderColor, 0xFF2E8B57);
      expect(notifications, 4);
    });
  });

  group('répétition', () {
    test('doit partir sur tous les ans quand on l\'active', () {
      final viewModel = buildViewModel();

      viewModel.setRepeats(true);

      expect(viewModel.recurrence, ImportantDateRecurrence.yearly);
      expect(viewModel.repeats, isTrue);
    });

    test('doit laisser choisir une autre fréquence', () {
      final viewModel = buildViewModel();
      viewModel.setRepeats(true);

      viewModel.setRecurrence(ImportantDateRecurrence.monthly);

      expect(viewModel.recurrence, ImportantDateRecurrence.monthly);
    });

    test('doit revenir à une date ponctuelle quand on la coupe', () {
      final viewModel = buildViewModel();
      viewModel.setRecurrence(ImportantDateRecurrence.weekly);

      viewModel.setRepeats(false);

      expect(viewModel.recurrence, ImportantDateRecurrence.none);
      expect(viewModel.repeats, isFalse);
    });

    test('doit proposer tous les ans comme première fréquence', () {
      expect(
        ImportantDatePalette.recurrences.first,
        ImportantDateRecurrence.yearly,
      );
    });
  });

  group('draft', () {
    test('doit refléter le formulaire, titre nettoyé de ses espaces', () {
      final viewModel = buildViewModel(initialDate: DateTime(2026, 12, 28));
      viewModel.titleController.text = '  Départ à Lisbonne ';
      viewModel.setEmoji('✈️');

      final draft = viewModel.draft;

      expect(draft.id, isEmpty);
      expect(draft.title, 'Départ à Lisbonne');
      expect(draft.date, DateTime(2026, 12, 28));
      expect(draft.emoji, '✈️');
      expect(draft.nextOccurrence(viewModel.today), DateTime(2026, 12, 28));
    });

    test('doit proposer par défaut des couleurs présentes dans la palette', () {
      final draft = buildViewModel().draft;

      expect(ImportantDatePalette.backgroundColors, contains(draft.backgroundColor));
      expect(ImportantDatePalette.borderColors, contains(draft.borderColor));
    });
  });

  group('save', () {
    test('doit refuser un titre vide sans appeler le repository', () async {
      final viewModel = buildViewModel();
      viewModel.titleController.text = '   ';

      final saved = await viewModel.save();

      expect(saved, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      verifyZeroInteractions(mockRepository);
    });

    test('doit ajouter une nouvelle date avec les valeurs du formulaire',
        () async {
      when(() => mockRepository.addImportantDate(any()))
          .thenAnswer((_) async => 'new_id');
      final viewModel = buildViewModel(initialDate: DateTime(2026, 12, 28));
      viewModel.titleController.text = '  Départ à Lisbonne  ';
      viewModel.setEmoji('✈️');
      viewModel.setRecurrence(ImportantDateRecurrence.weekly);
      viewModel.setBackgroundColor(0xFFD9EAFF);
      viewModel.setBorderColor(0xFF2F6FDE);

      final saved = await viewModel.save();

      expect(saved, isTrue);
      expect(viewModel.isSaving, isFalse);
      final captured = verify(
        () => mockRepository.addImportantDate(captureAny()),
      ).captured.single as ImportantDateEntity;
      expect(captured.id, isEmpty);
      expect(captured.title, 'Départ à Lisbonne');
      expect(captured.date, DateTime(2026, 12, 28));
      expect(captured.emoji, '✈️');
      expect(captured.recurrence, ImportantDateRecurrence.weekly);
      expect(captured.backgroundColor, 0xFFD9EAFF);
      expect(captured.borderColor, 0xFF2F6FDE);
    });

    test('doit mettre à jour la date existante en gardant son id', () async {
      when(() => mockRepository.updateImportantDate(any()))
          .thenAnswer((_) async {});
      final viewModel = buildViewModel(dateToEdit: tExisting);
      viewModel.titleController.text = 'Anniversaire de ma Lulu';

      final saved = await viewModel.save();

      expect(saved, isTrue);
      final captured = verify(
        () => mockRepository.updateImportantDate(captureAny()),
      ).captured.single as ImportantDateEntity;
      expect(captured.id, 'date_42');
      expect(captured.title, 'Anniversaire de ma Lulu');
      verifyNever(() => mockRepository.addImportantDate(any()));
    });

    test('doit exposer un message et renvoyer false si l\'envoi échoue',
        () async {
      when(() => mockRepository.addImportantDate(any()))
          .thenThrow(Exception('Firestore indisponible'));
      final viewModel = buildViewModel();
      viewModel.titleController.text = 'Noël';

      final saved = await viewModel.save();

      expect(saved, isFalse);
      expect(viewModel.isSaving, isFalse);
      expect(viewModel.errorMessage, contains('Enregistrement impossible'));
    });
  });
}
