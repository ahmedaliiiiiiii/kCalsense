import 'package:flutter/material.dart';

import '../../features/askai/askai_page.dart';
import '../navigation/page_transitions.dart';
import '../utils/color_manager.dart';

class HomeBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const HomeBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          _NavItem(
            icon: Icons.home_filled,
            label: "Home",
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),

          // Scan
          _NavItem(
            icon: Icons.camera_alt_outlined,
            label: "Scan",
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),

          // AI FAB
          GestureDetector(
            onTap: () {
              context.pushWithTransition(
                const AskAiPage(),
                type: TransitionType.fromBottom,
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.primaryColor,
                    context.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology_alt_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),

          // Stats
          _NavItem(
            icon: Icons.show_chart,
            label: "Stats",
            isSelected: selectedIndex == 2,
            onTap: () => onChanged(2),
          ),

          // Profile
          _NavItem(
            icon: Icons.person_outline,
            label: "Profile",
            isSelected: selectedIndex == 3,
            onTap: () => onChanged(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? context.primaryColor : context.lightGrey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
