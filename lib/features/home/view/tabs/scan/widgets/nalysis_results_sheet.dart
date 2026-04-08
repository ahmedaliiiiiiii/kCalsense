import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';

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
    final confidence = result.confidenceScore.clamp(0.0, 1.0);
    String pct(double v) => '${(v * 100).toStringAsFixed(0)}%';

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 56,
              height: 5,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: context.dividerColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: context.primaryColor,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "scan.nutritional_breakdown".tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondaryColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ChipPill(
                context: context,
                icon: Icons.restaurant_menu,
                text: result.foodName,
              ),
              _ChipPill(
                context: context,
                icon: Icons.category_outlined,
                text: result.categoryName,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            "scan.macros".tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _MacroCard(
                  context: context,
                  title: "scan.calories".tr(),
                  value: result.calories.toStringAsFixed(0),
                  unit: 'kcal',
                  icon: Icons.local_fire_department_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroCard(
                  context: context,
                  title: "scan.protein".tr(),
                  value: result.protien.toStringAsFixed(1),
                  unit: 'g',
                  icon: Icons.fitness_center_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MacroCard(
                  context: context,
                  title: "scan.carbs".tr(),
                  value: result.carbs.toStringAsFixed(1),
                  unit: 'g',
                  icon: Icons.rice_bowl_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroCard(
                  context: context,
                  title: "scan.fat".tr(),
                  value: result.fats.toStringAsFixed(1),
                  unit: 'g',
                  icon: Icons.opacity_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            "scan.confidence".tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.dividerColor),
              color: context.surfaceColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: confidence,
                      minHeight: 10,
                      backgroundColor: context.dividerColor,
                      valueColor: AlwaysStoppedAnimation(context.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  pct(confidence),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: context.primaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: Text(
                "scan.done".tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String text;

  const _ChipPill({
    required this.context,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.primaryColor.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: context.primaryColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: context.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String value;
  final String unit;
  final IconData icon;

  const _MacroCard({
    required this.context,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: context.surfaceColor,
        border: Border.all(color: context.dividerColor),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: context.primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.textSecondaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: context.textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        unit,
                        style: TextStyle(
                          color: context.textSecondaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
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
