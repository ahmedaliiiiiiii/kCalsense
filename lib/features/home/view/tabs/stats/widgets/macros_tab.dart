import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/utils/color_manager.dart';
import '../../../../../../core/utils/responsive_manager.dart';
import '../view_model/stats_viewmodel.dart';

class MacrosTab extends StatelessWidget {
  final StatsData statsData;
  const MacrosTab({super.key, required this.statsData});

  @override
  Widget build(BuildContext context) {
    final macros = statsData.macrosAverage;
    final total = macros.values.fold<double>(0.0, (a, b) => a + b);
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
