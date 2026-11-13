// ============================================================================
// TEST UNITAIRE : ColorPickerViewModel
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/color_history/presentation/viewmodels/color_picker_viewmodel.dart';

void main() {
  ColorPickerViewModel buildViewModel(int initialColor) {
    final viewModel = ColorPickerViewModel(initialColor: initialColor);
    addTearDown(viewModel.dispose);
    return viewModel;
  }

  test('doit partir de la couleur reçue', () {
    final viewModel = buildViewModel(0xFFFF0000);

    expect(viewModel.colorValue, 0xFFFF0000);
    expect(viewModel.hexLabel, '#FF0000');
    expect(viewModel.color.hue, 0);
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
}
