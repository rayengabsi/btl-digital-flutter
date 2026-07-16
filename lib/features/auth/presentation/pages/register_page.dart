import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.05),
                  const _RegisterHeader(),
                  SizedBox(height: size.height * 0.04),
                  _FormField(
                    label: 'Full Name',
                    controller: _fullNameController,
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _FormField(
                    label: 'Email Address',
                    controller: _emailController,
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _FormField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    hint: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _PasswordField(
                    label: 'Password',
                    controller: _passwordController,
                    obscure: _obscurePassword,
                    hint: 'Enter your password',
                    textInputAction: TextInputAction.next,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _PasswordField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscure: _obscureConfirmPassword,
                    hint: 'Confirm your password',
                    textInputAction: TextInputAction.done,
                    onToggle: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _TermsCheckbox(
                    agreed: _agreedToTerms,
                    onChanged: (value) =>
                        setState(() => _agreedToTerms = value ?? false),
                  ),
                  SizedBox(height: size.height * 0.03),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Create Account'),
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),
                  const _SignInPrompt(),
                  const SizedBox(height: AppDimensions.paddingXL),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

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
          'Create Account',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Text(
            'Join BTL Bank and enjoy\nsecure banking anytime.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    required this.keyboardType,
    required this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              prefixIcon,
              color: AppColors.textSecondary,
              size: AppDimensions.iconM,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.hint,
    required this.textInputAction,
    required this.onToggle,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final String hint;
  final TextInputAction textInputAction;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        TextField(
          controller: controller,
          obscureText: obscure,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hint,
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

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.agreed, required this.onChanged});

  final bool agreed;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: agreed,
          onChanged: onChanged,
          activeColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.paddingXS),
          ),
          side: const BorderSide(color: AppColors.borderLight),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingS - 2),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
          onPressed: () => context.goNamed('login'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryRed,
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign In',
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
