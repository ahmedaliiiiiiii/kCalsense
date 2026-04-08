// ignore_for_file: deprecated_member_use, use_full_hex_values_for_flutter_colors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../view_model.dart';

class ChatInputWidget extends StatefulWidget {
  final AskAiViewModel vm;
  final FocusNode focusNode;
  final VoidCallback onMessageSent;

  const ChatInputWidget({
    required this.vm,
    required this.focusNode,
    required this.onMessageSent,
    super.key,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  late final TextEditingController _controller;
  bool _canSend = false;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    final wasComposing = _isComposing;

    setState(() {
      _canSend = hasText;
      _isComposing = hasText;
    });

    if (wasComposing != hasText) {
      setState(() {});
    }
  }

  void _onFocusChange() {
    setState(() {});
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || widget.vm.isTyping) return;

    final message = _controller.text.trim();
    _controller.clear();
    widget.focusNode.unfocus();

    setState(() => _canSend = false);

    await widget.vm.sendPrompt(message);
    widget.onMessageSent();

    setState(() => _canSend = _controller.text.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding > 0 ? bottomPadding + 8 : 16,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: widget.focusNode,
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.send,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.transparent,
                        hintText: "ask_ai.input_hint".tr(),
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(
                            color: Color(0xFF4158D0),
                            width: 1.5,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      onEditingComplete: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _canSend && !widget.vm.isTyping
                      ? const Color(0xFF4158D0)
                      : const Color(0xFF2A2A3E),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    color: _canSend && !widget.vm.isTyping
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    size: 20,
                  ),
                  onPressed:
                      (_canSend && !widget.vm.isTyping) ? _sendMessage : null,
                  splashRadius: 24,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
