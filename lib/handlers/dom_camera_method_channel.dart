import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:dom_camera/dom_camera_platform_interface.dart';
import 'package:dom_camera/handlers/api_service.dart';

class MethodChannelDomCamera extends DomCameraPlatform {
  ApiService apiService = ApiService();
  String initializedCamera = "";
  bool isSingleInterComStarted = false;
  bool isDualInterComStarted = false;
  bool isPlaybackStarted = false;

  bool isUserLogged = false;
  String tempUsername = "";
  String tempPassword = "";
  String tempCameraId = "";

  bool isRequestPending = false;

  @visibleForTesting
  final methodChannel = const MethodChannel('dom_camera');

  @override
  Future<Map<String, dynamic>> iosNetworkPermission() async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called iosNetworkPermission()"
      };
    }
    if (Platform.isIOS) {
      isRequestPending = true;
      List result = await methodChannel.invokeMethod('WIFI_PERMISSION');
      isRequestPending = false;

      return {
        "isError": false,
        "result": result[0] == 0 ? false : true,
      };
    } else {
      return {
        "isError": false,
        "result": true,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> addCamera(
      String wifiSsid, String wifiPassword) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called addCamera()"
      };
    }
    try {
      isRequestPending = true;

      final apiResponse = await apiService.fetchMasterAccount();
      if (apiResponse['isError']) {
        isRequestPending = false;
        return apiResponse;
      }

      final account = apiResponse["account"];

      await methodChannel.invokeMethod('LOGIN', {
        "userName": account["username"],
        "password": account["password"],
      });

      final version =
          await methodChannel.invokeMethod('ADD_CAMERA_THROUGH_WIFI', {
        "ssid": wifiSsid,
        "password": wifiPassword,
      });

      final addResponse = await apiService.addDeviceToMasterAccount(
          version[0], account["username"]);
      isRequestPending = false;
      if (addResponse['isError']) return addResponse;

      return {
        "isError": false,
        "message": "Camera added successfully",
        "cameraId": version[0]
      };
    } catch (e) {
      isRequestPending = false;
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> addCameraWithSerialNumber(
      String cameraId, String cameraType) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called addCameraWithSerialNumber()"
      };
    }
    try {
      isRequestPending = true;
      final apiResponse = await apiService.fetchMasterAccount();
      if (apiResponse['isError']) {
        isRequestPending = false;
        return apiResponse;
      }

      final account = apiResponse["account"];

      await methodChannel.invokeMethod('LOGIN', {
        "userName": account["username"],
        "password": account["password"],
      });

      final version =
          await methodChannel.invokeMethod('ADD_CAMERA_THROUGH_SERIAL_NUMBER', {
        "cameraId": cameraId,
        "cameraType": cameraType,
      });

      final addResponse = await apiService.addDeviceToMasterAccount(
          version[0], account["username"]);
      isRequestPending = false;
      if (addResponse['isError']) return addResponse;

      return {
        "isError": false,
        "message": "Camera added successfully",
        "cameraId": version[0]
      };
    } catch (e) {
      isRequestPending = false;

      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> getUserInformation(String cameraId) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called getUserInformation()"
      };
    }
    try {
      isRequestPending = true;
      final apiResponse = await apiService.getDeviceMasterAccount(cameraId);
      if (apiResponse['isError']) return apiResponse;
      final account = apiResponse["account"];

      await methodChannel.invokeMethod('LOGIN', {
        "userName": account["username"],
        "password": account["password"],
      });

      final va = await methodChannel.invokeMethod('GET_USER_INFO');
      Map<String, dynamic> jsonData = json.decode(va[0]);

      return {
        "isError": false,
        "details": jsonData["data"],
      };
    } catch (e) {
      isRequestPending = false;
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> getCameraName() async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called getCameraName()"
      };
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      final data = await methodChannel
          .invokeMethod('GET_CAMERA_NAME', {"cameraId": initializedCamera});
      isRequestPending = false;

      return {"isError": false, "details": data[0]};
    } catch (e) {
      isRequestPending = false;

      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> setCameraName(String newName) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called setCameraName()"
      };
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      await methodChannel.invokeMethod('SET_CAMERA_NAME', {
        "cameraId": initializedCamera,
        "newName": newName,
      });
      isRequestPending = false;

      return {"isError": false};
    } catch (e) {
      isRequestPending = false;

      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> addPresetPoint(int presetId) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called addPresetPoint()"
      };
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      await methodChannel.invokeMethod('ADD_PRESET',
          {"cameraId": initializedCamera, "presetId": presetId, "chnNo": 1});
      isRequestPending = false;

      return {"isError": false};
    } catch (e) {
      isRequestPending = false;

      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> turnToPreset(int presetId) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called turnToPreset()"
      };
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      await methodChannel.invokeMethod('TURN_TO_PRESET',
          {"cameraId": initializedCamera, "presetId": presetId, "chnNo": 1});
      isRequestPending = false;

      return {"isError": false};
    } catch (e) {
      isRequestPending = false;

      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> getConfiguration(String type) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called getConfiguration($type)"
      };
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      List data = await methodChannel.invokeMethod('GET_CONFIG', {
        "cameraId": initializedCamera,
        "type": type,
      });
      isRequestPending = false;
      return {"isError": false, "details": data[0]};
    } catch (e) {
      isRequestPending = false;

      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> setConfiguration(
      String type, String newConfig) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called setConfiguration($type)"
      };
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      await methodChannel.invokeMethod('SET_CONFIG', {
        "cameraId": initializedCamera,
        "type": type,
        "newConfig": newConfig,
      });
      isRequestPending = false;

      return {"isError": false};
    } catch (e) {
      isRequestPending = false;

      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> getWifiInfo() async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called getWifiInfo()"
      };
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      List data = await methodChannel
          .invokeMethod('GET_WIFI_SIGNAL', {"cameraId": initializedCamera});
      isRequestPending = false;

      return {"isError": false, "details": data[0]};
    } catch (e) {
      isRequestPending = false;

      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> getBatteryPercentage() async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called getBatteryPercentage()"
      };
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      List data = await methodChannel.invokeMethod(
          'GET_BATTERY_PERCENTAGE', {"cameraId": initializedCamera});
      isRequestPending = false;

      return {"isError": false, "details": data[0]};
    } catch (e) {
      isRequestPending = false;

      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> cameraLogin(String cameraId) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called cameraLogin()"
      };
    }
    try {
      isRequestPending = true;
      final apiResponse = await apiService.getDeviceMasterAccount(cameraId);
      if (apiResponse['isError']) return apiResponse;
      final account = apiResponse["account"];

      await methodChannel.invokeMethod('LOGIN', {
        "userName": account["username"],
        "password": account["password"],
      });

      await methodChannel.invokeMethod('CAMERA_LOGIN', {"cameraId": cameraId});
      initializedCamera = cameraId;
      isRequestPending = false;
      isUserLogged = true;

      return {
        "isError": false,
        "message": "Camera Logged in",
      };
    } catch (e) {
      isRequestPending = false;
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> setDeviceAlarmCallback(
      String callbackUrl, String? cameraId) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called setDeviceAlarmCallback()"
      };
    }
    try {
      if (initializedCamera.isEmpty && cameraId == null) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      final apiResponse = await apiService.setDeviceAlarmCallback(
          cameraId ?? initializedCamera, callbackUrl);
      isRequestPending = false;

      if (apiResponse['isError']) return apiResponse;

      return {
        "isError": false,
        "message": "Callback set successful",
      };
    } catch (e) {
      isRequestPending = false;

      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> cameraState(String cameraId) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called cameraState()"
      };
    }

    isRequestPending = true;

    if (!isUserLogged || initializedCamera != cameraId) {
      final apiResponse = await apiService.getDeviceMasterAccount(cameraId);
      if (apiResponse['isError']) {
        isRequestPending = false;
        return apiResponse;
      }
      final account = apiResponse["account"];
      if (tempUsername != account["username"]) {
        await methodChannel.invokeMethod('LOGIN', {
          "userName": account["username"],
          "password": account["password"],
        });
      }
      isUserLogged = true;
      tempUsername = account["username"];
      tempPassword = account["password"];
      tempCameraId = cameraId;
    }

    final state = await methodChannel
        .invokeMethod('GET_CAMERA_STATE', {"cameraId": cameraId});
    isRequestPending = false;

    if (state[0] == 0) return {"isError": false, "state": "OFF_LINE"};
    if (state[0] == 1) return {"isError": false, "state": "ON_LINE"};
    if (state[0] == 2) return {"isError": false, "state": "SLEEP"};
    if (state[0] == 3) return {"isError": false, "state": "WAKE_UP"};
    if (state[0] == 4) return {"isError": false, "state": "WAKE"};
    if (state[0] == 5) return {"isError": false, "state": "SLEEP_UNWAKE"};
    if (state[0] == 6) return {"isError": false, "state": "PREPARE_SLEEP"};

    return {"isError": true, "message": "PREPARE_SLEEP"};
  }

  @override
  Future<Map<String, dynamic>> setHumanDetection(bool isEnabled) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called setHumanDetection()"
      };
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      await methodChannel.invokeMethod('SET_HUMAN_DETECTION',
          {"cameraId": initializedCamera, "isEnabled": isEnabled});
      isRequestPending = false;

      return {"isError": false};
    } catch (e) {
      isRequestPending = false;

      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> setRecordType(String type) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called setRecordType()"
      };
    }
    if (type != "ALWAYS" && type != "NEVER" && type != "ALARM") {
      return {"error": true, "message": "Invalid record type [$type]"};
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      await methodChannel.invokeMethod(
          'SET_RECORD_TYPE', {"cameraId": initializedCamera, "type": type});
      isRequestPending = false;

      return {"isError": false};
    } catch (e) {
      isRequestPending = false;
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> cameraStream(bool isShowStream) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called cameraStream()"
      };
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }
      isRequestPending = true;

      if (isShowStream) {
        await methodChannel
            .invokeMethod('LIVE_STREAM', {"cameraId": initializedCamera});
        isRequestPending = false;

        return {
          "isError": false,
          "message": isShowStream ? "Started Streaming!" : "Stopped Streaming!"
        };
      } else {
        methodChannel.invokeMethod('STOP_STREAM');
        isRequestPending = false;
        return {
          "isError": false,
          "message": isShowStream ? "Started Streaming!" : "Stopped Streaming!"
        };
      }
    } catch (e) {
      isRequestPending = false;
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Map<String, dynamic> cameraAudio(bool audioState) {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called cameraAudio()"
      };
    }
    if (initializedCamera.isEmpty) {
      return {"isError": true, "message": "Invalid camera operation!"};
    }

    isRequestPending = true;
    if (audioState) {
      methodChannel.invokeMethod('START_AUDIO');
    } else {
      methodChannel.invokeMethod('STOP_AUDIO');
    }
    isRequestPending = false;

    return {
      "isError": false,
      "message": audioState ? "Enabled camera audio!" : "Disabled camera audio!"
    };
  }

  @override
  Map<String, dynamic> interCommunication(bool isStart, bool isSingleChannel) {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called interCommunication()"
      };
    }
    if (initializedCamera.isEmpty) {
      return {"isError": true, "message": "Invalid camera operation!"};
    }

    if (isSingleChannel) {
      if (isDualInterComStarted) {
        methodChannel.invokeMethod(
            'DUAL_INTERCOM_STOP', {"cameraId": initializedCamera});
      }

      if (isStart) {
        isSingleInterComStarted = true;
        methodChannel.invokeMethod(
            'SINGLE_INTERCOM_START', {"cameraId": initializedCamera});
      } else {
        isSingleInterComStarted = false;
        methodChannel.invokeMethod(
            'SINGLE_INTERCOM_STOP', {"cameraId": initializedCamera});
      }
    } else {
      if (isDualInterComStarted) {
        methodChannel.invokeMethod(
            'SINGLE_INTERCOM_STOP', {"cameraId": initializedCamera});
      }

      if (isStart) {
        isDualInterComStarted = true;
        methodChannel.invokeMethod(
            'DUAL_INTERCOM_START', {"cameraId": initializedCamera});
      } else {
        isDualInterComStarted = false;
        methodChannel.invokeMethod(
            'DUAL_INTERCOM_STOP', {"cameraId": initializedCamera});
      }
    }

    return {
      "isError": false,
      "message": isStart
          ? "Enabled InterCommunication!"
          : "Disabled InterCommunication!"
    };
  }

  @override
  Map<String, dynamic> captureImageSaveLocal() {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called captureImageSaveLocal()"
      };
    }
    if (initializedCamera.isEmpty) {
      return {"isError": true, "message": "Invalid camera operation!"};
    }

    methodChannel.invokeMethod('CAPTURE_IMG', {"cameraId": initializedCamera});

    return {"isError": false, "message": "Saved to your local device"};
  }

  @override
  Map<String, dynamic> videoRecordAndSaveLocal(bool isStart) {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called videoRecordAndSaveLocal()"
      };
    }
    if (initializedCamera.isEmpty) {
      return {"isError": true, "message": "Invalid camera operation!"};
    }
    if (isStart) {
      methodChannel.invokeMethod('START_RECORDING');
    } else {
      methodChannel.invokeMethod('STOP_RECORDING');
    }

    return {
      "isError": false,
      "message":
          isStart ? "Recording started" : "Recording save to your local device"
    };
  }

  @override
  Future<Map<String, dynamic>> imageListInCamera() async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called imageListInCamera()"
      };
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Invalid camera operation!"};
      }
      isRequestPending = true;

      List dataList = await methodChannel
          .invokeMethod('IMAGE_LIST', {"cameraId": initializedCamera});
      isRequestPending = false;

      String arrayString = dataList[0];
      List<String> elements = arrayString.split('H264_DVR_FILE_DATA ');
      elements.removeAt(0);

      List<String> result = [];
      for (String element in elements) {
        int startIndex =
            element.indexOf("st_2_fileName=") + "st_2_fileName=".length;
        int endIndex = element.indexOf(", st_3_beginTime=");

        result.add(
            (element.substring(startIndex, endIndex)).replaceAll('/', '_'));
      }

      return {"isError": false, "dataList": result};
    } catch (e) {
      isRequestPending = false;
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> imageDownloadFromCamera(position) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called imageDownloadFromCamera()"
      };
    }
    if (initializedCamera.isEmpty) {
      return {"isError": true, "message": "Invalid camera operation!"};
    }
    isRequestPending = true;

    List dataList = await methodChannel
        .invokeMethod('IMAGE_SAVE_LOCAL', {"position": position});

    isRequestPending = false;
    return {
      "isError": false,
      "dataList": dataList,
      "message": "Saved to your local device"
    };
  }

  @override
  Future<Map<String, dynamic>> playbackList(
    String fromDate,
    String fromMonth,
    String fromYear,
    String toDate,
    String toMonth,
    String toYear,
  ) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called playbackList()"
      };
    }
    try {
      DateTime currentDate = DateTime.now();
      DateTime pickedDate = DateTime(
          int.parse(fromYear), int.parse(fromMonth), int.parse(fromDate));

      if (pickedDate.isAfter(currentDate)) {
        return {
          "isError": true,
          "message": "Date selected must be less than or equal to today"
        };
      }

      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Invalid camera operation!"};
      }

      isRequestPending = true;
      List dataList = await methodChannel.invokeMethod('PLAYBACK_LIST', {
        "cameraId": initializedCamera,
        "fromDate": fromDate,
        "fromMonth": fromMonth,
        "fromYear": fromYear,
        "toDate": toDate,
        "toMonth": toMonth,
        "toYear": toYear,
      });
      isRequestPending = false;

      return {"isError": false, "dataList": dataList};
    } catch (e) {
      isRequestPending = false;
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> playFromPosition(position) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called playFromPosition()"
      };
    }
    isPlaybackStarted = true;
    if (initializedCamera.isEmpty) {
      return {"isError": true, "message": "Invalid camera operation!"};
    }
    isRequestPending = true;

    await methodChannel
        .invokeMethod('PLAY_FROM_POSITION', {"position": position});
    isRequestPending = false;

    return {"isError": false};
  }

  @override
  Future<Map<String, dynamic>> downloadFromPosition(position) async {
    if (isRequestPending) {
      return {
        "isError": true,
        "message": "PENDING_PREVIOUS_REQUEST",
        "details": "Called downloadFromPosition()"
      };
    }
    try {
      isPlaybackStarted = true;
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Invalid camera operation!"};
      }

      isRequestPending = true;
      await methodChannel.invokeMethod('DOWNLOAD_FROM_POSITION',
          {"position": position, "cameraId": initializedCamera});
      isRequestPending = false;

      return {"isError": false};
    } catch (e) {
      isRequestPending = false;
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Map<String, dynamic> pausePlayBack() {
    methodChannel.invokeMethod('PB_PAUSE');
    return {"isError": false};
  }

  @override
  Map<String, dynamic> rePlayPlayBack() {
    methodChannel.invokeMethod('PB_PLAY');
    return {"isError": false};
  }

  @override
  Map<String, dynamic> skipPlayBack(int skipTime) {
    methodChannel.invokeMethod('PB_SKIP_TIME', {"skipTime": skipTime});
    return {"isError": false};
  }

  @override
  Map<String, dynamic> openAudioPlayBack() {
    methodChannel.invokeMethod('PB_OPEN_SOUND');
    return {"isError": false};
  }

  @override
  Map<String, dynamic> closeAudioPlayBack() {
    methodChannel.invokeMethod('PB_CLOSE_SOUND');
    return {"isError": false};
  }

  @override
  Map<String, dynamic> captureImageFromPlayBack() {
    methodChannel.invokeMethod('PB_CAPTURE_SAVE_LOCAL');
    return {"isError": false};
  }

  @override
  Map<String, dynamic> cameraMovement(double x, double y) {
    if (initializedCamera.isEmpty) {
      return {"isError": true, "message": "Invalid camera operation!"};
    }

    if (x == 0 && y == 0) {
      sendPTZControlCmd(1, true, initializedCamera);
      return {"isError": false};
    }

    double angle = atan2(y, x);
    double degrees = angle * (180 / pi);

    if (degrees >= -22.5 && degrees < 22.5) {
      sendPTZControlCmd(PTZConstants.panLeft, false, initializedCamera);
    } else if (degrees >= 22.5 && degrees < 67.5) {
      sendPTZControlCmd(PTZConstants.panLeftDown, false, initializedCamera);
    } else if (degrees >= 67.5 && degrees < 112.5) {
      sendPTZControlCmd(PTZConstants.tiltDown, false, initializedCamera);
    } else if (degrees >= 112.5 && degrees < 157.5) {
      sendPTZControlCmd(PTZConstants.panRightDown, false, initializedCamera);
    } else if (degrees >= 157.5 || degrees < -157.5) {
      sendPTZControlCmd(PTZConstants.panRight, false, initializedCamera);
    } else if (degrees >= -157.5 && degrees < -112.5) {
      sendPTZControlCmd(PTZConstants.panRightTop, false, initializedCamera);
    } else if (degrees >= -112.5 && degrees < -67.5) {
      sendPTZControlCmd(PTZConstants.tiltUp, false, initializedCamera);
    } else if (degrees >= -67.5 && degrees < -22.5) {
      sendPTZControlCmd(PTZConstants.panLeftTop, false, initializedCamera);
    } else {
      sendPTZControlCmd(1, true, initializedCamera);
      return {"isError": false};
    }

    return {"isError": false};
  }

  void sendPTZControlCmd(int cmd, bool isStop, String cameraId) async {
    await methodChannel.invokeMethod("PTZ_CONTROL", {
      "cameraId": cameraId,
      "cmd": cmd,
      "isStop": isStop ? isStop : false,
    });
  }
}

class PTZConstants {
  static const int tiltUp = 0; // on
  static const int tiltDown = 1; // down
  static const int panLeft = 2; // Left
  static const int panRight = 3; // Right
  static const int panLeftTop = 4; // Upper left
  static const int panLeftDown = 5; // Lower left
  static const int panRightTop = 6; // Top right
  static const int panRightDown = 7; // Lower right
}
