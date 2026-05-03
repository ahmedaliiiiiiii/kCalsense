// lib/features/home/view/tabs/stats/view/stats_tab.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show TickerCallback, Ticker;
import 'package:intl/intl.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/navigation/animated_widgets.dart';
import '../../../../../../core/utiles/responsive_manager.dart';
import '../view model/stats_viewmodel.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatsViewModel()..loadStats(),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatefulWidget {
  const _StatsView();

  @override
  State<_StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<_StatsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // استخدام post frame callback لتجنب notify أثناء build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = Provider.of<StatsViewModel>(context, listen: false);
        vm.loadStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = context.watch<StatsViewModel>();
    ResponsiveManager.init(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildPeriodSelector(context, vm),
            _buildTabBar(context),
            Expanded(
              child: vm.isLoading
                  ? _buildLoadingWidget(context)
                  : vm.statsData == null
                      ? _buildEmptyState(context)
                      : TabBarView(
                          controller: TabController(length: 3, vsync: _Vsync()),
                          children: [
                            _CaloriesTab(
                                statsData: vm.statsData!,
                                period: vm.selectedPeriod),
                            _MacrosTab(statsData: vm.statsData!),
                            _ProgressTab(statsData: vm.statsData!),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ResponsiveManager.horizontalPadding,
        ResponsiveManager.spacingLarge,
        ResponsiveManager.horizontalPadding,
        ResponsiveManager.spacingMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analytics',
                    style: TextStyle(
                        fontSize: ResponsiveManager.heading2,
                        fontWeight: FontWeight.w700,
                        color: context.textColor)),
                const SizedBox(height: 4),
                Text('Track your nutrition journey',
                    style: TextStyle(
                        fontSize: ResponsiveManager.bodySmall,
                        color: context.lightGrey)),
              ],
            ),
          ),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                context.primaryColor,
                context.primaryColor.withAlpha(200)
              ]),
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
              boxShadow: [
                BoxShadow(
                    color: context.primaryColor.withAlpha(76),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Icon(Icons.insights,
                color: Colors.white, size: ResponsiveManager.iconMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, StatsViewModel vm) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
            horizontal: ResponsiveManager.horizontalPadding),
        itemBuilder: (_, index) {
          final period = vm.periods[index];
          final isSelected = period['label'] == vm.selectedPeriod;
          return _PeriodChip(
            period: period,
            isSelected: isSelected,
            onTap: () => vm.setPeriod(period['label']),
          );
        },
        separatorBuilder: (_, __) =>
            SizedBox(width: ResponsiveManager.spacingSmall),
        itemCount: vm.periods.length,
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        ResponsiveManager.horizontalPadding,
        ResponsiveManager.spacingMedium,
        ResponsiveManager.horizontalPadding,
        ResponsiveManager.spacingLarge,
      ),
      padding: EdgeInsets.all(ResponsiveManager.spacingXSmall),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
        boxShadow: [
          BoxShadow(
              color: context.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: TabBar(
        controller: TabController(length: 3, vsync: _Vsync()),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
          gradient: LinearGradient(colors: [
            context.primaryColor,
            context.primaryColor.withAlpha(200)
          ]),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: context.lightGrey,
        labelStyle: TextStyle(
            fontSize: ResponsiveManager.bodySmall, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
            fontSize: ResponsiveManager.bodySmall, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding:
            EdgeInsets.symmetric(horizontal: ResponsiveManager.spacingLarge),
        isScrollable: false,
        tabs: const [
          Tab(text: 'Calories'),
          Tab(text: 'Macros'),
          Tab(text: 'Progress')
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOut,
              builder: (_, value, child) =>
                  Transform.scale(scale: 1 + 0.1 * value, child: child),
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    context.primaryColor.withAlpha(25),
                    context.primaryColor.withAlpha(12)
                  ]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: CircularProgressIndicator(
                        color: context.primaryColor, strokeWidth: 2.5)),
              ),
            ),
            SizedBox(height: ResponsiveManager.spacingLarge),
            Text('Loading statistics...',
                style: TextStyle(
                    fontSize: ResponsiveManager.bodyMedium,
                    color: context.lightGrey)),
          ],
        ),
      );

  Widget _buildEmptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64.w, color: context.lightGrey),
            SizedBox(height: ResponsiveManager.spacingLarge),
            Text('No data yet',
                style: TextStyle(
                    fontSize: ResponsiveManager.bodyLarge,
                    fontWeight: FontWeight.w600,
                    color: context.textColor)),
            const SizedBox(height: 8),
            Text('Start logging your meals to see statistics',
                style: TextStyle(
                    fontSize: ResponsiveManager.bodySmall,
                    color: context.lightGrey)),
          ],
        ),
      );
}

// Vsync for TabController
class _Vsync extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

// ========== Calories Tab ==========
class _CaloriesTab extends StatelessWidget {
  final StatsData statsData;
  final String period;
  const _CaloriesTab({required this.statsData, required this.period});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      child: Column(
        children: [
          _StatsCards(statsData: statsData),
          SizedBox(height: ResponsiveManager.spacingXLarge),
          _ChartHeader(period: period),
          SizedBox(height: ResponsiveManager.spacingLarge),
          _BarChart(statsData: statsData),
        ],
      ),
    );
  }
}

class _StatsCards extends StatelessWidget {
  final StatsData statsData;
  const _StatsCards({required this.statsData});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: ResponsiveManager.spacingMedium,
      mainAxisSpacing: ResponsiveManager.spacingMedium,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
            title: 'Total Calories',
            value: statsData.totalCalories.toString(),
            unit: 'kcal',
            icon: Icons.local_fire_department,
            gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
            index: 0),
        _StatCard(
            title: 'Daily Average',
            value: statsData.avgCalories.toString(),
            unit: 'kcal',
            icon: Icons.trending_up,
            gradientColors: const [Color(0xFF4ECDC4), Color(0xFF6CD4CC)],
            index: 1),
        _StatCard(
            title: 'Active Days',
            value: statsData.totalDays.toString(),
            unit: 'days',
            icon: Icons.calendar_today,
            gradientColors: const [Color(0xFF9D4EDD), Color(0xFFB07CE0)],
            index: 2),
        _StatCard(
            title: 'Current Streak',
            value: statsData.streakDays.toString(),
            unit: 'days',
            icon: Icons.whatshot,
            gradientColors: const [Color(0xFFFFD166), Color(0xFFFFDF8C)],
            index: 3),
      ],
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily Calories',
                  style: TextStyle(
                      fontSize: ResponsiveManager.bodyLarge,
                      fontWeight: FontWeight.w700,
                      color: context.textColor)),
              const SizedBox(height: 4),
              Text('Your calorie intake over time',
                  style: TextStyle(
                      fontSize: ResponsiveManager.caption,
                      color: context.lightGrey)),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveManager.spacingMedium,
              vertical: ResponsiveManager.spacingXSmall),
          decoration: BoxDecoration(
              color: context.primaryColor.withAlpha(25),
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusCircular)),
          child: Text(period,
              style: TextStyle(
                  fontSize: ResponsiveManager.caption,
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600)),
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
            borderRadius:
                BorderRadius.circular(ResponsiveManager.radiusXLarge)),
        child: Center(
            child: Text('No calorie data for this period',
                style: TextStyle(color: context.lightGrey))),
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
              width: 16.w,
              borderRadius: BorderRadius.circular(4))
        ],
        barsSpace: 4,
      ));
    }

    return Container(
      height: 280.h,
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
        boxShadow: [
          BoxShadow(
              color: context.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, 5))
        ],
      ),
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
                color: context.dividerColor, strokeWidth: 1, dashArray: [5, 5]),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < sortedEntries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                          DateFormat('MM/dd').format(sortedEntries[index].key),
                          style: TextStyle(
                              fontSize: ResponsiveManager.caption,
                              color: context.lightGrey)),
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
                getTitlesWidget: (value, meta) => Text('${value.toInt()}',
                    style: TextStyle(
                        fontSize: ResponsiveManager.caption,
                        color: context.lightGrey)),
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

// ========== Macros Tab ==========
class _MacrosTab extends StatelessWidget {
  final StatsData statsData;
  const _MacrosTab({required this.statsData});

  @override
  Widget build(BuildContext context) {
    final macros = statsData.macrosAverage;
    final total = macros.values.reduce((a, b) => a + b);
    if (total == 0) {
      return Center(
          child: Text('No macro data available',
              style: TextStyle(color: context.lightGrey)));
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Macronutrient Distribution (Avg/day)',
              style: TextStyle(
                  fontSize: ResponsiveManager.bodyLarge,
                  fontWeight: FontWeight.w700,
                  color: context.textColor)),
          const SizedBox(height: 20),
          _MacroPieChart(macros: macros, total: total),
          const SizedBox(height: 32),
          ...macros.entries.map((e) => _MacroProgressBar(
              label: e.key,
              value: e.value,
              total: total,
              color: _getMacroColor(e.key),
              key: ValueKey(e.key))),
        ],
      ),
    );
  }

  Color _getMacroColor(String macro) {
    switch (macro) {
      case 'Protein':
        return const Color(0xFF4ECDC4);
      case 'Carbs':
        return const Color(0xFFFFD166);
      case 'Fat':
        return const Color(0xFFFF6B6B);
      default:
        return ColorManager.primaryColor;
    }
  }
}

class _MacroPieChart extends StatelessWidget {
  final Map<String, double> macros;
  final double total;
  const _MacroPieChart({required this.macros, required this.total});

  @override
  Widget build(BuildContext context) {
    final sections = [
      PieChartSectionData(
          value: macros['Protein'] ?? 0,
          title: 'Protein',
          color: const Color(0xFF4ECDC4),
          radius: 60,
          titleStyle: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
      PieChartSectionData(
          value: macros['Carbs'] ?? 0,
          title: 'Carbs',
          color: const Color(0xFFFFD166),
          radius: 60,
          titleStyle: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
      PieChartSectionData(
          value: macros['Fat'] ?? 0,
          title: 'Fat',
          color: const Color(0xFFFF6B6B),
          radius: 60,
          titleStyle: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
    ];
    return Container(
      height: 280.h,
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
        boxShadow: [
          BoxShadow(
              color: context.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, 5))
        ],
      ),
      child: Stack(
        children: [
          PieChart(PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              pieTouchData: PieTouchData(enabled: false))),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Total',
                      style: TextStyle(
                          fontSize: ResponsiveManager.caption,
                          color: context.lightGrey)),
                  Text('${total.toStringAsFixed(0)}g',
                      style: TextStyle(
                          fontSize: ResponsiveManager.bodyLarge,
                          fontWeight: FontWeight.w700,
                          color: context.textColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== Progress Tab ==========
class _ProgressTab extends StatelessWidget {
  final StatsData statsData;
  const _ProgressTab({required this.statsData});

  @override
  Widget build(BuildContext context) {
    final weeklyCurrent = statsData.avgCalories * 7;
    final weeklyTarget = statsData.dailyGoal * 7;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderText(context, 'Goal Progress',
              'Track your progress towards your goals'),
          const SizedBox(height: 20),
          _GoalCard(
              title: 'Daily Calorie Goal',
              current: statsData.avgCalories.toDouble(),
              target: statsData.dailyGoal.toDouble(),
              unit: 'kcal',
              gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E8E)]),
          const SizedBox(height: 20),
          _GoalCard(
              title: 'Weekly Calorie Goal',
              current: weeklyCurrent.toDouble(),
              target: weeklyTarget.toDouble(),
              unit: 'kcal',
              gradientColors: const [Color(0xFF4ECDC4), Color(0xFF6CD4CC)]),
          const SizedBox(height: 32),
          _buildHeaderText(
              context, 'Achievements', 'Badges earned on your journey'),
          const SizedBox(height: 16),
          _AchievementsGrid(statsData: statsData),
        ],
      ),
    );
  }

  Widget _buildHeaderText(
          BuildContext context, String title, String subtitle) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: ResponsiveManager.bodyLarge,
                  fontWeight: FontWeight.w700,
                  color: context.textColor)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  fontSize: ResponsiveManager.caption,
                  color: context.lightGrey)),
        ],
      );
}

class _AchievementsGrid extends StatelessWidget {
  final StatsData statsData;
  const _AchievementsGrid({required this.statsData});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      {
        'icon': Icons.whatshot,
        'label': '5 Day Streak',
        'achieved': statsData.streakDays >= 5,
        'color': const Color(0xFFFF6B6B)
      },
      {
        'icon': Icons.emoji_events,
        'label': 'Goal Master',
        'achieved': statsData.avgCalories >= statsData.dailyGoal * 0.9,
        'color': const Color(0xFFFFD166)
      },
      {
        'icon': Icons.fitness_center,
        'label': 'Protein King',
        'achieved': (statsData.macrosAverage['Protein'] ?? 0) >= 100,
        'color': const Color(0xFF4ECDC4)
      },
      {
        'icon': Icons.bolt,
        'label': 'Energy Boost',
        'achieved': statsData.totalLoggedMeals >= 50,
        'color': const Color(0xFFFF8E8E)
      },
      {
        'icon': Icons.eco,
        'label': 'Healthy Eater',
        'achieved': statsData.totalDays >= 7,
        'color': const Color(0xFF6CD4CC)
      },
      {
        'icon': Icons.timer,
        'label': 'Early Bird',
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
            key: ValueKey(a['label']));
      },
    );
  }
}

// ========== Reusable UI Components ==========
class _PeriodChip extends StatelessWidget {
  final Map<String, dynamic> period;
  final bool isSelected;
  final VoidCallback onTap;
  const _PeriodChip(
      {required this.period, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusCircular),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveManager.spacingLarge,
                vertical: ResponsiveManager.spacingSmall),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: [
                      context.primaryColor,
                      context.primaryColor.withAlpha(200)
                    ])
                  : null,
              color: isSelected ? null : context.surfaceColor,
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusCircular),
              border: Border.all(
                  color:
                      isSelected ? Colors.transparent : context.dividerColor),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: context.primaryColor.withAlpha(76),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(period['icon'],
                    size: ResponsiveManager.iconSmall,
                    color: isSelected ? Colors.white : context.lightGrey),
                SizedBox(width: ResponsiveManager.spacingXSmall),
                Flexible(
                    child: Text(period['label'],
                        style: TextStyle(
                            fontSize: ResponsiveManager.bodySmall,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : context.textColor))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final List<Color> gradientColors;
  final int index;
  const _StatCard(
      {required this.title,
      required this.value,
      required this.unit,
      required this.icon,
      required this.gradientColors,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedListItem(
      index: index,
      child: Container(
        padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors),
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
          boxShadow: [
            BoxShadow(
                color: gradientColors.first.withAlpha(76),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: EdgeInsets.all(ResponsiveManager.spacingXSmall),
                    decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(
                            ResponsiveManager.radiusSmall)),
                    child: Icon(icon,
                        size: ResponsiveManager.iconSmall,
                        color: Colors.white)),
                Flexible(
                    child: Text(unit,
                        style: TextStyle(
                            fontSize: ResponsiveManager.caption,
                            color: Colors.white.withAlpha(204)))),
              ],
            ),
            Text(value,
                style: TextStyle(
                    fontSize: ResponsiveManager.heading3,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            Flexible(
                child: Text(title,
                    style: TextStyle(
                        fontSize: ResponsiveManager.bodySmall,
                        color: Colors.white.withAlpha(230)))),
          ],
        ),
      ),
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final double value, total;
  final Color color;
  const _MacroProgressBar(
      {required this.label,
      required this.value,
      required this.total,
      required this.color,
      required super.key});

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (value / total) * 100 : 0;
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveManager.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    SizedBox(width: ResponsiveManager.spacingSmall),
                    Expanded(
                        child: Text(label,
                            style: TextStyle(
                                fontSize: ResponsiveManager.bodyMedium,
                                fontWeight: FontWeight.w600,
                                color: context.textColor))),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                    '${value.toStringAsFixed(1)}g • ${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: ResponsiveManager.bodySmall,
                        color: context.lightGrey),
                    textAlign: TextAlign.end),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(ResponsiveManager.radiusCircular),
            child: LinearProgressIndicator(
                value: total > 0 ? value / total : 0,
                backgroundColor: color.withAlpha(25),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8.h),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title, unit;
  final double current, target;
  final List<Color> gradientColors;
  const _GoalCard(
      {required this.title,
      required this.current,
      required this.target,
      required this.unit,
      required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    final percentage = target > 0 ? (current / target) * 100 : 0;
    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors),
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
        boxShadow: [
          BoxShadow(
              color: gradientColors.first.withAlpha(76),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: ResponsiveManager.bodyMedium,
                          fontWeight: FontWeight.w600,
                          color: Colors.white))),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveManager.spacingMedium,
                    vertical: ResponsiveManager.spacingXSmall),
                decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(
                        ResponsiveManager.radiusCircular)),
                child: Text('${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: ResponsiveManager.bodySmall,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(ResponsiveManager.radiusCircular),
            child: LinearProgressIndicator(
                value: target > 0 ? current / target : 0,
                backgroundColor: Colors.white.withAlpha(51),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 10.h),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Current',
                        style: TextStyle(
                            fontSize: ResponsiveManager.caption,
                            color: Colors.white.withAlpha(204))),
                    Text('${current.toStringAsFixed(0)} $unit',
                        style: TextStyle(
                            fontSize: ResponsiveManager.bodyLarge,
                            fontWeight: FontWeight.w700,
                            color: Colors.white))
                  ])),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Text('Target',
                        style: TextStyle(
                            fontSize: ResponsiveManager.caption,
                            color: Colors.white.withAlpha(204))),
                    Text('${target.toStringAsFixed(0)} $unit',
                        style: TextStyle(
                            fontSize: ResponsiveManager.bodyLarge,
                            fontWeight: FontWeight.w700,
                            color: Colors.white))
                  ])),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool achieved;
  final Color color;
  const _AchievementItem(
      {required this.icon,
      required this.label,
      required this.achieved,
      required this.color,
      required super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
      decoration: BoxDecoration(
        gradient: achieved
            ? LinearGradient(colors: [color.withAlpha(25), color.withAlpha(12)])
            : null,
        color: achieved ? null : context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        border: Border.all(
            color: achieved ? color.withAlpha(76) : context.dividerColor,
            width: 1.5),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: ResponsiveManager.iconLarge,
                  color: achieved ? color : context.lightGrey),
              const SizedBox(height: 6),
              Flexible(
                  child: Text(label,
                      style: TextStyle(
                          fontSize: ResponsiveManager.caption,
                          color:
                              achieved ? context.textColor : context.lightGrey,
                          fontWeight:
                              achieved ? FontWeight.w600 : FontWeight.normal),
                      textAlign: TextAlign.center,
                      maxLines: 2)),
            ],
          ),
          if (achieved)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Icon(Icons.check,
                      size: ResponsiveManager.iconSmall * 0.6,
                      color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
