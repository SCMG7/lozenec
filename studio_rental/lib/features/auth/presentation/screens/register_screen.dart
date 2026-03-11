import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/password_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateForm(AppLocalizations l10n) {
    bool isValid = true;

    setState(() {
      // Full name
      if (_fullNameController.text.trim().isEmpty) {
        _fullNameError = l10n.register_error_name_required;
        isValid = false;
      } else if (_fullNameController.text.trim().length < 2) {
        _fullNameError = l10n.register_error_name_min;
        isValid = false;
      } else {
        _fullNameError = null;
      }

      // Email
      if (_emailController.text.trim().isEmpty) {
        _emailError = l10n.register_error_email_required;
        isValid = false;
      } else if (!EmailValidator.validate(_emailController.text.trim())) {
        _emailError = l10n.register_error_email_invalid;
        isValid = false;
      } else {
        _emailError = null;
      }

      // Password
      if (_passwordController.text.isEmpty) {
        _passwordError = l10n.register_error_password_required;
        isValid = false;
      } else if (_passwordController.text.length < 8) {
        _passwordError = l10n.register_error_password_min;
        isValid = false;
      } else if (!_hasUppercaseAndNumber(_passwordController.text)) {
        _passwordError = l10n.register_error_password_format;
        isValid = false;
      } else {
        _passwordError = null;
      }

      // Confirm password
      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = l10n.register_error_confirm_required;
        isValid = false;
      } else if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordError = l10n.register_error_confirm_mismatch;
        isValid = false;
      } else {
        _confirmPasswordError = null;
      }

    });

    return isValid;
  }

  bool _hasUppercaseAndNumber(String password) {
    return RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  void _onSubmit(AppLocalizations l10n) {
    if (!_validateForm(l10n)) return;

    context.read<AuthBloc>().add(Register(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.dashboard,
            (route) => false,
          );
        } else if (state is AuthError) {
          String errorMessage;
          if (state.message == 'network_error') {
            errorMessage = l10n.register_error_network;
          } else if (state.message.toLowerCase().contains('email') &&
              state.message.toLowerCase().contains('exist')) {
            errorMessage = l10n.register_error_email_exists;
          } else {
            errorMessage = state.message;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.register_title, style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _fullNameController,
                    label: l10n.register_full_name_label,
                    hint: l10n.register_full_name_hint,
                    errorText: _fullNameError,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_fullNameError != null) {
                        setState(() => _fullNameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    label: l10n.register_email_label,
                    hint: l10n.register_email_hint,
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  PasswordField(
                    controller: _passwordController,
                    label: l10n.register_password_label,
                    hint: l10n.register_password_hint,
                    errorText: _passwordError,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  PasswordField(
                    controller: _confirmPasswordController,
                    label: l10n.register_confirm_password_label,
                    hint: l10n.register_confirm_password_hint,
                    errorText: _confirmPasswordError,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_confirmPasswordError != null) {
                        setState(() => _confirmPasswordError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _onSubmit(l10n),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      l10n.register_button_loading,
                                      style: AppTextStyles.button,
                                    ),
                                  ],
                                )
                              : Text(
                                  l10n.register_button,
                                  style: AppTextStyles.button,
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          AppRoutes.login,
                        );
                      },
                      child: Text(
                        l10n.register_already_have_account,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            errorText: errorText,
            errorStyle: AppTextStyles.errorText,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
