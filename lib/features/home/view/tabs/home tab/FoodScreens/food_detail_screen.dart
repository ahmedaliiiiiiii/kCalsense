// lib/features/home/screens/food_detail_screen.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';

import '../../../../../../core/utiles/responsive_manager.dart';

class FoodDetailScreen extends StatelessWidget {
  final String name;
  final String time;
  final String calories;
  final Color color;
  final String imagePath;
  final String description;
  final Map<String, String> nutrition;

  const FoodDetailScreen({
    super.key,
    required this.name,
    required this.time,
    required this.calories,
    required this.color,
    required this.imagePath,
    required this.description,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'food_detail.food_details'.tr(),
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFoodHeaderCard(context),
            SizedBox(height: ResponsiveManager.spacingXLarge),
            _buildDescriptionSection(context),
            SizedBox(height: ResponsiveManager.spacingXLarge),
            _buildNutritionFactsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodHeaderCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(ResponsiveManager.spacingXLarge),
      child: Column(
        children: [
          Container(
            width: ResponsiveManager.imageLarge,
            height: ResponsiveManager.imageLarge,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: color.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        _getFoodIcon(name),
                        color: color,
                        size: ResponsiveManager.iconXLarge,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingLarge),
          Text(
            name,
            style: TextStyle(
              fontSize: ResponsiveManager.heading3,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingSmall),
          Text(
            time,
            style: TextStyle(
              fontSize: ResponsiveManager.bodyMedium,
              color: context.textSecondaryColor,
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingLarge),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveManager.spacingXLarge,
              vertical: ResponsiveManager.spacingMedium,
            ),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
            ),
            child: Text(
              calories,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: context.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(ResponsiveManager.spacingXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "food_detail.description".tr(),
            style: TextStyle(
              fontSize: ResponsiveManager.heading4,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingMedium),
          Text(
            description,
            style: TextStyle(
              fontSize: ResponsiveManager.bodyMedium,
              color: context.textSecondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionFactsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(ResponsiveManager.spacingXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "food_detail.nutrition_facts".tr(),
            style: TextStyle(
              fontSize: ResponsiveManager.heading4,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingLarge),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: ResponsiveManager.gridCrossAxisCount,
            crossAxisSpacing: ResponsiveManager.gridSpacing,
            mainAxisSpacing: ResponsiveManager.gridSpacing,
            childAspectRatio: 1.2,
            children: [
              _buildNutritionItem(context,
                  label: "scan.calories".tr(),
                  value: nutrition['calories'] ?? '0',
                  color: context.primaryColor),
              _buildNutritionItem(context,
                  label: "scan.protein".tr(),
                  value: nutrition['protein'] ?? '0g',
                  color: const Color(0xFF4ECDC4)),
              _buildNutritionItem(context,
                  label: "scan.carbs".tr(),
                  value: nutrition['carbs'] ?? '0g',
                  color: const Color(0xFFFFD166)),
              _buildNutritionItem(context,
                  label: "scan.fat".tr(),
                  value: nutrition['fat'] ?? '0g',
                  color: const Color(0xFFFF6B6B)),
              _buildNutritionItem(context,
                  label: "Fiber",
                  value: nutrition['fiber'] ?? '0g',
                  color: const Color(0xFF9D4EDD)),
              _buildNutritionItem(context,
                  label: "Sugar",
                  value: nutrition['sugar'] ?? '0g',
                  color: const Color(0xFFF8961E)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(BuildContext context,
      {required String label, required String value, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.dividerColor),
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusSmall),
      ),
      padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveManager.bodyLarge,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingXSmall),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveManager.caption,
              color: context.textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getFoodIcon(String foodName) {
    final name = foodName.toLowerCase();
    if (name.contains('apple')) return Icons.apple;
    if (name.contains('pizza')) return Icons.local_pizza;
    if (name.contains('burger')) return Icons.lunch_dining;
    if (name.contains('salad')) return Icons.eco;
    if (name.contains('chicken')) return Icons.kebab_dining;
    if (name.contains('pasta')) return Icons.dinner_dining;
    if (name.contains('peanut')) return Icons.egg_alt;
    if (name.contains('lasagna')) return Icons.restaurant;
    return Icons.fastfood;
  }
}
