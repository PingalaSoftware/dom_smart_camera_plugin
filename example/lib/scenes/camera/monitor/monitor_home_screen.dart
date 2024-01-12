import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/alerts.dart';
import 'package:dom_camera_example/utils/constants.dart';
import 'package:dom_camera_example/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CameraEntry {
  final String cameraId;
  String? cameraState;

  CameraEntry({required this.cameraId, this.cameraState});
}

class MonitorHomeScreen extends StatefulWidget {
  const MonitorHomeScreen({Key? key}) : super(key: key);

  @override
  State<MonitorHomeScreen> createState() => _MonitorHomeScreenState();
}

class _MonitorHomeScreenState extends State<MonitorHomeScreen> {
  final _domCameraPlugin = DomCamera();
  final _localStorage = Hive.box('dom_camera_storage');

  final TextEditingController _cameraIdController = TextEditingController();
  List<CameraEntry> usedCameraIds = [];
  bool isCameraLogin = false;

  @override
  void initState() {
    super.initState();
    _loadUsedCameraIds();
  }

  void _loadUsedCameraIds() async {
    final cameraIds = _localStorage.get('usedCameraIds', defaultValue: []);
    for (String deviceId in cameraIds!) {
      usedCameraIds.add(CameraEntry(cameraId: deviceId, cameraState: "--"));
    }
    setState(() {});

    // for (String deviceId in cameraIds!) {
    //   final response = await _domCameraPlugin.cameraState(deviceId);
    //   // _updateCameraIdList(deviceId);
    //   if (response["isError"]) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text(response["$deviceId: message"])),
    //     );
    //   } else {
    //     final cameraState = response["state"] as String?;
    //     final existingEntry = usedCameraIds.firstWhere(
    //       (entry) => entry.cameraId == deviceId,
    //       orElse: () => CameraEntry(cameraId: deviceId),
    //     );

    //     existingEntry.cameraState = cameraState;

    //     setState(() {});
    //   }
    // }
  }

  // void _loadUsedCameraIds() async {
  //   final cameraIds = _localStorage.get('usedCameraIds', defaultValue: []);
  //   final futures = <Future>[];

  //   for (String deviceId in cameraIds!) {
  //     futures.add(_getCameraState(deviceId));
  //   }

  //   await Future.wait(futures);

  //   setState(() {});
  // }

  // Future<void> _getCameraState(String deviceId) async {
  //   final response = await _domCameraPlugin.cameraState(deviceId);

  //   if (response["isError"]) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(response["$deviceId: message"])),
  //     );
  //   } else {
  //     final cameraState = response["state"] as String?;
  //     final existingEntry = usedCameraIds.firstWhere(
  //       (entry) => entry.cameraId == deviceId,
  //       orElse: () => CameraEntry(cameraId: deviceId),
  //     );

  //     existingEntry.cameraState = cameraState;
  //   }
  // }

  void _updateCameraIdList(String cameraId, [bool remove = false]) async {
    final cameraIds = _localStorage.get('usedCameraIds', defaultValue: []);

    cameraIds.remove(cameraId);
    if (!remove) {
      cameraIds.insert(0, cameraId);

      if (cameraIds.length > 20) {
        cameraIds.removeLast();
      }
    }

    _localStorage.put('usedCameraIds', cameraIds);

    setState(() {});
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
                      _cameraIdController.text = usedCameraIds[index].cameraId;
                    },
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    tileColor: Theme.of(context).primaryColor.withOpacity(0.8),
                    textColor: Theme.of(context).secondaryHeaderColor,
                    iconColor: Theme.of(context).secondaryHeaderColor,
                    leading: const Icon(
                      Icons.camera,
                      size: 25,
                    ),
                    title: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(usedCameraIds[index].cameraId),
                          const SizedBox(width: 8.0),
                          if (usedCameraIds[index].cameraState == "")
                            const CircularProgressIndicator()
                          else
                            Text(usedCameraIds[index].cameraState!),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            _refreshCameraState(usedCameraIds[index].cameraId);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            showDeleteConfirmationDialog(
                              context,
                              usedCameraIds[index].cameraId,
                              () => _updateCameraIdList(
                                  usedCameraIds[index].cameraId, true),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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
                      const SizedBox(width: 4.0),
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

  void _refreshCameraState(String cameraId) async {
    final existingEntryIndex = usedCameraIds.indexWhere(
      (entry) => entry.cameraId == cameraId,
    );

    if (existingEntryIndex != -1) {
      setState(() {
        usedCameraIds[existingEntryIndex].cameraState = "";
      });
    }
    final response = await _domCameraPlugin.cameraState(cameraId);

    if (response["isError"]) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"])),
        );
      }
    } else {
      final cameraState = response["state"] as String?;

      if (existingEntryIndex != -1) {
        setState(() {
          usedCameraIds[existingEntryIndex].cameraState = cameraState;
        });
      }
    }
  }
}
