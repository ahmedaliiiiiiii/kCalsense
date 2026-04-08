import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kcalsense/features/askai/view_model.dart';
import 'package:provider/provider.dart';

import '../../core/utiles/responsive_manager.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input.dart';
import 'widgets/typing_indicator.dart';

class AskAiPage extends StatelessWidget {
  const AskAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AskAiViewModel()..init(),
      child: const _AskAiView(),
    );
  }
}

class _AskAiView extends StatefulWidget {
  const _AskAiView();

  @override
  State<_AskAiView> createState() => _AskAiViewState();
}

class _AskAiViewState extends State<_AskAiView>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _focusNode = FocusNode();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveManager.init(context);

    final vm = context.watch<AskAiViewModel>();
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.only(left: ResponsiveManager.spacingSmall),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: ResponsiveManager.iconMedium,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          leadingWidth: ResponsiveManager.spacingXXLarge,
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveManager.spacingSmall),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(ResponsiveManager.radiusMedium),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: ResponsiveManager.iconSmall,
                ),
              ),
              SizedBox(width: ResponsiveManager.spacingXSmall),
              Expanded(
                child: Text(
                  "ask_ai.title".tr(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveManager.heading3,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (vm.messages.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.white70,
                  size: ResponsiveManager.iconMedium,
                ),
                onPressed: () => _showClearDialog(context, vm),
              ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: RepaintBoundary(
                    child: vm.messages.isEmpty
                        ? _buildWelcomeScreen(constraints, w, h)
                        : _buildChatScreen(vm),
                  ),
                ),
                if (vm.isTyping) const TypingIndicatorWidget(),
                RepaintBoundary(
                  child: ChatInputWidget(
                    vm: vm,
                    focusNode: _focusNode,
                    onMessageSent: _scrollToBottom,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(BoxConstraints constraints, double w, double h) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              SizedBox(height: h * 0.05),
              Container(
                width: ResponsiveManager.iconXXLarge * 2.5,
                height: ResponsiveManager.iconXXLarge * 2.5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(ResponsiveManager.radiusLarge),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: ResponsiveManager.iconXXLarge,
                ),
              ),
              SizedBox(height: ResponsiveManager.spacingLarge),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveManager.spacingXLarge),
                child: Text(
                  "ask_ai.welcome".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveManager.heading1,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveManager.spacingSmall),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveManager.spacingXLarge),
                child: Text(
                  "ask_ai.welcome_subtitle".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: ResponsiveManager.bodyLarge,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveManager.spacingXXLarge),
              const SuggestionChipsWidget(),
              const Spacer(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatScreen(AskAiViewModel vm) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
      itemCount: vm.messages.length,
      itemBuilder: (context, index) {
        return AnimatedChatBubble(
          key: ValueKey('${vm.messages[index].text}_$index'),
          message: vm.messages[index],
          isLastMessage: index == vm.messages.length - 1,
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, AskAiViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveManager.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: ResponsiveManager.iconXXLarge,
              ),
              SizedBox(height: ResponsiveManager.spacingMedium),
              Text(
                "ask_ai.clear_conversation".tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveManager.heading3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ResponsiveManager.spacingSmall),
              Text(
                "ask_ai.clear_warning".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: ResponsiveManager.bodyMedium,
                ),
              ),
              SizedBox(height: ResponsiveManager.spacingLarge),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveManager.spacingMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ResponsiveManager.radiusMedium),
                        ),
                      ),
                      child: Text(
                        "profile.cancel".tr(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: ResponsiveManager.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveManager.spacingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        vm.clearChat();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveManager.spacingMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ResponsiveManager.radiusMedium),
                        ),
                      ),
                      child: Text(
                        "ask_ai.clear".tr(),
                        style: TextStyle(
                          fontSize: ResponsiveManager.bodyMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuggestionChipsWidget extends StatelessWidget {
  const SuggestionChipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AskAiViewModel>();

    final suggestions = [
      "What's a healthy breakfast?",
      "Calories in an apple",
      "High protein recipes",
      "Meal prep ideas",
      "Low carb foods",
      "Post-workout meal",
    ];

    return Wrap(
      spacing: ResponsiveManager.spacingSmall,
      runSpacing: ResponsiveManager.spacingSmall,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) {
        return ActionChip(
          label: Text(
            suggestion,
            style: TextStyle(
              fontSize: ResponsiveManager.bodySmall,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF2A2A3E),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          onPressed: () => vm.sendPrompt(suggestion),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(ResponsiveManager.radiusXXLarge),
          ),
        );
      }).toList(),
    );
  }
}
