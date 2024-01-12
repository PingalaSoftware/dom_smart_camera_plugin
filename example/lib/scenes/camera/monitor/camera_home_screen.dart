import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_1.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_2.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_3.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_4.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_5.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_6.dart';
import 'package:dom_camera_example/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class CameraHomeScreen extends StatefulWidget {
  final String cameraId;

  const CameraHomeScreen({Key? key, required this.cameraId}) : super(key: key);

  @override
  State<CameraHomeScreen> createState() => _CameraHomeScreenState();
}

class _CameraHomeScreenState extends State<CameraHomeScreen> {
  final _domCameraPlugin = DomCamera();

  late String cameraId;
  bool isLiveStreamError = false;

  @override
  void dispose() async {
    super.dispose();
    _domCameraPlugin.stopStreaming();
  }

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Camera Home Screen $cameraId',
      ),
      body: Center(
        child: cameraId.isNotEmpty || isLiveStreamError
            ? Column(
                children: [
                  SizedBox(
                    height: 240,
                    width: MediaQuery.of(context).size.width,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(color: Colors.black),
                      child: _domCameraPlugin.cameraStreamWidget(),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          CameraOptionScreen1(
                            cameraId: cameraId,
                            onStreamError: () {
                              setState(() {
                                isLiveStreamError = true;
                              });
                            },
                          ),
                          const SizedBox(height: 18),
                          CameraOptionScreen2(cameraId: cameraId),
                          CameraOptionScreen3(cameraId: cameraId),
                          const SizedBox(height: 18),
                          CameraOptionScreen4(cameraId: cameraId),
                          const SizedBox(height: 18),
                          CameraOptionScreen5(cameraId: cameraId),
                          const SizedBox(height: 18),
                          CameraOptionScreen6(cameraId: cameraId),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : const InvalidCameraWidget(),
      ),
    );
  }
}

class InvalidCameraWidget extends StatelessWidget {
  const InvalidCameraWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Invalid Camera', style: TextStyle(fontSize: 24)),
    );
  }
}
