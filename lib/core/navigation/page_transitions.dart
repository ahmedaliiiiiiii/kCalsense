import 'package:flutter/material.dart';

class CustomPageTransitions {
  static Route<T> iosSlideTransition<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<T> slideFromBottom<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<T> zoomTransition<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<T> fadeTransition<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }

  static Route<T> fastSlideTransition<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.8, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuad,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }

  static Route<T> instantTransition<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}

enum TransitionType {
  ios,
  zoom,
  fade,
  fast,
  fromBottom,
  instant,
}

extension NavigationExtensions on BuildContext {
  Future<T?> pushWithTransition<T>(
    Widget page, {
    TransitionType type = TransitionType.fast,
  }) {
    switch (type) {
      case TransitionType.ios:
        return Navigator.of(this)
            .push(CustomPageTransitions.iosSlideTransition(page));
      case TransitionType.zoom:
        return Navigator.of(this)
            .push(CustomPageTransitions.zoomTransition(page));
      case TransitionType.fade:
        return Navigator.of(this)
            .push(CustomPageTransitions.fadeTransition(page));
      case TransitionType.fast:
        return Navigator.of(this)
            .push(CustomPageTransitions.fastSlideTransition(page));
      case TransitionType.fromBottom:
        return Navigator.of(this)
            .push(CustomPageTransitions.slideFromBottom(page));
      case TransitionType.instant:
        return Navigator.of(this)
            .push(CustomPageTransitions.instantTransition(page));
    }
  }

  Future<T?> pushReplacementWithTransition<T>(
    Widget page, {
    TransitionType type = TransitionType.fast,
  }) {
    switch (type) {
      case TransitionType.ios:
        return Navigator.of(this)
            .pushReplacement(CustomPageTransitions.iosSlideTransition(page));
      case TransitionType.zoom:
        return Navigator.of(this)
            .pushReplacement(CustomPageTransitions.zoomTransition(page));
      case TransitionType.fade:
        return Navigator.of(this)
            .pushReplacement(CustomPageTransitions.fadeTransition(page));
      case TransitionType.fast:
        return Navigator.of(this)
            .pushReplacement(CustomPageTransitions.fastSlideTransition(page));
      case TransitionType.fromBottom:
        return Navigator.of(this)
            .pushReplacement(CustomPageTransitions.slideFromBottom(page));
      case TransitionType.instant:
        return Navigator.of(this)
            .pushReplacement(CustomPageTransitions.instantTransition(page));
    }
  }

  void popWithTransition([dynamic result]) {
    Navigator.of(this).pop(result);
  }
}
