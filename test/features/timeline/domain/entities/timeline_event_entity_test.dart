// ============================================================================
// TEST UNITAIRE : TimelineEventEntity (logique pure, aucun mock nécessaire)
// ============================================================================
// Couvre uniquement la logique métier réelle : le getter `imagesList`,
// qui découpe la chaîne `imageUrl` et corrige les urls Imgur sans extension.

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/timeline/domain/entities/timeline_event_entity.dart';

void main() {
  TimelineEventEntity buildEvent({required String imageUrl}) {
    return TimelineEventEntity(
      id: 'e1',
      title: 'Titre',
      date: DateTime(2024, 1, 1),
      place: 'Paris',
      who: 'Lulu',
      imageUrl: imageUrl,
      description: 'desc',
    );
  }

  group('imagesList', () {
    test('doit renvoyer une liste vide quand imageUrl est vide', () {
      final event = buildEvent(imageUrl: '');

      expect(event.imagesList, isEmpty);
    });

    test('doit découper les urls séparées par | et retirer les espaces', () {
      final event = buildEvent(
        imageUrl: 'https://a.com/1.jpg | https://a.com/2.jpg',
      );

      expect(event.imagesList, [
        'https://a.com/1.jpg',
        'https://a.com/2.jpg',
      ]);
    });

    test('doit ajouter l\'extension .png à une url Imgur sans extension', () {
      final event = buildEvent(imageUrl: 'https://i.imgur.com/abc123');

      expect(event.imagesList, ['https://i.imgur.com/abc123.png']);
    });

    test('ne doit pas modifier une url Imgur qui a déjà une extension connue',
        () {
      final event = buildEvent(imageUrl: 'https://i.imgur.com/abc123.jpg');

      expect(event.imagesList, ['https://i.imgur.com/abc123.jpg']);
    });

    test('ne doit pas modifier une url qui n\'est pas hébergée sur Imgur', () {
      final event =
          buildEvent(imageUrl: 'https://storage.googleapis.com/abc123');

      expect(event.imagesList, ['https://storage.googleapis.com/abc123']);
    });
  });
}
