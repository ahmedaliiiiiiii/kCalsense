// lib/features/start_screen/start_screen.dart

// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/navigation/animated_widgets.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/storge/shared_preferences_helper.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utiles/color_manager.dart';
import '../../core/utiles/responsive_manager.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = "/settings";
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEnglish = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language_code');
    final themeProvider = context.read<ThemeProvider>();

    if (mounted) {
      setState(() {
        _isEnglish = savedLanguage != 'ar';
        _isDarkMode = themeProvider.isDarkMode;
      });
    }
  }

  Future<void> _saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    await SharedPreferencesHelper.saveLanguage(code);
  }

  void _toggleLanguage() async {
    setState(() {
      _isEnglish = !_isEnglish;
    });

    final newLocale = _isEnglish ? const Locale('en') : const Locale('ar');
    await context.setLocale(newLocale);
    await _saveLanguage(_isEnglish ? 'en' : 'ar');
  }

  void _toggleTheme() {
    final themeProvider = context.read<ThemeProvider>();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    themeProvider.toggleTheme();
  }

  Future<void> _continue() async {
    await SharedPreferencesHelper.setFirstLaunchCompleted();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      CustomPageTransitions.iosSlideTransition(const OnBoardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleAnimation(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                child: Image.asset(
                  "assets/icon/icon.png",
                  filterQuality: FilterQuality.high,
                  height: ResponsiveManager.screenHeight * 0.15,
                ),
              ),
              SizedBox(height: ResponsiveManager.spacingLarge),
              FadeInAnimation(
                duration: const Duration(milliseconds: 400),
                offsetX: 0,
                offsetY: 10,
                child: Column(
                  children: [
                    Text(
                      "settings.title".tr(),
                      style: TextStyle(
                        fontSize: ResponsiveManager.heading1,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    SizedBox(height: ResponsiveManager.spacingSmall),
                    Text(
                      "settings.subtitle".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodyMedium,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveManager.spacingXLarge),
              FadeInAnimation(
                duration: const Duration(milliseconds: 500),
                offsetX: 0,
                offsetY: 10,
                child: Container(
                  padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius:
                        BorderRadius.circular(ResponsiveManager.radiusXLarge),
                    boxShadow: [
                      BoxShadow(
                        color: context.cardShadow,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildOptionRow(
                        icon: Icons.language,
                        label: "settings.language".tr(),
                        isFirstActive: _isEnglish,
                        onToggle: _toggleLanguage,
                        child1: _buildTextToggle("EN", _isEnglish),
                        child2: _buildTextToggle("AR", !_isEnglish),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: ResponsiveManager.spacingMedium),
                        child: Divider(
                          height: ResponsiveManager.dividerThickness,
                          color: context.dividerColor,
                        ),
                      ),
                      _buildOptionRow(
                        icon: Icons.dark_mode,
                        label: "settings.dark_mode".tr(),
                        isFirstActive: !_isDarkMode,
                        onToggle: _toggleTheme,
                        child1: Icon(Icons.light_mode,
                            size: ResponsiveManager.iconSmall,
                            color: !_isDarkMode
                                ? Colors.white
                                : context.textSecondaryColor),
                        child2: Icon(Icons.dark_mode,
                            size: ResponsiveManager.iconSmall,
                            color: _isDarkMode
                                ? Colors.white
                                : context.textSecondaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: ResponsiveManager.spacingXLarge),
              FadeInAnimation(
                duration: const Duration(milliseconds: 600),
                offsetX: 0,
                offsetY: 10,
                child: SizedBox(
                  width: double.infinity,
                  height: ResponsiveManager.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            ResponsiveManager.buttonRadius),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "settings.continue".tr(),
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodyMedium,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String label,
    required bool isFirstActive,
    required VoidCallback onToggle,
    required Widget child1,
    required Widget child2,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon,
                color: context.primaryColor,
                size: ResponsiveManager.iconMedium),
            SizedBox(width: ResponsiveManager.spacingMedium),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveManager.bodyMedium,
                fontWeight: FontWeight.w500,
                color: context.textColor,
              ),
            ),
          ],
        ),
        _buildAnimatedToggle(
          isFirstOptionActive: isFirstActive,
          onToggle: onToggle,
          firstChild: child1,
          secondChild: child2,
        ),
      ],
    );
  }

  Widget _buildTextToggle(String text, bool isActive) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveManager.bodySmall,
        fontWeight: FontWeight.w800,
        color: isActive ? Colors.white : context.textSecondaryColor,
      ),
    );
  }

  Widget _buildAnimatedToggle({
    required bool isFirstOptionActive,
    required VoidCallback onToggle,
    required Widget firstChild,
    required Widget secondChild,
  }) {
    final double toggleWidth = ResponsiveManager.scale(80);
    final double toggleHeight = ResponsiveManager.smallButtonHeight;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: toggleWidth,
        height: toggleHeight,
        decoration: BoxDecoration(
          color: context.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: isFirstOptionActive
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              child: Container(
                width: toggleWidth * 0.5,
                height: toggleHeight,
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: context.primaryColor.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(child: Center(child: firstChild)),
                Expanded(child: Center(child: secondChild)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
