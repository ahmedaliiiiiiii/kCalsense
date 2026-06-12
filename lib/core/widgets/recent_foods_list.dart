import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/page_transitions.dart';
import '../../../core/utils/color_manager.dart';
import '../../features/home/model/home_models.dart';
import '../../features/home/view/tabs/home_tab/food_screens/food_detail_screen.dart';
import '../../features/home/viewmodel/homeviewmodel.dart';

class RecentFoodsList extends StatelessWidget {
  final List<RecentFoodUiModel> items;

  const RecentFoodsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.restaurant_outlined,
                size: 48, color: context.lightGrey.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              "home.No_recent_foods_yet".tr(),
              style: TextStyle(fontSize: 16, color: context.lightGrey),
            ),
            const SizedBox(height: 8),
            Text(
              "home.scan_meal".tr(),
              style: TextStyle(
                  fontSize: 14, color: context.lightGrey.withOpacity(0.8)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map((e) => _RecentFoodTile(item: e)).toList(),
    );
  }
}

class _RecentFoodTile extends StatelessWidget {
  final RecentFoodUiModel item;

  const _RecentFoodTile({required this.item});

  void _navigateToDetail(BuildContext context) {
    final homeVm = Provider.of<HomeViewModel>(context, listen: false);
    context.pushWithTransition(
      FoodDetailScreen(meal: item, homeViewModel: homeVm),
      type: TransitionType.fromBottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final imgW = (w * 0.3).clamp(46.0, 66.0);
    final imgH = (h * 0.1).clamp(38.0, 54.0);
    final pad = w * 0.03;
    final gap = w * 0.025;

    final nameSize = (w * 0.038).clamp(12.0, 16.0);
    final timeSize = (w * 0.032).clamp(10.0, 13.0);
    final badgeSize = (w * 0.03).clamp(10.0, 12.0);

    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        margin: EdgeInsets.only(bottom: h * 0.012),
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(imgW, imgH, w, context),
            ),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: nameSize,
                      fontWeight: FontWeight.w800,
                      color: context.textColor,
                    ),
                  ),
                  SizedBox(height: h * 0.003),
                  Text(
                    item.time,
                    style: TextStyle(
                      fontSize: timeSize,
                      color: context.lightGrey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.disabledColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${item.calories} cal",
                style: TextStyle(
                  fontSize: badgeSize,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double imgW, double imgH, double w, BuildContext context) {
    if (item.imagePath.isNotEmpty && File(item.imagePath).existsSync()) {
      return Image.file(
        File(item.imagePath),
        width: imgW,
        height: imgH,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _fallbackImage(imgW, imgH, w, context);
        },
      );
    }
    return _fallbackImage(imgW, imgH, w, context);
  }

  Widget _fallbackImage(
      double imgW, double imgH, double w, BuildContext context) {
    return Container(
      width: imgW,
      height: imgH,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(w * 0.035),
      ),
      child: Icon(
        Icons.fastfood,
        size: (w * 0.05).clamp(16.0, 22.0),
        color: item.color,
      ),
    );
  }
}
