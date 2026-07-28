import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'forgot_password_controller.dart';
import 'forgot_password_state.dart';

final forgotPasswordControllerProvider = NotifierProvider<
    ForgotPasswordController, ForgotPasswordState>(
  ForgotPasswordController.new,
);