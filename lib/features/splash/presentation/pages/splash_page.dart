import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  static const Duration _splashDuration = Duration(seconds: 3, milliseconds: 500);
  static const Duration _fadeDuration = Duration(milliseconds: 650);
  static const double _brandTopFactor = 0.255;

  Timer? _timer;
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _sloganFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _fadeDuration);
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _sloganFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 1.0, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.forward();
      _timer = Timer(_splashDuration, _checkSession);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _checkSession() {
    if (!mounted) return;
    ref.read(authControllerProvider.notifier).checkAuthStatus();
  }

  void _onAuthStateChanged(AuthState state) {
    if (!mounted) return;

    switch (state) {
      case AuthAuthenticated():
        context.goNamed('home');
      case AuthUnauthenticated():
        context.goNamed('onboarding');
      case AuthLoading():
      case AuthInitial():
      case AuthCredentialsVerified():
      case AuthMfaOtpSent():
      case AuthRegistrationStep():
      case AuthRegistrationSuccess():
        break;
      case AuthError():
        context.goNamed('onboarding');
    }
  }


  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next is! AuthLoading && next is! AuthInitial) {
        _onAuthStateChanged(next);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/splash_waves.png',
                  width: size.width,
                  fit: BoxFit.fitWidth,
                ),
              ),
              SafeArea(
                bottom: false,
                child: SizedBox.expand(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: size.height * _brandTopFactor,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BrandSection(
                          screenWidth: size.width,
                          logoFade: _logoFade,
                          sloganFade: _sloganFade,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  const _BrandSection({
    required this.screenWidth,
    required this.logoFade,
    required this.sloganFade,
  });

  final double screenWidth;
  final Animation<double> logoFade;
  final Animation<double> sloganFade;

  @override
  Widget build(BuildContext context) {
    final logoWidth = (screenWidth * 0.52).clamp(176.0, 320.0).toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: logoFade,
          child: Image.asset(
            'assets/logos/btl_logo.png',
            width: logoWidth,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: AppDimensions.paddingL * 1.35),
        FadeTransition(
          opacity: sloganFade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Banking made simple,',
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                  height: 1.12,
                ),
              ),
              SizedBox(height: AppDimensions.paddingXS * 0.75),
              Text(
                'life made better.',
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.12,
                ),
              ),
              SizedBox(height: AppDimensions.paddingM),
              Container(
                width: 42,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
