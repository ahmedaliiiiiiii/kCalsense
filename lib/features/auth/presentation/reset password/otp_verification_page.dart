import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/utils/responsive_manager.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';

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
  final ApiClient _apiClient = sl<ApiClient>();

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
      if (!mounted) return false;
      if (_resendCooldown <= 1) {
        setState(() => _canResend = true);
        return false;
      }
      setState(() => _resendCooldown--);
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
      await _apiClient.post(ApiEndpoints.verifyOtp, data: {
        'email': widget.email,
        'otp': otp,
      });
      if (!mounted) return;
      context.push('${AppRouter.resetPassword}/${widget.email}/$otp');
    } catch (e) {
      setState(
          () => _otpError = 'Invalid verification code. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    setState(() {
      _isLoading = true;
      _otpError = null;
    });
    try {
      await _apiClient
          .post(ApiEndpoints.forgotPassword, data: {'email': widget.email});
      if (!mounted) return;
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('New verification code sent!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() => _otpError = 'Failed to resend code. Try again.');
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
                  child: Icon(Icons.pin_outlined,
                      size: isSmall ? 50 : 70, color: theme.primaryColor),
                ),
                const SizedBox(height: 32),
                Text('Verify Code', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Enter the verification code sent to',
                    style: theme.textTheme.bodyMedium),
                Text(widget.email,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor)),
                const SizedBox(height: 40),
                AppTextField(
                  hint: 'Enter 6-digit code',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  errorText: _otpError,
                  prefixIcon: Icon(Icons.pin_outlined, color: theme.hintColor),
                  onChanged: (_) => setState(() => _otpError = null),
                ),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Didn't receive code? ",
                      style:
                          TextStyle(color: theme.textTheme.bodyMedium?.color)),
                  if (_canResend)
                    GestureDetector(
                        onTap: _resendOtp,
                        child: Text('Resend',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor)))
                  else
                    Text('Resend in ${_resendCooldown}s',
                        style: TextStyle(color: theme.hintColor)),
                ]),
                const SizedBox(height: 32),
                AppButton(
                  text: 'VERIFY CODE',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _verifyOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
