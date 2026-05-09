// lib/features/home/view/tabs/scan/widgets/analysis_results_sheet.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/utils/responsive_manager.dart';
import '../../../../../../core/widgets/app_button.dart'; // ✅ استخدم الزر الموحد
import '../model/food_recognition_result.dart';

class AnalysisResultsSheet extends StatelessWidget {
  final VoidCallback onDone;
  final List<FoodRecognitionResult> results;

  const AnalysisResultsSheet({
    super.key,
    required this.onDone,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();

    final mainResult = results.first;
    final hasMultiple = results.length > 1;

    ResponsiveManager.init(context);
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveManager.isSmallScreen;

    // أحجام خطوط متجاوبة
    final titleFontSize = isSmallScreen ? 22.0 : 26.0;
    final subtitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final foodNameFontSize = isSmallScreen ? 15.0 : 17.0;
    final macroTitleFontSize = isSmallScreen ? 18.0 : 20.0;
    final macroValueFontSize = isSmallScreen ? 18.0 : 22.0;
    final macroUnitFontSize = isSmallScreen ? 12.0 : 14.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle (مؤشر السحب)
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // محتوى قابل للتمرير
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.analytics_outlined,
                          color: theme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "scan.analysis_results".tr(),
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w800,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasMultiple
                                  ? "تم العثور على ${results.length} أطعمة"
                                  : "scan.nutritional_breakdown".tr(),
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // الأطعمة المكتشفة (Chips)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: results
                        .map(
                          (r) => _buildFoodChip(
                            r.foodName,
                            theme,
                            foodNameFontSize,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  // عنوان المغذيات
                  Text(
                    "scan.macros".tr(),
                    style: TextStyle(
                      fontSize: macroTitleFontSize,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // شبكة المغذيات
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _buildMacroCard(
                        "scan.calories".tr(),
                        mainResult.totalcalories.toStringAsFixed(0),
                        'kcal',
                        Icons.local_fire_department_outlined,
                        theme,
                        macroValueFontSize,
                        macroUnitFontSize,
                      ),
                      _buildMacroCard(
                        "scan.protein".tr(),
                        mainResult.totalprotein.toStringAsFixed(1),
                        'g',
                        Icons.fitness_center_outlined,
                        theme,
                        macroValueFontSize,
                        macroUnitFontSize,
                      ),
                      _buildMacroCard(
                        "scan.carbs".tr(),
                        mainResult.totalcarbs.toStringAsFixed(1),
                        'g',
                        Icons.rice_bowl_outlined,
                        theme,
                        macroValueFontSize,
                        macroUnitFontSize,
                      ),
                      _buildMacroCard(
                        "scan.fat".tr(),
                        mainResult.totalfats.toStringAsFixed(1),
                        'g',
                        Icons.opacity_outlined,
                        theme,
                        macroValueFontSize,
                        macroUnitFontSize,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // مسافة صغيرة قبل الزر
                ],
              ),
            ),
          ),
          // ✅ زر "تم" باستخدام الـ AppButton المخصص
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: AppButton(
              text: "scan.done".tr(),
              onPressed: onDone,
            ),
          ),
        ],
      ),
    );
  }

  // Chip خاص باسم الطعام
  Widget _buildFoodChip(String text, ThemeData theme, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primaryColor.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_menu, size: 16, color: theme.primaryColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة المغذيات (تصميم موحد)
  Widget _buildMacroCard(
    String title,
    String value,
    String unit,
    IconData icon,
    ThemeData theme,
    double valueFontSize,
    double unitFontSize,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.cardTheme.color,
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          color: theme.textTheme.titleLarge?.color,
                          fontWeight: FontWeight.w900,
                          fontSize: valueFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        unit,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                          fontSize: unitFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
