import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/utils/responsive_manager.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordPage({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _passwordError;
  String? _confirmError;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final ApiClient _apiClient = sl<ApiClient>();

  bool _isValidPassword(String password) =>
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
          .hasMatch(password);

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty) {
      setState(() => _passwordError = 'Please enter new password');
      return;
    }
    if (!_isValidPassword(password)) {
      setState(() => _passwordError =
          'Password must have uppercase, lowercase, number, and symbol');
      return;
    }
    if (confirm.isEmpty) {
      setState(() => _confirmError = 'Please confirm your password');
      return;
    }
    if (password != confirm) {
      setState(() => _confirmError = 'Passwords do not match');
      return;
    }

    setState(() {
      _passwordError = null;
      _confirmError = null;
      _isLoading = true;
    });

    try {
      await _apiClient.post(ApiEndpoints.resetPassword, data: {
        'email': widget.email,
        'otp': widget.otp,
        'password': password,
        'confirmPassword': confirm,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password reset successfully'),
            backgroundColor: Colors.green),
      );
      context.go(AppRouter.login);
    } catch (e) {
      setState(() => _passwordError = 'Failed to reset password. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final isSmall = ResponsiveManager.isSmallScreen;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.dialogBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 20 : 40, vertical: 24),
            child: Column(
              children: [
                Row(children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 24, color: theme.primaryColor),
                  ),
                ]),
                const SizedBox(height: 24),
                Container(
                  height: isSmall ? 100 : 140,
                  width: isSmall ? 100 : 140,
                  decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Icon(Icons.lock_reset,
                      size: isSmall ? 50 : 70, color: theme.primaryColor),
                ),
                const SizedBox(height: 32),
                Text('Reset Password', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Enter your new password',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 40),
                AppTextField(
                  hint: 'Enter new password',
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  errorText: _passwordError,
                  prefixIcon: Icon(Icons.lock_outline, color: theme.hintColor),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  onChanged: (_) => setState(() => _passwordError = null),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hint: 'Confirm new password',
                  controller: _confirmController,
                  obscure: _obscureConfirm,
                  errorText: _confirmError,
                  prefixIcon: Icon(Icons.lock_outline, color: theme.hintColor),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  onChanged: (_) => setState(() => _confirmError = null),
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: 'RESET PASSWORD',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
