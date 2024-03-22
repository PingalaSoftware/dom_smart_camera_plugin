import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/button.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_2.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_3.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_4.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_5.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_options_screen_6.dart';
import 'package:dom_camera_example/scenes/camera/monitor/options/main_stream_audio_control.dart';
import 'package:dom_camera_example/scenes/camera/monitor/options/preset_point.dart';
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

  // NEW START
  bool _isLiveView = false;
  bool _isLoading = false;
  late VoidCallback onStreamError;
  bool isFirstTime = true;
  // NEW END

  @override
  void dispose() async {
    await _domCameraPlugin.stopStreaming();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;

    WidgetsBinding.instance.addObserver(this);
    // _enableFullScreenAndLandscape();

    // NEW START

    setState(() {
      _isLoading = true;
    });
    // On loading the video player may not be properly attached to UI so added little bit delay
    Future.delayed(const Duration(milliseconds: 300), () => {_startLiveView()});

    eventBus.on<StopLiveStreamEvent>().listen((event) async {
      if (!_isLiveView) return;
      await _domCameraPlugin.stopStreaming();

      _stopLiveView();
    });
    // NEW END
  }

  // NEW START
  void _startLiveView() async {
    setState(() {
      _isLoading = true;
    });

    final data = await _domCameraPlugin.startStreaming();

    if (data["isError"]) {
      onStreamError();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
      }
      return;
    }

    // if (isFirstTime) {
    //   setState(() {
    //     isFirstTime = false;
    //   });
    //   await _domCameraPlugin.stopStreaming();
    //   Future.delayed(
    //       const Duration(milliseconds: 800), () => {_startLiveView()});
    //   return;
    // }

    setState(() {
      _isLoading = false;
      _isLiveView = true;
    });
  }

  void _stopLiveView() async {
    if (!_isLiveView) return;
    await _domCameraPlugin.stopStreaming();

    setState(() {
      _isLiveView = false;
    });
  }
  // NEW END

  void _enableFullScreenAndLandscape() async {
    await _domCameraPlugin.stopStreaming();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    await _domCameraPlugin.startStreaming();
  }

  void _restoreSystemSettings() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
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
            if (isFullScreen) {
              setState(() {
                isFullScreen = false;
              });
              _restoreSystemSettings();
              return;
            }
            Navigator.of(context).pop();
          },
          title: 'Camera Home Screen $cameraId',
          actions: [
            CustomAppBarAction(
              icon: Icons.settings,
              callback: () {
                if (isFullScreen) {
                  setState(() {
                    isFullScreen = false;
                  });
                  _restoreSystemSettings();
                }
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
                    SizedBox(
                      height: isFullScreen
                          ? MediaQuery.of(context).size.height - 60
                          : 240,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(color: Colors.black),
                        child: _domCameraPlugin.cameraStreamWidget(),
                      ),
                    ),
                    if (!isFullScreen)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 15),
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width),
                                padding: const EdgeInsets.only(
                                    left: 10.0, bottom: 8.0, right: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    MainStreamAudioControl(cameraId: cameraId),
                                    const PresetPoint(),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          isFullScreen = true;
                                        });
                                        _enableFullScreenAndLandscape();
                                      },
                                      child: const Text("FS"),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 4.0),
                                        child: GestureDetector(
                                          onTap: _isLiveView
                                              ? _stopLiveView
                                              : _startLiveView,
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 50,
                                                  width: 80,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.red,
                                                  ))
                                              : OptionsButton(
                                                  text: _isLiveView
                                                      ? "STOP LIVE STREAM"
                                                      : "SHOW LIVE STREAM",
                                                  size: 50,
                                                  textColor: Colors.white,
                                                  backgroundColor: _isLiveView
                                                      ? Colors.red
                                                      : Colors.green,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
