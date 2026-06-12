import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/utils/color_manager.dart';
import '../../../../../../core/utils/responsive_manager.dart';
import '../view_model/stats_viewmodel.dart';

class ProgressTab extends StatelessWidget {
  final StatsData statsData;
  const ProgressTab({super.key, required this.statsData});

  @override
  Widget build(BuildContext context) {
    final weeklyCurrent = statsData.avgCalories * 7;
    final weeklyTarget = statsData.dailyGoal * 7;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderText(context, "stats.goal_progress".tr(),
                  "stats.track_progress".tr()),
              const SizedBox(height: 20),
              _GoalCard(
                title: "stats.daily_calorie_goal".tr(),
                current: statsData.avgCalories.toDouble(),
                target: statsData.dailyGoal.toDouble(),
                unit: 'kcal',
                gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
              ),
              const SizedBox(height: 24),
              _GoalCard(
                title: "stats.weekly_calorie_goal".tr(),
                current: weeklyCurrent.toDouble(),
                target: weeklyTarget.toDouble(),
                unit: 'kcal',
                gradientColors: const [Color(0xFF4ECDC4), Color(0xFF6CD4CC)],
              ),
              const SizedBox(height: 32),
              _buildHeaderText(context, "stats.achievements".tr(),
                  "stats.badges_earned".tr()),
              const SizedBox(height: 20),
              _AchievementsGrid(statsData: statsData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText(
          BuildContext context, String title, String subtitle) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveManager.bodyLarge,
              fontWeight: FontWeight.w800,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: ResponsiveManager.caption,
              color: context.lightGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}

class _GoalCard extends StatelessWidget {
  final String title, unit;
  final double current, target;
  final List<Color> gradientColors;
  const _GoalCard({
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = target > 0 ? (current / target) * 100 : 0;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors),
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
        boxShadow: [
          BoxShadow(
              color: gradientColors.first.withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveManager.bodyMedium,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveManager.spacingMedium,
                    vertical: ResponsiveManager.spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius:
                        BorderRadius.circular(ResponsiveManager.radiusCircular),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: ResponsiveManager.bodySmall,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusCircular),
              child: LinearProgressIndicator(
                value: target > 0 ? current / target : 0,
                backgroundColor: Colors.white.withAlpha(40),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 12.h,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "stats.current".tr(),
                      style: TextStyle(
                        fontSize: ResponsiveManager.caption,
                        color: Colors.white.withAlpha(200),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${current.toStringAsFixed(0)} $unit',
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodyLarge,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "stats.target".tr(),
                      style: TextStyle(
                        fontSize: ResponsiveManager.caption,
                        color: Colors.white.withAlpha(200),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${target.toStringAsFixed(0)} $unit',
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodyLarge,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  final StatsData statsData;
  const _AchievementsGrid({required this.statsData});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      {
        'icon': Icons.whatshot,
        'label': "stats.streak_5_days".tr(),
        'achieved': statsData.streakDays >= 5,
        'color': const Color(0xFFFF6B6B)
      },
      {
        'icon': Icons.emoji_events,
        'label': "stats.goal_master".tr(),
        'achieved': statsData.avgCalories >= statsData.dailyGoal * 0.9,
        'color': const Color(0xFFFFD166)
      },
      {
        'icon': Icons.fitness_center,
        'label': "stats.protein_king".tr(),
        'achieved': (statsData.macrosAverage['Protein'] ?? 0) >= 100,
        'color': const Color(0xFF4ECDC4)
      },
      {
        'icon': Icons.bolt,
        'label': "stats.energy_boost".tr(),
        'achieved': statsData.totalLoggedMeals >= 10,
        'color': const Color(0xFFFF8E8E)
      },
      {
        'icon': Icons.eco,
        'label': "stats.healthy_eater".tr(),
        'achieved': statsData.totalDays >= 7,
        'color': const Color(0xFF6CD4CC)
      },
      {
        'icon': Icons.timer,
        'label': "stats.early_bird".tr(),
        'achieved': false,
        'color': Colors.grey
      },
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: ResponsiveManager.spacingMedium,
        mainAxisSpacing: ResponsiveManager.spacingMedium,
        childAspectRatio: 0.9,
      ),
      itemCount: achievements.length,
      itemBuilder: (_, i) {
        final a = achievements[i];
        return _AchievementItem(
          icon: a['icon'] as IconData,
          label: a['label'] as String,
          achieved: a['achieved'] as bool,
          color: a['color'] as Color,
          key: ValueKey(a['label']),
        );
      },
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool achieved;
  final Color color;
  const _AchievementItem({
    required this.icon,
    required this.label,
    required this.achieved,
    required this.color,
    required super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: achieved
            ? LinearGradient(colors: [color.withAlpha(25), color.withAlpha(10)])
            : null,
        color: achieved ? null : context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        border: Border.all(
            color: achieved ? color.withAlpha(80) : context.dividerColor,
            width: 1.5),
        boxShadow: achieved
            ? [
                BoxShadow(
                    color: color.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: ResponsiveManager.iconLarge,
                    color: achieved ? color : context.lightGrey),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: ResponsiveManager.caption,
                      color: achieved ? context.textColor : context.lightGrey,
                      fontWeight: achieved ? FontWeight.w700 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          if (achieved)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: color.withAlpha(120),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Icon(Icons.check,
                    size: ResponsiveManager.iconSmall * 0.7,
                    color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
