import 'package:dom_camera_example/scenes/camera/monitor/settings/alarm_config_human.dart';
import 'package:dom_camera_example/scenes/camera/monitor/settings/alarm_config_motion.dart';
import 'package:dom_camera_example/scenes/camera/monitor/settings/battery_percentage.dart';
import 'package:dom_camera_example/scenes/camera/monitor/settings/camera_info.dart';
import 'package:dom_camera_example/scenes/camera/monitor/settings/encoding_config.dart';
import 'package:dom_camera_example/scenes/camera/monitor/settings/image_config.dart';
import 'package:dom_camera_example/scenes/camera/monitor/settings/name_change.dart';
import 'package:dom_camera_example/scenes/camera/monitor/settings/storage_modification.dart';
import 'package:dom_camera_example/scenes/camera/monitor/settings/video_config.dart';
import 'package:dom_camera_example/scenes/camera/monitor/settings/wifi_info.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String cameraId;

  const SettingsPage({required this.cameraId, Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String cameraId;

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ExpansionTile(
              title: const Text("Change Name"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: NameChange(cameraId: cameraId),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Alarm Config [Human Detect]"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AlarmConfigHuman(cameraId: cameraId),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Alarm Config [Move Detect]"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AlarmConfigMotion(cameraId: cameraId),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Camera Info"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CameraInfo(cameraId: cameraId),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Encoding config"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: EncodingConfig(cameraId: cameraId),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Image config"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ImageConfig(cameraId: cameraId),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Video Config"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: VideoConfig(cameraId: cameraId),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Storage Modifications"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StorageModification(cameraId: cameraId),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Wifi Information"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: WifiInfo(cameraId: cameraId),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Battery Percentage"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BatteryPercentage(cameraId: cameraId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
