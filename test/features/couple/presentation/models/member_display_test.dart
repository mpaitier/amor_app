// ============================================================================
// TEST UNITAIRE : MemberDisplay
// ============================================================================
// Surnom et couleur affichés pour l'auteur d'un souvenir, avec les cas d'un
// membre parti et d'un surnom vide.

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/couple/domain/entities/couple_member.dart';
import 'package:amor_app/features/couple/presentation/models/member_display.dart';

void main() {
  test('doit afficher le surnom et la couleur du membre', () {
    const lulu = CoupleMember(uid: 'uid-lulu', nickname: 'Lulu', color: 0xFF7B4FD6);

    final display = MemberDisplay.of(lulu);

    expect(display.name, 'Lulu');
    expect(display.color, const Color(0xFF7B4FD6));
  });

  test('doit prendre la couleur par défaut pour un membre parti', () {
    final display = MemberDisplay.of(null);

    expect(display.name, MemberDisplay.formerMemberName);
    expect(display.color, const Color(CoupleMember.defaultColor));
  });

  test('doit afficher "un membre" quand le surnom est vide', () {
    const member = CoupleMember(uid: 'uid-x', nickname: '  ', color: 0xFF7B4FD6);

    final display = MemberDisplay.of(member);

    expect(display.name, MemberDisplay.unnamedMemberName);
    expect(display.color, const Color(0xFF7B4FD6));
  });

  test('doit suivre un changement de surnom ou de couleur', () {
    const before = CoupleMember(uid: 'uid-lulu', nickname: 'Lulu', color: 0xFF7B4FD6);
    final after = before.copyWith(nickname: 'Lucie', color: 0xFF2E7D32);

    expect(MemberDisplay.of(before), isNot(MemberDisplay.of(after)));
    expect(MemberDisplay.of(after).name, 'Lucie');
    expect(MemberDisplay.of(after).color, const Color(0xFF2E7D32));
  });

  test('doit assombrir le texte d\'une couleur trop claire, pas la pastille',
      () {
    const lulu = CoupleMember(uid: 'uid-lulu', nickname: 'Lulu', color: 0xFFE0A800);

    final display = MemberDisplay.of(lulu);

    expect(display.color, const Color(0xFFE0A800));
    expect(
      display.textColor.computeLuminance(),
      lessThan(display.color.computeLuminance()),
    );
  });

  test('doit garder la couleur du texte quand elle est assez foncée', () {
    final display = MemberDisplay.of(null);
    expect(display.textColor, display.color);
  });
}
