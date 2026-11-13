// ============================================================================
// TEST UNITAIRE : extractEmoji (fonction pure)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/important_dates/presentation/utils/emoji_input.dart';

void main() {
  test('doit renvoyer un emoji simple', () {
    expect(extractEmoji('🐧'), '🐧');
  });

  test('doit garder entier un emoji avec sélecteur de variante', () {
    expect(extractEmoji('❤️'), '❤️');
  });

  test('doit garder entier un emoji composé', () {
    expect(extractEmoji('👩‍❤️‍👨'), '👩‍❤️‍👨');
  });

  test('doit garder entier un emoji avec couleur de peau', () {
    expect(extractEmoji('👍🏽'), '👍🏽');
  });

  test('doit accepter un drapeau', () {
    expect(extractEmoji('🇫🇷'), '🇫🇷');
  });

  test('doit ne garder que le premier emoji, espaces ignorés', () {
    expect(extractEmoji('  🎉🎂'), '🎉');
  });

  test('doit refuser une lettre ou un chiffre', () {
    expect(extractEmoji('a'), isNull);
    expect(extractEmoji('7'), isNull);
  });

  test('doit refuser une saisie vide', () {
    expect(extractEmoji('   '), isNull);
  });
}
