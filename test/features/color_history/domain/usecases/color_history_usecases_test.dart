// ============================================================================
// TEST UNITAIRE : GetRecentColors et AddRecentColor (use cases)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/color_history/domain/repositories/color_history_repository.dart';
import 'package:amor_app/features/color_history/domain/usecases/add_recent_color.dart';
import 'package:amor_app/features/color_history/domain/usecases/get_recent_colors.dart';

class MockColorHistoryRepository extends Mock
    implements ColorHistoryRepository {}

void main() {
  late MockColorHistoryRepository mockRepository;

  setUp(() {
    mockRepository = MockColorHistoryRepository();
  });

  test('GetRecentColors doit relayer la liste du repository', () async {
    when(() => mockRepository.getRecentColors())
        .thenAnswer((_) async => [0xFF2F6FDE]);

    expect(await GetRecentColors(mockRepository)(), [0xFF2F6FDE]);
  });

  test('AddRecentColor doit transmettre la couleur et renvoyer la liste',
      () async {
    when(() => mockRepository.addRecentColor(0xFF2F6FDE))
        .thenAnswer((_) async => [0xFF2F6FDE]);

    final result = await AddRecentColor(mockRepository)(0xFF2F6FDE);

    expect(result, [0xFF2F6FDE]);
    verify(() => mockRepository.addRecentColor(0xFF2F6FDE)).called(1);
  });
}
