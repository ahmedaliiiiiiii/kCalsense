// ignore_for_file: unused_element, depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/utiles/responsive_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../login_page.dart';

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

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isValidPassword(String password) {
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(password);
  }

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
      final response = await http.post(
        Uri.parse(
            'http://foodrecognitionapp.runasp.net/api/Auth/resetpassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': widget.otp,
          'password': password,
          'confirmPassword': confirm,
        }),
      );

      if (mounted) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // ✅ التوجه لصفحة Login بنفس الترانزيشن
          Navigator.pushReplacement(
            context,
            CustomPageTransitions.fastSlideTransition(const LoginPage()),
          );
        } else {
          String errorMessage = 'Failed to reset password. Try again.';
          try {
            final data = jsonDecode(response.body);
            if (data is Map) {
              errorMessage = data['message'] ?? data['title'] ?? errorMessage;
            }
          } catch (_) {}
          setState(() => _passwordError = errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _passwordError = 'Network error. Please check your connection.');
      }
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
              horizontal: isSmall
                  ? ResponsiveManager.spacingLarge
                  : ResponsiveManager.spacingXXLarge,
              vertical: ResponsiveManager.spacingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: ResponsiveManager.spacingMedium),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: ResponsiveManager.iconMedium,
                          color: theme.primaryColor,
                        ),
                        padding:
                            EdgeInsets.all(ResponsiveManager.spacingXSmall),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveManager.spacingMedium),
                Center(
                  child: Container(
                    height: isSmall ? 100 : 140,
                    width: isSmall ? 100 : 140,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: isSmall ? 50 : 70,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveManager.spacingLarge),
                Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: isSmall
                        ? ResponsiveManager.heading2
                        : ResponsiveManager.heading1,
                  ),
                ),
                SizedBox(height: ResponsiveManager.spacingSmall),
                Text(
                  'Enter your new password',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isSmall
                        ? ResponsiveManager.bodySmall
                        : ResponsiveManager.bodyMedium,
                  ),
                ),
                SizedBox(height: ResponsiveManager.spacingXXLarge),
                AppTextField(
                  hint: 'Enter new password',
                  controller: _passwordController,
                  obscure: true,
                  errorText: _passwordError,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    size: ResponsiveManager.iconMedium,
                    color: theme.hintColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: ResponsiveManager.iconSmall,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                ),
                SizedBox(height: ResponsiveManager.spacingMedium),
                AppTextField(
                  hint: 'Confirm new password',
                  controller: _confirmController,
                  obscure: true,
                  errorText: _confirmError,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    size: ResponsiveManager.iconMedium,
                    color: theme.hintColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      size: ResponsiveManager.iconSmall,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  onChanged: (_) {
                    if (_confirmError != null) {
                      setState(() => _confirmError = null);
                    }
                  },
                ),
                SizedBox(height: ResponsiveManager.spacingXLarge),
                AppButton(
                  text: _isLoading ? 'RESETTING...' : 'RESET PASSWORD',
                  onPressed: _isLoading ? null : _resetPassword,
                ),
                SizedBox(height: ResponsiveManager.spacingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
