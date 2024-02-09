import 'dart:math';

import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_1.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_2.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_3.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_4.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_5.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_6.dart';
import 'package:dom_camera_example/utils/constants.dart';
import 'package:dom_camera_example/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/event_bus.dart';

class CameraHomeScreen extends StatefulWidget {
  final String cameraId;

  const CameraHomeScreen({Key? key, required this.cameraId}) : super(key: key);

  @override
  State<CameraHomeScreen> createState() => _CameraHomeScreenState();
}

class _CameraHomeScreenState extends State<CameraHomeScreen>
    with WidgetsBindingObserver {
  final _domCameraPlugin = DomCamera();

  late String cameraId;
  bool isLiveStreamError = false;
  bool isFullScreen = false;

  @override
  void dispose() async {
    _domCameraPlugin.stopStreaming();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;

    WidgetsBinding.instance.addObserver(this);
    // _enableFullScreenAndLandscape();
  }

  void _enableFullScreenAndLandscape() {
    _domCameraPlugin.stopStreaming();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _domCameraPlugin.startStreaming();
  }

  void _restoreSystemSettings() {
    // _domCameraPlugin.stopStreaming();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    // _domCameraPlugin.startStreaming();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isFullScreen) {
          setState(() {
            isFullScreen = false;
          });
          _restoreSystemSettings();

          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          onBackButtonPressed: () {
            _restoreSystemSettings();
            Navigator.of(context).pop();
          },
          title: 'Camera Home Screen $cameraId',
          actions: [
            CustomAppBarAction(
              icon: Icons.settings,
              callback: () {
                _restoreSystemSettings();
                eventBus.fire(StopLiveStreamEvent());

                Navigator.pushNamed(
                  context,
                  ScreenRoutes.settingsPage,
                  arguments: {"cameraId": cameraId},
                );
              },
            ),
          ],
        ),
        body: Center(
          child: cameraId.isNotEmpty || isLiveStreamError
              ? Column(
                  mainAxisAlignment: isFullScreen
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    // Transform.rotate(
                    //   angle: isFullScreen ? -pi / 2 : 0,
                    //   child:
                    SizedBox(
                      height: isFullScreen
                          ? MediaQuery.of(context).size.height - 60
                          : 240,
                      // width: isFullScreen
                      //     ? MediaQuery.of(context).size.width
                      //     : MediaQuery.of(context).size.height,
                      child: DecoratedBox(
                        decoration:
                            const BoxDecoration(color: Colors.redAccent),
                        child: _domCameraPlugin.cameraStreamWidget(),
                      ),
                    ),
                    // ),
                    if (!isFullScreen)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      final data = await _domCameraPlugin
                                          .isFullScreenStreaming();
                                      print("isFullScreenStreaming: $data");
                                    },
                                    child: const Text("Get Streaming state"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _domCameraPlugin.showFullScreenStream(),
                                    child: const Text("Expand"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _domCameraPlugin.stopFullScreenStream(),
                                    child: const Text("Fit"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isFullScreen = true;
                                      });
                                      _enableFullScreenAndLandscape();
                                      // eventBus.fire(StopLiveStreamEvent());

                                      // Future.delayed(
                                      //     const Duration(milliseconds: 1000), () {
                                      //   Navigator.pushNamed(
                                      //     context,
                                      //     ScreenRoutes.cameraFullScreen,
                                      //   );
                                      // });
                                    },
                                    child: const Text("FullScreen"),
                                  ),
                                ],
                              ),
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
