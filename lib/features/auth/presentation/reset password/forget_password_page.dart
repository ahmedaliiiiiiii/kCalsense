import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/utils/responsive_manager.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';

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

  final ApiClient _apiClient = sl<ApiClient>();

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email address');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _emailError = null;
      _isLoading = true;
    });

    try {
      await _apiClient
          .post(ApiEndpoints.forgotPassword, data: {'email': email});
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Reset code sent to your email'),
            backgroundColor: Colors.green),
      );
      context.push('${AppRouter.otpVerification}/$email');
    } catch (e) {
      setState(() => _emailError = e.toString().contains('network')
          ? 'Network error. Please check your connection.'
          : 'Failed to send reset link. Try again.');
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
                Center(
                  child: Image.asset(
                    'assets/pictures/forgetpass.png',
                    height: isSmall ? 120 : 160,
                    width: isSmall ? 120 : 160,
                    color: theme.primaryColor,
                    errorBuilder: (_, __, ___) => Icon(Icons.lock_reset,
                        size: isSmall ? 70 : 90, color: theme.primaryColor),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Forgot Password?', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address and we\'ll send you a verification code.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontSize: isSmall ? 14 : 16),
                ),
                const SizedBox(height: 40),
                AppTextField(
                  hint: 'Enter your email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  prefixIcon: Icon(Icons.email_outlined,
                      size: 20, color: theme.hintColor),
                  onChanged: (_) => setState(() => _emailError = null),
                ),
                const SizedBox(height: 32),
                AppButton(
                  text:
                      'SEND RESET LINK', // النص ثابت أثناء التحميل (لكن سيحجبه الـ spinner)
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _sendResetLink,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall,
                      children: const [
                        TextSpan(text: 'Remember your password? '),
                        TextSpan(
                            text: 'Back to Login',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
