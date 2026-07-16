import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final horizontalPadding = size.width < 360
                ? AppDimensions.paddingM
                : AppDimensions.paddingL;
            final illustrationWidth = (size.width * 1.04)
                .clamp(340.0, 430.0)
                .toDouble();

            return Stack(
              children: [
                Positioned(
                  top: -AppDimensions.paddingM,
                  left: (size.width - illustrationWidth) / 2,
                  child: _OnboardingIllustration(width: illustrationWidth),
                ),
                Align(
                  alignment: const Alignment(0, 0.78),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      AppDimensions.paddingS,
                    ),
                    child: const _OnboardingContent(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/onboarding_cards.png',
      width: width,
      fit: BoxFit.contain,
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _OnboardingCopy(),
        const SizedBox(height: 64),
        ElevatedButton(
          onPressed: () => context.goNamed('login'),
          child: const Text('Get Started'),
        ),
        const SizedBox(height: 20),
        const _SignInPrompt(),
      ],
    );
  }
}

class _OnboardingCopy extends StatelessWidget {
  const _OnboardingCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fast and easy\npayment solution.',
          style: AppTypography.h1.copyWith(
            color: AppColors.textPrimary,
            height: 1.22,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 285,
          child: Text(
            'Manage your accounts, transfer money,\npay bills and more – all in one place.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFD5042B),
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}
