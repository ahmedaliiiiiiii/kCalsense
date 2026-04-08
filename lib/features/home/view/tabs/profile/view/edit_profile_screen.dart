// lib/features/home/tabs/profile/view/edit_profile_screen.dart

// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kcalsense/core/utiles/color_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/utiles/responsive_manager.dart';
import '../../../../../setup/model/setup_models.dart';
import '../viewmodel/edit_profile_view_model.dart';
import '../viewmodel/profile_api_models.dart';
import '../viewmodel/profile_view_model.dart';

class EditProfileScreen extends StatelessWidget {
  final ProfileUiModel model;

  const EditProfileScreen({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = EditProfileViewModel();

        vm.fillDefaults(
          age: model.age,
          heightCm: model.heightCm,
          weightKg: model.weightKg,
          initialGender: model.genderText.toGenderEnum(),
          initialActivity: model.activityText.toActivityEnum(),
          initialGoal: model.goalText.toGoalEnum(),
        );

        return vm;
      },
      child: _EditProfileBody(model: model),
    );
  }
}

class _EditProfileBody extends StatefulWidget {
  final ProfileUiModel model;

  const _EditProfileBody({required this.model});

  @override
  State<_EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<_EditProfileBody> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final String _imageKey = 'profile_image';

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_imageKey);
    if (imagePath != null && imagePath.isNotEmpty && mounted) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_imageKey, imageFile.path);

        if (mounted) {
          setState(() {
            _profileImage = imageFile;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile picture updated successfully'),
              backgroundColor: context.primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ResponsiveManager.radiusMedium),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: context.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveManager.bottomSheetRadius),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ResponsiveManager.bottomSheetRadius),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.lightGrey.withValues(alpha: 0.3),
                  borderRadius:
                      BorderRadius.circular(ResponsiveManager.radiusCircular),
                ),
              ),
              SizedBox(height: ResponsiveManager.spacingLarge),
              Text(
                'Change Profile Picture',
                style: TextStyle(
                  fontSize: ResponsiveManager.bodyLarge,
                  fontWeight: FontWeight.w600,
                  color: context.textColor,
                ),
              ),
              SizedBox(height: ResponsiveManager.spacingXLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    context,
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _buildImageSourceOption(
                    context,
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
              SizedBox(height: ResponsiveManager.spacingMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
      child: Container(
        padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: ResponsiveManager.iconXLarge,
              color: color,
            ),
            SizedBox(height: ResponsiveManager.spacingSmall),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveManager.bodySmall,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final vm = context.watch<EditProfileViewModel>();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.iconColor,
            size: ResponsiveManager.iconMedium,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "profile.edit_profile".tr(),
          style: TextStyle(
            color: context.textColor,
            fontSize: ResponsiveManager.heading4,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveManager.horizontalPadding,
                  vertical: ResponsiveManager.spacingLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.primaryColor,
                                width: 2.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: context.primaryColor
                                      .withValues(alpha: 0.2),
                                  blurRadius: 12.h,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _profileImage != null
                                  ? Image.file(
                                      _profileImage!,
                                      fit: BoxFit.cover,
                                      width: 100.w,
                                      height: 100.w,
                                    )
                                  : Image.network(
                                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.model.name)}&size=200&background=42E87F&color=fff',
                                      fit: BoxFit.cover,
                                      width: 100.w,
                                      height: 100.w,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  color: context.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: context.surfaceColor,
                                    width: 2.w,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: ResponsiveManager.iconSmall,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveManager.spacingXLarge),
                    Text(
                      "profile.personal_information".tr(),
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodyLarge,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                    SizedBox(height: ResponsiveManager.spacingMedium),
                    _buildTextField(
                      context: context,
                      controller: vm.ageC,
                      label: "profile.age".tr(),
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: ResponsiveManager.spacingLarge),
                    _buildTextField(
                      context: context,
                      controller: vm.heightC,
                      label: "profile.height".tr(),
                      icon: Icons.height_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: ResponsiveManager.spacingLarge),
                    _buildTextField(
                      context: context,
                      controller: vm.weightC,
                      label: "profile.weight".tr(),
                      icon: Icons.monitor_weight_outlined,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: ResponsiveManager.spacingXXLarge),
                    Text(
                      "profile.gender".tr(),
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodyLarge,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                    SizedBox(height: ResponsiveManager.spacingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: _GenderButton(
                            context: context,
                            title: "profile.male".tr(),
                            isSelected: vm.gender == Gender.male,
                            onTap: () {
                              vm.gender = Gender.male;
                              vm.notifyListeners();
                            },
                          ),
                        ),
                        SizedBox(width: ResponsiveManager.spacingLarge),
                        Expanded(
                          child: _GenderButton(
                            context: context,
                            title: "profile.female".tr(),
                            isSelected: vm.gender == Gender.female,
                            onTap: () {
                              vm.gender = Gender.female;
                              vm.notifyListeners();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveManager.spacingXXLarge),
                    Text(
                      "profile.activity_level".tr(),
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodyLarge,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                    SizedBox(height: ResponsiveManager.spacingMedium),
                    _ActivityDropdown(
                      context: context,
                      value: vm.activity,
                      onChanged: (value) {
                        vm.activity = value;
                        vm.notifyListeners();
                      },
                    ),
                    SizedBox(height: ResponsiveManager.spacingXXLarge),
                    Text(
                      "profile.your_goal".tr(),
                      style: TextStyle(
                        fontSize: ResponsiveManager.bodyLarge,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                    SizedBox(height: ResponsiveManager.spacingMedium),
                    _GoalDropdown(
                      context: context,
                      value: vm.goal,
                      onChanged: (value) {
                        vm.goal = value;
                        vm.notifyListeners();
                      },
                    ),
                    if (vm.error != null) ...[
                      SizedBox(height: ResponsiveManager.spacingLarge),
                      _buildErrorWidget(context, vm.error!),
                    ],
                    SizedBox(height: ResponsiveManager.spacingLarge),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                ResponsiveManager.horizontalPadding,
                ResponsiveManager.spacingSmall,
                ResponsiveManager.horizontalPadding,
                ResponsiveManager.spacingMedium,
              ),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: context.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: ResponsiveManager.buttonHeight,
                  child: ElevatedButton(
                    onPressed: vm.isSaving || !vm.canSave
                        ? null
                        : () async {
                            final ok = await vm.save();
                            if (ok && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: context.disabledColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            ResponsiveManager.buttonRadius),
                      ),
                    ),
                    child: vm.isSaving
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Text(
                            "profile.save_changes".tr(),
                            style: TextStyle(
                              fontSize: ResponsiveManager.bodyMedium,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: ResponsiveManager.bodyMedium,
        color: context.textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: context.lightGrey,
          fontSize: ResponsiveManager.bodySmall,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: context.primaryColor,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: context.primaryColor,
          size: ResponsiveManager.iconMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
          borderSide: BorderSide(color: context.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
          borderSide: BorderSide(color: context.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
          borderSide: BorderSide(color: context.primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: context.surfaceColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveManager.spacingLarge,
          vertical: ResponsiveManager.spacingMedium,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Container(
      padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
      decoration: BoxDecoration(
        color: context.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusSmall),
        border: Border.all(color: context.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: context.errorColor,
            size: ResponsiveManager.iconSmall,
          ),
          SizedBox(width: ResponsiveManager.spacingSmall),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: context.errorColor,
                fontSize: ResponsiveManager.bodySmall,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final BuildContext context;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.context,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveManager.radiusSmall),
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: ResponsiveManager.spacingMedium),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusSmall),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.dividerColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : context.textColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: ResponsiveManager.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityDropdown extends StatelessWidget {
  final BuildContext context;
  final ActivityLevel? value;
  final Function(ActivityLevel?) onChanged;

  const _ActivityDropdown({
    required this.context,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: ResponsiveManager.spacingMedium),
      decoration: BoxDecoration(
        border: Border.all(color: context.dividerColor),
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
        color: context.surfaceColor,
      ),
      child: DropdownButton<ActivityLevel>(
        value: value,
        hint: Text(
          "profile.select_activity".tr(),
          style: TextStyle(
            color: context.lightGrey,
            fontSize: ResponsiveManager.bodyMedium,
          ),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: context.primaryColor,
          size: ResponsiveManager.iconMedium,
        ),
        style: TextStyle(
          color: context.textColor,
          fontSize: ResponsiveManager.bodyMedium,
          fontWeight: FontWeight.w500,
        ),
        items: ActivityLevel.values.map((level) {
          String text;
          switch (level) {
            case ActivityLevel.sedentary:
              text = "profile.sedentary".tr();
              break;
            case ActivityLevel.lightlyActive:
              text = "profile.lightly_active".tr();
              break;
            case ActivityLevel.moderatelyActive:
              text = "profile.moderately_active".tr();
              break;
            case ActivityLevel.highlyActive:
              text = "profile.highly_active".tr();
              break;
          }
          return DropdownMenuItem(
            value: level,
            child: Text(text),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _GoalDropdown extends StatelessWidget {
  final BuildContext context;
  final WeightGoal? value;
  final Function(WeightGoal?) onChanged;

  const _GoalDropdown({
    required this.context,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: ResponsiveManager.spacingMedium),
      decoration: BoxDecoration(
        border: Border.all(color: context.dividerColor),
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
        color: context.surfaceColor,
      ),
      child: DropdownButton<WeightGoal>(
        value: value,
        hint: Text(
          "profile.select_goal".tr(),
          style: TextStyle(
            color: context.lightGrey,
            fontSize: ResponsiveManager.bodyMedium,
          ),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: context.primaryColor,
          size: ResponsiveManager.iconMedium,
        ),
        style: TextStyle(
          color: context.textColor,
          fontSize: ResponsiveManager.bodyMedium,
          fontWeight: FontWeight.w500,
        ),
        items: WeightGoal.values.map((goal) {
          String text;
          switch (goal) {
            case WeightGoal.weightLoss:
              text = "profile.goal.lose".tr();
              break;
            case WeightGoal.maintain:
              text = "profile.goal.maintain".tr();
              break;
            case WeightGoal.weightGain:
              text = "profile.goal.gain".tr();
              break;
          }
          return DropdownMenuItem(
            value: goal,
            child: Text(text),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
