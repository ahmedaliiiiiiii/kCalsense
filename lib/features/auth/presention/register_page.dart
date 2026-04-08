// lib/features/auth/presention/register_page.dart

// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../core/diauth/service_locator.dart';
import '../../../core/storge/shared_preferences_helper.dart';
import '../../../core/utiles/color_manager.dart';
import '../../../core/utiles/responsive_manager.dart';
import '../../setup/view/setup_flow_page.dart';
import 'cubit/authcubit_cubit.dart';
import 'cubit/authcubit_state.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  String? emailError;
  String? passError;
  String? confirmError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ResponsiveManager.init(context);
  }

  void validateEmail(String val) {
    final bool emailValid =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val);
    setState(() {
      emailError = (val.isEmpty || emailValid)
          ? null
          : "auth.register.invalid_email".tr();
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
    if (confirm.text.isNotEmpty) validateConfirm(confirm.text);
  }

  void validateConfirm(String val) {
    setState(() {
      confirmError = (val.isEmpty || val == password.text)
          ? null
          : "auth.register.password_mismatch".tr();
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
                if (state.user != null) {
                  // ✅ حفظ حالة تسجيل الدخول
                  await SharedPreferencesHelper.setLoggedIn(true);

                  // ✅ أول مرة يسجل → يعمل Setup
                  await SharedPreferencesHelper.setNewUserCompleted();

                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      CustomPageTransitions.fastSlideTransition(
                        const SetupFlowPage(),
                      ),
                    );
                  }
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
                                "auth.register.title".tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: context.primaryColor,
                                  fontSize: ResponsiveManager.heading2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: ResponsiveManager.spacingSmall),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "auth.register.have_account".tr(),
                                    style: TextStyle(
                                      color: context.textSecondaryColor,
                                      fontSize: ResponsiveManager.bodyMedium,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        CustomPageTransitions
                                            .fastSlideTransition(
                                          const LoginPage(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      "auth.register.sign_in".tr(),
                                      style: TextStyle(
                                        color: context.primaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: ResponsiveManager.bodyMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: ResponsiveManager.spacingXXLarge),
                              AppTextField(
                                controller: name,
                                hint: "auth.register.name_hint".tr(),
                              ),
                              SizedBox(height: ResponsiveManager.spacingMedium),
                              AppTextField(
                                controller: email,
                                hint: "auth.register.email_hint".tr(),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: validateEmail,
                                errorText: emailError,
                              ),
                              SizedBox(height: ResponsiveManager.spacingMedium),
                              AppTextField(
                                controller: password,
                                hint: "auth.register.password_hint".tr(),
                                obscure: true,
                                onChanged: validatePassword,
                                errorText: passError,
                              ),
                              SizedBox(height: ResponsiveManager.spacingMedium),
                              AppTextField(
                                controller: confirm,
                                hint:
                                    "auth.register.confirm_password_hint".tr(),
                                obscure: true,
                                onChanged: validateConfirm,
                                errorText: confirmError,
                              ),
                              SizedBox(height: ResponsiveManager.spacingXLarge),
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  bool hasErrors = emailError != null ||
                                      passError != null ||
                                      confirmError != null;
                                  bool isFormEmpty = name.text.isEmpty ||
                                      email.text.isEmpty ||
                                      password.text.isEmpty ||
                                      confirm.text.isEmpty;

                                  return AppButton(
                                    text: state.loading
                                        ? "auth.register.loading".tr()
                                        : "auth.register.register_button".tr(),
                                    onPressed: (state.loading ||
                                            hasErrors ||
                                            isFormEmpty)
                                        ? null
                                        : () {
                                            context.read<AuthCubit>().register(
                                                  userName: name.text.trim(),
                                                  email: email.text.trim(),
                                                  password: password.text,
                                                  confirmPassword: confirm.text,
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
