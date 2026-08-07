import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  // Step 1 Controllers
  final _step1FormKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  String _idType = 'CIN';
  final _idNumberCtrl = TextEditingController();
  final _dobCtrl = TextEditingController(); // yyyyMMdd
  final _phoneCtrl = TextEditingController();

  // Step 2 & 4 Controllers
  final _phoneOtpCtrl = TextEditingController();
  final _emailCodeCtrl = TextEditingController();

  // Step 3 Controller
  final _step3FormKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  // Step 5 Controller
  final _step5FormKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;

  // Retains the current registration step so that during in-flight requests or
  // after an error the user is not thrown back to Step 1 (and does not lose the
  // session token), which previously forced a full restart.
  AuthRegistrationStep? _retainedStep;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _idNumberCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _phoneOtpCtrl.dispose();
    _emailCtrl.dispose();
    _emailCodeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _onVerifyClient() {
    if (!_step1FormKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).verifyClient(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          idType: _idType,
          idNumber: _idNumberCtrl.text.trim(),
          dateOfBirth: _dobCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
        );
  }

  void _onVerifyPhoneOtp(String sessionToken) {
    if (_phoneOtpCtrl.text.trim().length != 6) {
      _showError('Please enter the 6-digit phone OTP');
      return;
    }
    ref.read(authControllerProvider.notifier).verifyPhoneOtp(
          sessionToken: sessionToken,
          otp: _phoneOtpCtrl.text.trim(),
        );
  }

  void _onSendEmail(String sessionToken) {
    if (!_step3FormKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).sendEmailVerification(
          sessionToken: sessionToken,
          email: _emailCtrl.text.trim(),
        );
  }

  void _onVerifyEmailCode(String sessionToken) {
    if (_emailCodeCtrl.text.trim().length != 6) {
      _showError('Please enter the 6-digit email code');
      return;
    }
    ref.read(authControllerProvider.notifier).verifyEmailCode(
          sessionToken: sessionToken,
          code: _emailCodeCtrl.text.trim(),
        );
  }

  void _onCompleteRegistration(String sessionToken) {
    if (!_step5FormKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      _showError('Passwords do not match');
      return;
    }

    ref.read(authControllerProvider.notifier).completeRegistration(
          sessionToken: sessionToken,
          password: _passwordCtrl.text,
        );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next is AuthRegistrationStep) {
        _retainedStep = next;
      } else if (next is AuthInitial) {
        _retainedStep = null;
      }
      if (next case AuthError(:final message, :final details)) {
        final err = details.isNotEmpty ? '$message\n${details.join("\n")}' : message;
        _showError(err);
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Digital Account Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (authState is AuthRegistrationStep && authState.step > 1) {
              ref.read(authControllerProvider.notifier).reset();
            } else {
              context.goNamed('login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: _buildStepContent(context, authState, isLoading),
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, AuthState state, bool isLoading) {
    if (state is AuthRegistrationSuccess) {
      return _buildSuccessStep(state.username);
    }

    // Fall back to the retained step while a request is loading or after an
    // error, so the user stays on the correct step instead of resetting to 1.
    final AuthRegistrationStep? stepState =
        state is AuthRegistrationStep ? state : _retainedStep;

    int currentStep = 1;
    String? sessionToken;
    String? phone;
    String? email;

    if (stepState != null) {
      currentStep = stepState.step;
      sessionToken = stepState.sessionToken;
      phone = stepState.phone;
      email = stepState.email;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepperIndicator(currentStep),
        const SizedBox(height: 24),
        if (currentStep == 1) _buildStep1ClientInfo(isLoading),
        if (currentStep == 2 && sessionToken != null)
          _buildStep2PhoneOtp(sessionToken, phone ?? '', isLoading),
        if (currentStep == 3 && sessionToken != null)
          _buildStep3EmailInput(sessionToken, isLoading),
        if (currentStep == 4 && sessionToken != null)
          _buildStep4EmailCode(sessionToken, email ?? '', isLoading),
        if (currentStep == 5 && sessionToken != null)
          _buildStep5Password(sessionToken, isLoading),
      ],
    );
  }

  Widget _buildStepperIndicator(int step) {
    return Row(
      children: List.generate(5, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber <= step;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryGreen : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),

          ),
        );
      }),
    );
  }

  // ─── STEP 1: VERIFY CLIENT ──────────────────────────────────────────────────
  Widget _buildStep1ClientInfo(bool isLoading) {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 1 of 5: Customer Verification', style: AppTypography.h3),
          const SizedBox(height: 4),
          Text(
            'Enter your identity details registered with BTL Bank',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'First Name',
                  controller: _firstNameCtrl,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Last Name',
                  controller: _lastNameCtrl,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('ID Type', style: AppTypography.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'CIN', label: Text('National ID (CIN)')),
              ButtonSegment(value: 'PASSPORT', label: Text('Passport')),
            ],
            selected: {_idType},
            onSelectionChanged: (val) => setState(() => _idType = val.first),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'ID Number',
            controller: _idNumberCtrl,
            hint: 'e.g. 12345678',
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter ID number' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Date of Birth (YYYYMMDD)',
            controller: _dobCtrl,
            hint: '19900101',
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.trim().length != 8) {
                return 'Enter 8 digits date of birth (YYYYMMDD)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Phone Number (SMS_1 registered)',
            controller: _phoneCtrl,
            hint: '21655123456',
            keyboardType: TextInputType.phone,
            validator: (v) => v == null || v.trim().length < 8 ? 'Enter valid phone number' : null,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: isLoading ? null : _onVerifyClient,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Verify Identity'),
          ),
        ],
      ),
    );
  }

  // ─── STEP 2: VERIFY PHONE OTP ──────────────────────────────────────────────
  Widget _buildStep2PhoneOtp(String token, String phone, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2 of 5: Phone OTP Verification', style: AppTypography.h3),
        const SizedBox(height: 4),
        Text(
          'Enter 6-digit OTP code sent via SMS to $phone',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _phoneOtpCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: AppTypography.h2.copyWith(letterSpacing: 8),
          decoration: const InputDecoration(hintText: '123456', counterText: ''),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: isLoading ? null : () => _onVerifyPhoneOtp(token),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Verify Phone OTP'),
        ),
      ],
    );
  }

  // ─── STEP 3: EMAIL INPUT ──────────────────────────────────────────────────
  Widget _buildStep3EmailInput(String token, bool isLoading) {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 3 of 5: Email Verification', style: AppTypography.h3),
          const SizedBox(height: 4),
          Text(
            'Submit your official email address to receive your verification code',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Email Address',
            controller: _emailCtrl,
            hint: 'amina@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                return 'Enter valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: isLoading ? null : () => _onSendEmail(token),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Send Email Code'),
          ),
        ],
      ),
    );
  }

  // ─── STEP 4: VERIFY EMAIL CODE ─────────────────────────────────────────────
  Widget _buildStep4EmailCode(String token, String email, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4 of 5: Confirm Email Code', style: AppTypography.h3),
        const SizedBox(height: 4),
        Text(
          'Enter the 6-digit email code sent to $email',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailCodeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: AppTypography.h2.copyWith(letterSpacing: 8),
          decoration: const InputDecoration(hintText: '123456', counterText: ''),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: isLoading ? null : () => _onVerifyEmailCode(token),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Verify Email Code'),
        ),
      ],
    );
  }

  // ─── STEP 5: CREATE PASSWORD ───────────────────────────────────────────────
  Widget _buildStep5Password(String token, bool isLoading) {
    return Form(
      key: _step5FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 5 of 5: Create Account Password', style: AppTypography.h3),
          const SizedBox(height: 4),
          Text(
            'Min 10 chars with uppercase, lowercase, digit, and symbol (@#\$%&*?)',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'New Password',
            controller: _passwordCtrl,
            obscure: _obscurePassword,
            suffix: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password required';
              final passRegex = RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%&*?])[A-Za-z\d@#$%&*?]{10,}$',
              );
              if (!passRegex.hasMatch(v)) {
                return 'Must meet all password complexity rules';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Confirm Password',
            controller: _confirmPasswordCtrl,
            obscure: _obscurePassword,
            validator: (v) {
              if (v != _passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: isLoading ? null : () => _onCompleteRegistration(token),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Complete Registration'),
          ),
        ],
      ),
    );
  }

  // ─── SUCCESS STEP ──────────────────────────────────────────────────────────
  Widget _buildSuccessStep(String username) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(

            Icons.check_circle_rounded,
            color: AppColors.primaryGreen,
            size: 64,
          ),
        ),
        const SizedBox(height: 24),
        Text('Registration Complete!', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text(
          'Your account for $username has been successfully activated.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => context.goNamed('login'),
          child: const Text('Sign In Now'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}