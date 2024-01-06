package com.dom.camera.dom_camera;

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
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.ArrayList;
import java.util.List;

public class DomCameraPlugin implements FlutterPlugin, MethodCallHandler {

  private MethodChannel channel;
  private Context applicationContext;

  String cameraId;
  String userName;
  String password;
  String ssid;
  int position;

  private ViewGroup viewCameraActivity;
  private ViewGroup playBackView;

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

    channel =
      new MethodChannel(
        flutterPluginBinding.getBinaryMessenger(),
        "dom_camera"
      );
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    MethodName methodName = MethodName.valueOf(call.method.toUpperCase());

    switch (methodName) {
      case LOGIN:
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
              result.success(list);
            }

            public void onFailed(int i, int errorId) {
              result.error("0", "Failed", errorId);
            }

            @Override
            public void onFunSDKResult(
              Message message,
              MsgContent msgContent
            ) {}
          }
        );
        break;
      case GET_CAMERA_STATE:
        cameraId = call.argument("cameraId");
        int data = UserClass.getCameraState(cameraId);

        List<Integer> list = new ArrayList<Integer>(data);
        list.add(data);
        break;
      case ADD_CAMERA_THROUGH_WIFI:
        ssid = call.argument("ssid");
        password = call.argument("password");

        UserClass.addDeviceThroughWifi(
          ssid,
          password,
          this.applicationContext,
          new DeviceClass.myDomResultInterface() {
            public void onFailed(String errorId, String message) {
              result.error(errorId, message, null);
            }

            public void onSuccess(List dataList) {
              result.success(dataList);
            }
          }
        );
        break;
      case CAMERA_LOGIN:
        cameraId = call.argument("cameraId");

        DeviceClass.cameraLogin(
          cameraId,
          new DeviceManager.OnDevManagerListener() {
            public void onSuccess(String devId, int operationType, Object o) {
              List<Object> list = new ArrayList<>();
              list.add(true);
              result.success(list);
            }

            public void onFailed(
              String devId,
              int msgId,
              String jsonName,
              int i1
            ) {
              if (devId == "0" && msgId == 0 && jsonName == "0" && i1 == 0) {
                result.error(
                  "0",
                  "Please reset the camera and try again",
                  cameraId
                );
              }
              result.error("0", "Camera/Device is Offline", cameraId);
            }
          }
        );
        break;
      case STOP_STREAM:
        DeviceClass.stopStream();
        break;
      case LIVE_STREAM:
        cameraId = call.argument("cameraId");
        DeviceClass.liveStream(
          this.applicationContext,
          cameraId,
          this.viewCameraActivity,
                new DeviceClass.myDomResultInterface(){

                  @Override
                  public void onSuccess(List<String> dataList) {
                    result.success(dataList);
                  }

                  @Override
                  public void onFailed(String errorId, String message) {
                    result.error(
                            errorId,
                            "Please check the device connection",
                            "" + message
                    );
                  }
                }
        );
        break;
      case SET_HUMAN_DETECTION:
        cameraId = call.argument("cameraId");
        boolean isEnabled = call.argument("isEnabled");
        DeviceClass.HumanDetection(
          cameraId,
          isEnabled,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              result.success(dataList);
            }

            public void onFailed(String errorId, String message) {
              result.error(
                errorId,
                "Please check the device connection",
                "" + message
              );
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
        String cameraId = call.argument("cameraId");
        new ImageList(
          cameraId,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              result.success(dataList);
            }

            public void onFailed(String errorId, String message) {
              result.error(errorId, "Failed to get list", "" + message);
            }
          }
        );

        break;
      case IMAGE_SAVE_LOCAL:
        position = call.argument("position");
        ImageList.downloadFile(
          position,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              result.success(dataList);
            }

            public void onFailed(String errorId, String message) {
              result.error(errorId, "Invalid position", "" + message);
            }
          }
        );
        break;
      case PLAYBACK_LIST:
        cameraId = call.argument("cameraId");
        String date = call.argument("date");
        String month = call.argument("month");
        String year = call.argument("year");
        new PlayBackClass(
          cameraId,
          playBackView,
          date,
          month,
          year,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              result.success(dataList);
            }

            @Override
            public void onFailed(String errorId, String message) {
              result.error(errorId, message, "Failed to get list");
            }
          }
        );
        break;
      case PLAY_FROM_POSITION:
        position = call.argument("position");
        PlayBackClass.startPlayRecord(position,
                new DeviceClass.myDomResultInterface(){

                  @Override
                  public void onSuccess(List<String> dataList) {
                    result.success(dataList);
                  }

                  @Override
                  public void onFailed(String errorId, String message) {
                    result.error(
                            errorId,
                            "Please check the device connection",
                            "" + message
                    );
                  }
                });
        break;
      case DOWNLOAD_FROM_POSITION:
        position = call.argument("position");
        cameraId = call.argument("cameraId");

        PlayBackClass.downloadVideoFile(
          position,
          cameraId,
          new DeviceClass.myDomResultInterface() {
            public void onSuccess(List<String> dataList) {
              result.success(dataList);
            }

            @Override
            public void onFailed(String errorId, String message) {
              result.error(errorId, "Error while downloading", "" + message);
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
        PlayBackClass.seekToTime(skipTime);
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
