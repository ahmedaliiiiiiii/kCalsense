import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/navigation/page_transitions.dart';
import '../../../../../core/storage/token_storage.dart';
import '../../../../../core/utils/color_manager.dart';
import '../../../../../core/utils/time_helper.dart';
import '../../../../../core/widgets/home_bottom_nav.dart';
import '../../../../../core/widgets/quick_actions_grid.dart';
import '../../../../../core/widgets/recent_foods_list.dart';
import '../../../../../core/widgets/today_progress_card.dart';
import '../../../../askai/askai_page.dart';
import '../../../../notifications/notification_helper.dart';
import '../../../../notifications/notifications_page.dart';
import '../../../viewmodel/homeviewmodel.dart';
import '../profile/view/profile_page.dart';
import '../scan/scan.dart';
import '../stats/view/stats_tab.dart';
import 'food_screens/foods_screen.dart';

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

class _HomeTabContent extends StatefulWidget {
  const _HomeTabContent();

  @override
  State<_HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<_HomeTabContent> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ØªØ­Ø¯ÙŠØ« Ø§Ù„Ø¹Ø¯Ø¯ Ø¹Ù†Ø¯ Ø§Ù„Ø¹ÙˆØ¯Ø© Ù„Ù„Ø´Ø§Ø´Ø© (ÙÙŠ Ø­Ø§Ù„Ø© Ø§Ù„Ø¹ÙˆØ¯Ø© Ù…Ù† ØµÙØ­Ø© Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±Ø§Øª)
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationHelper.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      CustomPageTransitions.slideFromBottom(const NotificationsPage()),
    );
    // Ø¨Ø¹Ø¯ Ø§Ù„Ø¹ÙˆØ¯Ø© Ù…Ù† ØµÙØ­Ø© Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±Ø§ØªØŒ ÙŠØªÙ… ØªØ¹Ù„ÙŠÙ… Ø¬Ù…ÙŠØ¹ Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±Ø§Øª ÙƒÙ…Ù‚Ø±ÙˆØ¡Ø©ØŒ Ù„Ø°Ø§ Ù†Ø¹ÙŠØ¯ ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ø¹Ø¯Ø¯
    await _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final greeting = TimeHelper.getGreeting();

    if (vm.isLoading) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        body: Center(
            child: CircularProgressIndicator(color: context.primaryColor)),
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
                color: context.lightGrey,
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
                onPressed: _openNotifications,
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.015),
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
                  onScan: () => vm.changeTab(1),
                  onAskAi: () {
                    context.pushWithTransition(
                      const AskAiPage(),
                      type: TransitionType.ios,
                    );
                  },
                  onStats: () => vm.changeTab(2),
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
                        final homeVm =
                            Provider.of<HomeViewModel>(context, listen: false);
                        Navigator.push(
                          context,
                          CustomPageTransitions.fastSlideTransition(
                            ChangeNotifierProvider.value(
                              value: homeVm,
                              child: const FoodsScreen(),
                            ),
                          ),
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
                RecentFoodsList(items: vm.recentFoodsForHome),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
