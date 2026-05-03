// lib/features/auth/presention/login_page.dart

// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../core/diauth/service_locator.dart';
import '../../../core/storge/shared_preferences_helper.dart';
import '../../../core/storge/token_storage.dart';
import '../../../core/utiles/color_manager.dart';
import '../../../core/utiles/responsive_manager.dart';
import '../../home/view/tabs/home tab/home_tab.dart';
import 'cubit/authcubit_cubit.dart';
import 'cubit/authcubit_state.dart';
import 'register_page.dart';
import 'reset password/forget_password_page.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = "/login";
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  String? emailError;
  String? passError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ResponsiveManager.init(context);
  }

  void validateEmail(String val) {
    final bool emailValid =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val);
    setState(() {
      emailError =
          (val.isEmpty || emailValid) ? null : "auth.login.invalid_email".tr();
    });
  }

  void validatePassword(String val) {
    final bool passValid =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
            .hasMatch(val);
    setState(() {
      passError = (val.isEmpty || passValid)
          ? null
          : "auth.register.password_requirements".tr();
    });
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AuthBackground(
          child: SafeArea(
            child: BlocListener<AuthCubit, AuthState>(
              listenWhen: (p, c) => p.user != c.user || p.error != c.error,
              listener: (context, state) async {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: context.errorColor,
                    ),
                  );
                  context.read<AuthCubit>().clearError();
                }
                // في BlocListener داخل login_page.dart

                if (state.user != null) {
                  // ✅ حفظ التوكن
                  final tokenStorage = TokenStorage();
                  await tokenStorage.saveAuth(
                    token: state.user!.token,
                    email: state.user!.email,
                    userName: state.user!.userName,
                  );

                  // ✅ حفظ حالة تسجيل الدخول
                  await SharedPreferencesHelper.setLoggedIn(true);

                  // ✅ حفظ اكتمال الـ Setup
                  await SharedPreferencesHelper.setSetupCompleted(true);

                  if (!mounted) return;

                  Navigator.pushReplacement(
                    context,
                    CustomPageTransitions.fastSlideTransition(const HomePage()),
                  );
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveManager.horizontalPadding,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: ResponsiveManager.spacingSmall),
                              Text(
                                "auth.login.title".tr(),
                                style: TextStyle(
                                  color: context.primaryColor,
                                  fontSize: ResponsiveManager.heading1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: ResponsiveManager.spacingSmall),
                              Text.rich(
                                TextSpan(
                                  text: "auth.login.no_account".tr(),
                                  style: TextStyle(
                                    color: context.textSecondaryColor,
                                    fontSize: ResponsiveManager.bodyMedium,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "auth.login.sign_up".tr(),
                                      style: TextStyle(
                                        color: context.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: ResponsiveManager.bodyMedium,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            CustomPageTransitions
                                                .fastSlideTransition(
                                              const RegisterPage(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: ResponsiveManager.spacingXXLarge),
                              AppTextField(
                                controller: email,
                                hint: "auth.login.email_hint".tr(),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: validateEmail,
                                errorText: emailError,
                              ),
                              SizedBox(height: ResponsiveManager.spacingMedium),
                              AppTextField(
                                controller: password,
                                hint: "auth.login.password_hint".tr(),
                                obscure: true,
                                onChanged: validatePassword,
                                errorText: passError,
                              ),
                              SizedBox(height: ResponsiveManager.spacingSmall),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      CustomPageTransitions.fastSlideTransition(
                                          const ForgotPasswordPage()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          ResponsiveManager.spacingSmall,
                                      vertical: ResponsiveManager.spacingXSmall,
                                    ),
                                  ),
                                  child: Text(
                                    "auth.login.forget_password".tr(),
                                    style: TextStyle(
                                      color: context.textSecondaryColor,
                                      fontSize: ResponsiveManager.bodySmall,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: ResponsiveManager.spacingXLarge),
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  bool hasError =
                                      emailError != null || passError != null;
                                  bool isEmpty = email.text.isEmpty ||
                                      password.text.isEmpty;

                                  return AppButton(
                                    text: state.loading
                                        ? "auth.login.loading".tr()
                                        : "auth.login.login_button".tr(),
                                    onPressed:
                                        (state.loading || hasError || isEmpty)
                                            ? null
                                            : () {
                                                context.read<AuthCubit>().login(
                                                      email: email.text.trim(),
                                                      password: password.text,
                                                    );
                                              },
                                  );
                                },
                              ),
                              SizedBox(height: ResponsiveManager.spacingLarge),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
