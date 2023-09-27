// import 'package:dom_camera/dom_camera.dart';
import 'package:flutter/material.dart';

class CameraPictureControl extends StatefulWidget {
  final String cameraId;

  const CameraPictureControl({required this.cameraId, Key? key})
      : super(key: key);

  @override
  State<CameraPictureControl> createState() => _CameraPictureControlState();
}

class _CameraPictureControlState extends State<CameraPictureControl> {
  // final _domCameraPlugin = DomCamera();

  late String cameraId;

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => {},
              child: Row(
                children: [
                  Container(
                    width: 2,
                    height: 50,
                    color: Theme.of(context).primaryColor,
                    margin: const EdgeInsets.only(right: 4.0),
                  ),
                  const Text("Inside Camera: "),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
