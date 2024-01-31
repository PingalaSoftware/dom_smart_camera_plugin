import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/button.dart';
import 'package:dom_camera_example/utils/constants.dart';
import 'package:dom_camera_example/utils/event_bus.dart';
import 'package:flutter/material.dart';

class CameraVideoControl extends StatefulWidget {
  final String cameraId;

  const CameraVideoControl({required this.cameraId, Key? key})
      : super(key: key);

  @override
  State<CameraVideoControl> createState() => _CameraVideoControlState();
}

class _CameraVideoControlState extends State<CameraVideoControl> {
  final _domCameraPlugin = DomCamera();
  bool _isRecording = false;

  late String cameraId;

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: GestureDetector(
            onTap: () {
              if (!_isRecording) {
                final data = _domCameraPlugin.startVideRecordAndSaveLocal();
                if (data["isError"]) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(data['message'])),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Started recording!")),
                );
                setState(() {
                  _isRecording = true;
                });
              }
            },
            child: OptionsButton(
              icon: Icons.play_circle,
              size: 50,
              textColor: _isRecording
                  ? Theme.of(context).secondaryHeaderColor.withOpacity(0.5)
                  : Theme.of(context).primaryColor,
              backgroundColor: _isRecording
                  ? Theme.of(context).primaryColor.withOpacity(0.5)
                  : Theme.of(context).secondaryHeaderColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: GestureDetector(
            onTap: () {
              if (_isRecording) {
                final data = _domCameraPlugin.stopVideRecordAndSaveLocal();
                if (data["isError"]) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(data['message'])),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Recording saved to your Camera folder!")),
                );
                setState(() {
                  _isRecording = false;
                });
              }
            },
            child: OptionsButton(
              icon: Icons.stop_circle,
              size: 50,
              textColor: _isRecording
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor.withOpacity(0.5),
              backgroundColor: _isRecording
                  ? Colors.red
                  : Theme.of(context).secondaryHeaderColor.withOpacity(0.5),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor, width: 4),
          ),
          margin: const EdgeInsets.only(right: 4.0),
          child: GestureDetector(
            onTap: () {
              eventBus.fire(StopLiveStreamEvent());

              Navigator.pushNamed(
                context,
                ScreenRoutes.videoPlayback,
                arguments: {"cameraId": cameraId},
              );
            },
            child: OptionsButton(
              height: 42,
              textColor: Theme.of(context).primaryColor,
              icon: Icons.video_camera_back_outlined,
              size: 42,
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              borderRadios: 4,
            ),
          ),
        ),
      ],
    );
  }
}
