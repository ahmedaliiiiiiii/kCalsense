import 'dart:async';

class MealEventBus {
  static final MealEventBus _instance = MealEventBus._internal();
  factory MealEventBus() => _instance;
  MealEventBus._internal();

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onMealChanged => _controller.stream;

  void notifyMealChanged() {
    _controller.add(true);
  }

  void dispose() {
    _controller.close();
  }
}
