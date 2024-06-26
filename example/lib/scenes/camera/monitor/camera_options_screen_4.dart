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
      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).secondaryHeaderColor,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text("Human Detection: "),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () async {
                await toggleHumanDetection(true);
              },
              child: OptionsButton(
                text: "ON",
                size: 50,
                textColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () async {
                await toggleHumanDetection(false);
              },
              child: OptionsButton(
                text: "OFF",
                size: 50,
                textColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
