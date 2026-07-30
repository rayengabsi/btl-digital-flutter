import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/forgot_password_provider.dart';
import '../providers/forgot_password_state.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, this.initialToken});

  final String? initialToken;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _token;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _token = widget.initialToken;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  PasswordStrength _computeStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    if (password.length >= 12) score++;
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  bool _hasUppercase(String v) => v.contains(RegExp(r'[A-Z]'));
  bool _hasLowercase(String v) => v.contains(RegExp(r'[a-z]'));
  bool _hasDigit(String v) => v.contains(RegExp(r'[0-9]'));
  bool _hasSpecial(String v) =>
      v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('Password Changed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: 64,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'Password changed successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            const Text(
              'Your password has been updated.\n'
              'You can now login using your new password.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.goNamed('login');
            },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  void _onReset() {
    if (!_formKey.currentState!.validate()) return;
    if (_token == null || _token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reset token is missing. Please use the link from the email.'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
        ),
      );
      return;
    }
    ref
        .read(forgotPasswordControllerProvider.notifier)
        .resetPassword(
          token: _token!,
          newPassword: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(forgotPasswordControllerProvider, (previous, next) {
      if (next case ForgotPasswordSuccess(:final message)) {
        _showSuccessDialog(message);
      } else if (next case ForgotPasswordError(:final message)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        );
      }
    });

    final state = ref.watch(forgotPasswordControllerProvider);
    final isLoading = state is ForgotPasswordLoading;
    final password = _passwordController.text;
    final strength = _computeStrength(password);
    final showPasswordLive =
        password.isNotEmpty && _passwordController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('login');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final horizontalPadding = size.width < 360
                ? AppDimensions.paddingM
                : AppDimensions.paddingXL;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.06),
                    const _ResetHeader(),
                    SizedBox(height: size.height * 0.04),

                    // ── New Password ────────────────────────────────────
                    Text(
                      'New Password',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Minimum 8 characters';
                        }
                        if (!_hasUppercase(value)) {
                          return 'Needs 1 uppercase letter';
                        }
                        if (!_hasLowercase(value)) {
                          return 'Needs 1 lowercase letter';
                        }
                        if (!_hasDigit(value)) {
                          return 'Needs 1 number';
                        }
                        if (!_hasSpecial(value)) {
                          return 'Needs 1 special character';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: AppDimensions.iconM,
                          ),
                        ),
                      ),
                    ),

                    // ── Password Strength Bar ───────────────────────────
                    if (showPasswordLive) ...[
                      const SizedBox(height: AppDimensions.paddingM),
                      _PasswordStrengthBar(strength: strength),
                      const SizedBox(height: AppDimensions.paddingS),
                      _PasswordRequirements(
                        password: password,
                        hasUppercase: _hasUppercase(password),
                        hasLowercase: _hasLowercase(password),
                        hasDigit: _hasDigit(password),
                        hasSpecial: _hasSpecial(password),
                        minLength: password.length >= 8,
                      ),
                    ],

                    const SizedBox(height: AppDimensions.paddingL),

                    // ── Confirm Password ────────────────────────────────
                    Text(
                      'Confirm Password',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Confirm new password',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: AppDimensions.iconM,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    ElevatedButton(
                      onPressed: isLoading ? null : _onReset,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Reset Password'),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _ResetHeader extends StatelessWidget {
  const _ResetHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logos/btl_logo.png',
          width: 140,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppDimensions.paddingXL),
        Text(
          'Set New Password',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Text(
          'Choose a strong password for\nyour account.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── Strength Bar ─────────────────────────────────────────────────────────────
enum PasswordStrength { none, weak, medium, strong }

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final double fraction;
    final Color color;
    final String label;

    switch (strength) {
      case PasswordStrength.none:
        fraction = 0.0;
        color = Colors.transparent;
        label = '';
      case PasswordStrength.weak:
        fraction = 0.33;
        color = AppColors.primaryRed;
        label = 'Weak';
      case PasswordStrength.medium:
        fraction = 0.66;
        color = AppColors.warning;
        label = 'Medium';
      case PasswordStrength.strong:
        fraction = 1.0;
        color = AppColors.success;
        label = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Requirements Checklist ──────────────────────────────────────────────────
class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements({
    required this.password,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecial,
    required this.minLength,
  });

  final String password;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigit;
  final bool hasSpecial;
  final bool minLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequirementRow(met: minLength, text: 'At least 8 characters'),
          const SizedBox(height: 4),
          _RequirementRow(met: hasUppercase, text: '1 uppercase letter'),
          const SizedBox(height: 4),
          _RequirementRow(met: hasLowercase, text: '1 lowercase letter'),
          const SizedBox(height: 4),
          _RequirementRow(met: hasDigit, text: '1 number'),
          const SizedBox(height: 4),
          _RequirementRow(met: hasSpecial, text: '1 special character'),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.met, required this.text});

  final bool met;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: met ? AppColors.success : AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.paddingS),
        Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: met ? AppColors.success : AppColors.textSecondary,
            fontWeight: met ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}