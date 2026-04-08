// lib/features/home/tabs/home tab/foods_screen.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';

import '../../../../../../core/navigation/page_transitions.dart';
import 'food_detail_screen.dart';

class FoodsScreen extends StatelessWidget {
  const FoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            backgroundColor: context.surfaceColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            floating: true,
            toolbarHeight: 60,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: context.iconColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: _buildSearchBar(context),
            centerTitle: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildSectionTitle(context, "home.recent_foods".tr()),
                const SizedBox(height: 16),
                ..._buildFoodList(context, _getRecentFoods()),
                const SizedBox(height: 16),
                _buildSectionTitle(context, "home.Smart_Food_Suggestions".tr()),
                const SizedBox(height: 16),
                ..._buildFoodList(context, _getSuggestions()),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: context.textColor,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 5,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "home.Search_here".tr(),
          hintStyle: TextStyle(color: context.textHintColor),
          prefixIcon: Icon(Icons.search, color: context.textHintColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getRecentFoods() {
    return const [
      {
        'name': 'Apple',
        'weight': '800 gr',
        'calories': '83 cal',
        'color': Color(0xFFFF6B6B),
        'imagePath': 'assets/pictures/apple.png'
      },
      {
        'name': 'Pizza',
        'weight': '1100 gr',
        'calories': '350 cal',
        'color': Color(0xFFFFD166),
        'imagePath': 'assets/pictures/pizza.png'
      },
      {
        'name': 'Burger',
        'weight': '1300 gr',
        'calories': '200 cal',
        'color': Color(0xFF4ECDC4),
        'imagePath': 'assets/pictures/burger.png'
      },
      {
        'name': 'Salad',
        'weight': '1000 gr',
        'calories': '100 cal',
        'color': Color(0xFF42E87F),
        'imagePath': 'assets/pictures/salad.png'
      },
    ];
  }

  List<Map<String, dynamic>> _getSuggestions() {
    return const [
      {
        'name': 'Rice',
        'weight': '2200 gr',
        'calories': '80 cal',
        'color': Color(0xFF9D4EDD),
        'imagePath': 'assets/pictures/rice.png'
      },
      {
        'name': 'Chicken',
        'weight': '1100 gr',
        'calories': '390 cal',
        'color': Color(0xFF4ECDC4),
        'imagePath': 'assets/pictures/chicken.png'
      },
      {
        'name': 'Pasta',
        'weight': '1200 gr',
        'calories': '200 cal',
        'color': Color(0xFFFFD166),
        'imagePath': 'assets/pictures/pasta.png'
      },
      {
        'name': 'Peanut Butter',
        'weight': '1500 gr',
        'calories': '100 cal',
        'color': Color(0xFFF8961E),
        'imagePath': 'assets/pictures/peanut_butter.png'
      },
      {
        'name': 'Lasagna',
        'weight': '500 gr',
        'calories': '100 cal',
        'color': Color(0xFFFF6B6B),
        'imagePath': 'assets/pictures/lasagna.png'
      },
    ];
  }

  List<Widget> _buildFoodList(
      BuildContext context, List<Map<String, dynamic>> foods) {
    return foods
        .map((food) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildFoodCard(
                context,
                name: food['name'] as String,
                weight: food['weight'] as String,
                calories: food['calories'] as String,
                color: food['color'] as Color,
                imagePath: food['imagePath'] as String,
              ),
            ))
        .toList();
  }

  Widget _buildFoodCard(
    BuildContext context, {
    required String name,
    required String weight,
    required String calories,
    required Color color,
    required String imagePath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final foodData = _getFoodData(name);
            context.pushWithTransition(
              FoodDetailScreen(
                name: foodData['name'] as String,
                time: 'Recent',
                calories: foodData['calories'] as String,
                color: foodData['color'] as Color,
                imagePath: foodData['imagePath'] as String,
                description: foodData['description'] as String,
                nutrition: foodData['nutrition'] as Map<String, String>,
              ),
              type: TransitionType.fromBottom, // ✅ تم التصحيح
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weight,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      calories,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getFoodData(String foodName) {
    switch (foodName.toLowerCase()) {
      case 'apple':
        return {
          'name': 'Apple',
          'calories': '83 cal',
          'color': const Color(0xFFFF6B6B),
          'imagePath': 'assets/pictures/apple.png',
          'description':
              'An apple is a popular, healthy, low-calorie fruit, rich in fiber and essential vitamins like Vitamin C.',
          'nutrition': {
            'calories': '83 kcal',
            'protein': '0.4g',
            'carbs': '22g',
            'fat': '0.2g',
            'fiber': '4g',
            'sugar': '17g'
          },
        };
      case 'pizza':
        return {
          'name': 'Pizza',
          'calories': '350 cal',
          'color': const Color(0xFFFFD166),
          'imagePath': 'assets/pictures/pizza.png',
          'description':
              'Pizza is a popular dish of Italian origin consisting of a flat, round base of dough baked with various toppings.',
          'nutrition': {
            'calories': '350 kcal',
            'protein': '15g',
            'carbs': '40g',
            'fat': '14g',
            'fiber': '3g',
            'sugar': '5g'
          },
        };
      case 'burger':
        return {
          'name': 'Burger',
          'calories': '200 cal',
          'color': const Color(0xFF4ECDC4),
          'imagePath': 'assets/pictures/burger.png',
          'description':
              'A hamburger is a sandwich consisting of one or more cooked patties of ground meat, usually beef.',
          'nutrition': {
            'calories': '200 kcal',
            'protein': '14g',
            'carbs': '20g',
            'fat': '10g',
            'fiber': '2g',
            'sugar': '4g'
          },
        };
      case 'salad':
        return {
          'name': 'Salad',
          'calories': '100 cal',
          'color': const Color(0xFF42E87F),
          'imagePath': 'assets/pictures/salad.png',
          'description':
              'A salad is a dish consisting of mixed, mostly natural ingredients with at least one raw ingredient.',
          'nutrition': {
            'calories': '100 kcal',
            'protein': '3g',
            'carbs': '10g',
            'fat': '6g',
            'fiber': '4g',
            'sugar': '5g'
          },
        };
      case 'rice':
        return {
          'name': 'Rice',
          'calories': '80 cal',
          'color': const Color(0xFF9D4EDD),
          'imagePath': 'assets/pictures/rice.png',
          'description':
              'Rice is the most widely consumed staple food for a large part of the world\'s human population.',
          'nutrition': {
            'calories': '80 kcal',
            'protein': '2g',
            'carbs': '18g',
            'fat': '0.5g',
            'fiber': '0.6g',
            'sugar': '0g'
          },
        };
      case 'chicken':
        return {
          'name': 'Chicken',
          'calories': '390 cal',
          'color': const Color(0xFF4ECDC4),
          'imagePath': 'assets/pictures/chicken.png',
          'description':
              'Chicken is a type of poultry, and is one of the most common types of meat in the world.',
          'nutrition': {
            'calories': '390 kcal',
            'protein': '35g',
            'carbs': '0g',
            'fat': '25g',
            'fiber': '0g',
            'sugar': '0g'
          },
        };
      default:
        return {
          'name': foodName,
          'calories': '100 cal',
          'color': const Color(0xFF42E87F),
          'imagePath': 'assets/pictures/apple.png',
          'description': 'Detailed information about $foodName.',
          'nutrition': {
            'calories': '100 kcal',
            'protein': '5g',
            'carbs': '15g',
            'fat': '3g',
            'fiber': '2g',
            'sugar': '5g'
          },
        };
    }
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
    if (name.contains('rice')) return Icons.rice_bowl;
    return Icons.fastfood;
  }
}
