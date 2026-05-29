// <<===========================================================================>>
// <<====================== QUESTION PAR SECOUSSE ==============================>>
// <<===========================================================================>>
// Équivalent de NumberQuestion.kt — compteur activé par secousse du téléphone

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class ShakeCounterQuestion extends StatefulWidget {
  // <<--- Paramètres --->
  final String question;
  final int initialValue;
  final void Function(int answer) onConfirm;

  const ShakeCounterQuestion({
    super.key,
    required this.question,
    this.initialValue = 0,
    required this.onConfirm,
  });

  @override
  State<ShakeCounterQuestion> createState() => _ShakeCounterQuestionState();
}

class _ShakeCounterQuestionState extends State<ShakeCounterQuestion>
    with SingleTickerProviderStateMixin {
  // <<--- État du compteur --->
  late int _counter;
  bool _showWarning = false;

  // <<--- Animation pulse --->
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // <<--- Détection shake --->
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  int _lastShakeTime = 0;
  static const double _shakeThreshold = 2.7;
  static const int _shakeSlopMs = 500;

  @override
  void initState() {
    super.initState();
    _counter = widget.initialValue;

    // <<--- Initialisation animation pulse --->
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // <<--- Écoute de l'accéléromètre --->
    _startShakeDetection();
  }

  // <<--- Démarrage de la détection de shake --->
  void _startShakeDetection() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final gForce = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      ) / 9.81;

      if (gForce > _shakeThreshold) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastShakeTime > _shakeSlopMs) {
          _lastShakeTime = now;
          _onShake();
        }
      }
    });
  }

  // <<--- Action lors d'une secousse --->
  void _onShake() {
    if (!mounted) return;
    setState(() {
      _counter++;
      _showWarning = false;
    });
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [amorBackground, amorBackgroundEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // <<--- Question --->
            _buildQuestion(context),

            // <<--- Compteur animé --->
            _buildCounter(),

            // <<--- Zone du bas : avertissement + boutons --->
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  // <<--- Texte de la question --->
  Widget _buildQuestion(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Text(
        widget.question,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: const Color(0xFF2D2D2D),
          fontWeight: FontWeight.w300,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // <<--- Compteur géant avec animation --->
  Widget _buildCounter() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _pulseAnimation.value,
        child: Text(
          '$_counter',
          style: const TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.w900,
            color: amorPink,
          ),
        ),
      ),
    );
  }

  // <<--- Zone bas : warning + boutons --->
  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          // <<--- Message d'avertissement --->
          AnimatedOpacity(
            opacity: _showWarning ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Presque... réessaie ! 🌹',
                style: TextStyle(
                  color: amorPink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // <<--- Boutons Reset et Valider --->
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // <<--- Reset --->
              TextButton(
                onPressed: () => setState(() => _counter = 0),
                child: const Text('Reset', style: TextStyle(color: Colors.grey)),
              ),

              const SizedBox(width: 24),

              // <<--- Valider --->
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_counter == anneesEcoulees) {
                      widget.onConfirm(_counter);
                    } else {
                      setState(() => _showWarning = true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amorPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Valider',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}