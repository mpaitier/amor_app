// ============================================================================
// OCCURRENCE LIMIT STEPPER
// ============================================================================
// Compteur "− 5 ans +" pour la durée d'une répétition. Le nombre au milieu
// est un champ : un tap ouvre le clavier numérique pour le taper. En mode
// compact, l'unité passe après les boutons ("− 1 + jour avant"), pour tenir
// sur une ligne avec d'autres réglages. Composant "bête" : reçoit la valeur,
// ses bornes, son unité et un callback.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class OccurrenceLimitStepper extends StatefulWidget {
  final int value;
  final int min;
  final int max;

  // --- Unité affichée après le nombre : "ans", "mois", "semaines"... ---
  final String unit;
  final ValueChanged<int> onChanged;

  // --- Champ plus étroit, boutons resserrés, unité après le bouton + ---
  final bool compact;

  const OccurrenceLimitStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    this.compact = false,
  });

  @override
  State<OccurrenceLimitStepper> createState() => _OccurrenceLimitStepperState();
}

class _OccurrenceLimitStepperState extends State<OccurrenceLimitStepper> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.value}');
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // --- En quittant le champ, une saisie hors bornes est corrigée ---
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(OccurrenceLimitStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // --- La valeur a changé par les boutons : le champ suit ---
    if (int.tryParse(_controller.text) != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int _clamp(int value) {
    if (value < widget.min) return widget.min;
    if (value > widget.max) return widget.max;
    return value;
  }

  // --- Pendant la frappe : on ne prévient que pour une valeur valable ---
  void _onTyped(String text) {
    final typed = int.tryParse(text);
    if (typed != null && typed >= widget.min && typed <= widget.max) {
      widget.onChanged(typed);
    }
  }

  // --- À la validation : valeur ramenée dans les bornes, champ réécrit ---
  void _commit() {
    final typed = int.tryParse(_controller.text) ?? widget.value;
    final value = _clamp(typed);
    _controller.text = '$value';
    if (value != widget.value) widget.onChanged(value);
  }

  void _step(int delta) {
    _focusNode.unfocus();
    widget.onChanged(_clamp(widget.value + delta));
  }

  @override
  Widget build(BuildContext context) {
    final minus = IconButton(
      onPressed: widget.value > widget.min ? () => _step(-1) : null,
      tooltip: 'Moins',
      visualDensity: widget.compact ? VisualDensity.compact : null,
      icon: const Icon(Icons.remove_circle_outline),
      color: amorDarkRose,
    );
    final plus = IconButton(
      onPressed: widget.value < widget.max ? () => _step(1) : null,
      tooltip: 'Plus',
      visualDensity: widget.compact ? VisualDensity.compact : null,
      icon: const Icon(Icons.add_circle_outline),
      color: amorDarkRose,
    );
    final unit = Text(
      widget.unit,
      style: const TextStyle(color: onBackgroundLight, fontSize: 16),
    );

    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          minus,
          SizedBox(width: 40, child: _buildField()),
          plus,
          const SizedBox(width: 2),
          unit,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        minus,
        SizedBox(width: 64, child: _buildField()),
        const SizedBox(width: 6),
        // --- Largeur minimale plutôt que fixe : l'unité tient sur une ligne ---
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 76),
          child: unit,
        ),
        plus,
      ],
    );
  }

  Widget _buildField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter('${widget.max}'.length),
      ],
      onChanged: _onTyped,
      onSubmitted: (_) => _commit(),
      style: const TextStyle(
        color: onBackgroundLight,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: outlineVariantLight),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: amorDarkRose, width: 2),
        ),
      ),
    );
  }
}
