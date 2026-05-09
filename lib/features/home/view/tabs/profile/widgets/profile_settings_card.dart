// lib/features/home/tabs/profile/widgets/profile_settings_card.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utils/color_manager.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/di/service_locator.dart';
import '../../../../../../core/storage/app_prefs.dart';
import '../../../../../../core/theme/theme_provider.dart';
import '../../../../../../core/utils/responsive_manager.dart';

class ProfileSettingsCard extends StatelessWidget {
  final VoidCallback onNotifications;
  final VoidCallback onPrivacy;
  final VoidCallback onHelp;
  final VoidCallback onSignOut;

  const ProfileSettingsCard({
    super.key,
    required this.onNotifications,
    required this.onPrivacy,
    required this.onHelp,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    ResponsiveManager.init(context);

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLanguageSection(context),
          _buildDivider(context),
          _buildThemeSection(context, themeProvider),
          _buildDivider(context),
          _buildTile(
            context,
            icon: Icons.notifications_none_outlined,
            title: "profile.notifications".tr(),
            onTap: onNotifications,
          ),
          _buildDivider(context),
          _buildTile(
            context,
            icon: Icons.lock_outline,
            title: "profile.privacy".tr(),
            onTap: onPrivacy,
          ),
          _buildDivider(context),
          _buildTile(
            context,
            icon: Icons.help_outline,
            title: "profile.help_center".tr(),
            onTap: onHelp,
          ),
          _buildDivider(context),
          _buildSignOutTile(context),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final currentLocale = context.locale;
    final isEnglish = currentLocale.languageCode == 'en';

    return ListTile(
      leading: Icon(
        Icons.language,
        color: context.iconColor,
        size: ResponsiveManager.iconMedium,
      ),
      title: Text(
        "profile.language".tr(),
        style: TextStyle(
          fontSize: ResponsiveManager.bodyMedium,
          color: context.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        isEnglish ? "English" : "العربية",
        style: TextStyle(
          fontSize: ResponsiveManager.bodySmall,
          color: context.textSecondaryColor,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: ResponsiveManager.iconSmall,
        color: context.lightGrey,
      ),
      onTap: () => _showLanguageDialog(context),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final currentLocale = context.locale;
    final appPrefs = sl<AppPrefs>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            "profile.language".tr(),
            style: TextStyle(
              color: context.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context,
                title: "English",
                flag: "🇬🇧",
                isSelected: currentLocale.languageCode == 'en',
                onTap: () async {
                  await context.setLocale(const Locale('en'));
                  await appPrefs.saveLanguage('en');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                context,
                title: "العربية",
                flag: "🇸🇦",
                isSelected: currentLocale.languageCode == 'ar',
                onTap: () async {
                  await context.setLocale(const Locale('ar'));
                  await appPrefs.saveLanguage('ar');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "profile.cancel".tr(),
                style:
                    TextStyle(color: ColorManager.primaryColor, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveManager.bodyMedium,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? context.primaryColor : context.textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: context.primaryColor,
                size: ResponsiveManager.iconMedium,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: Icon(
        Icons.brightness_6_outlined,
        color: context.iconColor,
        size: ResponsiveManager.iconMedium,
      ),
      title: Text(
        "profile.theme".tr(),
        style: TextStyle(
          fontSize: ResponsiveManager.bodyMedium,
          color: context.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        themeProvider.currentThemeName,
        style: TextStyle(
          fontSize: ResponsiveManager.bodySmall,
          color: context.textSecondaryColor,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: ResponsiveManager.iconSmall,
        color: context.lightGrey,
      ),
      onTap: () => _showThemeDialog(context, themeProvider),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? context.iconColor,
        size: ResponsiveManager.iconMedium,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveManager.bodyMedium,
          color: color ?? context.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: ResponsiveManager.iconSmall,
        color: context.lightGrey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSignOutTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.logout,
        color: Colors.red,
        size: ResponsiveManager.iconMedium,
      ),
      title: Text(
        "profile.sign_out".tr(),
        style: TextStyle(
          fontSize: ResponsiveManager.bodyMedium,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: ResponsiveManager.iconSmall,
        color: context.lightGrey,
      ),
      onTap: onSignOut,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: ResponsiveManager.spacingXXLarge,
      color: context.dividerColor,
    );
  }

  Future<void> _showThemeDialog(
      BuildContext context, ThemeProvider themeProvider) async {
    final appPrefs = sl<AppPrefs>();
    final result = await showDialog<AppThemeMode>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveManager.spacingLarge,
            vertical: ResponsiveManager.spacingMedium,
          ),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.primaryColor.withOpacity(0.1),
                        context.primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(ResponsiveManager.radiusXLarge),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveManager.spacingSmall),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.brightness_6,
                          color: context.primaryColor,
                          size: ResponsiveManager.iconLarge,
                        ),
                      ),
                      SizedBox(width: ResponsiveManager.spacingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "profile.theme_dialog.title".tr(),
                              style: TextStyle(
                                fontSize: ResponsiveManager.bodyLarge,
                                fontWeight: FontWeight.w700,
                                color: context.textColor,
                              ),
                            ),
                            Text(
                              "profile.theme_dialog.subtitle".tr(),
                              style: TextStyle(
                                fontSize: ResponsiveManager.caption,
                                color: context.lightGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveManager.spacingLarge,
                      vertical: ResponsiveManager.spacingMedium,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: AppThemeMode.values.map((mode) {
                        return _buildThemeOption(
                          context: context,
                          mode: mode,
                          currentMode: themeProvider.themeMode,
                          onTap: () => Navigator.pop(context, mode),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveManager.spacingMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveManager.radiusCircular,
                              ),
                            ),
                          ),
                          child: Text(
                            "profile.theme_dialog.cancel".tr(),
                            style: TextStyle(
                              fontSize: ResponsiveManager.bodyMedium,
                              color: context.textSecondaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveManager.spacingMedium),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveManager.spacingMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveManager.radiusCircular,
                              ),
                            ),
                          ),
                          child: Text(
                            "profile.theme_dialog.close".tr(),
                            style: TextStyle(
                              fontSize: ResponsiveManager.bodyMedium,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result != themeProvider.themeMode) {
      await themeProvider.setThemeMode(result);
      String themeValue = 'system';
      if (result == AppThemeMode.light) {
        themeValue = 'light';
      } else if (result == AppThemeMode.dark) {
        themeValue = 'dark';
      }
      await appPrefs.saveThemeMode(themeValue);
    }
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required AppThemeMode mode,
    required AppThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    String title;
    IconData icon;
    String description;

    switch (mode) {
      case AppThemeMode.light:
        title = "profile.theme_option.light".tr();
        icon = Icons.light_mode;
        description = "profile.theme_option.light_desc".tr();
        break;
      case AppThemeMode.dark:
        title = "profile.theme_option.dark".tr();
        icon = Icons.dark_mode;
        description = "profile.theme_option.dark_desc".tr();
        break;
      case AppThemeMode.system:
        title = "profile.theme_option.system".tr();
        icon = Icons.settings_suggest;
        description = "profile.theme_option.system_desc".tr();
        break;
    }

    final isSelected = mode == currentMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveManager.spacingMedium),
        padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.primaryColor.withOpacity(0.1),
                    context.primaryColor.withOpacity(0.05),
                  ],
                )
              : null,
          color: isSelected ? null : context.backgroundColor,
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
          border: Border.all(
            color: isSelected
                ? context.primaryColor.withOpacity(0.5)
                : context.dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveManager.spacingSmall),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.primaryColor.withOpacity(0.2)
                    : context.surfaceColor,
                borderRadius: BorderRadius.circular(
                  ResponsiveManager.radiusMedium,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? context.primaryColor : context.iconColor,
                size: ResponsiveManager.iconMedium,
              ),
            ),
            SizedBox(width: ResponsiveManager.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveManager.bodyMedium,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? context.primaryColor : context.textColor,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: ResponsiveManager.caption,
                      color: context.lightGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(ResponsiveManager.spacingXSmall),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: ResponsiveManager.iconSmall * 0.8,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
