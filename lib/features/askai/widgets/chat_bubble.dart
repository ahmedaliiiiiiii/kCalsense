// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../core/utils/responsive_manager.dart';
import '../chat_message.dart';

class AnimatedChatBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isLastMessage;

  const AnimatedChatBubble({
    required this.message,
    this.isLastMessage = false,
    super.key,
  });

  @override
  State<AnimatedChatBubble> createState() => _AnimatedChatBubbleState();
}

class _AnimatedChatBubbleState extends State<AnimatedChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);
    final isUser = widget.message.role == MessageRole.user;

    return FadeTransition(
      opacity: _fade,
      child: Padding(
        padding: EdgeInsets.only(
          top: ResponsiveManager.spacingSmall,
          bottom: widget.isLastMessage
              ? ResponsiveManager.spacingMedium
              : ResponsiveManager.spacingSmall,
        ),
        child: Row(
          mainAxisAlignment: isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start, // âœ… Ù…Ø­Ø§Ø°Ø§Ø© Ø­Ø³Ø¨ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // âœ… AI message (ÙŠØ³Ø§Ø±)
            if (!isUser) ...[
              _buildAiAvatar(),
              SizedBox(width: ResponsiveManager.spacingSmall),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3E),
                    borderRadius:
                        BorderRadius.circular(ResponsiveManager.radiusLarge)
                            .copyWith(
                      bottomLeft: const Radius.circular(4),
                    ),
                  ),
                  child: SelectableText(
                    widget.message.text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: ResponsiveManager.bodyMedium,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],

            // âœ… User message (ÙŠÙ…ÙŠÙ†)
            if (isUser) ...[
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4158D0),
                    borderRadius:
                        BorderRadius.circular(ResponsiveManager.radiusLarge)
                            .copyWith(
                      bottomRight: const Radius.circular(4),
                    ),
                  ),
                  child: SelectableText(
                    widget.message.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveManager.bodyMedium,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveManager.spacingSmall),
              _buildUserAvatar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: ResponsiveManager.iconLarge,
      height: ResponsiveManager.iconLarge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusSmall),
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: ResponsiveManager.iconLarge,
      height: ResponsiveManager.iconLarge,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(ResponsiveManager.radiusSmall),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white70,
          size: 18,
        ),
      ),
    );
  }
}
