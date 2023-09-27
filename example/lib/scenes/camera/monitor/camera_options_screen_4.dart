import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/button.dart';
import 'package:flutter/material.dart';

class CameraOptionScreen4 extends StatefulWidget {
  final String cameraId;

  const CameraOptionScreen4({required this.cameraId, Key? key})
      : super(key: key);

  @override
  State<CameraOptionScreen4> createState() => _CameraOptionScreen4State();
}

class _CameraOptionScreen4State extends State<CameraOptionScreen4> {
  final _domCameraPlugin = DomCamera();
  late String cameraId;
  bool isFunctionInProgress = false;

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;
  }

  Future<void> toggleHumanDetection(bool enable) async {
    if (isFunctionInProgress) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Previous action is in progress."),
          ),
        );
      }
      return;
    }

    setState(() {
      isFunctionInProgress = true;
    });

    final data = await _domCameraPlugin.setHumanDetection(enable);
    if (data["isError"]) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Human detection set to: ${enable ? 'ON' : 'OFF'}"),
          ),
        );
      }
    }

    setState(() {
      isFunctionInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, bottom: 8.0, right: 10.0),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () async {
                  await toggleHumanDetection(true);
                },
                child: OptionsButton(
                  text: "Human Detection: ON",
                  size: 50,
                  textColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () async {
                  await toggleHumanDetection(false);
                },
                child: OptionsButton(
                  text: "Human Detection: OFF",
                  size: 50,
                  textColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
