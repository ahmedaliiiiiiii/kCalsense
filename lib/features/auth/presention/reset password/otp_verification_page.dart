// ignore_for_file: unused_element, depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/utiles/responsive_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'reset_password_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _otpError;
  int _resendCooldown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCooldown = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_resendCooldown <= 1) {
        if (mounted) setState(() => _canResend = true);
        return false;
      }
      if (mounted) setState(() => _resendCooldown--);
      return true;
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      setState(() => _otpError = 'Please enter the verification code');
      return;
    }

    if (otp.length < 6) {
      setState(() => _otpError = 'Please enter a valid 6-digit code');
      return;
    }

    setState(() {
      _otpError = null;
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://foodrecognitionapp.runasp.net/api/Auth/verifyotp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': otp,
        }),
      );

      if (mounted) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // ✅ التوجه لصفحة Reset Password بنفس الترانزيشن
          Navigator.push(
            context,
            CustomPageTransitions.fastSlideTransition(
              ResetPasswordPage(email: widget.email, otp: otp),
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
            _otpError = 'Invalid verification code. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpError = 'Network error. Please check your connection.';
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _otpError = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://foodrecognitionapp.runasp.net/api/Auth/forgotpassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      if (mounted) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          _startResendTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New verification code sent!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          setState(() => _otpError = 'Failed to resend code. Try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _otpError = 'Network error. Please check your connection.');
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
                      Icons.pin_outlined,
                      size: isSmall ? 50 : 70,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveManager.spacingLarge),
                Text(
                  'Verify Code',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: isSmall
                        ? ResponsiveManager.heading2
                        : ResponsiveManager.heading1,
                  ),
                ),
                SizedBox(height: ResponsiveManager.spacingSmall),
                Text(
                  'Enter the verification code sent to',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isSmall
                        ? ResponsiveManager.bodySmall
                        : ResponsiveManager.bodyMedium,
                  ),
                ),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmall
                        ? ResponsiveManager.bodyMedium
                        : ResponsiveManager.bodyLarge,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: ResponsiveManager.spacingXXLarge),
                AppTextField(
                  hint: 'Enter 6-digit code',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  errorText: _otpError,
                  prefixIcon: Icon(
                    Icons.pin_outlined,
                    size: ResponsiveManager.iconMedium,
                    color: theme.hintColor,
                  ),
                  onChanged: (_) {
                    if (_otpError != null) setState(() => _otpError = null);
                  },
                ),
                SizedBox(height: ResponsiveManager.spacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code? ",
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodySmall,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    if (_canResend)
                      GestureDetector(
                        onTap: _resendOtp,
                        child: Text(
                          'Resend',
                          style: TextStyle(
                            fontSize: ResponsiveManager.bodySmall,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Resend in ${_resendCooldown}s',
                        style: TextStyle(
                          fontSize: ResponsiveManager.bodySmall,
                          color: theme.hintColor,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: ResponsiveManager.spacingXLarge),
                AppButton(
                  text: _isLoading ? 'VERIFYING...' : 'VERIFY CODE',
                  onPressed: _isLoading ? null : _verifyOtp,
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
