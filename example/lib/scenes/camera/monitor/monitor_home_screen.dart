import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/alerts.dart';
import 'package:dom_camera_example/utils/constants.dart';
import 'package:dom_camera_example/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class MonitorHomeScreen extends StatefulWidget {
  const MonitorHomeScreen({Key? key}) : super(key: key);

  @override
  State<MonitorHomeScreen> createState() => _MonitorHomeScreenState();
}

class _MonitorHomeScreenState extends State<MonitorHomeScreen> {
  final _domCameraPlugin = DomCamera();
  final _localStorage = Hive.box('dom_camera_storage');

  final TextEditingController _cameraIdController = TextEditingController();
  List<String> usedCameraIds = [];
  bool isCameraLogin = false;

  @override
  void initState() {
    super.initState();
    _loadUsedCameraIds();
  }

  void _loadUsedCameraIds() {
    final cameraIds = _localStorage.get('usedCameraIds', defaultValue: []);

    for (String deviceId in cameraIds!) {
      usedCameraIds.add(deviceId);
    }

    setState(() {
      usedCameraIds;
    });
  }

  void _updateCameraIdList(String cameraId, [bool remove = false]) {
    final cameraIds = _localStorage.get('usedCameraIds', defaultValue: []);

    cameraIds.remove(cameraId);
    if (!remove) {
      cameraIds.insert(0, cameraId);

      if (cameraIds.length > 20) {
        cameraIds.removeLast();
      }
    }

    _localStorage.put('usedCameraIds', cameraIds);

    setState(() {
      usedCameraIds = cameraIds;
    });
  }

  @override
  void dispose() {
    _cameraIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Monitor Camera',
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              "Used Camera Id",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: usedCameraIds.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2.0,
                    horizontal: 1.0,
                  ),
                  child: ListTile(
                      dense: true,
                      onTap: () {
                        _cameraIdController.text = usedCameraIds[index];
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      tileColor:
                          Theme.of(context).primaryColor.withOpacity(0.8),
                      textColor: Theme.of(context).secondaryHeaderColor,
                      iconColor: Theme.of(context).secondaryHeaderColor,
                      leading: const Icon(
                        Icons.camera,
                        size: 25,
                      ),
                      title: Text(usedCameraIds[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          showDeleteConfirmationDialog(
                            context,
                            usedCameraIds[index],
                            () =>
                                _updateCameraIdList(usedCameraIds[index], true),
                          );
                        },
                      )),
                );
              },
            ),
          ),
          Container(
            height: 80,
            color: Theme.of(context).secondaryHeaderColor,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: isCameraLogin
                  ? [const Text("Initializing Camera! Please wait..")]
                  : [
                      Expanded(
                        child: TextField(
                          controller: _cameraIdController,
                          decoration: const InputDecoration(
                            hintText: 'Enter/Select Camera ID',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          final cameraId = _cameraIdController.text.trim();

                          if (cameraId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("CameraId is required"),
                              ),
                            );
                            return;
                          }

                          _updateCameraIdList(cameraId);
                          _cameraIdController.clear();

                          setState(() {
                            isCameraLogin = true;
                          });

                          final value =
                              await _domCameraPlugin.cameraLogin(cameraId);

                          setState(() {
                            isCameraLogin = false;
                          });
                          if (!value["isError"]) {
                            if (context.mounted) {
                              Navigator.pushNamed(
                                context,
                                ScreenRoutes.cameraHome,
                                arguments: {"cameraId": cameraId},
                              );
                            }
                            return;
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(value["message"])),
                            );
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
