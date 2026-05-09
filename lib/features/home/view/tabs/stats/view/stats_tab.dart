// ignore_for_file: unused_element, must_call_super

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utils/color_manager.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/navigation/animated_widgets.dart';
import '../../../../../../core/utils/responsive_manager.dart';
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
    with
        AutomaticKeepAliveClientMixin,
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() {
    if (mounted) {
      final vm = Provider.of<StatsViewModel>(context, listen: false);
      vm.loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatsViewModel>();
    ResponsiveManager.init(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildPeriodSelector(context, vm),
            const SizedBox(height: 20),
            _buildTabBar(context, _tabController),
            Expanded(
              child: vm.isLoading
                  ? _buildLoadingWidget(context)
                  : (vm.statsData == null ||
                          (vm.statsData!.caloriesPerDay.isEmpty &&
                              vm.statsData!.totalLoggedMeals == 0))
                      ? _buildEmptyState(context)
                      : TabBarView(
                          controller: _tabController,
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
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "stats.title".tr(),
                style: TextStyle(
                  fontSize: ResponsiveManager.heading1,
                  fontWeight: FontWeight.w800,
                  color: context.textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "stats.subtitle".tr(),
                style: TextStyle(
                  fontSize: ResponsiveManager.bodySmall,
                  color: context.lightGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.primaryColor,
                  context.primaryColor.withAlpha(200)
                ],
              ),
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withAlpha(60),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
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
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
            horizontal: ResponsiveManager.horizontalPadding),
        itemBuilder: (_, index) {
          final period = vm.periods[index];
          final isSelected = period['label'] == vm.selectedPeriod;

          // ØªØ±Ø¬Ù…Ø© Ø§Ù„Ù†Øµ Ø¯ÙˆÙ† ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ø®Ø±ÙŠØ·Ø© Ø§Ù„Ø£ØµÙ„ÙŠØ©
          String translatedLabel;
          switch (period['label']) {
            case 'This Week':
              translatedLabel = "stats.period_week".tr();
              break;
            case 'This Month':
              translatedLabel = "stats.period_month".tr();
              break;
            case 'This Year':
              translatedLabel = "stats.period_year".tr();
              break;
            default:
              translatedLabel = period['label'];
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _PeriodChip(
              icon: period['icon'],
              label: translatedLabel, // âœ… Ø§Ù„Ù†Øµ Ø§Ù„Ù…ØªØ±Ø¬Ù…
              isSelected: isSelected,
              onTap: () => vm.setPeriod(period['label']),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: vm.periods.length,
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, TabController controller) {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: ResponsiveManager.horizontalPadding),
      height: 48.h,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
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
            fontSize: ResponsiveManager.bodySmall, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(
            fontSize: ResponsiveManager.bodySmall, fontWeight: FontWeight.w600),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding:
            EdgeInsets.symmetric(horizontal: ResponsiveManager.spacingMedium),
        tabs: [
          Tab(text: "stats.calories_tab".tr()),
          Tab(text: "stats.macros_tab".tr()),
          Tab(text: "stats.progress_tab".tr()),
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
                  Transform.scale(scale: 1 + 0.08 * value, child: child),
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    context.primaryColor.withAlpha(30),
                    context.primaryColor.withAlpha(15),
                  ]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                      color: context.primaryColor, strokeWidth: 3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "stats.loading_stats".tr(),
              style: TextStyle(
                fontSize: ResponsiveManager.bodyMedium,
                color: context.lightGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  Widget _buildEmptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart,
                size: 72.w, color: context.lightGrey.withAlpha(100)),
            const SizedBox(height: 20),
            Text(
              "stats.no_data".tr(),
              style: TextStyle(
                fontSize: ResponsiveManager.bodyLarge,
                fontWeight: FontWeight.w700,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "stats.start_logging".tr(),
              style: TextStyle(
                fontSize: ResponsiveManager.bodySmall,
                color: context.lightGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
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
        child: Text(
          "stats.no_macro_data".tr(),
          style:
              TextStyle(color: context.lightGrey, fontWeight: FontWeight.w500),
        ),
      );
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "stats.macronutrient_distribution".tr(),
                style: TextStyle(
                  fontSize: ResponsiveManager.bodyLarge,
                  fontWeight: FontWeight.w800,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 20),
              _MacroPieChart(macros: macros, total: total),
              const SizedBox(height: 28),
              ...macros.entries.map((e) => _MacroProgressBar(
                    label: e.key,
                    value: e.value,
                    total: total,
                    color: _getMacroColor(e.key),
                    key: ValueKey(e.key),
                  )),
            ],
          ),
        ),
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
            fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: macros['Carbs'] ?? 0,
        title: 'Carbs',
        color: const Color(0xFFFFD166),
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: macros['Fat'] ?? 0,
        title: 'Fat',
        color: const Color(0xFFFF6B6B),
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
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
      child: Stack(
        children: [
          PieChart(PieChartData(
            sections: sections,
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            pieTouchData: PieTouchData(enabled: false),
          )),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "stats.total".tr(),
                    style: TextStyle(
                      fontSize: ResponsiveManager.caption,
                      color: context.lightGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${total.toStringAsFixed(0)}g',
                    style: TextStyle(
                      fontSize: ResponsiveManager.bodyLarge,
                      fontWeight: FontWeight.w800,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final double value, total;
  final Color color;
  const _MacroProgressBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    required super.key,
  });

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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: ResponsiveManager.bodyMedium,
                          fontWeight: FontWeight.w700,
                          color: context.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${value.toStringAsFixed(1)}g • ${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: ResponsiveManager.bodySmall,
                  color: context.lightGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(ResponsiveManager.radiusCircular),
            child: LinearProgressIndicator(
              value: total > 0 ? value / total : 0,
              backgroundColor: color.withAlpha(25),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10.h,
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

class _PeriodChip extends StatelessWidget {
  final IconData icon;
  final String label; // âœ… Ø§Ù„Ù†Øµ Ø§Ù„Ù…ØªØ±Ø¬Ù…
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusCircular),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveManager.spacingLarge,
            vertical: ResponsiveManager.spacingSmall,
          ),
          decoration: BoxDecoration(
            gradient: isSelected && !context.isDarkMode
                ? LinearGradient(colors: [
                    context.primaryColor,
                    context.primaryColor.withAlpha(200)
                  ])
                : isSelected && context.isDarkMode
                    ? LinearGradient(
                        colors: [context.primaryColor, context.primaryColor])
                    : null,
            color: isSelected ? null : context.surfaceColor,
            borderRadius:
                BorderRadius.circular(ResponsiveManager.radiusCircular),
            border: Border.all(
                color: isSelected ? Colors.transparent : context.dividerColor,
                width: 1.2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: context.primaryColor.withAlpha(60),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: ResponsiveManager.iconSmall,
                  color: isSelected ? Colors.white : context.lightGrey),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label, // âœ… Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø§Ù„Ù†Øµ Ø§Ù„Ù…ØªØ±Ø¬Ù…
                  style: TextStyle(
                    fontSize: ResponsiveManager.bodySmall,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : context.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
