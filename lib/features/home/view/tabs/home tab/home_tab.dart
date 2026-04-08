// lib/features/home/view/home_tab.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/diauth/service_locator.dart';
import '../../../../../core/navigation/page_transitions.dart';
import '../../../../../core/storge/token_storage.dart';
import '../../../../../core/utiles/color_manager.dart';
import '../../../../../core/utiles/time_helper.dart';
import '../../../../../core/widgets/home_bottom_nav.dart';
import '../../../../../core/widgets/quick_actions_grid.dart';
import '../../../../../core/widgets/recent_foods_list.dart';
import '../../../../../core/widgets/today_progress_card.dart';
import '../../../../askai/askai_page.dart';
import '../../../../notifications/notifications_page.dart';
import '../../../viewmodel/homeviewmodel.dart';
import '../profile/view/profile_page.dart';
import '../scan/scan.dart';
import '../stats/view/stats_tab.dart';
import 'FoodScreens/foods_screen.dart';

class HomePage extends StatelessWidget {
  static const String routeName = "/home";
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = HomeViewModel(storage: sl<TokenStorage>());
        vm.init();
        return vm;
      },
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    final tabs = [
      const _HomeTabContent(),
      const ScanTab(),
      const StatsTab(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: context.backgroundColor,
      bottomNavigationBar: HomeBottomNav(
        selectedIndex: vm.selectedTab,
        onChanged: vm.changeTab,
      ),
      body: IndexedStack(
        index: vm.selectedTab,
        children: tabs,
      ),
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final greeting = TimeHelper.getGreeting();

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: context.surfaceColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$greeting${vm.userName.isEmpty ? '' : ' ${vm.userName}'} 👋",
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            Text(
              "home.greeting.track_nutrition".tr(),
              style: TextStyle(
                fontSize: w * 0.035,
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  size: w * 0.06,
                  color: context.iconColor,
                ),
                onPressed: () {
                  context.pushWithTransition(
                    const NotificationsPage(),
                    type: TransitionType.fromBottom,
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: w * 0.02),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: w * 0.06, vertical: h * 0.015),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TodayProgressCard(progress: vm.progress!),
                SizedBox(height: h * 0.025),
                Text(
                  "home.quick_actions".tr(),
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                SizedBox(height: h * 0.01),
                QuickActionsGrid(
                  onScan: () {
                    vm.changeTab(1);
                  },
                  onAskAi: () {
                    context.pushWithTransition(
                      const AskAiPage(),
                      type: TransitionType.ios,
                    );
                  },
                  onStats: () {
                    vm.changeTab(2);
                  },
                  onManual: () {},
                ),
                SizedBox(height: h * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "home.recent_foods".tr(),
                      style: TextStyle(
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pushWithTransition(
                          const FoodsScreen(),
                          type: TransitionType.ios,
                        );
                      },
                      child: Text(
                        "home.see_all".tr(),
                        style: TextStyle(
                          fontSize: w * 0.04,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.01),
                RecentFoodsList(items: vm.recentFoods),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
