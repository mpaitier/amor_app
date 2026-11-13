// ============================================================================
// TEST UNITAIRE : ImportantDateRepositoryImpl
// ============================================================================
// Vérifie la conversion Entity <-> Model et la délégation vers la
// datasource distante (Firestore mocké).

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/important_dates/data/datasources/important_date_remote_datasource.dart';
import 'package:amor_app/features/important_dates/data/models/important_date_model.dart';
import 'package:amor_app/features/important_dates/data/repositories/important_date_repository_impl.dart';
import 'package:amor_app/features/important_dates/domain/entities/important_date_entity.dart';

class MockImportantDateRemoteDataSource extends Mock
    implements ImportantDateRemoteDataSource {}

// --- Fake utilisé uniquement pour enregistrer une valeur de repli auprès
// --- de mocktail (nécessaire pour matcher any() sur un type non natif) ---
class _FakeImportantDateModel extends Fake implements ImportantDateModel {}

void main() {
  late MockImportantDateRemoteDataSource mockDataSource;
  late ImportantDateRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_FakeImportantDateModel());
  });

  setUp(() {
    mockDataSource = MockImportantDateRemoteDataSource();
    repository = ImportantDateRepositoryImpl(remoteDataSource: mockDataSource);
  });

  final tEntity = ImportantDateEntity(
    id: 'date_1',
    title: 'Anniversaire de Lulu',
    date: DateTime(2026, 12, 28),
    emoji: '🎂',
    repeatsYearly: true,
  );

  test('watchImportantDates doit relayer le flux de modèles en tant qu\'entités',
      () async {
    final model = ImportantDateModel.fromEntity(tEntity);
    when(() => mockDataSource.watchImportantDates())
        .thenAnswer((_) => Stream.value([model]));

    final result = await repository.watchImportantDates().first;

    expect(result, hasLength(1));
    expect(result.first.title, 'Anniversaire de Lulu');
    expect(result.first.repeatsYearly, isTrue);
  });

  test('addImportantDate doit convertir l\'entité en modèle avant l\'envoi',
      () async {
    when(() => mockDataSource.addImportantDate(any()))
        .thenAnswer((_) async => 'new_id');

    final id = await repository.addImportantDate(tEntity);

    expect(id, 'new_id');
    final captured = verify(
      () => mockDataSource.addImportantDate(captureAny()),
    ).captured.single as ImportantDateModel;
    expect(captured.title, tEntity.title);
    expect(captured.emoji, tEntity.emoji);
    expect(captured.date, tEntity.date);
  });

  test('updateImportantDate doit convertir l\'entité en modèle avant l\'envoi',
      () async {
    when(() => mockDataSource.updateImportantDate(any()))
        .thenAnswer((_) async {});

    await repository.updateImportantDate(tEntity);

    final captured = verify(
      () => mockDataSource.updateImportantDate(captureAny()),
    ).captured.single as ImportantDateModel;
    expect(captured.id, tEntity.id);
    expect(captured.repeatsYearly, tEntity.repeatsYearly);
  });

  test(
      'deleteImportantDate doit déléguer directement l\'id à la source '
      'distante', () async {
    when(() => mockDataSource.deleteImportantDate('date_1'))
        .thenAnswer((_) async {});

    await repository.deleteImportantDate('date_1');

    verify(() => mockDataSource.deleteImportantDate('date_1')).called(1);
  });
}
