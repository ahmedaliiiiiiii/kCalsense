import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/utiles/responsive_manager.dart';
import '../../../../model/home_models.dart';
import '../../../../viewmodel/homeviewmodel.dart';

class FoodDetailScreen extends StatelessWidget {
  final RecentFoodUiModel meal;

  const FoodDetailScreen({super.key, required this.meal});

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
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFoodHeaderCard(context),
            const SizedBox(height: 24),
            _buildDescriptionSection(context),
            const SizedBox(height: 24),
            _buildNutritionFactsSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${meal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final homeVm = Provider.of<HomeViewModel>(context, listen: false);
              await homeVm.deleteMeal(meal);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodHeaderCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: _buildFoodImage(context),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  meal.name,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  meal.time,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.lightGrey,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: meal.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    '${meal.calories} cal',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: meal.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(BuildContext context) {
    if (meal.imagePath.isNotEmpty && File(meal.imagePath).existsSync()) {
      return Image.file(
        File(meal.imagePath),
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _fallbackImage(context);
        },
      );
    }
    return _fallbackImage(context);
  }

  Widget _fallbackImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      alignment: Alignment.center,
      color: meal.color.withOpacity(0.1),
      child: Icon(Icons.fastfood_rounded, size: 60, color: meal.color),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "food_detail.description".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            meal.description,
            style: TextStyle(
              fontSize: 15,
              color: context.lightGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionFactsSection(BuildContext context) {
    final nutritionItems = [
      {
        'label': "scan.calories".tr(),
        'value': meal.nutrition['calories'] ?? '0',
        'color': context.primaryColor,
      },
      {
        'label': "scan.protein".tr(),
        'value': meal.nutrition['protein'] ?? '0g',
        'color': const Color(0xFF4ECDC4),
      },
      {
        'label': "scan.carbs".tr(),
        'value': meal.nutrition['carbs'] ?? '0g',
        'color': const Color(0xFFFFD166),
      },
      {
        'label': "scan.fat".tr(),
        'value': meal.nutrition['fat'] ?? '0g',
        'color': const Color(0xFFFF6B6B),
      },
      {
        'label': "Fiber",
        'value': meal.nutrition['fiber'] ?? '0g',
        'color': const Color(0xFF9D4EDD),
      },
      {
        'label': "Sugar",
        'value': meal.nutrition['sugar'] ?? '0g',
        'color': const Color(0xFFF8961E),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "food_detail.nutrition_facts".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: nutritionItems.length,
            itemBuilder: (context, index) {
              final item = nutritionItems[index];
              return _buildNutritionItem(
                label: item['label'] as String,
                value: item['value'] as String,
                color: item['color'] as Color,
                ctx: context,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem({
    required String label,
    required String value,
    required Color color,
    required BuildContext ctx,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ctx.lightGrey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
