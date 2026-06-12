// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/color_manager.dart';
import '../../../core/utils/responsive_manager.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';

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
                  if (mounted) {
                    context.go(AppRouter.setup);
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
                            vertical: ResponsiveManager.spacingMedium,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional.topStart,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: ColorManager.primaryColor
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          context.pop();
                                        },
                                        icon: Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          size: ResponsiveManager.iconMedium,
                                          color: ColorManager.primaryColor,
                                        ),
                                        padding: EdgeInsets.all(
                                            ResponsiveManager.spacingXSmall),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              SizedBox(height: ResponsiveManager.spacingMedium),
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
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go(AppRouter.login);
                                      }
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
                                    text: "auth.register.register_button".tr(),
                                    isLoading: state.loading,
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
                              const Spacer(),
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
