import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/button.dart';
import 'package:flutter/material.dart';

class CameraOptionScreen6 extends StatefulWidget {
  final String cameraId;

  const CameraOptionScreen6({required this.cameraId, Key? key})
      : super(key: key);

  @override
  State<CameraOptionScreen6> createState() => _CameraOptionScreen6State();
}

class _CameraOptionScreen6State extends State<CameraOptionScreen6> {
  final _domCameraPlugin = DomCamera();
  late String cameraId;
  bool isFunctionInProgress = false;

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;
  }

  Future<void> updateRecordConfigurationType(recordType) async {
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

    final data = await _domCameraPlugin.setRecordType(recordType);
    if (data["isError"]) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Record Setting updated"),
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
              child: Text("Video Recording: "),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () async {
                await updateRecordConfigurationType("ALWAYS");
              },
              child: OptionsButton(
                text: "Always",
                size: 60,
                textColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () async {
                await updateRecordConfigurationType("NEVER");
              },
              child: OptionsButton(
                text: "Never",
                size: 60,
                textColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () async {
                await updateRecordConfigurationType("ALARM");
              },
              child: OptionsButton(
                text: "Alarm",
                size: 60,
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
