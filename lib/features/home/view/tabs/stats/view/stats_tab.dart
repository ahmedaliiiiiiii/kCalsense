import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/utils/color_manager.dart';
import '../../../../../../core/utils/responsive_manager.dart';
import '../view_model/stats_viewmodel.dart';
import '../widgets/calories_tab.dart';
import '../widgets/macros_tab.dart';
import '../widgets/period_chip.dart';
import '../widgets/progress_tab.dart';

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
        SingleTickerProviderStateMixin {
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
    super.build(context);
    ResponsiveManager.init(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const _StatsHeader(),
            const SizedBox(height: 16),
            const _PeriodSelector(),
            const SizedBox(height: 20),
            _buildTabBar(context, _tabController),
            Expanded(
              child: _StatsContent(tabController: _tabController),
            ),
          ],
        ),
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
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context) {
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
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector();

  @override
  Widget build(BuildContext context) {
    final selectedPeriod = context.select<StatsViewModel, String>((vm) => vm.selectedPeriod);
    final periods = context.select<StatsViewModel, List<Map<String, dynamic>>>((vm) => vm.periods);

    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
            horizontal: ResponsiveManager.horizontalPadding),
        itemBuilder: (_, index) {
          final period = periods[index];
          final isSelected = period['label'] == selectedPeriod;

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

          return PeriodChip(
            icon: period['icon'],
            label: translatedLabel,
            isSelected: isSelected,
            onTap: () {
              Provider.of<StatsViewModel>(context, listen: false).setPeriod(period['label']);
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: periods.length,
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final TabController tabController;
  const _StatsContent({required this.tabController});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<StatsViewModel, bool>((vm) => vm.isLoading);
    final statsData = context.select<StatsViewModel, StatsData?>((vm) => vm.statsData);
    final selectedPeriod = context.select<StatsViewModel, String>((vm) => vm.selectedPeriod);

    if (isLoading) {
      return const _StatsLoadingWidget();
    }

    if (statsData == null || (statsData.caloriesPerDay.isEmpty && statsData.totalLoggedMeals == 0)) {
      return const _StatsEmptyState();
    }

    return TabBarView(
      controller: tabController,
      children: [
        CaloriesTab(
          statsData: statsData,
          period: selectedPeriod,
        ),
        MacrosTab(statsData: statsData),
        ProgressTab(statsData: statsData),
      ],
    );
  }
}

class _StatsLoadingWidget extends StatelessWidget {
  const _StatsLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
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
  }
}

class _StatsEmptyState extends StatelessWidget {
  const _StatsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
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
}
