// ============================================================================
// GIFT SCREEN
// ============================================================================
// Final onboarding animation revealing the app's gift.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../navigation/app_routes.dart';
import '../viewmodels/gift_viewmodel.dart';

class GiftScreen extends StatelessWidget {
  const GiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GiftViewModel(completeOnboarding: sl.completeOnboarding),
      child: const _GiftView(),
    );
  }
}

class _GiftView extends StatelessWidget {
  const _GiftView();

  Future<void> _handleTap(
    BuildContext context,
    GiftViewModel viewModel,
  ) async {
    final completed = await viewModel.onGiftTap();
    if (completed && context.mounted) {
      context.go(AppRoutes.mainMenu);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GiftViewModel>();
    final giftScale = 1.0 + (viewModel.clickCount * 0.4);

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
              AnimatedOpacity(
                opacity: viewModel.showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: AnimatedScale(
                  scale: giftScale,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: () => _handleTap(context, viewModel),
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
              if (viewModel.clickCount > 0 && viewModel.clickCount < 3)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Encore !',
                    style: TextStyle(color: Color(0x99E91E63), fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}