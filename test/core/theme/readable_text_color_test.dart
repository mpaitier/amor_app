// ============================================================================
// TEST UNITAIRE : readableTextColor
// ============================================================================
// Une couleur trop claire est assombrie jusqu'au contraste visé avec le
// blanc, sans changer de teinte ; une couleur assez foncée ne bouge pas.

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/core/theme/readable_text_color.dart';

double contrastWithWhite(Color color) {
  return 1.05 / (color.computeLuminance() + 0.05);
}

void main() {
  test('doit garder une couleur déjà foncée', () {
    const darkRose = Color(0xFF703348);
    expect(readableTextColor(darkRose), darkRose);
  });

  test('doit assombrir un jaune clair jusqu\'au contraste 3:1', () {
    const yellow = Color(0xFFE0A800);
    final result = readableTextColor(yellow);

    expect(contrastWithWhite(yellow), lessThan(3.0));
    expect(contrastWithWhite(result), greaterThanOrEqualTo(3.0));
  });

  test('doit garder la teinte d\'origine', () {
    const yellow = Color(0xFFE0A800);
    final before = HSLColor.fromColor(yellow).hue;
    final after = HSLColor.fromColor(readableTextColor(yellow)).hue;

    expect(after, closeTo(before, 1.0));
  });

  test('doit rester proche de la couleur : juste assez assombrie', () {
    const yellow = Color(0xFFE0A800);
    final result = readableTextColor(yellow);

    // --- Un pas de moins et le contraste ne suffirait plus ---
    final hsl = HSLColor.fromColor(result);
    final lighter = hsl.withLightness(hsl.lightness + 0.02).toColor();
    expect(contrastWithWhite(lighter), lessThan(3.0));
  });

  test('doit rendre le blanc lisible', () {
    final result = readableTextColor(const Color(0xFFFFFFFF));
    expect(contrastWithWhite(result), greaterThanOrEqualTo(3.0));
  });

  test('doit respecter un contraste demandé plus élevé', () {
    final result = readableTextColor(
      const Color(0xFF7B4FD6),
      contrast: 4.5,
    );
    expect(contrastWithWhite(result), greaterThanOrEqualTo(4.5));
  });

  test('doit garder la transparence', () {
    const translucent = Color(0x80E0A800);
    expect(readableTextColor(translucent).a, closeTo(translucent.a, 0.01));
  });
}
