import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/navigation/animated_widgets.dart';
import '../../../../../../core/utils/color_manager.dart';
import '../../../../../../core/utils/responsive_manager.dart';
import '../view_model/stats_viewmodel.dart';

class CaloriesTab extends StatelessWidget {
  final StatsData statsData;
  final String period;

  const CaloriesTab({
    super.key,
    required this.statsData,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatsCards(statsData: statsData),
              const SizedBox(height: 36),
              _ChartHeader(period: period),
              const SizedBox(height: 20),
              _BarChart(statsData: statsData),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCards extends StatelessWidget {
  final StatsData statsData;
  const _StatsCards({required this.statsData});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': "stats.total_calories".tr(),
        'value': statsData.totalCalories.toString(),
        'unit': 'kcal',
        'icon': Icons.local_fire_department,
        'colors': const [Color(0xFFFF6B6B), Color(0xFFFF8E8E)]
      },
      {
        'title': "stats.daily_average".tr(),
        'value': statsData.avgCalories.toString(),
        'unit': 'kcal',
        'icon': Icons.trending_up,
        'colors': const [Color(0xFF4ECDC4), Color(0xFF6CD4CC)]
      },
      {
        'title': "stats.active_days".tr(),
        'value': statsData.totalDays.toString(),
        'unit': 'days',
        'icon': Icons.calendar_today,
        'colors': const [Color(0xFF9D4EDD), Color(0xFFB07CE0)]
      },
      {
        'title': "stats.current_streak".tr(),
        'value': statsData.streakDays.toString(),
        'unit': 'days',
        'icon': Icons.whatshot,
        'colors': const [Color(0xFFFFD166), Color(0xFFFFDF8C)]
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: ResponsiveManager.spacingMedium,
      mainAxisSpacing: ResponsiveManager.spacingMedium,
      childAspectRatio: 1.5,
      children: List.generate(items.length, (index) {
        final item = items[index];
        return _StatCard(
          title: item['title'] as String,
          value: item['value'] as String,
          unit: item['unit'] as String,
          icon: item['icon'] as IconData,
          gradientColors: item['colors'] as List<Color>,
          index: index,
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final List<Color> gradientColors;
  final int index;
  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.gradientColors,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedListItem(
      index: index,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors),
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
          boxShadow: [
            BoxShadow(
                color: gradientColors.first.withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveManager.spacingXSmall),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius:
                          BorderRadius.circular(ResponsiveManager.radiusSmall),
                    ),
                    child: Icon(icon,
                        size: ResponsiveManager.iconSmall, color: Colors.white),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      unit,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodySmall * 0.9,
                        color: Colors.white.withAlpha(200),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveManager.heading3,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ResponsiveManager.caption,
                  color: Colors.white.withAlpha(230),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  final String period;
  const _ChartHeader({required this.period});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "stats.daily_calories".tr(),
              style: TextStyle(
                fontSize: ResponsiveManager.bodyLarge,
                fontWeight: FontWeight.w800,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "stats.calorie_intake_over_time".tr(),
              style: TextStyle(
                fontSize: ResponsiveManager.caption,
                color: context.lightGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveManager.spacingMedium,
            vertical: ResponsiveManager.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: context.primaryColor.withAlpha(15),
            borderRadius:
                BorderRadius.circular(ResponsiveManager.radiusCircular),
            border: Border.all(color: context.primaryColor.withAlpha(50)),
          ),
          child: Text(
            period,
            style: TextStyle(
              fontSize: ResponsiveManager.caption,
              color: context.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final StatsData statsData;
  const _BarChart({required this.statsData});

  @override
  Widget build(BuildContext context) {
    if (statsData.caloriesPerDay.isEmpty) {
      return Container(
        height: 280.h,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
          boxShadow: [
            BoxShadow(
                color: context.cardShadow.withAlpha(40),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Text(
            "stats.no_calorie_data".tr(),
            style: TextStyle(
                color: context.lightGrey, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final sortedEntries = statsData.caloriesPerDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxY =
        (statsData.caloriesPerDay.values.reduce((a, b) => a > b ? a : b) * 1.2)
            .ceilToDouble();

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: sortedEntries[i].value.toDouble(),
            color: context.primaryColor,
            width: 20.w,
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(colors: [
              context.primaryColor,
              context.primaryColor.withAlpha(180)
            ]),
          ),
        ],
        barsSpace: 6,
      ));
    }

    return Container(
      height: 280.h,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
        boxShadow: [
          BoxShadow(
              color: context.cardShadow.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY.clamp(100, 5000),
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.dividerColor.withAlpha(80),
              strokeWidth: 1,
              dashArray: [6, 4],
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < sortedEntries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('MM/dd').format(sortedEntries[index].key),
                        style: TextStyle(
                          fontSize: ResponsiveManager.caption,
                          color: context.lightGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY / 5,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    fontSize: ResponsiveManager.caption,
                    color: context.lightGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
