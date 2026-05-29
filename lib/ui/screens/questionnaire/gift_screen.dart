// <<===========================================================================>>
// <<========================= ÉCRAN CADEAU ====================================>>
// <<===========================================================================>>
// Équivalent de Gift.kt — animation du cadeau final

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/prefs_service.dart';
import '../../../navigation/screen.dart';

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> {
  // <<--- États --->
  bool _showButton = false;
  int _clickCount = 0;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  // <<--- Séquence d'apparition du bouton --->
  Future<void> _startSequence() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _showButton = true);
  }

  // <<--- Action au clic sur le cadeau --->
  Future<void> _onGiftTap() async {
    if (_clickCount < 2) {
      setState(() => _clickCount++);
    } else {
      await PrefsService.setFirstRunCompleted();
      if (mounted) {
        context.go(AppRoutes.mainMenu);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // <<--- Échelle du bouton cadeau --->
    final giftScale = 1.0 + (_clickCount * 0.4);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [amorBackground, amorBackgroundEnd],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // <<--- Message de félicitations --->
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Bravo ma Lulu,\ntu peux accéder à ton cadeau !',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF2D2D2D),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // <<--- Bouton cadeau animé --->
              AnimatedOpacity(
                opacity: _showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: AnimatedScale(
                  scale: giftScale,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _onGiftTap,
                    child: const SizedBox(
                      width: 120,
                      height: 120,
                      child: Center(
                        child: Text('🎁', style: TextStyle(fontSize: 60)),
                      ),
                    ),
                  ),
                ),
              ),

              // <<--- Indice "Encore !" --->
              if (_clickCount > 0 && _clickCount < 3)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Encore !',
                    style: TextStyle(
                      color: Color(0x99E91E63),
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}