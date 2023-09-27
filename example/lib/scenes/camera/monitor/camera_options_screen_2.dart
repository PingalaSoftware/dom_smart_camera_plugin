import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/button.dart';
import 'package:dom_camera_example/scenes/camera/monitor/options/camera_video_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class CameraOptionScreen2 extends StatefulWidget {
  final String cameraId;

  const CameraOptionScreen2({required this.cameraId, Key? key})
      : super(key: key);

  @override
  State<CameraOptionScreen2> createState() => _CameraOptionScreen2State();
}

class _CameraOptionScreen2State extends State<CameraOptionScreen2> {
  final _domCameraPlugin = DomCamera();

  late String cameraId;

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      padding: const EdgeInsets.only(left: 10.0, bottom: 8.0, right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CameraVideoControl(cameraId: cameraId),
          Expanded(
            child: GestureDetector(
              onTap: _showPTZDialog,
              child: const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: OptionsButton(
                  text: "PTZ",
                  size: 50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPTZDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Card(
              shape: const CircleBorder(),
              child: Joystick(
                listener: (details) {
                  final data =
                      _domCameraPlugin.cameraMovement(details.x, details.y);

                  if (data["isError"]) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data["message"])),
                    );
                    return;
                  }
                },
              ),
            ),
            const SizedBox(
              height: 80,
            )
          ],
        );
      },
    );
  }
}
