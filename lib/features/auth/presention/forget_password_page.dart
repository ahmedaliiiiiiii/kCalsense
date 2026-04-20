// ignore_for_file: unused_element

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/utiles/responsive_manager.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const String routeName = "/forgot-password";
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Pre-compile Regex for better performance
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
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
      // ✅ الرابط الجديد بس
      final response = await http.post(
        Uri.parse(
            'http://foodrecognitionapp.runasp.net/api/Auth/forgotpassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (mounted) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          setState(() {
            _isLoading = false;
            _emailSent = true;
          });
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
    final isTablet = ResponsiveManager.isTablet;
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
                // زر الرجوع - في الشمال
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
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

                // ✅ الصورة في النص
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

                // النص الوصفي
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
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

                // حالة إدخال الإيميل
                if (!_emailSent) ...[
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
                      if (_emailError != null) {
                        setState(() {
                          _emailError = null;
                        });
                      }
                    },
                  ),

                  SizedBox(height: ResponsiveManager.spacingXLarge),

                  // زر الإرسال
                  AppButton(
                    text: _isLoading ? 'SENDING...' : 'SEND RESET LINK',
                    onPressed: _isLoading ? null : _sendResetLink,
                  ),
                ],

                // رسالة النجاح
                if (_emailSent) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      isSmall
                          ? ResponsiveManager.spacingLarge
                          : ResponsiveManager.spacingXLarge,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveManager.radiusLarge,
                      ),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: isSmall
                              ? ResponsiveManager.iconXLarge
                              : ResponsiveManager.iconXXLarge,
                          color: theme.primaryColor,
                        ),
                        SizedBox(height: ResponsiveManager.spacingLarge),
                        Text(
                          'Check Your Email',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: isSmall
                                ? ResponsiveManager.heading4
                                : ResponsiveManager.heading3,
                          ),
                        ),
                        SizedBox(height: ResponsiveManager.spacingMedium),
                        Text(
                          'We have sent a password reset link to:',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: ResponsiveManager.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _emailController.text.trim(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: isSmall
                                ? ResponsiveManager.bodyMedium
                                : ResponsiveManager.bodyLarge,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: ResponsiveManager.spacingXLarge),
                        SizedBox(
                          width: isSmall
                              ? double.infinity
                              : (isTablet
                                  ? MediaQuery.of(context).size.width * 0.5
                                  : MediaQuery.of(context).size.width * 0.7),
                          height: ResponsiveManager.buttonHeight,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveManager.buttonRadius,
                                ),
                              ),
                            ),
                            child: Text(
                              'BACK TO LOGIN',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: ResponsiveManager.bodyMedium,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // رابط العودة لتسجيل الدخول
                if (!_emailSent) ...[
                  SizedBox(height: ResponsiveManager.spacingXLarge),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveManager.spacingMedium,
                          vertical: ResponsiveManager.spacingSmall,
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: ResponsiveManager.bodySmall,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Remember your password? ',
                            ),
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
                ],

                SizedBox(height: ResponsiveManager.spacingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
