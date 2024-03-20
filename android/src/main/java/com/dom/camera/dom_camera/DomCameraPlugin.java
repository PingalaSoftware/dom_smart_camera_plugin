package com.dom.camera.dom_camera;

import static com.dom.camera.dom_camera.UserClass.deviceManager;
import static com.dom.camera.dom_camera.UserClass.manager;

import android.content.Context;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import com.dom.camera.dom_camera.liveStream.CustomViewFactor;
import com.dom.camera.dom_camera.utils.MethodName;
import com.example.camera_sdk.videoPlayback.PlayBackFactory;
import com.lib.MsgContent;
import com.manager.XMFunSDKManager;
import com.manager.account.BaseAccountManager;
import com.manager.device.DeviceManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import org.json.JSONObject;

public class DomCameraPlugin
  implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

  private MethodChannel channel;
  private EventChannel eventChannel;
  private Context applicationContext;

  String cameraId;
  String userName;
  String password;
  String ssid;
  int position;

  private HashMap<String, Result> methodResults = new HashMap<>();

  private ViewGroup viewCameraActivity;
  private ViewGroup playBackView;
  private EventSink eventSink;

  private void storeResult(String methodName, @NonNull Result result) {
    methodResults.put(methodName, result);
  }

  private Result getResultAndClear(String methodName) {
    Result result = methodResults.get(methodName);
    methodResults.remove(methodName);
    return result;
  }

  private boolean isResultAvailable(String methodName) {
    return methodResults.containsKey(methodName);
  }

  @Override
  public void onAttachedToEngine(
    @NonNull FlutterPluginBinding flutterPluginBinding
  ) {
    Context applicationContext = flutterPluginBinding.getApplicationContext();
    this.applicationContext = applicationContext;

    this.viewCameraActivity =
      (ViewGroup) LayoutInflater
        .from(applicationContext)
        .inflate(R.layout.camera_activity, null);
    this.playBackView =
      (ViewGroup) LayoutInflater
        .from(applicationContext)
        .inflate(R.layout.video_play_back, null);

    flutterPluginBinding
      .getPlatformViewRegistry()
      .registerViewFactory(
        "dom_camera_stream",
        new CustomViewFactor(viewCameraActivity)
      );

    flutterPluginBinding
      .getPlatformViewRegistry()
      .registerViewFactory(
        "dom_video_playback",
        new PlayBackFactory(playBackView)
      );

    XMFunSDKManager.getInstance().initXMCloudPlatform(applicationContext);
    XMFunSDKManager.getInstance().initLog();

    eventChannel =
      new EventChannel(
        flutterPluginBinding.getBinaryMessenger(),
        "dom_camera/playbackListener"
      );
    eventChannel.setStreamHandler(this);

    channel =
      new MethodChannel(
        flutterPluginBinding.getBinaryMessenger(),
        "dom_camera"
      );
    channel.setMethodCallHandler(this);
  }

  public void onListen(Object arguments, EventSink events) {
    this.eventSink = events;
  }

  public void onCancel(Object arguments) {
    this.eventSink = null;
  }

  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    MethodName methodName = MethodName.valueOf(call.method.toUpperCase());

    switch (methodName) {
      case LOGIN:
        if (isResultAvailable("LOGIN")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("LOGIN", result);

        userName = call.argument("userName");
        password = call.argument("password");

        UserClass.loginUser(
          userName,
          password,
          new BaseAccountManager.OnAccountManagerListener() {
            public void onSuccess(int i) {
              List<Object> list = new ArrayList<>();
              list.add(true);
              list.add(i);
              if (isResultAvailable("LOGIN")) {
                Result tempResult = getResultAndClear("LOGIN");
                tempResult.success(list);
              }
            }

            public void onFailed(int i, int errorId) {
              if (isResultAvailable("LOGIN")) {
                Result tempResult = getResultAndClear("LOGIN");
                tempResult.error("0", "Failed", errorId);
              }
            }

            @Override
            public void onFunSDKResult(
              Message message,
              MsgContent msgContent
            ) {}
          }
        );
        break;
      case GET_USER_INFO:
        if (isResultAvailable("GET_USER_INFO")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("GET_USER_INFO", result);
        UserClass.getUserInfo(
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("GET_USER_INFO")) {
                Result tempResult = getResultAndClear("GET_USER_INFO");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("GET_USER_INFO")) {
                Result tempResult = getResultAndClear("GET_USER_INFO");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case ADD_CAMERA_THROUGH_SERIAL_NUMBER:
        if (isResultAvailable("ADD_CAMERA_THROUGH_SERIAL_NUMBER")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("ADD_CAMERA_THROUGH_SERIAL_NUMBER", result);

        cameraId = call.argument("cameraId");
        String cameraType = call.argument("cameraType");

        UserClass.addDev(
          cameraId,
          cameraType,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("ADD_CAMERA_THROUGH_SERIAL_NUMBER")) {
                Result tempResult = getResultAndClear(
                  "ADD_CAMERA_THROUGH_SERIAL_NUMBER"
                );
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("ADD_CAMERA_THROUGH_SERIAL_NUMBER")) {
                Result tempResult = getResultAndClear(
                  "ADD_CAMERA_THROUGH_SERIAL_NUMBER"
                );
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case ADD_CAMERA_THROUGH_WIFI:
        if (isResultAvailable("ADD_CAMERA_THROUGH_WIFI")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("ADD_CAMERA_THROUGH_WIFI", result);

        ssid = call.argument("ssid");
        password = call.argument("password");

        UserClass.addDeviceThroughWifi(
          ssid,
          password,
          this.applicationContext,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List dataList) {
              if (isResultAvailable("ADD_CAMERA_THROUGH_WIFI")) {
                Result tempResult = getResultAndClear(
                  "ADD_CAMERA_THROUGH_WIFI"
                );
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("ADD_CAMERA_THROUGH_WIFI")) {
                Result tempResult = getResultAndClear(
                  "ADD_CAMERA_THROUGH_WIFI"
                );
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case GET_CAMERA_STATE:
        cameraId = call.argument("cameraId");
        if (isResultAvailable("GET_CAMERA_STATE" + cameraId)) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("GET_CAMERA_STATE" + cameraId, result);

        DeviceClass.cameraLoginState(
          cameraId,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("GET_CAMERA_STATE" + cameraId)) {
                Result tempResult = getResultAndClear(
                  "GET_CAMERA_STATE" + cameraId
                );
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("GET_CAMERA_STATE" + cameraId)) {
                Result tempResult = getResultAndClear(
                  "GET_CAMERA_STATE" + cameraId
                );
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case CAMERA_LOGIN:
        if (isResultAvailable("CAMERA_LOGIN")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("CAMERA_LOGIN", result);

        cameraId = call.argument("cameraId");

        DeviceClass.cameraLogin(
          cameraId,
          new DeviceManager.OnDevManagerListener() {
            public void onSuccess(String devId, int operationType, Object o) {
              List<Object> list = new ArrayList<>();
              list.add(true);
              UserClass.initPresetManager(
                cameraId,
                new UserClass.PresetOperationCallback() {
                  public void onPresetOperationSuccess() {
                    System.out.println("init preset manager success");
                  }

                  public void onPresetOperationFailed(
                    String errorCode,
                    String errorMessage
                  ) {
                    System.out.println("init preset manager failed");
                  }
                }
              );
              if (isResultAvailable("CAMERA_LOGIN")) {
                Result tempResult = getResultAndClear("CAMERA_LOGIN");
                tempResult.success(list);
              }
            }

            public void onFailed(
              String devId,
              int msgId,
              String jsonName,
              int i1
            ) {
              if (devId == "0" && msgId == 0 && jsonName == "0" && i1 == 0) {
                if (isResultAvailable("CAMERA_LOGIN")) {
                  Result tempResult = getResultAndClear("CAMERA_LOGIN");
                  tempResult.error(
                    "0",
                    "Please reset the camera and try again",
                    null
                  );
                }
              } else {
                if (isResultAvailable("CAMERA_LOGIN")) {
                  Result tempResult = getResultAndClear("CAMERA_LOGIN");
                  tempResult.error("0", "Camera/Device is Offline", null);
                }
              }
            }
          }
        );
        break;
      case GET_CAMERA_NAME:
        cameraId = call.argument("cameraId");
        if (isResultAvailable("GET_CAMERA_NAME" + cameraId)) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("GET_CAMERA_NAME" + cameraId, result);

        DeviceClass.getCameraName(
          cameraId,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("GET_CAMERA_NAME" + cameraId)) {
                Result tempResult = getResultAndClear(
                  "GET_CAMERA_NAME" + cameraId
                );
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("GET_CAMERA_NAME" + cameraId)) {
                Result tempResult = getResultAndClear(
                  "GET_CAMERA_NAME" + cameraId
                );
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case ADD_PRESET:
        if (isResultAvailable("ADD_PRESET")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("ADD_PRESET", result);

        cameraId = call.argument("cameraId");
        int presetId = call.argument("presetId");
        int chnId = call.argument("chnNo");
        UserClass.addPreset(
          cameraId,
          presetId,
          chnId,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("ADD_PRESET")) {
                Result tempResult = getResultAndClear("ADD_PRESET");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("ADD_PRESET")) {
                Result tempResult = getResultAndClear("ADD_PRESET");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case TURN_TO_PRESET:
        if (isResultAvailable("TURN_TO_PRESET")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("TURN_TO_PRESET", result);

        cameraId = call.argument("cameraId");
        int turnToPresetId = call.argument("presetId");
        int chnNo = call.argument("chnNo");

        UserClass.turnToPreset(
          cameraId,
          turnToPresetId,
          chnNo,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("TURN_TO_PRESET")) {
                Result tempResult = getResultAndClear("TURN_TO_PRESET");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("TURN_TO_PRESET")) {
                Result tempResult = getResultAndClear("TURN_TO_PRESET");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case SET_CAMERA_NAME:
        if (isResultAvailable("SET_CAMERA_NAME")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("SET_CAMERA_NAME", result);

        cameraId = call.argument("cameraId");
        String newName = call.argument("newName");
        DeviceClass.setCameraName(
          cameraId,
          newName,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("SET_CAMERA_NAME")) {
                Result tempResult = getResultAndClear("SET_CAMERA_NAME");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("SET_CAMERA_NAME")) {
                Result tempResult = getResultAndClear("SET_CAMERA_NAME");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case STOP_STREAM:
        DeviceClass.stopStream();
        break;
      case IS_FULL_SCREEN_STREAMING:
        if (isResultAvailable("IS_FULL_SCREEN_STREAMING")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("IS_FULL_SCREEN_STREAMING", result);

        DeviceClass.isFullScreenStreaming(
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("IS_FULL_SCREEN_STREAMING")) {
                Result tempResult = getResultAndClear(
                  "IS_FULL_SCREEN_STREAMING"
                );
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("IS_FULL_SCREEN_STREAMING")) {
                Result tempResult = getResultAndClear(
                  "IS_FULL_SCREEN_STREAMING"
                );
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case SHOW_FULL_SCREEN:
        if (isResultAvailable("SHOW_FULL_SCREEN")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("SHOW_FULL_SCREEN", result);

        System.out.println("SHOW_FULL_SCREEN called");
        boolean isFullScreen = call.argument("isFullScreen");
        System.out.println("SHOW_FULL_SCREEN called: " + isFullScreen);

        DeviceClass.setVideoFullScreen(
          isFullScreen,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("SHOW_FULL_SCREEN")) {
                Result tempResult = getResultAndClear("SHOW_FULL_SCREEN");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("SHOW_FULL_SCREEN")) {
                Result tempResult = getResultAndClear("SHOW_FULL_SCREEN");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case LIVE_STREAM:
        if (isResultAvailable("LIVE_STREAM")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("LIVE_STREAM", result);

        cameraId = call.argument("cameraId");
        DeviceClass.liveStream(
          this.applicationContext,
          cameraId,
          this.viewCameraActivity,
          new DeviceClass.myDomResultInterface() {
            @Override
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("LIVE_STREAM")) {
                Result tempResult = getResultAndClear("LIVE_STREAM");
                tempResult.success(dataList);
              }
            }

            @Override
            public void onFailed(String errorId, String message) {
              if (isResultAvailable("LIVE_STREAM")) {
                Result tempResult = getResultAndClear("LIVE_STREAM");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case SET_RECORD_TYPE:
        if (isResultAvailable("SET_RECORD_TYPE")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("SET_RECORD_TYPE", result);

        cameraId = call.argument("cameraId");
        String type = call.argument("type");
        DeviceClass.setRecordType(
          cameraId,
          type,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("SET_RECORD_TYPE")) {
                Result tempResult = getResultAndClear("SET_RECORD_TYPE");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("SET_RECORD_TYPE")) {
                Result tempResult = getResultAndClear("SET_RECORD_TYPE");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case GET_CONFIG:
        if (isResultAvailable("GET_CONFIG")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("GET_CONFIG", result);

        cameraId = call.argument("cameraId");
        String getType = call.argument("type");
        DeviceClass.getConfig(
          cameraId,
          getType,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("GET_CONFIG")) {
                Result tempResult = getResultAndClear("GET_CONFIG");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("GET_CONFIG")) {
                Result tempResult = getResultAndClear("GET_CONFIG");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case SET_CONFIG:
        if (isResultAvailable("SET_CONFIG")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("SET_CONFIG", result);

        cameraId = call.argument("cameraId");
        String setType = call.argument("type");
        String newConfig = call.argument("newConfig");
        DeviceClass.updateConfig(
          cameraId,
          setType,
          newConfig,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("SET_CONFIG")) {
                Result tempResult = getResultAndClear("SET_CONFIG");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("SET_CONFIG")) {
                Result tempResult = getResultAndClear("SET_CONFIG");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case GET_WIFI_SIGNAL:
        if (isResultAvailable("GET_WIFI_SIGNAL")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("GET_WIFI_SIGNAL", result);

        cameraId = call.argument("cameraId");

        DeviceClass.getDevWiFiSignalLevel(
          cameraId,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("GET_WIFI_SIGNAL")) {
                Result tempResult = getResultAndClear("GET_WIFI_SIGNAL");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("GET_WIFI_SIGNAL")) {
                Result tempResult = getResultAndClear("GET_WIFI_SIGNAL");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case GET_BATTERY_PERCENTAGE:
        if (isResultAvailable("GET_BATTERY_PERCENTAGE")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("GET_BATTERY_PERCENTAGE", result);

        cameraId = call.argument("cameraId");

        DeviceClass.getBatteryPercentage(
          cameraId,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("GET_BATTERY_PERCENTAGE")) {
                Result tempResult = getResultAndClear("GET_BATTERY_PERCENTAGE");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("GET_BATTERY_PERCENTAGE")) {
                Result tempResult = getResultAndClear("GET_BATTERY_PERCENTAGE");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case SET_HUMAN_DETECTION:
        if (isResultAvailable("SET_HUMAN_DETECTION")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("SET_HUMAN_DETECTION", result);

        cameraId = call.argument("cameraId");
        boolean isEnabled = call.argument("isEnabled");
        DeviceClass.HumanDetection(
          cameraId,
          isEnabled,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("SET_HUMAN_DETECTION")) {
                Result tempResult = getResultAndClear("SET_HUMAN_DETECTION");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("SET_HUMAN_DETECTION")) {
                Result tempResult = getResultAndClear("SET_HUMAN_DETECTION");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case START_AUDIO:
        DeviceClass.openVoice();
        break;
      case STOP_AUDIO:
        DeviceClass.closeVoice();
        break;
      case SINGLE_INTERCOM_START:
        DeviceClass.startSingleIntercomAndSpeak(this.applicationContext);
        break;
      case SINGLE_INTERCOM_STOP:
        DeviceClass.stopSingleIntercomAndHear();
        break;
      case DUAL_INTERCOM_START:
        DeviceClass.startDoubleIntercom(this.applicationContext);
        break;
      case DUAL_INTERCOM_STOP:
        DeviceClass.stopIntercom();
        break;
      case CAPTURE_IMG:
        DeviceClass.capture(this.applicationContext);
        break;
      case START_RECORDING:
        DeviceClass.startRecord();
        break;
      case STOP_RECORDING:
        DeviceClass.stopRecord();
        break;
      case PTZ_CONTROL:
        cameraId = call.argument("cameraId");
        int cmd = call.argument("cmd");
        boolean isStop = call.argument("isStop");
        DeviceClass.ptzControl(cameraId, cmd, isStop);
        break;
      case IMAGE_LIST:
        if (isResultAvailable("IMAGE_LIST")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("IMAGE_LIST", result);

        String cameraId = call.argument("cameraId");
        new ImageList(
          cameraId,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("IMAGE_LIST")) {
                Result tempResult = getResultAndClear("IMAGE_LIST");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("IMAGE_LIST")) {
                Result tempResult = getResultAndClear("IMAGE_LIST");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );

        break;
      case IMAGE_SAVE_LOCAL:
        if (isResultAvailable("IMAGE_SAVE_LOCAL")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("IMAGE_SAVE_LOCAL", result);

        position = call.argument("position");
        ImageList.downloadFile(
          position,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("IMAGE_SAVE_LOCAL")) {
                Result tempResult = getResultAndClear("IMAGE_SAVE_LOCAL");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("IMAGE_SAVE_LOCAL")) {
                Result tempResult = getResultAndClear("IMAGE_SAVE_LOCAL");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case PLAYBACK_LIST:
        if (isResultAvailable("PLAYBACK_LIST")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("PLAYBACK_LIST", result);

        cameraId = call.argument("cameraId");
        String fromDate = call.argument("fromDate");
        String fromMonth = call.argument("fromMonth");
        String fromYear = call.argument("fromYear");
        String toDate = call.argument("toDate");
        String toMonth = call.argument("toMonth");
        String toYear = call.argument("toYear");

        new PlayBackClass(
          cameraId,
          playBackView,
          fromDate,
          fromMonth,
          fromYear,
          toDate,
          toMonth,
          toYear,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("PLAYBACK_LIST")) {
                Result tempResult = getResultAndClear("PLAYBACK_LIST");
                tempResult.success(dataList);
              }
            }

            @Override
            public void onFailed(String errorId, String message) {
              if (isResultAvailable("PLAYBACK_LIST")) {
                Result tempResult = getResultAndClear("PLAYBACK_LIST");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case STOP_PLAY_BACK:
        PlayBackClass.stopPlayBack();
        break;
      case PLAY_FROM_POSITION:
        //        if (isResultAvailable("PLAY_FROM_POSITION")) {
        //          result.error("0", "Request is in progress", null);
        //          break;
        //        }
        storeResult("PLAY_FROM_POSITION", result);

        position = call.argument("position");
        PlayBackClass.startPlayRecord(
          position,
          eventSink,
          new DeviceClass.myDomResultInterface() {
            @Override
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("PLAY_FROM_POSITION")) {
                Result tempResult = getResultAndClear("PLAY_FROM_POSITION");
                tempResult.success(dataList);
              }
            }

            @Override
            public void onFailed(String errorId, String message) {
              if (isResultAvailable("PLAY_FROM_POSITION")) {
                Result tempResult = getResultAndClear("PLAY_FROM_POSITION");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case DOWNLOAD_FROM_POSITION:
        if (isResultAvailable("DOWNLOAD_FROM_POSITION")) {
          result.error("0", "Request is in progress", null);
          break;
        }
        storeResult("DOWNLOAD_FROM_POSITION", result);

        position = call.argument("position");
        cameraId = call.argument("cameraId");

        PlayBackClass.downloadVideoFile(
          position,
          cameraId,
          eventSink,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              if (isResultAvailable("DOWNLOAD_FROM_POSITION")) {
                Result tempResult = getResultAndClear("DOWNLOAD_FROM_POSITION");
                tempResult.success(dataList);
              }
            }

            public void onFailed(String errorId, String message) {
              if (isResultAvailable("DOWNLOAD_FROM_POSITION")) {
                Result tempResult = getResultAndClear("DOWNLOAD_FROM_POSITION");
                tempResult.error(errorId, message, null);
              }
            }
          }
        );
        break;
      case PB_PAUSE:
        PlayBackClass.pausePlayPlayback();
        break;
      case PB_PLAY:
        PlayBackClass.rePlayPlayback();
        break;
      case PB_SKIP_TIME:
        int skipTime = call.argument("skipTime");
        PlayBackClass.seekToTime(
          skipTime,
          new DeviceClass.myDomResultInterface() {
            @Override
            public void onSuccess(List<String> dataList) {
              result.success(dataList);
            }

            @Override
            public void onFailed(String errorId, String message) {
              result.error(errorId, message, null);
            }
          }
        );
        break;
      case PB_OPEN_SOUND:
        PlayBackClass.openVoiceBySoundPlayback();
        break;
      case PB_CLOSE_SOUND:
        PlayBackClass.closeVoiceBySoundPlayback();
        break;
      case PB_CAPTURE_SAVE_LOCAL:
        PlayBackClass.captureImagePlayback();
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
