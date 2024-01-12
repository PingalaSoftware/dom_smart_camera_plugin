import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dom_camera_example/utils/event_bus.dart';

class TimeRangeSeekBar extends StatefulWidget {
  final DateTime startTime;
  final DateTime endTime;

  const TimeRangeSeekBar({
    Key? key,
    required this.startTime,
    required this.endTime,
  }) : super(key: key);

  @override
  State<TimeRangeSeekBar> createState() => _TimeRangeSeekBarState();
}

class _TimeRangeSeekBarState extends State<TimeRangeSeekBar> {
  late DateTime _startTime;
  late DateTime _endTime;
  late DateTime _currentTime;
  late double _minValue;
  late double _maxValue;
  late double _currentValue;
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _startTime = widget.startTime;
    _endTime = widget.endTime;
    _currentTime = _startTime;
    _minValue = _startTime.millisecondsSinceEpoch.toDouble();
    _maxValue = _endTime.millisecondsSinceEpoch.toDouble();
    _currentValue = _minValue;
    _isPlaying = false;

    eventBus.on<PausePlayBackEvent>().listen((event) {
      _pause();
    });
    eventBus.on<PlayPlayBackEvent>().listen((event) {
      _play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Current Playback Time: ${_formatDateTime(_currentTime)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          StatefulBuilder(builder: (context, state) {
            return Slider(
              value: _currentValue,
              min: _minValue,
              max: _maxValue,
              onChanged: (double value) {
                state(() {});
                setState(() {
                  _currentValue = value;
                  _currentTime =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  eventBus.fire(SeekToPositionPlayback(_currentTime));
                });
              },
            );
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _play(),
                child: const Text('Play'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _pause(),
                child: const Text('Pause'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  void _play() {
    if (!_isPlaying) {
      _isPlaying = true;
      _moveSeekBar();
    }
  }

  void _pause() {
    _isPlaying = false;
  }

  void _moveSeekBar() {
    if (_isPlaying && _currentTime.isBefore(_endTime)) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _currentTime = _currentTime.add(const Duration(seconds: 1));
          _currentValue = _currentTime.millisecondsSinceEpoch.toDouble();
        });
        _moveSeekBar();
        setState(() {});
      });
    }
    setState(() {});
  }
}
