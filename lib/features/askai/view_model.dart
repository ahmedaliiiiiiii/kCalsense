// ignore_for_file: depend_on_referenced_packages

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'chat_message.dart';

class AskAiViewModel extends ChangeNotifier {
  final List<ChatMessage> messages = [];
  bool isTyping = false;

  final String _systemPrompt = """
    You are 'CalorieCalc Magic AI'. 
    1. Your ONLY purpose is to discuss food, nutrition, recipes, and calories.
    2. If the user asks about anything else (politics, tech, etc.), politely say: 
       "I'm sorry, I can only assist with food-related topics and calorie tracking."
    3. Provide estimated calories when asked about a meal.
    4. Keep your tone helpful, healthy, and use food emojis.
  """;

  late final GenerativeModel _model;
  late final ChatSession _chat;

  void init() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: 'AIzaSyBtbKiQ0Wh1FvmF5ch-vzMT5s8iehOkHkw',
      systemInstruction: Content.system(_systemPrompt),
    );
    _chat = _model.startChat();
  }

  Future<void> sendPrompt(String text) async {
    if (text.trim().isEmpty) return;

    messages.add(ChatMessage(text: text, role: MessageRole.user));
    isTyping = true;
    notifyListeners();

    try {
      final response = await _chat.sendMessage(Content.text(text));

      if (response.text != null) {
        messages.add(ChatMessage(text: response.text!, role: MessageRole.ai));
      } else {
        messages.add(ChatMessage(
            text:
                "I'm having trouble understanding that. Try asking about a recipe! 🥗",
            role: MessageRole.ai));
      }
    } catch (e) {
      debugPrint("AI Error Details: $e");

      String errorMessage = "ask_ai.connection_error".tr();

      if (e.toString().contains('429') || e.toString().contains('quota')) {
        errorMessage = "ask_ai.quota_error".tr();
      } else if (e.toString().contains('SocketException')) {
        errorMessage = "ask_ai.connection_error".tr();
      }

      messages.add(ChatMessage(text: errorMessage, role: MessageRole.ai));
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    messages.clear();
    _chat = _model.startChat();
    notifyListeners();
  }
}
