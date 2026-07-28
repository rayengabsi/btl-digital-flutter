sealed class ForgotPasswordState {
  const ForgotPasswordState();

  const factory ForgotPasswordState.initial() = ForgotPasswordInitial;
  const factory ForgotPasswordState.loading() = ForgotPasswordLoading;
  const factory ForgotPasswordState.success({required String message}) =
      ForgotPasswordSuccess;
  const factory ForgotPasswordState.error({required String message}) =
      ForgotPasswordError;
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess({required this.message});
  final String message;
}

class ForgotPasswordError extends ForgotPasswordState {
  const ForgotPasswordError({required this.message});
  final String message;
}