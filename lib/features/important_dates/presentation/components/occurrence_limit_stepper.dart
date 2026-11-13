// ============================================================================
// OCCURRENCE LIMIT STEPPER
// ============================================================================
// Compteur "− 5 ans +" pour la durée d'une répétition. Le nombre au milieu
// est un champ : un tap ouvre le clavier numérique pour le taper. Composant
// "bête" : reçoit la valeur, ses bornes, son unité et un callback.

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

  const OccurrenceLimitStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: widget.value > widget.min ? () => _step(-1) : null,
          tooltip: 'Moins',
          icon: const Icon(Icons.remove_circle_outline),
          color: amorDarkRose,
        ),
        SizedBox(
          width: 64,
          child: TextField(
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
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 76,
          child: Text(
            widget.unit,
            style: const TextStyle(color: onBackgroundLight, fontSize: 16),
          ),
        ),
        IconButton(
          onPressed: widget.value < widget.max ? () => _step(1) : null,
          tooltip: 'Plus',
          icon: const Icon(Icons.add_circle_outline),
          color: amorDarkRose,
        ),
      ],
    );
  }
}
