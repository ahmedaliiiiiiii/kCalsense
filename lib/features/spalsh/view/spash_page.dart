// lib/features/splash/view/splash_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/page_transitions.dart';
import '../../../core/utiles/color_manager.dart';
import '../../auth/presention/login_page.dart';
import '../../home/view/tabs/home tab/home_tab.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../setup/view/setup_flow_page.dart';
import '../../start screen/start_screen.dart';
import '../viewmodel/splash_view_model.dart';
import '../widgets/plash_fade_logo.dart';
import '../widgets/splash_typewriter_title.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = SplashViewModel();
        vm.init();
        return vm;
      },
      child: const _SplashBody(),
    );
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody();

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack),
    );

    _logoCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    super.dispose();
  }

  void _navigateToNextRoute(String routeName) {
    switch (routeName) {
      case '/settings':
        Navigator.pushReplacement(
          context,
          CustomPageTransitions.fadeTransition(const SettingsScreen()),
        );
        break;
      case '/OnBoarding':
        Navigator.pushReplacement(
          context,
          CustomPageTransitions.fadeTransition(const OnBoardingScreen()),
        );
        break;
      case '/setup':
        Navigator.pushReplacement(
          context,
          CustomPageTransitions.fadeTransition(const SetupFlowPage()),
        );
        break;
      case '/home':
        Navigator.pushReplacement(
          context,
          CustomPageTransitions.fadeTransition(const HomePage()),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          CustomPageTransitions.fadeTransition(const LoginPage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SplashViewModel>();
    final s = MediaQuery.of(context).size;
    final w = s.width;
    final h = s.height;

    if (vm.goNext) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToNextRoute(vm.nextRoute);
      });
    }

    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SplashFadeLogo(fade: _fade, scale: _scale),
              SizedBox(height: (h * 0.02).clamp(12.0, 18.0)),
              SplashTypewriterTitle(fontSize: (w * 0.06).clamp(18.0, 24.0)),
              SizedBox(height: (h * 0.03).clamp(18.0, 26.0)),
              SizedBox(
                width: (w * 0.22).clamp(86.0, 120.0),
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
