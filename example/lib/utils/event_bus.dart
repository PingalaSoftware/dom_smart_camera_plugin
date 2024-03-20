import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class StopLiveStreamEvent {
  StopLiveStreamEvent();
}

class PausePlayBackEvent {
  PausePlayBackEvent();
}

class PlayPlayBackEvent {
  PlayPlayBackEvent();
}

class SeekToPositionPlayback {
  SeekToPositionPlayback(DateTime currentTime);
}
