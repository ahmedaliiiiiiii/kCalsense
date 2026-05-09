import 'package:flutter/material.dart';

import '../utils/color_manager.dart';
import '../utils/responsive_manager.dart';

class StepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget bottom;
  final VoidCallback? onBack;

  const StepScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.bottom,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.backgroundColor,
      appBar: onBack != null
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: ResponsiveManager.iconMedium,
                  color: context.iconColor,
                ),
                padding: EdgeInsets.all(ResponsiveManager.spacingSmall),
              ),
              title: null,
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveManager.horizontalPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (onBack == null)
                          SizedBox(height: ResponsiveManager.spacingXLarge),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveManager.spacingMedium,
                          ),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: ResponsiveManager.heading2,
                              fontWeight: FontWeight.w800,
                              color: context.textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: ResponsiveManager.spacingSmall),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveManager.spacingMedium,
                          ),
                          child: Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.textSecondaryColor,
                              fontSize: ResponsiveManager.bodyLarge,
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveManager.spacingXXLarge),
                        child,
                        SizedBox(height: ResponsiveManager.spacingXXLarge),
                        bottom,
                        SizedBox(height: ResponsiveManager.spacingLarge),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
