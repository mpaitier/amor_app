// ============================================================================
// IMAGE VIEWER DIALOG
// ============================================================================
// Visionneuse plein écran des images d'un souvenir. Elle s'ouvre sur
// l'image touchée ; on passe à la suivante ou à la précédente par
// glissement ou avec les flèches, en boucle. Avec une seule image, ni
// flèches ni glissement. Un appui à côté de l'image ou le bouton retour
// la ferme.
// Le contrôleur de pages est un pur état d'interface : pas de ViewModel.

import 'package:flutter/material.dart';
import '../models/looping_image_index.dart';
import 'image_viewer_arrow.dart';
import 'image_viewer_page.dart';

class ImageViewerDialog extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewerDialog({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  // --- Ouvre la visionneuse sur l'image d'index initialIndex ---
  static Future<void> show(
    BuildContext context, {
    required List<String> imageUrls,
    required int initialIndex,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (_) => ImageViewerDialog(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  State<ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<ImageViewerDialog> {
  static const Duration _slideDuration = Duration(milliseconds: 280);

  late final LoopingImageIndex _index =
      LoopingImageIndex(widget.imageUrls.length);
  late final PageController _pageController = PageController(
    initialPage: _index.initialPage(widget.initialIndex),
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  void _goToPrevious() {
    _pageController.previousPage(
      duration: _slideDuration,
      curve: Curves.easeOut,
    );
  }

  void _goToNext() {
    _pageController.nextPage(duration: _slideDuration, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    // --- Material transparent : sans lui, les textes d'aide (tooltips)
    // --- et les effets d'appui des flèches n'ont pas de support ---
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildPages()),
            if (_index.canNavigate) ...[
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: ImageViewerArrow(
                    direction: ImageViewerArrowDirection.previous,
                    onPressed: _goToPrevious,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: ImageViewerArrow(
                    direction: ImageViewerArrowDirection.next,
                    onPressed: _goToNext,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Pages sans fin quand on peut naviguer (itemCount null), une seule
  // --- page fixe sinon ---
  Widget _buildPages() {
    return PageView.builder(
      controller: _pageController,
      physics: _index.canNavigate
          ? const PageScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: _index.canNavigate ? null : 1,
      itemBuilder: (context, page) => ImageViewerPage(
        imageUrl: widget.imageUrls[_index.imageIndexOf(page)],
        onBackgroundTap: _close,
      ),
    );
  }
}
