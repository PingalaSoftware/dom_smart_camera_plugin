import 'package:dom_camera/dom_camera.dart';
import 'package:flutter/material.dart';

class PlaybackTimeWidget extends StatefulWidget {
  const PlaybackTimeWidget({super.key});
  @override
  State<PlaybackTimeWidget> createState() => _PlaybackTimeWidgetState();
}

class _PlaybackTimeWidgetState extends State<PlaybackTimeWidget> {
  TimeOfDay? selectedTime;
  final _domCameraPlugin = DomCamera();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedTime != null) {
          _domCameraPlugin.skipPlayBack(pickedTime.hour, pickedTime.minute, 00);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No time provided")),
            );
          }
        }
      },
      child: const Text('Skip To'),
    );
  }
}
