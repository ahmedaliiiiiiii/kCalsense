import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utils/color_manager.dart';

import '../../../../../../core/utils/responsive_manager.dart';

class PrivacyPolicyPage extends StatelessWidget {
  static const String routeName = "/privacy";
  const PrivacyPolicyPage({super.key});

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
          'privacy_policy.title'.tr(),
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
            _buildSection(
              context,
              title: "privacy_policy.info_collect".tr(),
              content: "privacy_policy.info_collect_content".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingXLarge),
            _buildSection(
              context,
              title: "privacy_policy.how_we_use".tr(),
              content: "privacy_policy.how_we_use_content".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingXLarge),
            _buildSection(
              context,
              title: "privacy_policy.data_security".tr(),
              content: "privacy_policy.data_security_content".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingXLarge),
            _buildSection(
              context,
              title: "privacy_policy.data_sharing".tr(),
              content: "privacy_policy.data_sharing_content".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingXLarge),
            _buildSection(
              context,
              title: "privacy_policy.your_rights".tr(),
              content: "privacy_policy.your_rights_content".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingXLarge),
            _buildSection(
              context,
              title: "privacy_policy.contact_us".tr(),
              content: "privacy_policy.contact_us_content".tr(),
            ),
            SizedBox(height: ResponsiveManager.spacingLarge),
            Container(
              padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
              decoration: BoxDecoration(
                color: context.dividerColor.withOpacity(0.3),
                borderRadius:
                    BorderRadius.circular(ResponsiveManager.radiusMedium),
              ),
              child: Text(
                "privacy_policy.last_updated".tr(),
                style: TextStyle(
                  fontSize: ResponsiveManager.caption,
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: ResponsiveManager.spacingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveManager.heading4,
            fontWeight: FontWeight.w700,
            color: context.primaryColor,
          ),
        ),
        SizedBox(height: ResponsiveManager.spacingMedium),
        Text(
          content,
          style: TextStyle(
            fontSize: ResponsiveManager.bodyMedium,
            color: context.textSecondaryColor,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
