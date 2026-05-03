// lib/features/home/view/tabs/scan/widgets/nalysis_results_sheet.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/utiles/responsive_manager.dart';
import '../model/food_recognition_result.dart';

class AnalysisResultsSheet extends StatelessWidget {
  final VoidCallback onDone;
  final FoodRecognitionResult result;

  const AnalysisResultsSheet({
    super.key,
    required this.onDone,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveManager.isSmallScreen;

    final confidence = result.confidenceScore.clamp(0.0, 1.0);
    String percentage(double v) => '${(v * 100).toStringAsFixed(0)}%';

    return Container(
      height: ResponsiveManager.bottomSheetHeight,
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveManager.bottomSheetRadius),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin:
                          EdgeInsets.only(top: ResponsiveManager.spacingXSmall),
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveManager.spacingMedium),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: isSmallScreen ? 36 : 40,
                        height: isSmallScreen ? 36 : 40,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(
                              ResponsiveManager.radiusMedium),
                        ),
                        child: Icon(
                          Icons.analytics_outlined,
                          color: theme.primaryColor,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: ResponsiveManager.spacingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "scan.analysis_results".tr(),
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? ResponsiveManager.heading4
                                    : ResponsiveManager.heading3,
                                fontWeight: FontWeight.w800,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            SizedBox(height: ResponsiveManager.spacingXSmall),
                            Text(
                              "scan.nutritional_breakdown".tr(),
                              style: TextStyle(
                                fontSize: ResponsiveManager.caption,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveManager.spacingMedium),

                  // Food Name & Category Chips
                  Wrap(
                    spacing: ResponsiveManager.spacingSmall,
                    runSpacing: ResponsiveManager.spacingSmall,
                    children: [
                      _buildChip(Icons.restaurant_menu, result.foodName, theme),
                      _buildChip(
                          Icons.category_outlined, result.categoryName, theme),
                    ],
                  ),

                  SizedBox(height: ResponsiveManager.spacingLarge),

                  // Macros Title
                  Text(
                    "scan.macros".tr(),
                    style: TextStyle(
                      fontSize: ResponsiveManager.bodyLarge,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),

                  SizedBox(height: ResponsiveManager.spacingSmall),

                  // Macros Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: ResponsiveManager.spacingSmall,
                    mainAxisSpacing: ResponsiveManager.spacingSmall,
                    childAspectRatio: 2.2,
                    children: [
                      _buildMacroCard(
                        title: "scan.calories".tr(),
                        value: result.calories.toStringAsFixed(0),
                        unit: 'kcal',
                        icon: Icons.local_fire_department_outlined,
                        theme: theme,
                        color: const Color(0xFFFF6B6B),
                      ),
                      _buildMacroCard(
                        title: "scan.protein".tr(),
                        value: result.protein.toStringAsFixed(1),
                        unit: 'g',
                        icon: Icons.fitness_center_outlined,
                        theme: theme,
                        color: const Color(0xFF4ECDC4),
                      ),
                      _buildMacroCard(
                        title: "scan.carbs".tr(),
                        value: result.carbs.toStringAsFixed(1),
                        unit: 'g',
                        icon: Icons.rice_bowl_outlined,
                        theme: theme,
                        color: const Color(0xFFFFD166),
                      ),
                      _buildMacroCard(
                        title: "scan.fat".tr(),
                        value: result.fats.toStringAsFixed(1),
                        unit: 'g',
                        icon: Icons.opacity_outlined,
                        theme: theme,
                        color: const Color(0xFF9D4EDD),
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveManager.spacingLarge),

                  // Confidence Title
                  Text(
                    "scan.confidence".tr(),
                    style: TextStyle(
                      fontSize: ResponsiveManager.bodyLarge,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),

                  SizedBox(height: ResponsiveManager.spacingSmall),

                  // Confidence Progress Bar
                  Container(
                    padding: EdgeInsets.all(ResponsiveManager.spacingSmall),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(ResponsiveManager.radiusMedium),
                      border: Border.all(color: theme.dividerColor),
                      color: theme.cardTheme.color,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                ResponsiveManager.radiusCircular),
                            child: LinearProgressIndicator(
                              value: confidence,
                              minHeight: 8,
                              backgroundColor: theme.dividerColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.primaryColor),
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveManager.spacingSmall),
                        Text(
                          percentage(confidence),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: theme.primaryColor,
                            fontSize: ResponsiveManager.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ResponsiveManager.spacingLarge),
                ],
              ),
            ),
          ),

          // Done Button (Outside ScrollView)
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveManager.spacingXSmall,
              bottom: 0,
            ),
            child: SizedBox(
              width: double.infinity,
              height: ResponsiveManager.buttonHeight,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ResponsiveManager.buttonRadius),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "scan.done".tr(),
                  style: TextStyle(
                    fontSize: ResponsiveManager.bodyLarge,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String text, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveManager.spacingSmall,
        vertical: ResponsiveManager.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusCircular),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.primaryColor),
          SizedBox(width: ResponsiveManager.spacingXSmall),
          Text(
            text,
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveManager.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required ThemeData theme,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        color: theme.cardTheme.color,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: ResponsiveManager.spacingSmall),
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
                SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          color: theme.textTheme.titleLarge?.color,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        unit,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
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
