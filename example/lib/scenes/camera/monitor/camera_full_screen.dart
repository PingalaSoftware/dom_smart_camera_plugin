import 'package:dom_camera/dom_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraFullScreen extends StatefulWidget {
  const CameraFullScreen({super.key});

  @override
  State<CameraFullScreen> createState() => _CameraFullScreenState();
}

class _CameraFullScreenState extends State<CameraFullScreen>
    with WidgetsBindingObserver {
  bool isLoading = true;
  final _domCameraPlugin = DomCamera();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _enableFullScreenAndLandscape();

    // if (context.mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("testing")),
    //   );
    //   Navigator.of(context).pop();
    // }

    _domCameraPlugin.startStreaming().then((value) {
      if (value["isError"]) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(value["message"])),
          );
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _domCameraPlugin.stopStreaming();
    WidgetsBinding.instance.removeObserver(this);
    _restoreSystemSettings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.black),
          child: _domCameraPlugin.cameraStreamWidget(),
        ),
      ),
    );
  }

  void _enableFullScreenAndLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _restoreSystemSettings() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }
}
