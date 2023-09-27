import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/button.dart';
import 'package:dom_camera_example/scenes/camera/monitor/options/main_stream_audio_control.dart';
import 'package:dom_camera_example/utils/event_bus.dart';
import 'package:flutter/material.dart';

class CameraOptionScreen1 extends StatefulWidget {
  final String cameraId;
  final VoidCallback onStreamError;

  const CameraOptionScreen1(
      {required this.cameraId, required this.onStreamError, Key? key})
      : super(key: key);

  @override
  State<CameraOptionScreen1> createState() => _CameraOptionScreen1State();
}

class _CameraOptionScreen1State extends State<CameraOptionScreen1> {
  final _domCameraPlugin = DomCamera();

  late String cameraId;
  bool _isLiveView = false;
  late VoidCallback onStreamError;

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;
    onStreamError = widget.onStreamError;
    _startLiveView();

    eventBus.on<StopLiveStreamEvent>().listen((event) {
      _stopLiveView();
    });
  }

  void _startLiveView() {
    final data = _domCameraPlugin.startStreaming();
    if (data["isError"]) {
      onStreamError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"])),
      );
      return;
    }

    setState(() {
      _isLiveView = true;
    });
  }

  void _stopLiveView() {
    if (!_isLiveView) return;
    _domCameraPlugin.stopStreaming();

    setState(() {
      _isLiveView = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      padding: const EdgeInsets.only(left: 10.0, bottom: 8.0, right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MainStreamAudioControl(cameraId: cameraId),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: GestureDetector(
                onTap: _isLiveView ? _stopLiveView : _startLiveView,
                child: OptionsButton(
                  text: _isLiveView ? "STOP LIVE STREAM" : "SHOW LIVE STREAM",
                  size: 50,
                  textColor: Colors.white,
                  backgroundColor: _isLiveView ? Colors.red : Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
