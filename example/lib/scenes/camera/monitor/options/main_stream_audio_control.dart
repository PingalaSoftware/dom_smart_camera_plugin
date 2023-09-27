import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/alerts.dart';
import 'package:dom_camera_example/components/button.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MainStreamAudioControl extends StatefulWidget {
  final String cameraId;

  const MainStreamAudioControl({required this.cameraId, Key? key})
      : super(key: key);

  @override
  State<MainStreamAudioControl> createState() => _MainStreamAudioControlState();
}

class _MainStreamAudioControlState extends State<MainStreamAudioControl> {
  final _domCameraPlugin = DomCamera();

  bool _isAudioOpen = false;
  bool _isMicOpen = false;
  late String cameraId;

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;
  }

  void _openAudioInterCom() {
    Permission.microphone.status.then((value) => {
          if (value == PermissionStatus.denied)
            {showAudioAlertDialog(context)}
          else
            enableAudioInterCom()
        });
  }

  void enableAudioInterCom() {
    if (_isMicOpen) {
      if (_isAudioOpen) {
        final data = _domCameraPlugin.stopDualInterCom();
        if (data["isError"]) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          return;
        }
      } else {
        final data = _domCameraPlugin.stopSingleInterCom();
        if (data["isError"]) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          return;
        }
      }

      setState(() {
        _isMicOpen = false;
      });
    } else {
      if (_isAudioOpen) {
        final data = _domCameraPlugin.startDualInterCom();
        if (data["isError"]) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          return;
        }
      } else {
        final data = _domCameraPlugin.startSingleInterCom();
        if (data["isError"]) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          return;
        }
      }

      setState(() {
        _isMicOpen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: GestureDetector(
            onTap: () {
              if (_isMicOpen) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Microphone is on, Please turn off"),
                  ),
                );
                return;
              }
              if (_isAudioOpen) {
                final data = _domCameraPlugin.stopAudio();
                if (data["isError"]) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(data['message'])),
                  );
                  return;
                }

                setState(() {
                  _isAudioOpen = false;
                });
              } else {
                final data = _domCameraPlugin.startAudio();
                if (data["isError"]) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(data['message'])),
                  );
                  return;
                }

                setState(() {
                  _isAudioOpen = true;
                });
              }
            },
            child: OptionsButton(
              icon: _isAudioOpen ? Icons.volume_up : Icons.volume_off,
              textColor: _isAudioOpen
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              backgroundColor: _isAudioOpen
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).secondaryHeaderColor,
              size: 50,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: GestureDetector(
            onTap: _openAudioInterCom,
            child: OptionsButton(
              icon: _isMicOpen ? Icons.mic : Icons.mic_off,
              textColor: _isMicOpen
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              backgroundColor: _isMicOpen
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).secondaryHeaderColor,
              size: 50,
            ),
          ),
        ),
      ],
    );
  }
}
