// ============================================================================
// GIF SEARCH TERM FIELD
// ============================================================================
// Terme de recherche des GIF tirés au hasard. Enregistré à la validation du
// clavier ou en quittant le champ.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/couple_settings_entity.dart';
import '../viewmodels/settings_viewmodel.dart';

class GifSearchTermField extends StatefulWidget {
  const GifSearchTermField({super.key});

  @override
  State<GifSearchTermField> createState() => _GifSearchTermFieldState();
}

class _GifSearchTermFieldState extends State<GifSearchTermField> {
  late final SettingsViewModel _viewModel = context.read<SettingsViewModel>();
  late final TextEditingController _controller =
      TextEditingController(text: _viewModel.settings.gifSearchTerm);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _save();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _viewModel.setGifSearchTerm(_controller.text);
    if (!mounted) return;
    // --- Un champ vidé reprend le terme d'origine ---
    final saved = _viewModel.settings.gifSearchTerm;
    if (_controller.text != saved) _controller.text = saved;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _focusNode.unfocus(),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.gif_box_outlined, color: amorDarkRose),
        hintText: CoupleSettingsEntity.defaultGifSearchTerm,
        helperText: 'Mots-clés Giphy, en anglais de préférence',
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
      ),
    );
  }
}
