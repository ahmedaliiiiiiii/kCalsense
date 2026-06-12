import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_router.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/color_manager.dart';
import '../../core/utils/responsive_manager.dart';
import '../../core/widgets/animated_toggle.dart';
import '../../core/widgets/app_button.dart';

class StartScreen extends StatefulWidget {
  static const String routeName = "/start";
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _isEnglish = true;
  bool _isDarkMode = false;
  final AppPrefs _appPrefs = sl<AppPrefs>();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final savedLanguage = _appPrefs.languageCode;
    final themeProvider = context.read<ThemeProvider>();
    if (mounted) {
      setState(() {
        _isEnglish = savedLanguage != 'ar';
        _isDarkMode = themeProvider.isDarkMode;
      });
    }
  }

  void _toggleLanguage(bool val) async {
    setState(() => _isEnglish = val);
    await context.setLocale(val ? const Locale('en') : const Locale('ar'));
    await _appPrefs.saveLanguage(val ? 'en' : 'ar');
  }

  void _toggleTheme(bool val) {
    final themeProvider = context.read<ThemeProvider>();
    setState(() => _isDarkMode = val);
    if (val != themeProvider.isDarkMode) themeProvider.toggleTheme();
    _appPrefs.saveThemeMode(val ? 'dark' : 'light');
  }

  Future<void> _continue() async {
    if (mounted) {
      context.go(AppRouter.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final theme = Theme.of(context);
    final primaryColor = ColorManager.primaryColor;

    return Scaffold(
      backgroundColor: theme.dialogBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Container(
                          padding:
                              EdgeInsets.all(ResponsiveManager.spacingXLarge),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.language_rounded,
                              size: 80, color: primaryColor),
                        ),
                        SizedBox(height: ResponsiveManager.spacingXXLarge),
                        Text(
                          'start.title'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveManager.heading2,
                            fontWeight: FontWeight.w900,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        SizedBox(height: ResponsiveManager.spacingMedium),
                        Text(
                          'start.subtitle'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveManager.bodyMedium,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        const Spacer(),
                        _buildOptionRow(
                          icon: Icons.translate_rounded,
                          title: 'start.language'.tr(),
                          trailing: AnimatedToggle(
                            value: _isEnglish,
                            onChanged: _toggleLanguage,
                            leftIcon: Icons.language_rounded,
                            rightIcon: Icons.language_rounded,
                            leftText: 'العربية',
                            rightText: 'English',
                            indicatorColor: primaryColor,
                            backgroundColor: theme.cardColor,
                            borderColor: theme.dividerColor,
                          ),
                        ),
                        SizedBox(height: ResponsiveManager.spacingMedium),
                        _buildOptionRow(
                          icon: _isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          title: 'start.appearance'.tr(),
                          trailing: AnimatedToggle(
                            value: _isDarkMode,
                            onChanged: _toggleTheme,
                            leftIcon: Icons.light_mode_rounded,
                            rightIcon: Icons.dark_mode_rounded,
                            leftText: 'start.light'.tr(),
                            rightText: 'start.dark'.tr(),
                            indicatorColor: primaryColor,
                            backgroundColor: theme.cardColor,
                            borderColor: theme.dividerColor,
                          ),
                        ),
                        SizedBox(height: ResponsiveManager.spacingXXLarge),
                        AppButton(
                          text: 'start.get_started'.tr(),
                          onPressed: _continue,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusCircular),
        border: Border.all(color: theme.primaryColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorManager.primaryColor, size: 24),
          SizedBox(width: ResponsiveManager.spacingMedium),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveManager.bodyMedium,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          trailing, // ✅ بدون Flexible لأن العرض محدد داخل AnimatedToggle
        ],
      ),
    );
  }
}
