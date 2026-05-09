import 'package:flutter/material.dart';

import '../utils/color_manager.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: child,
    );
  }
}
