// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SuggestionChipsWidget extends StatelessWidget {
  const SuggestionChipsWidget({super.key});

  static const List<Map<String, String>> _suggestions = [
    {'icon': '🍳', 'text': 'Healthy breakfast ideas'},
    {'icon': '🥗', 'text': 'Calories in salad'},
    {'icon': '🍝', 'text': 'Pasta recipes'},
    {'icon': '🥑', 'text': 'Meal prep tips'},
    {'icon': '🍎', 'text': 'Fruit calories'},
    {'icon': '🥩', 'text': 'Protein sources'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Try these examples",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _suggestions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return _SuggestionChip(
                icon: suggestion['icon']!,
                text: suggestion['text']!,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String icon;
  final String text;

  const _SuggestionChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A2A3E),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: () {
          // هضيف الـ functionality بعدين
        },
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
