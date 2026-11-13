// ============================================================================
// TEST UNITAIRE : RecentColorsViewModel
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/color_history/domain/entities/color_history_kind.dart';
import 'package:amor_app/features/color_history/domain/repositories/color_history_repository.dart';
import 'package:amor_app/features/color_history/domain/usecases/add_recent_color.dart';
import 'package:amor_app/features/color_history/domain/usecases/get_recent_colors.dart';
import 'package:amor_app/features/color_history/presentation/viewmodels/recent_colors_viewmodel.dart';

class MockColorHistoryRepository extends Mock
    implements ColorHistoryRepository {}

void main() {
  late MockColorHistoryRepository mockRepository;

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  RecentColorsViewModel buildViewModel() {
    final viewModel = RecentColorsViewModel(
      getRecentColors: GetRecentColors(mockRepository),
      addRecentColor: AddRecentColor(mockRepository),
    );
    addTearDown(viewModel.dispose);
    return viewModel;
  }

  setUp(() {
    mockRepository = MockColorHistoryRepository();
    when(() => mockRepository.getRecentColors(ColorHistoryKind.border))
        .thenAnswer((_) async => [0xFF2F6FDE]);
    when(() => mockRepository.getRecentColors(ColorHistoryKind.background))
        .thenAnswer((_) async => [0xFFD9EAFF]);
  });

  test('doit charger les deux listes', () async {
    final viewModel = buildViewModel();
    await flush();

    expect(viewModel.colorsFor(ColorHistoryKind.border), [0xFF2F6FDE]);
    expect(viewModel.colorsFor(ColorHistoryKind.background), [0xFFD9EAFF]);
  });

  test('doit mettre à jour la seule liste concernée par un ajout', () async {
    when(() => mockRepository.addRecentColor(ColorHistoryKind.border, 0xFF7B4FD6))
        .thenAnswer((_) async => [0xFF7B4FD6, 0xFF2F6FDE]);
    final viewModel = buildViewModel();
    await flush();

    await viewModel.addColor(ColorHistoryKind.border, 0xFF7B4FD6);

    expect(viewModel.colorsFor(ColorHistoryKind.border), [
      0xFF7B4FD6,
      0xFF2F6FDE,
    ]);
    expect(viewModel.colorsFor(ColorHistoryKind.background), [0xFFD9EAFF]);
  });

  test('doit rester utilisable si l\'historique ne se charge pas', () async {
    when(() => mockRepository.getRecentColors(ColorHistoryKind.border))
        .thenThrow(Exception('stockage illisible'));
    final viewModel = buildViewModel();
    await flush();

    expect(viewModel.colorsFor(ColorHistoryKind.border), isEmpty);
    expect(viewModel.colorsFor(ColorHistoryKind.background), [0xFFD9EAFF]);
  });
}
