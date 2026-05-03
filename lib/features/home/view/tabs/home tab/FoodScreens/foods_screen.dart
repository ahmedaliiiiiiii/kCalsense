import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/navigation/page_transitions.dart';
import '../../../../../../core/utiles/color_manager.dart';
import '../../../../../../core/utiles/responsive_manager.dart';
import '../../../../model/home_models.dart';
import '../../../../viewmodel/homeviewmodel.dart';
import 'food_detail_screen.dart';

class FoodsScreen extends StatefulWidget {
  const FoodsScreen({super.key});

  @override
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    final homeVm = Provider.of<HomeViewModel>(context);
    final allFoods = homeVm.recentFoods;

    final filteredFoods = _searchQuery.isEmpty
        ? allFoods
        : allFoods
            .where((food) =>
                food.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: context.surfaceColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            floating: true,
            toolbarHeight: 65,
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
                if (filteredFoods.isNotEmpty)
                  ..._buildFoodListFromModel(context, filteredFoods)
                else if (_searchQuery.isNotEmpty)
                  _buildEmptyState(
                      context,
                      "No results found for '$_searchQuery'",
                      Icons.search_off_rounded)
                else
                  _buildEmptyState(context, "home.no_recent_foods".tr(),
                      Icons.restaurant_outlined),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: context.dividerColor, width: 0.5),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "home.Search_here".tr(),
          hintStyle: TextStyle(
            color: context.lightGrey,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.lightGrey,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.lightGrey.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 56, color: context.lightGrey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: context.lightGrey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (message == "home.no_recent_foods".tr())
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final homeVm =
                    Provider.of<HomeViewModel>(context, listen: false);
                homeVm.changeTab(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text("home.scan_meal".tr()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: context.textColor,
      ),
    );
  }

  List<Widget> _buildFoodListFromModel(
      BuildContext context, List<RecentFoodUiModel> foods) {
    return foods
        .asMap()
        .entries
        .map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildFoodCardFromModel(
                context,
                food: entry.value,
                index: entry.key,
              ),
            ))
        .toList();
  }

  Widget _buildFoodCardFromModel(
    BuildContext context, {
    required RecentFoodUiModel food,
    required int index,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.pushWithTransition(
              FoodDetailScreen(meal: food), // ✅ تمرير الكائن الكامل
              type: TransitionType.fromBottom,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildFoodImage(food.imagePath, food.color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        food.weight,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.lightGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: food.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${food.calories} cal',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: food.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodImage(String imagePath, Color color) {
    if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(imagePath),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _fallbackImage(color);
          },
        ),
      );
    }
    return _fallbackImage(color);
  }

  Widget _fallbackImage(Color color) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.fastfood_rounded, size: 28, color: color),
    );
  }
}
