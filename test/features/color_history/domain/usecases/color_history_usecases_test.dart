// ============================================================================
// TEST UNITAIRE : GetRecentColors et AddRecentColor (use cases)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/color_history/domain/entities/color_history_kind.dart';
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

  test('GetRecentColors doit relayer la liste de l\'usage demandé', () async {
    when(() => mockRepository.getRecentColors(ColorHistoryKind.border))
        .thenAnswer((_) async => [0xFF2F6FDE]);

    final result = await GetRecentColors(mockRepository)(ColorHistoryKind.border);

    expect(result, [0xFF2F6FDE]);
  });

  test('AddRecentColor doit transmettre l\'usage et la couleur', () async {
    when(
      () => mockRepository.addRecentColor(
        ColorHistoryKind.background,
        0xFFD9EAFF,
      ),
    ).thenAnswer((_) async => [0xFFD9EAFF]);

    final result = await AddRecentColor(mockRepository)(
      ColorHistoryKind.background,
      0xFFD9EAFF,
    );

    expect(result, [0xFFD9EAFF]);
  });
}
