// ============================================================================
// TEST UNITAIRE : FloatingButtonsViewModel
// ============================================================================

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/navigation/presentation/models/floating_button_position.dart';
import 'package:amor_app/features/navigation/presentation/viewmodels/floating_buttons_viewmodel.dart';

void main() {
  const area = Size(390, 780);
  late FloatingButtonsViewModel viewModel;

  setUp(() {
    viewModel = FloatingButtonsViewModel();
  });

  tearDown(() => viewModel.dispose());

  test('doit partir des positions de départ', () {
    expect(
      viewModel.positionOf(FloatingButtonId.navigation),
      FloatingButtonPosition.navigationDefault,
    );
    expect(
      viewModel.positionOf(FloatingButtonId.add),
      FloatingButtonPosition.addDefault,
    );
    expect(viewModel.isDragging(FloatingButtonId.navigation), isFalse);
  });

  test('doit suivre le doigt pendant un glisser', () {
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    viewModel.drag(FloatingButtonId.navigation, const Offset(-100, -300), area);

    expect(viewModel.isDragging(FloatingButtonId.navigation), isTrue);
    expect(
      viewModel.centerOf(FloatingButtonId.navigation, area),
      const Offset(246, 436),
    );
    expect(notifications, 1);
  });

  test('doit cumuler les déplacements successifs', () {
    viewModel.drag(FloatingButtonId.add, const Offset(10, -100), area);
    viewModel.drag(FloatingButtonId.add, const Offset(10, -100), area);

    expect(
      viewModel.centerOf(FloatingButtonId.add, area),
      const Offset(64, 536),
    );
  });

  test('ne doit pas laisser le bouton sortir de l\'écran', () {
    viewModel.drag(FloatingButtonId.add, const Offset(-500, 500), area);

    expect(viewModel.centerOf(FloatingButtonId.add, area), const Offset(0, 780));
  });

  test('doit coller le bouton au bord le plus proche au lâcher', () {
    viewModel.drag(FloatingButtonId.navigation, const Offset(-310, -346), area);

    viewModel.endDrag(FloatingButtonId.navigation, area);

    expect(viewModel.isDragging(FloatingButtonId.navigation), isFalse);
    final position = viewModel.positionOf(FloatingButtonId.navigation);
    expect(position.edge, ScreenEdge.left);
    expect(position.fraction, closeTo(0.5, 0.0001));
  });

  test('ne doit déplacer que le bouton concerné', () {
    viewModel.drag(FloatingButtonId.navigation, const Offset(-310, -346), area);
    viewModel.endDrag(FloatingButtonId.navigation, area);

    expect(
      viewModel.positionOf(FloatingButtonId.add),
      FloatingButtonPosition.addDefault,
    );
  });

  test('ne doit rien faire en fin de glisser sans glisser', () {
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    viewModel.endDrag(FloatingButtonId.add, area);

    expect(notifications, 0);
  });
}
