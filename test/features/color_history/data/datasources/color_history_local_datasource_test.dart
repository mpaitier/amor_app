// ============================================================================
// TEST UNITAIRE : ColorHistoryLocalDataSource
// ============================================================================
// SharedPreferences fournit un stockage en mémoire pour les tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amor_app/features/color_history/data/datasources/color_history_local_datasource.dart';

void main() {
  const dataSource = ColorHistoryLocalDataSource();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('doit renvoyer une liste vide au départ', () async {
    expect(await dataSource.getRecentColors(), isEmpty);
  });

  test('doit placer la dernière couleur en tête', () async {
    await dataSource.addRecentColor(0xFF111111);
    final colors = await dataSource.addRecentColor(0xFF222222);

    expect(colors, [0xFF222222, 0xFF111111]);
    expect(await dataSource.getRecentColors(), [0xFF222222, 0xFF111111]);
  });

  test('doit remonter une couleur déjà présente sans la dupliquer', () async {
    await dataSource.addRecentColor(0xFF111111);
    await dataSource.addRecentColor(0xFF222222);

    final colors = await dataSource.addRecentColor(0xFF111111);

    expect(colors, [0xFF111111, 0xFF222222]);
  });

  test('doit oublier les plus anciennes au-delà du maximum', () async {
    for (var i = 0; i < ColorHistoryLocalDataSource.maxColors + 2; i++) {
      await dataSource.addRecentColor(0xFF000000 + i);
    }

    final colors = await dataSource.getRecentColors();

    expect(colors, hasLength(ColorHistoryLocalDataSource.maxColors));
    expect(colors.first, 0xFF000000 + ColorHistoryLocalDataSource.maxColors + 1);
  });

  test('doit ignorer une valeur stockée illisible', () async {
    SharedPreferences.setMockInitialValues({
      'recent_custom_colors': ['4278190335', 'pas une couleur'],
    });

    expect(await dataSource.getRecentColors(), [4278190335]);
  });
}
