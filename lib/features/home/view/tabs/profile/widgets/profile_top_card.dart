import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';

import '../../../../../../core/utiles/responsive_manager.dart';
import '../viewmodel/profile_view_model.dart';

class ProfileTopCard extends StatelessWidget {
  final ProfileUiModel model;
  final VoidCallback onEdit;
  final File? profileImage;

  const ProfileTopCard({
    super.key,
    required this.model,
    required this.onEdit,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: ResponsiveManager.spacingLarge,
            offset: Offset(0, ResponsiveManager.spacingSmall),
          ),
        ],
        border: Border.all(
          color: context.dividerColor,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveManager.avatarLarge,
            height: ResponsiveManager.avatarLarge,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.primaryColor,
                width: 2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: profileImage != null
                  ? Image.file(
                      profileImage!,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(model.name)}&size=200&background=42E87F&color=fff&bold=true',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: context.primaryColor.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.person,
                            color: context.primaryColor,
                            size: ResponsiveManager.iconXLarge,
                          ),
                        );
                      },
                    ),
            ),
          ),
          SizedBox(width: ResponsiveManager.spacingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: TextStyle(
                    fontSize: ResponsiveManager.bodyLarge,
                    fontWeight: FontWeight.w800,
                    color: context.textColor,
                  ),
                ),
                SizedBox(height: ResponsiveManager.spacingXSmall),
                Text(
                  model.email,
                  style: TextStyle(
                    fontSize: ResponsiveManager.bodySmall,
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          _EditButton(onTap: onEdit),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.primaryColor.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(ResponsiveManager.radiusCircular),
      child: InkWell(
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusCircular),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveManager.spacingLarge,
            vertical: ResponsiveManager.spacingSmall,
          ),
          child: Row(
            children: [
              Icon(
                Icons.edit,
                size: ResponsiveManager.iconSmall,
                color: context.primaryColor,
              ),
              SizedBox(width: ResponsiveManager.spacingXSmall),
              Text(
                "profile.edit".tr(),
                style: TextStyle(
                  fontSize: ResponsiveManager.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
