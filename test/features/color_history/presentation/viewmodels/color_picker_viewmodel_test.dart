// ============================================================================
// TEST UNITAIRE : ColorPickerViewModel
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/color_history/domain/repositories/color_history_repository.dart';
import 'package:amor_app/features/color_history/domain/usecases/add_recent_color.dart';
import 'package:amor_app/features/color_history/domain/usecases/get_recent_colors.dart';
import 'package:amor_app/features/color_history/presentation/viewmodels/color_picker_viewmodel.dart';

class MockColorHistoryRepository extends Mock
    implements ColorHistoryRepository {}

void main() {
  late MockColorHistoryRepository mockRepository;

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  ColorPickerViewModel buildViewModel(int initialColor) {
    final viewModel = ColorPickerViewModel(
      getRecentColors: GetRecentColors(mockRepository),
      addRecentColor: AddRecentColor(mockRepository),
      initialColor: initialColor,
    );
    addTearDown(viewModel.dispose);
    return viewModel;
  }

  setUp(() {
    mockRepository = MockColorHistoryRepository();
    when(() => mockRepository.getRecentColors())
        .thenAnswer((_) async => [0xFF2E8B57]);
  });

  test('doit partir de la couleur reçue', () {
    final viewModel = buildViewModel(0xFFFF0000);

    expect(viewModel.colorValue, 0xFFFF0000);
    expect(viewModel.hexLabel, '#FF0000');
    expect(viewModel.color.hue, 0);
  });

  test('doit charger les couleurs récentes', () async {
    final viewModel = buildViewModel(0xFFFF0000);
    await flush();

    expect(viewModel.recentColors, [0xFF2E8B57]);
  });

  test('doit changer de teinte en gardant saturation et luminosité', () {
    final viewModel = buildViewModel(0xFFFF0000);

    viewModel.setHue(240);

    expect(viewModel.colorValue, 0xFF0000FF);
  });

  test('doit régler saturation et luminosité, bornées entre 0 et 1', () {
    final viewModel = buildViewModel(0xFFFF0000);

    viewModel.setSaturationValue(0, 2);

    expect(viewModel.colorValue, 0xFFFFFFFF);
  });

  test('doit reprendre une couleur récente', () {
    final viewModel = buildViewModel(0xFFFF0000);

    viewModel.selectRecentColor(0xFF0000FF);

    expect(viewModel.colorValue, 0xFF0000FF);
  });

  test('doit ajouter la couleur validée à l\'historique et la renvoyer',
      () async {
    when(() => mockRepository.addRecentColor(0xFFFF0000))
        .thenAnswer((_) async => [0xFFFF0000, 0xFF2E8B57]);
    final viewModel = buildViewModel(0xFFFF0000);

    final color = await viewModel.confirm();

    expect(color, 0xFFFF0000);
    expect(viewModel.recentColors, [0xFFFF0000, 0xFF2E8B57]);
  });

  test('doit renvoyer la couleur même si l\'historique échoue', () async {
    when(() => mockRepository.addRecentColor(0xFFFF0000))
        .thenThrow(Exception('stockage plein'));
    final viewModel = buildViewModel(0xFFFF0000);

    expect(await viewModel.confirm(), 0xFFFF0000);
  });
}
