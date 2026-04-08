import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: (locale) {
        context.setLocale(locale);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: Locale('en'),
          child: Text('English'),
        ),
        const PopupMenuItem(
          value: Locale('ar'),
          child: Text('العربية'),
        ),
      ],
    );
  }
}
