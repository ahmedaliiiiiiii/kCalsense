import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';

import '../../../../../../core/navigation/animated_widgets.dart';
import '../../../../../../core/utiles/responsive_manager.dart';

class StatsData {
  final int totalCalories;
  final int avgCalories;
  final int totalDays;
  final int streakDays;
  final Map<String, int> caloriesPerDay;
  final Map<String, double> macrosAverage;

  const StatsData({
    required this.totalCalories,
    required this.avgCalories,
    required this.totalDays,
    required this.streakDays,
    required this.caloriesPerDay,
    required this.macrosAverage,
  });
}

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  StatsData? statsData;
  String selectedPeriod = 'This Week';

  final List<Map<String, dynamic>> periods = const [
    {'label': 'This Week', 'value': 'week', 'icon': Icons.calendar_view_week},
    {'label': 'This Month', 'value': 'month', 'icon': Icons.calendar_month},
    {'label': 'This Year', 'value': 'year', 'icon': Icons.calendar_today},
  ];

  // Cache for chart data to avoid rebuilding
  late final Map<String, List<BarChartGroupData>> _chartDataCache = {};
  late final Map<String, List<PieChartSectionData>> _pieChartDataCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatsData() async {
    setState(() => isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final caloriesPerDay = {
      'Mon': 2100,
      'Tue': 1950,
      'Wed': 2300,
      'Thu': 1850,
      'Fri': 2450,
      'Sat': 2700,
      'Sun': 2200,
    };

    final newStatsData = StatsData(
      totalCalories: 15550,
      avgCalories: 2221,
      totalDays: 7,
      streakDays: 5,
      caloriesPerDay: caloriesPerDay,
      macrosAverage: {
        'Protein': 85.5,
        'Carbs': 250.3,
        'Fat': 65.2,
        'Fiber': 30.1,
      },
    );

    // Clear cache when new data arrives
    _chartDataCache.clear();
    _pieChartDataCache.clear();

    setState(() {
      statsData = newStatsData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildPeriodSelector(context),
            _buildTabBar(context),
            Expanded(
              child: isLoading
                  ? _buildLoadingWidget(context)
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCaloriesTab(context),
                        _buildMacrosTab(context),
                        _buildProgressTab(context),
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
                Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: ResponsiveManager.heading2,
                    fontWeight: FontWeight.w700,
                    color: context.textColor,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveManager.spacingXSmall),
                Text(
                  'Track your nutrition journey',
                  style: TextStyle(
                    fontSize: ResponsiveManager.bodySmall,
                    color: context.lightGrey,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.primaryColor,
                  context.primaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.insights,
              color: Colors.white,
              size: ResponsiveManager.iconMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveManager.horizontalPadding,
        ),
        itemBuilder: (context, index) {
          final period = periods[index];
          final isSelected = period['label'] == selectedPeriod;

          return _PeriodChip(
            period: period,
            isSelected: isSelected,
            onTap: () {
              setState(() => selectedPeriod = period['label']);
              _loadStatsData();
            },
          );
        },
        separatorBuilder: (context, index) =>
            SizedBox(width: ResponsiveManager.spacingSmall),
        itemCount: periods.length,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.primaryColor,
              context.primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: context.lightGrey,
        labelStyle: TextStyle(
          fontSize: ResponsiveManager.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ResponsiveManager.bodySmall,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        // ضبط المسافات بين التبويبات
        labelPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveManager.spacingLarge,
        ),
        // جعل التبويبات تمتد لملء المساحة المتاحة بالتساوي
        isScrollable: false,
        tabs: const [
          Tab(text: 'Calories'),
          Tab(text: 'Macros'),
          Tab(text: 'Progress'),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1 + (0.1 * value),
                child: child,
              );
            },
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.primaryColor.withValues(alpha: 0.1),
                    context.primaryColor.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: context.primaryColor,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingLarge),
          Text(
            'Loading statistics...',
            style: TextStyle(
              fontSize: ResponsiveManager.bodyMedium,
              color: context.lightGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesTab(BuildContext context) {
    if (statsData == null) return const SizedBox();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      child: Column(
        children: [
          _buildStatsCards(context),
          SizedBox(height: ResponsiveManager.spacingXLarge),
          _buildChartHeader(context),
          SizedBox(height: ResponsiveManager.spacingLarge),
          _buildBarChart(context),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    final stats = statsData!;

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
          value: stats.totalCalories.toString(),
          unit: 'kcal',
          icon: Icons.local_fire_department,
          gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
          index: 0,
        ),
        _StatCard(
          title: 'Daily Average',
          value: stats.avgCalories.toString(),
          unit: 'kcal',
          icon: Icons.trending_up,
          gradientColors: const [Color(0xFF4ECDC4), Color(0xFF6CD4CC)],
          index: 1,
        ),
        _StatCard(
          title: 'Total Days',
          value: stats.totalDays.toString(),
          unit: 'days',
          icon: Icons.calendar_today,
          gradientColors: const [Color(0xFF9D4EDD), Color(0xFFB07CE0)],
          index: 2,
        ),
        _StatCard(
          title: 'Current Streak',
          value: stats.streakDays.toString(),
          unit: 'days',
          icon: Icons.whatshot,
          gradientColors: const [Color(0xFFFFD166), Color(0xFFFFDF8C)],
          index: 3,
        ),
      ],
    );
  }

  Widget _buildChartHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Calories',
                style: TextStyle(
                  fontSize: ResponsiveManager.bodyLarge,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveManager.spacingXSmall),
              Text(
                'Your calorie intake over time',
                style: TextStyle(
                  fontSize: ResponsiveManager.caption,
                  color: context.lightGrey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveManager.spacingMedium),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveManager.spacingMedium,
            vertical: ResponsiveManager.spacingXSmall,
          ),
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(ResponsiveManager.radiusCircular),
          ),
          child: Text(
            selectedPeriod,
            style: TextStyle(
              fontSize: ResponsiveManager.caption,
              color: context.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context) {
    if (statsData == null) return const SizedBox();

    final cacheKey = 'bar_chart_${selectedPeriod}_${statsData.hashCode}';

    if (!_chartDataCache.containsKey(cacheKey)) {
      final barGroups = statsData!.caloriesPerDay.entries.map((entry) {
        final index =
            statsData!.caloriesPerDay.keys.toList().indexOf(entry.key);
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              color: context.primaryColor,
              width: 16.w,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 3000,
                color: Colors.transparent,
              ),
            ),
          ],
          barsSpace: 4,
        );
      }).toList();

      _chartDataCache[cacheKey] = barGroups;
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
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 3000,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 500,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: context.dividerColor,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  const days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[value.toInt()],
                        style: TextStyle(
                          fontSize: ResponsiveManager.caption,
                          fontWeight: FontWeight.w500,
                          color: context.lightGrey,
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
                interval: 500,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      fontSize: ResponsiveManager.caption,
                      color: context.lightGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _chartDataCache[cacheKey]!,
        ),
      ),
    );
  }

  Widget _buildMacrosTab(BuildContext context) {
    if (statsData == null) return const SizedBox();

    final macros = statsData!.macrosAverage;
    final total = macros.values.reduce((a, b) => a + b);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macronutrient Distribution',
            style: TextStyle(
              fontSize: ResponsiveManager.bodyLarge,
              fontWeight: FontWeight.w700,
              color: context.textColor,
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: ResponsiveManager.spacingLarge),
          _buildMacroPieChart(context, total),
          SizedBox(height: ResponsiveManager.spacingXLarge),
          ...macros.entries.map((entry) {
            return _MacroProgressBar(
              key: ValueKey(entry.key),
              label: entry.key,
              value: entry.value,
              total: total,
              color: _getMacroColor(entry.key),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMacroPieChart(BuildContext context, double total) {
    if (statsData == null) return const SizedBox();

    final cacheKey = 'pie_chart_${statsData.hashCode}';

    if (!_pieChartDataCache.containsKey(cacheKey)) {
      final sections = [
        _createPieSection('Protein', statsData!.macrosAverage['Protein'] ?? 0),
        _createPieSection('Carbs', statsData!.macrosAverage['Carbs'] ?? 0),
        _createPieSection('Fat', statsData!.macrosAverage['Fat'] ?? 0),
        _createPieSection('Fiber', statsData!.macrosAverage['Fiber'] ?? 0),
      ];

      _pieChartDataCache[cacheKey] = sections;
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
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sections: _pieChartDataCache[cacheKey]!,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: ResponsiveManager.caption,
                      color: context.lightGrey,
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(0)}g',
                    style: TextStyle(
                      fontSize: ResponsiveManager.bodyLarge,
                      fontWeight: FontWeight.w700,
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

  PieChartSectionData _createPieSection(String title, double value) {
    return PieChartSectionData(
      value: value,
      title: title,
      color: _getMacroColor(title),
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildProgressTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoalProgressHeader(context),
          SizedBox(height: ResponsiveManager.spacingLarge),
          _GoalCard(
            title: 'Daily Calorie Goal',
            current: 2221,
            target: 2500,
            unit: 'kcal',
            gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
          ),
          SizedBox(height: ResponsiveManager.spacingLarge),
          _GoalCard(
            title: 'Weekly Calorie Goal',
            current: 15550,
            target: 17500,
            unit: 'kcal',
            gradientColors: const [Color(0xFF4ECDC4), Color(0xFF6CD4CC)],
          ),
          SizedBox(height: ResponsiveManager.spacingXLarge),
          _buildAchievementsHeader(context),
          SizedBox(height: ResponsiveManager.spacingLarge),
          _buildAchievementsGrid(context),
        ],
      ),
    );
  }

  Widget _buildGoalProgressHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Progress',
          style: TextStyle(
            fontSize: ResponsiveManager.bodyLarge,
            fontWeight: FontWeight.w700,
            color: context.textColor,
            letterSpacing: -0.3,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ResponsiveManager.spacingXSmall),
        Text(
          'Track your progress towards your goals',
          style: TextStyle(
            fontSize: ResponsiveManager.caption,
            color: context.lightGrey,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAchievementsHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: TextStyle(
            fontSize: ResponsiveManager.bodyLarge,
            fontWeight: FontWeight.w700,
            color: context.textColor,
            letterSpacing: -0.3,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ResponsiveManager.spacingXSmall),
        Text(
          'Badges earned on your journey',
          style: TextStyle(
            fontSize: ResponsiveManager.caption,
            color: context.lightGrey,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid(BuildContext context) {
    final achievements = const [
      {
        'icon': Icons.whatshot,
        'label': '5 Day Streak',
        'achieved': true,
        'color': Color(0xFFFF6B6B),
      },
      {
        'icon': Icons.emoji_events,
        'label': 'Goal Master',
        'achieved': true,
        'color': Color(0xFFFFD166),
      },
      {
        'icon': Icons.fitness_center,
        'label': 'Protein King',
        'achieved': false,
        'color': Colors.grey,
      },
      {
        'icon': Icons.bolt,
        'label': 'Energy Boost',
        'achieved': false,
        'color': Colors.grey,
      },
      {
        'icon': Icons.eco,
        'label': 'Healthy Eater',
        'achieved': true,
        'color': Color(0xFF4ECDC4),
      },
      {
        'icon': Icons.timer,
        'label': 'Early Bird',
        'achieved': false,
        'color': Colors.grey,
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
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementItem(
          key: ValueKey('${achievement['label']}_$index'),
          icon: achievement['icon'] as IconData,
          label: achievement['label'] as String,
          achieved: achievement['achieved'] as bool,
          color: achievement['color'] as Color,
        );
      },
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
      case 'Fiber':
        return const Color(0xFF9D4EDD);
      default:
        return ColorManager.primaryColor;
    }
  }
}

// Extracted Widgets

class _PeriodChip extends StatelessWidget {
  final Map<String, dynamic> period;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

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
              vertical: ResponsiveManager.spacingSmall,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        context.primaryColor,
                        context.primaryColor.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
              color: isSelected ? null : context.surfaceColor,
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusCircular),
              border: Border.all(
                color: isSelected ? Colors.transparent : context.dividerColor,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: context.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  period['icon'],
                  size: ResponsiveManager.iconSmall,
                  color: isSelected ? Colors.white : context.lightGrey,
                ),
                SizedBox(width: ResponsiveManager.spacingXSmall),
                Flexible(
                  child: Text(
                    period['label'],
                    style: TextStyle(
                      fontSize: ResponsiveManager.bodySmall,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : context.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
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
        padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
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
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(ResponsiveManager.radiusSmall),
                  ),
                  child: Icon(
                    icon,
                    size: ResponsiveManager.iconSmall,
                    color: Colors.white,
                  ),
                ),
                Flexible(
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: ResponsiveManager.caption,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveManager.heading3,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveManager.bodySmall,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final Color color;

  const _MacroProgressBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    required ValueKey<String> key,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / total) * 100;

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
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: ResponsiveManager.spacingSmall),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: ResponsiveManager.bodyMedium,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${value.toStringAsFixed(1)}g • ${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: ResponsiveManager.bodySmall,
                    color: context.lightGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveManager.spacingXSmall),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(ResponsiveManager.radiusCircular),
            child: LinearProgressIndicator(
              value: value / total,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final String unit;
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
    final percentage = (current / target) * 100;

    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: ResponsiveManager.spacingSmall),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveManager.spacingMedium,
                  vertical: ResponsiveManager.spacingXSmall,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(ResponsiveManager.radiusCircular),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: ResponsiveManager.bodySmall,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveManager.spacingLarge),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(ResponsiveManager.radiusCircular),
            child: LinearProgressIndicator(
              value: current / target,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10.h,
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current',
                      style: TextStyle(
                        fontSize: ResponsiveManager.caption,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '${current.toStringAsFixed(1)} $unit',
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodyLarge,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveManager.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target',
                      style: TextStyle(
                        fontSize: ResponsiveManager.caption,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '${target.toStringAsFixed(1)} $unit',
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodyLarge,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
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

  const _AchievementItem({
    required this.icon,
    required this.label,
    required this.achieved,
    required this.color,
    required ValueKey<String> key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
      decoration: BoxDecoration(
        gradient: achieved
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: achieved ? null : context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        border: Border.all(
          color: achieved ? color.withValues(alpha: 0.3) : context.dividerColor,
          width: 1.5,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ResponsiveManager.iconLarge,
                color: achieved ? color : context.lightGrey,
              ),
              SizedBox(height: ResponsiveManager.spacingXSmall),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveManager.caption,
                    color: achieved ? context.textColor : context.lightGrey,
                    fontWeight: achieved ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (achieved)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: ResponsiveManager.iconSmall * 0.6,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
