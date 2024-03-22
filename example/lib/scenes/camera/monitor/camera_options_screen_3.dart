import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/button.dart';
import 'package:dom_camera_example/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:dom_camera_example/utils/event_bus.dart';

class CameraOptionScreen3 extends StatefulWidget {
  final String cameraId;

  const CameraOptionScreen3({required this.cameraId, Key? key})
      : super(key: key);

  @override
  State<CameraOptionScreen3> createState() => _CameraOptionScreen3State();
}

class _CameraOptionScreen3State extends State<CameraOptionScreen3> {
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
      padding: const EdgeInsets.only(left: 10.0, bottom: 8.0, right: 10.0),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  // Only captures if live stream is running
                  final data = _domCameraPlugin.captureImageAndSaveLocal();
                  if (data["isError"]) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['message'])),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Image saved in your Camera folder.")),
                  );
                },
                child: OptionsButton(
                  icon: Icons.photo_camera,
                  size: 50,
                  textColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 4),
              ),
              margin: const EdgeInsets.only(right: 4.0, left: 4.0),
              child: GestureDetector(
                onTap: () {
                  eventBus.fire(StopLiveStreamEvent());

                  Navigator.pushNamed(
                    context,
                    ScreenRoutes.pictureList,
                    arguments: {"cameraId": cameraId},
                  );
                },
                child: OptionsButton(
                  height: 42,
                  textColor: Theme.of(context).primaryColor,
                  icon: Icons.collections_outlined,
                  size: 42,
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  borderRadios: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
