import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dom_camera_example/components/alerts.dart';
import 'package:dom_camera_example/utils/constants.dart';
import 'package:dom_camera_example/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dom_camera/dom_camera.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _domCameraPlugin = DomCamera();
  bool isCameraInitializing = false;

  final _localStorage = Hive.box('dom_camera_storage');

  @override
  void initState() {
    super.initState();
  }

  void initialiseCamera(BuildContext context, medium) async {
    final localContext = context;

    if (isCameraInitializing) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(
            content: Text("Adding camera is in Progress! Please wait.")),
      );

      return;
    }

    showCameraInitAlert(context, () {
      if (medium == "WIFI") {
        _initialiseCameraThroughWifi(localContext);
      }
    });
  }

  void _initialiseCameraThroughWifi(localContext) async {
    final info = NetworkInfo();

    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.wifi) {
      showWifiConnectionAlert(localContext);
      return;
    }

    final permissionValue = await Permission.location.status;
    if (permissionValue == PermissionStatus.denied) {
      locationAlertDialog(localContext);
      return;
    }

    final wifiName = await info.getWifiName();

    getWifiPasswordAlert(
      localContext,
      wifiName,
      (password) => connectCameraThroughWifi(wifiName, password, localContext),
    );
  }

  void connectCameraThroughWifi(wifiName, String password, localContext) async {
    try {
      setState(() {
        isCameraInitializing = true;
      });
      final setupResult = await _domCameraPlugin.addCamera(
          removeQuotesIfPresent(wifiName), password);

      ScaffoldMessenger.of(localContext).showSnackBar(
        SnackBar(content: Text(setupResult['message'])),
      );

      setState(() {
        isCameraInitializing = false;
      });

      addCameraId(setupResult["cameraId"]);

      textCopyDialog(
        localContext,
        "Camera ID",
        'Please save the Camera ID somewhere safe',
        setupResult["cameraId"],
      );
    } catch (e) {
      setState(() {
        isCameraInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: false,
        centerTitle: true,
        title: 'DOM Camera',
        actions: [
          CustomAppBarAction(
            icon: Icons.refresh,
            callback: () {
              if (isCameraInitializing) {
                setState(() {
                  isCameraInitializing = false;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No change in the system.")),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => initialiseCamera(context, "WIFI"),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Center(
                          child: isCameraInitializing
                              ? Icon(
                                  Icons.hourglass_bottom,
                                  size: 50,
                                  color: Theme.of(context).secondaryHeaderColor,
                                )
                              : Icon(
                                  Icons.add_box_outlined,
                                  size: 50,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                        ),
                      ),
                    ),
                  ),
                  isCameraInitializing
                      ? const Text("Loading...")
                      : const Text("Add New")
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ScreenRoutes.monitorHome,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Center(
                          child: Icon(
                            Icons.video_camera_back_outlined,
                            size: 50,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text("Monitor")
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String removeQuotesIfPresent(inputString) {
    if (inputString.isNotEmpty &&
        inputString[0] == '"' &&
        inputString[inputString.length - 1] == '"') {
      return inputString.substring(1, inputString.length - 1);
    } else {
      return inputString;
    }
  }

  void addCameraId(String cameraId) {
    final usedCameraIds = _localStorage.get('usedCameraIds', defaultValue: []);

    usedCameraIds.remove(cameraId);
    usedCameraIds.insert(0, cameraId);

    if (usedCameraIds.length > 20) {
      usedCameraIds.removeLast();
    }

    _localStorage.put('usedCameraIds', usedCameraIds);
  }
}
