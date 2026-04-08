import 'package:flutter/material.dart';

import '../../../core/utiles/color_manager.dart';
import '../../../core/utiles/responsive_manager.dart';

class AppTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final bool obscure;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.obscure = false,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final bool hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: widget.obscure && _obscureText,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          style: TextStyle(
            color: context.textColor,
            fontSize: ResponsiveManager.bodyMedium,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: context.textHintColor,
              fontSize: ResponsiveManager.bodyMedium,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: ResponsiveManager.spacingMedium,
                      end: ResponsiveManager.spacingSmall,
                    ),
                    child: widget.prefixIcon,
                  )
                : null,
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: ResponsiveManager.iconSmall,
                      color: context.textHintColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            errorText: widget.errorText,
            errorStyle: TextStyle(
              color: context.errorColor,
              fontSize: ResponsiveManager.caption,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveManager.spacingLarge,
              vertical: ResponsiveManager.spacingMedium,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
              borderSide: BorderSide(color: context.dividerColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
              borderSide: BorderSide(color: context.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
              borderSide: BorderSide(color: context.errorColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(ResponsiveManager.radiusMedium),
              borderSide: BorderSide(color: context.errorColor, width: 2),
            ),
            filled: true,
            fillColor: context.surfaceColor,
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(
              left: ResponsiveManager.spacingMedium,
              top: ResponsiveManager.spacingXSmall,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveManager.iconSmall,
                  color: context.errorColor,
                ),
                SizedBox(width: ResponsiveManager.spacingXSmall),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: TextStyle(
                      color: context.errorColor,
                      fontSize: ResponsiveManager.caption,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
