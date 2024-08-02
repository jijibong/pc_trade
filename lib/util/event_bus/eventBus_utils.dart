import 'package:event_bus/event_bus.dart';

class EventBusUtil{
  static final EventBus _eventBus=EventBus();

  static EventBus getInstance() {
    return _eventBus;
  }

}