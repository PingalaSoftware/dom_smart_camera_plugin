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
  int rate = 0;

  @override
  void initState() {
    super.initState();

    subscription =
        _domCameraPlugin.playbackTimerStreamListener().listen(timerData);
  }

  bool isDialogShown = false;
  int dummyProgress = 0;

  void timerData(event) {
    final eventJsonString = json.decode(event);

    if (eventJsonString["key"] == "PLAYBACK_DOWNLOAD_PROGRESS") {
      if (eventJsonString["state"] == 1) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Download Started!")),
          );
        }
        setState(() {
          isDialogShown = true;
        });
      } else if (eventJsonString["state"] == 2) {
        setState(() {
          dummyProgress = eventJsonString["progress"];
        });
      } else if (eventJsonString["state"] == 6) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Download Completed!")),
          );
        }
        if (isDialogShown) {
          setState(() {
            isDialogShown = false;
          });
        }
      } else if (eventJsonString["state"] == 3) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Download Completed!")),
          );
        }
        if (isDialogShown) {
          setState(() {
            isDialogShown = false;
          });
        }
      } else if (eventJsonString["state"] == 4) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Download Stopped!")),
          );
        }
        if (isDialogShown) {
          setState(() {
            isDialogShown = false;
          });
        }
      } else if (eventJsonString["state"] == 5) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Download Failed!")),
          );
        }
        if (isDialogShown) {
          setState(() {
            isDialogShown = false;
          });
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unknown error!")),
          );
        }
        if (isDialogShown) {
          setState(() {
            isDialogShown = false;
          });
        }
      }
    }

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
    return Column(
      children: [
        if (isDialogShown)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Downloading video... ($dummyProgress%)',
              ),
              const SizedBox(height: 20),
            ],
          ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$time [$rate]"),
            ],
          ),
        ),
      ],
    );
  }
}
