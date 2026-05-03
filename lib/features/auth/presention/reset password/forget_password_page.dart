// ignore_for_file: unused_element, depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/utiles/responsive_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const String routeName = "/forgot-password";
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    String? error;
    if (email.isEmpty) {
      error = 'Please enter your email address';
    } else if (!_isValidEmail(email)) {
      error = 'Please enter a valid email address';
    }

    if (error != null) {
      setState(() {
        _emailError = error;
      });
      return;
    }

    setState(() {
      _emailError = null;
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://foodrecognitionapp.runasp.net/api/Auth/forgotpassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (mounted) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // ✅ التوجه لصفحة OTP بنفس الترانزيشن
          Navigator.push(
            context,
            CustomPageTransitions.fastSlideTransition(
              OtpVerificationPage(email: email),
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
            _emailError = 'Failed to send reset link. Try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailError = 'Network error. Please check your connection.';
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
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
                  child: Image.asset(
                    color: theme.primaryColor,
                    'assets/pictures/forgetpass.png',
                    height: isSmall ? 120 : 160,
                    width: isSmall ? 120 : 160,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
                      );
                    },
                  ),
                ),
                SizedBox(height: ResponsiveManager.spacingLarge),
                Text(
                  'Forgot Password?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: isSmall
                        ? ResponsiveManager.heading2
                        : ResponsiveManager.heading1,
                  ),
                ),
                SizedBox(height: ResponsiveManager.spacingSmall),
                Text(
                  'Enter your email address and we\'ll send you a verification code to reset your password.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isSmall
                        ? ResponsiveManager.bodySmall
                        : ResponsiveManager.bodyMedium,
                    height: 1.5,
                  ),
                ),
                SizedBox(
                    height: isSmall
                        ? ResponsiveManager.spacingXLarge
                        : ResponsiveManager.spacingXXLarge),
                AppTextField(
                  hint: 'Enter your email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    size: ResponsiveManager.iconMedium,
                    color: theme.hintColor,
                  ),
                  onChanged: (_) {
                    if (_emailError != null) setState(() => _emailError = null);
                  },
                ),
                SizedBox(height: ResponsiveManager.spacingXLarge),
                AppButton(
                  text: _isLoading ? 'SENDING...' : 'SEND RESET LINK',
                  onPressed: _isLoading ? null : _sendResetLink,
                ),
                SizedBox(height: ResponsiveManager.spacingXLarge),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontSize: ResponsiveManager.bodySmall),
                        children: [
                          const TextSpan(text: 'Remember your password? '),
                          TextSpan(
                            text: 'Back to Login',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveManager.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
