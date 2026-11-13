// ============================================================================
// TEST UNITAIRE : CalendarLayout (géométrie pure, aucun mock nécessaire)
// ============================================================================
// Vérifie les conversions entre position de défilement et mois affiché :
// c'est ce calcul qui décide du mois montré dans l'en-tête fixe.

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/calendar/domain/entities/calendar_month.dart';
import 'package:amor_app/features/calendar/presentation/models/calendar_layout.dart';

void main() {
  const width = 390.0;
  const monthCount = 24;
  late CalendarLayout layout;

  // --- Novembre 2026 (index 0) compte 6 semaines, octobre (index 1) 5 ---
  late double novemberExtent;
  late double octoberExtent;
  late double septemberExtent;

  setUp(() {
    layout = CalendarLayout(
      width: width,
      lastMonth: const CalendarMonth(2026, 11),
      monthCount: monthCount,
    );
    novemberExtent = layout.monthExtent(0);
    octoberExtent = layout.monthExtent(1);
    septemberExtent = layout.monthExtent(2);
  });

  group('dimensions', () {
    test('doit partager la largeur en 7 cases une fois marges et écarts retirés',
        () {
      const expected = (width -
              2 * CalendarLayout.horizontalPadding -
              6 * CalendarLayout.cellGap) /
          7;

      expect(layout.cellSize, closeTo(expected, 1e-9));
    });

    test('doit additionner bande du numéro, case et écart pour une ligne', () {
      expect(
        layout.rowHeight,
        closeTo(
          CalendarLayout.dayNumberHeight +
              layout.cellSize +
              CalendarLayout.rowGap,
          1e-9,
        ),
      );
    });

    test('doit donner à chaque mois la hauteur de son titre et de ses lignes',
        () {
      expect(
        novemberExtent,
        closeTo(CalendarLayout.monthTitleHeight + 6 * layout.rowHeight, 1e-9),
      );
      expect(
        octoberExtent,
        closeTo(CalendarLayout.monthTitleHeight + 5 * layout.rowHeight, 1e-9),
      );
    });

    test('doit supposer 5 lignes pour un index hors de la liste', () {
      final fallback = CalendarLayout.monthTitleHeight + 5 * layout.rowHeight;

      expect(layout.monthExtent(-1), closeTo(fallback, 1e-9));
      expect(layout.monthExtent(monthCount), closeTo(fallback, 1e-9));
    });

    test('doit ne jamais renvoyer une case de taille négative', () {
      final narrow = CalendarLayout(
        width: 10,
        lastMonth: const CalendarMonth(2026, 11),
        monthCount: 1,
      );

      expect(narrow.cellSize, 0);
    });
  });

  group('monthAt', () {
    test('doit placer le mois le plus récent à l\'index 0', () {
      expect(layout.monthAt(0), const CalendarMonth(2026, 11));
    });

    test('doit remonter dans le passé quand l\'index augmente', () {
      expect(layout.monthAt(2), const CalendarMonth(2026, 9));
      expect(layout.monthAt(11), const CalendarMonth(2025, 12));
    });
  });

  group('topMonthIndex', () {
    test('doit renvoyer le mois le plus récent quand il remplit tout l\'écran',
        () {
      final index = layout.topMonthIndex(
        scrollOffset: 0,
        viewportHeight: CalendarLayout.bottomInset + novemberExtent - 1,
      );

      expect(index, 0);
    });

    test('doit garder le mois dont le haut tombe pile au bord de l\'écran', () {
      final index = layout.topMonthIndex(
        scrollOffset: 0,
        viewportHeight: CalendarLayout.bottomInset + novemberExtent,
      );

      expect(index, 0);
    });

    test('doit ignorer un dépassement de moins d\'un demi-pixel', () {
      final index = layout.topMonthIndex(
        scrollOffset: 0,
        viewportHeight: CalendarLayout.bottomInset + novemberExtent + 0.25,
      );

      expect(index, 0);
    });

    test('doit passer au mois précédent dès que celui-ci dépasse en haut', () {
      final index = layout.topMonthIndex(
        scrollOffset: 0,
        viewportHeight: CalendarLayout.bottomInset + novemberExtent + 1,
      );

      expect(index, 1);
    });

    test('doit suivre le défilement vers le passé', () {
      final index = layout.topMonthIndex(
        scrollOffset: novemberExtent + octoberExtent,
        viewportHeight: CalendarLayout.bottomInset + 10,
      );

      expect(index, 2);
    });

    test('doit rester sur le mois le plus récent en cas de rebond vers le bas',
        () {
      final index = layout.topMonthIndex(
        scrollOffset: -500,
        viewportHeight: 300,
      );

      expect(index, 0);
    });

    test('doit s\'arrêter au mois le plus ancien au-delà du contenu', () {
      final index = layout.topMonthIndex(
        scrollOffset: 1000000,
        viewportHeight: 700,
      );

      expect(index, monthCount - 1);
    });
  });

  group('scrollOffsetForMonth', () {
    const viewportHeight = 600.0;
    const maxScrollExtent = 1000000.0;

    test('doit amener la première ligne du mois juste sous l\'en-tête', () {
      final offset = layout.scrollOffsetForMonth(
        index: 2,
        viewportHeight: viewportHeight,
        maxScrollExtent: maxScrollExtent,
      );

      final topOfSeptember = novemberExtent + octoberExtent + septemberExtent;
      expect(
        offset,
        closeTo(
          topOfSeptember -
              CalendarLayout.monthTitleHeight -
              viewportHeight +
              CalendarLayout.bottomInset,
          1e-9,
        ),
      );
    });

    test('doit faire afficher le mois demandé dans l\'en-tête', () {
      for (var index = 1; index < monthCount; index++) {
        final offset = layout.scrollOffsetForMonth(
          index: index,
          viewportHeight: viewportHeight,
          maxScrollExtent: maxScrollExtent,
        );

        expect(
          layout.topMonthIndex(
            scrollOffset: offset,
            viewportHeight: viewportHeight,
          ),
          index,
        );
      }
    });

    test('doit rester en bas quand le mois est trop récent pour monter', () {
      final offset = layout.scrollOffsetForMonth(
        index: 0,
        viewportHeight: viewportHeight,
        maxScrollExtent: maxScrollExtent,
      );

      expect(offset, 0);
    });

    test('doit se limiter à la fin du défilement', () {
      final offset = layout.scrollOffsetForMonth(
        index: 20,
        viewportHeight: viewportHeight,
        maxScrollExtent: 50,
      );

      expect(offset, 50);
    });

    test('doit ramener un index trop grand sur le mois le plus ancien', () {
      final tooFar = layout.scrollOffsetForMonth(
        index: 999,
        viewportHeight: viewportHeight,
        maxScrollExtent: maxScrollExtent,
      );
      final oldest = layout.scrollOffsetForMonth(
        index: monthCount - 1,
        viewportHeight: viewportHeight,
        maxScrollExtent: maxScrollExtent,
      );

      expect(tooFar, oldest);
    });
  });
}
