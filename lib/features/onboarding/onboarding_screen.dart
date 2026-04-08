// lib/features/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';

import '../../core/navigation/page_transitions.dart';
import '../../core/utiles/color_manager.dart';
import '../../core/utiles/responsive_manager.dart';
import '../../features/auth/presention/login_page.dart';
import '../onboarding/widgets/onboarding_indicators.dart';
import '../onboarding/widgets/onboarding_page.dart';
import '../onboarding/widgets/onboarding_primary_button.dart';
import '../onboarding/widgets/onboarding_top_bar.dart';
import 'data/onboarding_data.dart';

class OnBoardingScreen extends StatefulWidget {
  static const String routeName = "/OnBoarding";
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  int _currentPage = 0;
  bool _isPageChanging = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
    _pageController.addListener(_onPageScroll);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  void _onPageScroll() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage && mounted) {
      setState(() {
        _currentPage = page;
        _isPageChanging = false;
      });

      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_isPageChanging) return;

    setState(() => _isPageChanging = true);

    final lastIndex = onboardingItems.length - 1;
    if (_currentPage < lastIndex) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  Future<void> _previousPage() async {
    if (_isPageChanging || _currentPage <= 0) return;

    setState(() => _isPageChanging = true);

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _skipToEnd() {
    if (_isPageChanging) return;
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    // تم مشاهدة Onboarding
    if (!mounted) return;

    context.pushWithTransition(
      const LoginPage(),
      type: TransitionType.zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            RepaintBoundary(
              child: OnboardingTopBar(
                currentPage: _currentPage,
                totalPages: onboardingItems.length,
                onBack: _previousPage,
                onSkip: _skipToEnd,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingItems.length,
                physics: _isPageChanging
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: RepaintBoundary(
                      child: OnboardingPage(
                        item: onboardingItems[index],
                        isActive: index == _currentPage,
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: OnboardingIndicators(
              key: ValueKey(_currentPage),
              currentPage: _currentPage,
              totalPages: onboardingItems.length,
            ),
          ),
          SizedBox(height: ResponsiveManager.spacingLarge),
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _fadeController,
              curve: Curves.easeOutBack,
            ),
            child: OnboardingPrimaryButton(
              isLast: _currentPage == onboardingItems.length - 1,
              onPressed: _nextPage,
              isLoading: _isPageChanging,
            ),
          ),
        ],
      ),
    );
  }
}
