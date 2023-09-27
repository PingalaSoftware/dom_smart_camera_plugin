import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/button.dart';
import 'package:flutter/material.dart';

class CameraOptionScreen5 extends StatefulWidget {
  final String cameraId;

  const CameraOptionScreen5({required this.cameraId, Key? key})
      : super(key: key);

  @override
  State<CameraOptionScreen5> createState() => _CameraOptionScreen5State();
}

class _CameraOptionScreen5State extends State<CameraOptionScreen5> {
  final _domCameraPlugin = DomCamera();
  final TextEditingController _callbackUrlController = TextEditingController();

  late String cameraId;

  @override
  void dispose() {
    _callbackUrlController.dispose();
    super.dispose();
  }

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
            child: TextField(
              controller: _callbackUrlController,
              decoration: const InputDecoration(
                hintText: 'Enter Callback URL',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () async {
                final callbackUrl = _callbackUrlController.text.trim();

                if (callbackUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Callback Url is required"),
                    ),
                  );
                  return;
                }

                final data =
                    await _domCameraPlugin.setDeviceAlarmCallback(callbackUrl);
                if (data["isError"]) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['message'])),
                    );
                  }
                  return;
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Added Callback URL")),
                  );
                }
              },
              child: OptionsButton(
                text: "Set Callback",
                size: 100,
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
