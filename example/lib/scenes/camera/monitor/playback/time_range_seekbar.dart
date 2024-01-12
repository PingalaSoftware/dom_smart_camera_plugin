import 'dart:async';
import 'dart:convert';

import 'package:dom_camera/dom_camera.dart';
import 'package:flutter/material.dart';

class TimeRangeSeekBar extends StatefulWidget {
  const TimeRangeSeekBar({
    Key? key,
  }) : super(key: key);

  @override
  State<TimeRangeSeekBar> createState() => _TimeRangeSeekBarState();
}

class _TimeRangeSeekBarState extends State<TimeRangeSeekBar> {
  final _domCameraPlugin = DomCamera();
  late StreamSubscription<dynamic> subscription;

  String time = "";
  String rate = "";

  @override
  void initState() {
    super.initState();

    subscription =
        _domCameraPlugin.playbackTimerStreamListener().listen(timerData);
  }

  void timerData(event) {
    final eventJsonString = json.decode(event);
    if (eventJsonString["key"] == "PLAYBACK_STREAM_DATA") {
      setState(() {
        time = eventJsonString["time"];
        rate = eventJsonString["rate"];
      });
    }
  }

  @override
  void dispose() async {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$time [$rate]"),
        ],
      ),
    );
  }
}
