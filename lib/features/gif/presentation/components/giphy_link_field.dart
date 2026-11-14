// ============================================================================
// GIPHY LINK FIELD
// ============================================================================
// Champ pour coller le lien d'un GIF GIPHY précis, à la place du tirage au
// hasard. Champ vide : le bouton de droite colle le presse-papiers et
// l'utilise aussitôt. Champ rempli : il valide le lien, comme la touche
// "Terminé" du clavier.
// Le contrôle du lien est fait par l'appelant : onSubmit renvoie null si le
// lien est accepté (le champ se vide), sinon le message d'erreur à afficher.
// Seuls le texte et l'erreur sont gardés ici (état d'interface).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class GiphyLinkField extends StatefulWidget {
  final String? Function(String link) onSubmit;

  const GiphyLinkField({super.key, required this.onSubmit});

  @override
  State<GiphyLinkField> createState() => _GiphyLinkFieldState();
}

class _GiphyLinkFieldState extends State<GiphyLinkField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String? _errorText;

  @override
  void initState() {
    super.initState();
    // --- Le bouton change selon que le champ est vide ou non, et une
    // --- erreur disparaît dès qu'on corrige le lien ---
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() => _errorText = null);
  }

  Future<void> _pasteAndSubmit() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    _controller.text = data?.text?.trim() ?? '';
    _submit();
  }

  void _submit() {
    final error = widget.onSubmit(_controller.text);
    if (error == null) {
      _controller.clear();
      _focusNode.unfocus();
    }
    // --- Après clear() : son listener effacerait sinon le message ---
    setState(() => _errorText = error);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.url,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.link, color: amorDarkRose),
        suffixIcon: _buildActionButton(),
        hintText: 'https://giphy.com/gifs/...',
        helperText: 'Ou colle le lien d\'un GIF GIPHY précis',
        errorText: _errorText,
        errorMaxLines: 2,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: amorDarkRose, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  // --- Coller si le champ est vide, valider sinon ---
  Widget _buildActionButton() {
    if (_controller.text.isEmpty) {
      return IconButton(
        onPressed: _pasteAndSubmit,
        tooltip: 'Coller le lien',
        icon: const Icon(Icons.content_paste, color: amorDarkRose),
      );
    }

    return IconButton(
      onPressed: _submit,
      tooltip: 'Utiliser ce GIF',
      icon: const Icon(Icons.check, color: amorDarkRose),
    );
  }
}
