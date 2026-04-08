// lib/features/home/tabs/profile/view/profile_page.dart

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/diauth/service_locator.dart';
import '../../../../../../core/navigation/page_transitions.dart';
import '../../../../../../core/storge/token_storage.dart';
import '../../../../../../core/utiles/responsive_manager.dart'
    show ResponsiveManager;
import '../../../../../auth/presention/login_page.dart';
import '../../../../../notifications/notifications_page.dart';
import '../viewmodel/profile_view_model.dart';
import '../widgets/profile_goal_card.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_section_title.dart';
import '../widgets/profile_settings_card.dart';
import '../widgets/profile_top_card.dart';
import 'edit_profile_screen.dart';
import 'help_center_page.dart';
import 'privacy_policy_page.dart';

class ProfilePage extends StatelessWidget {
  static const String routeName = "/profile";
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    return ChangeNotifierProvider(
      create: (_) {
        final vm = ProfileViewModel(tokenStorage: sl<TokenStorage>());
        vm.init();
        return vm;
      },
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  File? _profileImage;
  final String _imageKey = 'profile_image';

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString(_imageKey);
      if (imagePath != null && imagePath.isNotEmpty && mounted) {
        final file = File(imagePath);
        if (await file.exists()) {
          setState(() {
            _profileImage = file;
          });
        } else {
          await prefs.remove(_imageKey);
          if (mounted) {
            setState(() {
              _profileImage = null;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
  }

  void _signOut(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            'profile.sign_out'.tr(),
            style: TextStyle(
              color: context.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'profile.sign_out_confirmation'.tr(),
            style: TextStyle(color: context.textSecondaryColor),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'profile.cancel'.tr(),
                style: TextStyle(
                  color: context.lightGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _signOut(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ResponsiveManager.radiusSmall),
                ),
              ),
              child: Text('profile.sign_out'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final model = vm.data ?? ProfileUiModel.empty();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                ResponsiveManager.horizontalPadding,
                ResponsiveManager.spacingLarge,
                ResponsiveManager.horizontalPadding,
                ResponsiveManager.spacingSmall,
              ),
              child: ProfileTopCard(
                model: model,
                profileImage: _profileImage,
                onEdit: () async {
                  final updated = await context.pushWithTransition(
                    EditProfileScreen(model: model),
                    type: TransitionType.fromBottom,
                  );

                  if (updated == true && mounted) {
                    await vm.init();
                    await _loadSavedImage();
                  }
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                  ResponsiveManager.horizontalPadding,
                  0,
                  ResponsiveManager.horizontalPadding,
                  ResponsiveManager.spacingXLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vm.error != null)
                      Container(
                        padding:
                            EdgeInsets.all(ResponsiveManager.spacingMedium),
                        margin: EdgeInsets.only(
                            bottom: ResponsiveManager.spacingLarge),
                        decoration: BoxDecoration(
                          color: context.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              ResponsiveManager.radiusSmall),
                          border: Border.all(
                              color: context.errorColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: context.errorColor,
                              size: ResponsiveManager.iconSmall,
                            ),
                            SizedBox(width: ResponsiveManager.spacingSmall),
                            Expanded(
                              child: Text(
                                vm.error!,
                                style: TextStyle(
                                  color: context.errorColor,
                                  fontSize: ResponsiveManager.bodySmall,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ProfileSectionTitle(
                      icon: Icons.info_outline,
                      title: "profile.basic_information".tr(),
                    ),
                    SizedBox(height: ResponsiveManager.spacingMedium),
                    ProfileBasicInfoGrid(model: model),
                    SizedBox(height: ResponsiveManager.spacingXLarge),
                    ProfileSectionTitle(
                      icon: Icons.flag_outlined,
                      title: "profile.current_goal".tr(),
                    ),
                    SizedBox(height: ResponsiveManager.spacingMedium),
                    ProfileGoalCard(model: model),
                    SizedBox(height: ResponsiveManager.spacingXLarge),
                    ProfileSectionTitle(
                      icon: Icons.settings_outlined,
                      title: "profile.app_settings".tr(),
                    ),
                    SizedBox(height: ResponsiveManager.spacingMedium),
                    ProfileSettingsCard(
                      onNotifications: () {
                        context.pushWithTransition(
                          const NotificationsPage(),
                          type: TransitionType.ios,
                        );
                      },
                      onPrivacy: () {
                        context.pushWithTransition(
                          const PrivacyPolicyPage(),
                          type: TransitionType.ios,
                        );
                      },
                      onHelp: () {
                        context.pushWithTransition(
                          const HelpCenterPage(),
                          type: TransitionType.ios,
                        );
                      },
                      onSignOut: () {
                        _showSignOutDialog(context);
                      },
                    ),
                    SizedBox(height: ResponsiveManager.spacingLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
