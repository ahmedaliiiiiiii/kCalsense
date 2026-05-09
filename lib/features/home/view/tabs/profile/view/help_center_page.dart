import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utils/color_manager.dart';

import '../../../../../../core/utils/responsive_manager.dart';

class HelpCenterPage extends StatelessWidget {
  static const String routeName = "/help";
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'help_center.title'.tr(),
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context),
            SizedBox(height: ResponsiveManager.spacingXLarge),

            Text(
              "help_center.faq".tr(),
              style: TextStyle(
                fontSize: ResponsiveManager.heading4,
                fontWeight: FontWeight.w700,
                color: context.textColor,
              ),
            ),
            SizedBox(height: ResponsiveManager.spacingLarge),

            _buildFaqItem(
              context,
              question: "help_center.how_to_scan".tr(),
              answer: "help_center.how_to_scan_answer".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingMedium),

            _buildFaqItem(
              context,
              question: "help_center.accuracy".tr(),
              answer: "help_center.accuracy_answer".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingMedium),

            _buildFaqItem(
              context,
              question: "help_center.calorie_calculation".tr(),
              answer: "help_center.calorie_calculation_answer".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingMedium),

            _buildFaqItem(
              context,
              question: "help_center.edit_profile".tr(),
              answer: "help_center.edit_profile_answer".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingMedium),

            _buildFaqItem(
              context,
              question: "help_center.data_security".tr(),
              answer: "help_center.data_security_answer".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingMedium),

            _buildFaqItem(
              context,
              question: "help_center.delete_account".tr(),
              answer: "help_center.delete_account_answer".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingXLarge),

            // Contact Section
            Container(
              padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.primaryColor.withOpacity(0.1),
                    context.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(ResponsiveManager.radiusLarge),
                border: Border.all(color: context.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.contact_support_outlined,
                        color: context.primaryColor,
                        size: ResponsiveManager.iconLarge,
                      ),
                      SizedBox(width: ResponsiveManager.spacingMedium),
                      Text(
                        "help_center.still_need_help".tr(),
                        style: TextStyle(
                          fontSize: ResponsiveManager.bodyLarge,
                          fontWeight: FontWeight.w700,
                          color: context.textColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveManager.spacingMedium),
                  Text(
                    "help_center.contact_support".tr(),
                    style: TextStyle(
                      fontSize: ResponsiveManager.bodyMedium,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: ResponsiveManager.spacingLarge),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactButton(
                          context,
                          icon: Icons.email_outlined,
                          label: "help_center.email_us".tr(),
                          color: Colors.blue,
                          onTap: () => _showEmailDialog(context),
                        ),
                      ),
                      SizedBox(width: ResponsiveManager.spacingMedium),
                      Expanded(
                        child: _buildContactButton(
                          context,
                          icon: Icons.web_outlined,
                          label: "help_center.visit_website".tr(),
                          color: Colors.green,
                          onTap: () => _showWebsiteDialog(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveManager.spacingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'help_center.search'.tr(),
          hintStyle: TextStyle(color: context.textHintColor),
          prefixIcon: Icon(Icons.search, color: context.textHintColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      backgroundColor: context.surfaceColor,
      collapsedBackgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
        side: BorderSide(color: context.dividerColor),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
        side: BorderSide(color: context.dividerColor),
      ),
      title: Text(
        question,
        style: TextStyle(
          fontSize: ResponsiveManager.bodyMedium,
          fontWeight: FontWeight.w600,
          color: context.textColor,
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: ResponsiveManager.bodySmall,
              color: context.textSecondaryColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveManager.spacingMedium,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: ResponsiveManager.iconMedium),
            SizedBox(height: ResponsiveManager.spacingXSmall),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveManager.bodySmall,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            'Contact Support',
            style: TextStyle(
              color: context.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Send an email to:',
                style: TextStyle(color: context.textSecondaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'support@kcalsense.com',
                style: TextStyle(
                  color: context.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveManager.bodyLarge,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Copy Email',
                style: TextStyle(color: context.primaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showWebsiteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            'Visit Website',
            style: TextStyle(
              color: context.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Visit our website at:',
                style: TextStyle(color: context.textSecondaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'www.kcalsense.com',
                style: TextStyle(
                  color: context.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveManager.bodyLarge,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Website URL copied!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Copy Link',
                style: TextStyle(color: context.primaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
