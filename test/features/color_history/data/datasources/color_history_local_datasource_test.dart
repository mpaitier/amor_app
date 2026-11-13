// ============================================================================
// TEST UNITAIRE : ColorHistoryLocalDataSource
// ============================================================================
// SharedPreferences fournit un stockage en mémoire pour les tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amor_app/features/color_history/data/datasources/color_history_local_datasource.dart';
import 'package:amor_app/features/color_history/domain/entities/color_history_kind.dart';

void main() {
  const dataSource = ColorHistoryLocalDataSource();
  const border = ColorHistoryKind.border;
  const background = ColorHistoryKind.background;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('doit renvoyer une liste vide au départ', () async {
    expect(await dataSource.getRecentColors(border), isEmpty);
  });

  test('doit placer la dernière couleur en tête', () async {
    await dataSource.addRecentColor(border, 0xFF111111);
    final colors = await dataSource.addRecentColor(border, 0xFF222222);

    expect(colors, [0xFF222222, 0xFF111111]);
    expect(await dataSource.getRecentColors(border), [0xFF222222, 0xFF111111]);
  });

  test('doit tenir des listes séparées pour la bordure et le fond', () async {
    await dataSource.addRecentColor(border, 0xFF111111);
    await dataSource.addRecentColor(background, 0xFFEEEEEE);

    expect(await dataSource.getRecentColors(border), [0xFF111111]);
    expect(await dataSource.getRecentColors(background), [0xFFEEEEEE]);
  });

  test('doit remonter une couleur déjà présente sans la dupliquer', () async {
    await dataSource.addRecentColor(border, 0xFF111111);
    await dataSource.addRecentColor(border, 0xFF222222);

    final colors = await dataSource.addRecentColor(border, 0xFF111111);

    expect(colors, [0xFF111111, 0xFF222222]);
  });

  test('doit oublier les plus anciennes au-delà de 8 couleurs', () async {
    for (var i = 0; i < ColorHistoryLocalDataSource.maxColors + 2; i++) {
      await dataSource.addRecentColor(background, 0xFF000000 + i);
    }

    final colors = await dataSource.getRecentColors(background);

    expect(ColorHistoryLocalDataSource.maxColors, 8);
    expect(colors, hasLength(8));
    expect(colors.first, 0xFF000000 + 9);
  });

  test('doit reprendre l\'ancienne liste unique tant qu\'un usage est vide',
      () async {
    SharedPreferences.setMockInitialValues({
      'recent_custom_colors': ['4278190335'],
    });

    expect(await dataSource.getRecentColors(border), [4278190335]);
    expect(await dataSource.getRecentColors(background), [4278190335]);
  });

  test('doit retirer une couleur de la seule liste concernée', () async {
    await dataSource.addRecentColor(border, 0xFF111111);
    await dataSource.addRecentColor(border, 0xFF222222);
    await dataSource.addRecentColor(background, 0xFF111111);

    final colors = await dataSource.removeRecentColor(border, 0xFF111111);

    expect(colors, [0xFF222222]);
    expect(await dataSource.getRecentColors(background), [0xFF111111]);
  });

  test('ne doit pas faire revenir l\'ancienne liste après une suppression',
      () async {
    SharedPreferences.setMockInitialValues({
      'recent_custom_colors': ['4278190335'],
    });

    await dataSource.removeRecentColor(border, 4278190335);

    expect(await dataSource.getRecentColors(border), isEmpty);
    expect(await dataSource.getRecentColors(background), [4278190335]);
  });

  test('doit ignorer une valeur stockée illisible', () async {
    SharedPreferences.setMockInitialValues({
      'recent_border_colors': ['4278190335', 'pas une couleur'],
    });

    expect(await dataSource.getRecentColors(border), [4278190335]);
  });
}
