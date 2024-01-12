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

  @visibleForTesting
  final methodChannel = const MethodChannel('dom_camera');

  @override
  Future<Map<String, dynamic>> iosNetworkPermission() async {
    if (Platform.isIOS) {
      List result = await methodChannel.invokeMethod('WIFI_PERMISSION');

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
    try {
      final apiResponse = await apiService.fetchMasterAccount();
      if (apiResponse['isError']) return apiResponse;

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
      if (addResponse['isError']) return addResponse;

      return {
        "isError": false,
        "message": "Camera added successfully",
        "cameraId": version[0]
      };
    } catch (e) {
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> cameraLogin(String cameraId) async {
    try {
      final apiResponse = await apiService.getDeviceMasterAccount(cameraId);
      if (apiResponse['isError']) return apiResponse;
      final account = apiResponse["account"];

      await methodChannel.invokeMethod('LOGIN', {
        "userName": account["username"],
        "password": account["password"],
      });

      await methodChannel.invokeMethod('CAMERA_LOGIN', {"cameraId": cameraId});
      initializedCamera = cameraId;
      isUserLogged = true;

      return {
        "isError": false,
        "message": "Camera Logged in",
      };
    } catch (e) {
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> setDeviceAlarmCallback(
      String callbackUrl, String? cameraId) async {
    try {
      if (initializedCamera.isEmpty && cameraId == null) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }

      final apiResponse = await apiService.setDeviceAlarmCallback(
          cameraId ?? initializedCamera, callbackUrl);
      if (apiResponse['isError']) return apiResponse;

      return {
        "isError": false,
        "message": "Callback set successful",
      };
    } catch (e) {
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> cameraState(String cameraId) async {
    if (!isUserLogged || initializedCamera != cameraId) {
      final apiResponse = await apiService.getDeviceMasterAccount(cameraId);
      if (apiResponse['isError']) return apiResponse;
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
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }

      await methodChannel.invokeMethod('SET_HUMAN_DETECTION',
          {"cameraId": initializedCamera, "isEnabled": isEnabled});

      return {"isError": false};
    } catch (e) {
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> setRecordType(String type) async {
    if (type != "ALWAYS" && type != "NEVER" && type != "ALARM") {
      return {"error": true, "message": "Invalid record type [$type]"};
    }
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }

      await methodChannel.invokeMethod(
          'SET_RECORD_TYPE', {"cameraId": initializedCamera, "type": type});

      return {"isError": false};
    } catch (e) {
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> cameraStream(bool isShowStream) async {
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Please Login to Camera!"};
      }

      if (isShowStream) {
        await methodChannel
            .invokeMethod('LIVE_STREAM', {"cameraId": initializedCamera});
        return {
          "isError": false,
          "message": isShowStream ? "Started Streaming!" : "Stopped Streaming!"
        };
      } else {
        methodChannel.invokeMethod('STOP_STREAM');
        return {
          "isError": false,
          "message": isShowStream ? "Started Streaming!" : "Stopped Streaming!"
        };
      }
    } catch (e) {
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Map<String, dynamic> cameraAudio(bool audioState) {
    if (initializedCamera.isEmpty) {
      return {"isError": true, "message": "Invalid camera operation!"};
    }

    if (audioState) {
      methodChannel.invokeMethod('START_AUDIO');
    } else {
      methodChannel.invokeMethod('STOP_AUDIO');
    }

    return {
      "isError": false,
      "message": audioState ? "Enabled camera audio!" : "Disabled camera audio!"
    };
  }

  @override
  Map<String, dynamic> interCommunication(bool isStart, bool isSingleChannel) {
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
    if (initializedCamera.isEmpty) {
      return {"isError": true, "message": "Invalid camera operation!"};
    }

    methodChannel.invokeMethod('CAPTURE_IMG', {"cameraId": initializedCamera});

    return {"isError": false, "message": "Saved to your local device"};
  }

  @override
  Map<String, dynamic> videoRecordAndSaveLocal(bool isStart) {
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
    try {
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Invalid camera operation!"};
      }

      List dataList = await methodChannel
          .invokeMethod('IMAGE_LIST', {"cameraId": initializedCamera});

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
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> imageDownloadFromCamera(position) async {
    if (initializedCamera.isEmpty) {
      return {"isError": true, "message": "Invalid camera operation!"};
    }

    List dataList = await methodChannel
        .invokeMethod('IMAGE_SAVE_LOCAL', {"position": position});

    return {
      "isError": false,
      "dataList": dataList,
      "message": "Saved to your local device"
    };
  }

  @override
  Future<Map<String, dynamic>> playbackList(
      String date, String month, String year) async {
    try {
      DateTime currentDate = DateTime.now();
      DateTime pickedDate =
          DateTime(int.parse(year), int.parse(month), int.parse(date));

      if (pickedDate.isAfter(currentDate)) {
        return {
          "isError": true,
          "message": "Date selected must be less than or equal to today"
        };
      }

      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Invalid camera operation!"};
      }

      List dataList = await methodChannel.invokeMethod('PLAYBACK_LIST', {
        "cameraId": initializedCamera,
        "date": date,
        "month": month,
        "year": year
      });

      return {"isError": false, "dataList": dataList};
    } catch (e) {
      if (e is PlatformException) {
        return {"isError": true, "message": e.message};
      }

      return {"isError": true, "message": "Error: $e"};
    }
  }

  @override
  Future<Map<String, dynamic>> playFromPosition(position) async {
    isPlaybackStarted = true;
    if (initializedCamera.isEmpty) {
      return {"isError": true, "message": "Invalid camera operation!"};
    }

    await methodChannel
        .invokeMethod('PLAY_FROM_POSITION', {"position": position});

    return {"isError": false};
  }

  @override
  Future<Map<String, dynamic>> downloadFromPosition(position) async {
    try {
      isPlaybackStarted = true;
      if (initializedCamera.isEmpty) {
        return {"isError": true, "message": "Invalid camera operation!"};
      }

      await methodChannel.invokeMethod('DOWNLOAD_FROM_POSITION',
          {"position": position, "cameraId": initializedCamera});

      return {"isError": false};
    } catch (e) {
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
