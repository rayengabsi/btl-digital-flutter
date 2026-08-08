import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';


class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePassword = true;

  // Retains the last resolved MFA screen (channel selection or OTP entry is preserved
  // while a request is in flight or after an error, so the user stays on the step).
  AuthState? _retainedView;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _onChooseMfa(int challengeId, String challengeToken, String channel) {
    ref.read(authControllerProvider.notifier).chooseMfa(
          challengeId: challengeId,
          challengeToken: challengeToken,
          mfaChannel: channel,
        );
  }

  void _onVerifyOtp(int challengeId, String challengeToken) {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit OTP code'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    ref.read(authControllerProvider.notifier).verifyLoginOtp(
          challengeId: challengeId,
          challengeToken: challengeToken,
          otp: otp,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next case AuthAuthenticated()) {
        context.goNamed('home');
      } else if (next case AuthError(:final message, :final details)) {
        final errorText = details.isNotEmpty
            ? '$message\n${details.join("\n")}'
            : message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorText),
            backgroundColor: AppColors.primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;
    final viewState = _resolveViewState(authState);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final horizontalPadding = size.width < 360
                ? AppDimensions.paddingM
                : AppDimensions.paddingXL;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height),
                child: _buildBodyForState(context, viewState, size, isLoading),
              ),
            );
          },
        ),
      ),
    );
  }

  // Keeps the MFA screen (channel selection / OTP entry) visible while a request
  // is loading or after an error, instead of falling back to the credentials view.
  AuthState _resolveViewState(AuthState state) {
    switch (state) {
      case AuthCredentialsVerified():
        _retainedView = state;
        return state;
      case AuthMfaOtpSent():
        _retainedView = state;
        return state;
      case AuthInitial():
        _retainedView = null;
        return state;
      case AuthLoading():
        return _retainedView ?? state;
      case AuthError():
        return _retainedView ?? state;
      default:
        return state;
    }
  }

  Widget _buildBodyForState(
    BuildContext context,
    AuthState state,
    Size size,
    bool isLoading,
  ) {
    if (state is AuthCredentialsVerified) {
      return _buildChooseMfaView(context, state, size, isLoading);
    }
    if (state is AuthMfaOtpSent) {
      return _buildOtpView(context, state, size, isLoading);
    }
    return _buildCredentialsView(context, size, isLoading);
  }

  // ─── STEP 1: CREDENTIALS VIEW ──────────────────────────────────────────────
  Widget _buildCredentialsView(BuildContext context, Size size, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: size.height * 0.08),
          const _LoginHeader(
            title: 'Welcome back',
            subtitle: 'Sign in to continue to your account',
          ),
          SizedBox(height: size.height * 0.06),
          _EmailField(controller: _emailController),
          const SizedBox(height: AppDimensions.paddingM),
          _PasswordField(
            controller: _passwordController,
            obscure: _obscurePassword,
            onToggle: () => setState(
              () => _obscurePassword = !_obscurePassword,
            ),
          ),
          SizedBox(height: size.height * 0.04),
          ElevatedButton(
            onPressed: isLoading ? null : _onLogin,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Sign In'),
          ),
          SizedBox(height: size.height * 0.06),
          const _SignUpPrompt(),
          const SizedBox(height: AppDimensions.paddingXL),
        ],
      ),
    );
  }

  // ─── STEP 2: CHOOSE MFA CHANNEL VIEW ───────────────────────────────────────
  Widget _buildChooseMfaView(
    BuildContext context,
    AuthCredentialsVerified state,
    Size size,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: size.height * 0.08),
            const _LoginHeader(
              title: 'Select Verification Method',
              subtitle: 'Choose where you would like to receive your security OTP code',
            ),
            SizedBox(height: size.height * 0.05),
            ...state.availableChannels.map((channelInfo) {
              final isPhone = channelInfo.channel == 'PHONE';
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  child: InkWell(
                    onTap: isLoading
                        ? null
                        : () => _onChooseMfa(
                              state.challengeId,
                              state.challengeToken,
                              channelInfo.channel,
                            ),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(

                              isPhone ? Icons.phone_android_rounded : Icons.email_rounded,
                              color: AppColors.primaryGreen,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isPhone ? 'SMS OTP' : 'Email OTP',
                                  style: AppTypography.h3.copyWith(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Send code to ${channelInfo.maskedDestination}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGreen),
                ),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: () => ref.read(authControllerProvider.notifier).reset(),
              child: const Text('Back to Login'),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
          ],
        ),
      ],
    );
  }

  // ─── STEP 3: VERIFY LOGIN OTP VIEW ─────────────────────────────────────────
  Widget _buildOtpView(
    BuildContext context,
    AuthMfaOtpSent state,
    Size size,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: size.height * 0.08),
            _LoginHeader(
              title: 'Enter 6-Digit OTP',
              subtitle: 'Verification code sent to ${state.maskedDestination}',
            ),
            SizedBox(height: size.height * 0.06),
            Text(
              'Security Code',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: AppTypography.h2.copyWith(letterSpacing: 8),
              decoration: const InputDecoration(
                hintText: '123456',
                counterText: '',
              ),
            ),
            SizedBox(height: size.height * 0.04),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => _onVerifyOtp(state.challengeId, state.challengeToken),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Verify & Login'),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: () => ref.read(authControllerProvider.notifier).reset(),
              child: const Text('Cancel Verification'),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
          ],
        ),
      ],
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logos/btl_logo.png',
          width: 160,
          fit: BoxFit.contain,
        ),
        const SizedBox(
          height: AppDimensions.paddingXL + AppDimensions.paddingM,
        ),
        Text(
          title,
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value.trim())) {
              return 'Please enter a valid email';
            }
            return null;
          },
          decoration: const InputDecoration(hintText: 'Enter your email'),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your password',
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: AppDimensions.iconM,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => context.goNamed('register'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryRed,
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign Up',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
