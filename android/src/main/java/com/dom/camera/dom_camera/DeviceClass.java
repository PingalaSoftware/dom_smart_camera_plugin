package com.dom.camera.dom_camera;

import static com.dom.camera.dom_camera.UserClass.manager;

import android.content.Context;
import android.os.Environment;
import android.os.Message;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;
import com.alibaba.fastjson.JSON;
import com.google.gson.JsonObject;
import com.lib.MsgContent;
import com.lib.SDKCONST;
import com.lib.sdk.bean.ElectCapacityBean;
import com.lib.sdk.bean.HandleConfigData;
import com.lib.sdk.bean.HumanDetectionBean;
import com.lib.sdk.bean.JsonConfig;
import com.lib.sdk.bean.OPStorageManagerBean;
import com.lib.sdk.bean.PtzCtrlInfoBean;
import com.lib.sdk.bean.StringUtils;
import com.lib.sdk.bean.WifiRouteInfo;
import com.lib.sdk.struct.H264_DVR_FILE_DATA;
import com.manager.account.BaseAccountManager;
import com.manager.db.DevDataCenter;
import com.manager.db.XMDevInfo;
import com.manager.device.DeviceManager;
import com.manager.device.config.DevConfigInfo;
import com.manager.device.config.DevConfigManager;
import com.manager.device.config.DevReportManager;
import com.manager.device.config.preset.IPresetManager;
import com.manager.device.media.MediaManager;
import com.manager.device.media.attribute.PlayerAttribute;
import com.manager.device.media.audio.OnAudioDecibelListener;
import com.manager.device.media.monitor.MonitorManager;
import com.utils.FileUtils;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class DeviceClass {

  private static MonitorManager monitorManager;
  private static List<H264_DVR_FILE_DATA> recordList = new ArrayList<>();
  private List<Map<String, Object>> recordTimeList = new ArrayList<>();
  public static final int TIME_UNIT = 60;
  private int timeUnit = TIME_UNIT;
  public static final int MN_COUNT = 8;
  private int timeCount = MN_COUNT;
  private IPresetManager presetManager;

  private static DevReportManager devReportManager;

  public interface myDomResultInterface {
    void onSuccess(List<String> dataList);
    void onFailed(String errorId, String message);
  }

  static void cameraLogin(
    String cameraId,
    DeviceManager.OnDevManagerListener onDevManagerListener
  ) {
    List devList = UserClass.DeviceList();
    boolean cameraIdExists = false;

    for (Object map : devList) {
      if (map instanceof Map) {
        Object devIdValue = ((Map<?, ?>) map).get("devId");

        if (devIdValue != null && devIdValue.toString().equals(cameraId)) {
          cameraIdExists = true;
          break;
        }
      }
    }

    if (cameraIdExists) {
      DeviceManager.getInstance().loginDev(cameraId, onDevManagerListener);
    } else {
      onDevManagerListener.onFailed("0", 0, "0", 0);
    }
  }

  static void getCameraName(String cameraId, myDomResultInterface resultCb) {
    XMDevInfo xmDevInfo = DevDataCenter.getInstance().getDevInfo(cameraId);

    resultCb.onSuccess(
      new ArrayList<>(Collections.singleton(xmDevInfo.getDevName()))
    );
  }

  static void setCameraName(
    String cameraId,
    String newName,
    myDomResultInterface resultCb
  ) {
    manager.modifyDevName(
      cameraId,
      newName,
      new BaseAccountManager.OnAccountManagerListener() {
        public void onSuccess(int msgId) {
          resultCb.onSuccess(new ArrayList<>());
        }

        public void onFailed(int msgId, int errorId) {
          resultCb.onFailed("" + errorId, "Set name failed [" + errorId + "]");
        }

        public void onFunSDKResult(Message msg, MsgContent ex) {}
      }
    );
  }

  static void cameraLoginState(
    String cameraId,
    DeviceClass.myDomResultInterface result
  ) {
    if ((manager.getDevList()).contains(cameraId)) {
      List<String> devStateList = Arrays.asList(cameraId);
      manager.updateAllDevStateFromServer(
        devStateList,
        new BaseAccountManager.OnDevStateListener() {
          public void onUpdateDevState(String devId) {}

          public void onUpdateCompleted() {
            int value = manager.getDevState(cameraId);
            ArrayList dataList = new ArrayList<>();
            dataList.add(value);
            result.onSuccess(dataList);
          }
        }
      );
    } else {
      result.onFailed("0", "Camera Not Found");
    }
  }

  static void stopStream() {
    monitorManager.destroyPlay();
  }

  static void ptzControl(String cameraId, int commandID, boolean isStop) {
    PtzCtrlInfoBean ptzCtrlInfoBean = new PtzCtrlInfoBean();
    ptzCtrlInfoBean.setPtzCommandId(commandID);
    ptzCtrlInfoBean.setDevId(cameraId);
    ptzCtrlInfoBean.setSpeed(1);
    ptzCtrlInfoBean.setStop(isStop);
    DeviceManager
      .getInstance()
      .devPTZControl(
        ptzCtrlInfoBean,
        new DeviceManager.OnDevManagerListener() {
          @Override
          public void onSuccess(
            String devId,
            int operationType,
            Object result
          ) {}

          @Override
          public void onFailed(
            String devId,
            int msgId,
            String jsonName,
            int errorId
          ) {}
        }
      );
  }

  static void HumanDetection(
    String cameraId,
    boolean isEnabled,
    myDomResultInterface resultCb
  ) {
    DevConfigManager devConfigManager = DeviceManager
      .getInstance()
      .getDevConfigManager(cameraId);
    HumanDetectionBean humanDetectionBean = new HumanDetectionBean();
    humanDetectionBean.setEnable(isEnabled);
    DevConfigInfo devConfigInfo = DevConfigInfo.create(
      new DeviceManager.OnDevManagerListener() {
        @Override
        public void onSuccess(String devId, int operationType, Object result) {
          resultCb.onSuccess(new ArrayList<>());
        }

        @Override
        public void onFailed(
          String devId,
          int msgId,
          String jsonName,
          int errorId
        ) {
          resultCb.onFailed("0", "Please check the device connection");
        }
      }
    );
    devConfigInfo.setChnId(1);
    devConfigInfo.setJsonName(JsonConfig.DETECT_HUMAN_DETECTION);
    devConfigInfo.setJsonData(
      HandleConfigData.getSendData(
        HandleConfigData.getFullName(JsonConfig.DETECT_HUMAN_DETECTION, 0),
        "0x08",
        humanDetectionBean
      )
    );

    devConfigManager.setDevConfig(devConfigInfo);
  }

  static void getConfig(
    String cameraId,
    String type,
    myDomResultInterface resultCb
  ) {
    DevConfigManager devConfigManager = DeviceManager
      .getInstance()
      .getDevConfigManager(cameraId);

    DevConfigInfo devConfigInfo = DevConfigInfo.create(
      new DeviceManager.OnDevManagerListener() {
        public void onSuccess(String devId, int operationType, Object result) {
          String currentDevConfig;
          if (result instanceof String) currentDevConfig =
            (String) result; else currentDevConfig = JSON.toJSONString(result);
          ArrayList dataList = new ArrayList<>();
          dataList.add(currentDevConfig);

          resultCb.onSuccess(dataList);
        }

        public void onFailed(
          String devId,
          int msgId,
          String jsonName,
          int errorId
        ) {
          if (errorId == -11406) {
            resultCb.onFailed(
              "" + errorId,
              "The configuration device does not support or is not a configuration type"
            );
          } else {
            resultCb.onFailed("" + errorId, jsonName);
          }
        }
      }
    );

    if (type.equals("HUMAN_DETECT")) {
      devConfigInfo.setJsonName(JsonConfig.DETECT_HUMAN_DETECTION);
      devConfigInfo.setChnId(0);
      devConfigManager.getDevConfig(devConfigInfo);
    } else if (type.equals("MOVE_DETECT")) {
      devConfigInfo.setJsonName(JsonConfig.DETECT_MOTIONDETECT);
      devConfigInfo.setChnId(0);
      devConfigManager.getDevConfig(devConfigInfo);
    } else if (type.equals("SIMPLIFY_ENCODE")) {
      devConfigInfo.setJsonName(JsonConfig.SIMPLIFY_ENCODE);
      devConfigInfo.setChnId(-1);
      devConfigManager.getDevConfig(devConfigInfo);
    } else if (type.equals("STORAGE_INFO")) {
      devConfigInfo.setJsonName(JsonConfig.STORAGE_INFO);
      devConfigInfo.setChnId(-1);
      devConfigManager.getDevConfig(devConfigInfo);
    } else if (type.equals("CAMERA_PARAM")) {
      devConfigInfo.setJsonName(JsonConfig.CAMERA_PARAM);
      devConfigInfo.setChnId(-1);
      devConfigManager.getDevConfig(devConfigInfo);
    } else if (type.equals("VIDEO_CONFIG")) {
      devConfigInfo.setJsonName(JsonConfig.RECORD);
      devConfigInfo.setChnId(-1);
      devConfigManager.getDevConfig(devConfigInfo);
    } else if (type.equals("SYSTEM_INFO")) {
      devConfigInfo.setJsonName(JsonConfig.SYSTEM_INFO);
      devConfigInfo.setChnId(1);
      devConfigManager.getDevConfig(devConfigInfo);
    } else {
      resultCb.onFailed("0", "Invalid config type");
    }
  }

  static void updateConfig(
    String cameraId,
    String type,
    String newData,
    myDomResultInterface resultCb
  ) {
    DevConfigManager devConfigManager = DeviceManager
      .getInstance()
      .getDevConfigManager(cameraId);
    DevConfigInfo devConfigInfo = DevConfigInfo.create(
      new DeviceManager.OnDevManagerListener() {
        public void onSuccess(String devId, int operationType, Object result) {
          resultCb.onSuccess(new ArrayList<>());
        }

        public void onFailed(
          String devId,
          int msgId,
          String jsonName,
          int errorId
        ) {
          resultCb.onFailed("" + errorId, jsonName);
        }
      }
    );

    if (type.equals("HUMAN_DETECT")) {
      devConfigInfo.setJsonName(JsonConfig.DETECT_HUMAN_DETECTION);
      devConfigInfo.setChnId(0);
      devConfigInfo.setJsonData(newData);
      devConfigManager.setDevConfig(devConfigInfo);
    }
    if (type.equals("MOVE_DETECT")) {
      devConfigInfo.setJsonName(JsonConfig.DETECT_MOTIONDETECT);
      devConfigInfo.setChnId(0);
      devConfigInfo.setJsonData(newData);
      devConfigManager.setDevConfig(devConfigInfo);
    } else if (type.equals("SIMPLIFY_ENCODE")) {
      devConfigInfo.setJsonName(JsonConfig.SIMPLIFY_ENCODE);
      devConfigInfo.setChnId(1);
      devConfigInfo.setJsonData(newData);
      devConfigManager.setDevConfig(devConfigInfo);
    } else if (type.equals("STORAGE_INFO")) {
      devConfigInfo.setJsonName(JsonConfig.OPSTORAGE_MANAGER);
      devConfigInfo.setTimeOut(10000);
      devConfigInfo.setChnId(-1);

      OPStorageManagerBean opStorageManagerBean = new OPStorageManagerBean();
      opStorageManagerBean.setAction("Clear");
      opStorageManagerBean.setSerialNo(0);
      opStorageManagerBean.setType("Data");
      opStorageManagerBean.setPartNo(0);

      String jsonData = HandleConfigData.getSendData(
        JsonConfig.OPSTORAGE_MANAGER,
        "0x08",
        opStorageManagerBean
      );
      devConfigInfo.setJsonData(jsonData);
      devConfigManager.setDevConfig(devConfigInfo);
    } else if (type.equals("CAMERA_PARAM")) {
      devConfigInfo.setJsonName(JsonConfig.CAMERA_PARAM);
      devConfigInfo.setChnId(-1);
      devConfigInfo.setJsonData(newData);
      devConfigManager.setDevConfig(devConfigInfo);
    } else if (type.equals("VIDEO_CONFIG")) {
      devConfigInfo.setJsonName(JsonConfig.RECORD);
      devConfigInfo.setChnId(-1);
      devConfigInfo.setJsonData(newData);
      devConfigManager.setDevConfig(devConfigInfo);
    } else if (type.equals("SYSTEM_INFO")) {
      devConfigInfo.setJsonName(JsonConfig.SYSTEM_INFO);
      devConfigInfo.setChnId(1);
      devConfigInfo.setJsonData(newData);
      devConfigManager.setDevConfig(devConfigInfo);
    } else {
      resultCb.onFailed("0", "Invalid config type");
    }
  }

  static void setRecordType(
    String cameraId,
    String type,
    myDomResultInterface resultCb
  ) {
    DevConfigManager devConfigManager = DeviceManager
      .getInstance()
      .getDevConfigManager(cameraId);

    DevConfigInfo devConfigInfo = DevConfigInfo.create(
      new DeviceManager.OnDevManagerListener() {
        public void onSuccess(String devId, int operationType, Object result) {
          String currentDevConfig;
          if (result instanceof String) currentDevConfig =
            (String) result; else currentDevConfig = JSON.toJSONString(result);

          String alwaysRecordMask =
            "[[\"0x7\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]" +
            "[\"0x7\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x7\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x7\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x7\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x7\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x7\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]]";
          String alarmRecordMask =
            "[[\"0x00000006\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000006\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000006\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000006\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000006\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000006\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000006\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]]";
          String noRecordMask =
            "[[\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]," +
            "[\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\",\"0x00000000\"]]";

          String newData = "";
          if ("ALWAYS".equals(type)) {
            newData =
              addArrayToMaskProperty(currentDevConfig, alwaysRecordMask);
          } else if ("NEVER".equals(type)) {
            newData = addArrayToMaskProperty(currentDevConfig, noRecordMask);
          } else if ("ALARM".equals(type)) {
            newData = addArrayToMaskProperty(currentDevConfig, alarmRecordMask);
          }
          updateRecordType(cameraId, newData, resultCb);
        }

        public void onFailed(
          String devId,
          int msgId,
          String jsonName,
          int errorId
        ) {
          resultCb.onFailed("" + errorId, jsonName);
        }
      }
    );
    devConfigInfo.setJsonName(JsonConfig.RECORD);
    devConfigInfo.setChnId(-1);
    devConfigManager.getDevConfig(devConfigInfo);
  }

  private static void updateRecordType(
    String cameraId,
    String newData,
    myDomResultInterface resultCb
  ) {
    DevConfigManager devConfigManager = DeviceManager
      .getInstance()
      .getDevConfigManager(cameraId);
    DevConfigInfo devConfigInfo = DevConfigInfo.create(
      new DeviceManager.OnDevManagerListener() {
        public void onSuccess(String devId, int operationType, Object result) {
          resultCb.onSuccess(new ArrayList<>());
        }

        public void onFailed(
          String devId,
          int msgId,
          String jsonName,
          int errorId
        ) {
          resultCb.onFailed("" + errorId, jsonName);
        }
      }
    );
    devConfigInfo.setJsonName(JsonConfig.RECORD);
    devConfigInfo.setChnId(-1);
    devConfigInfo.setJsonData(newData);
    devConfigManager.setDevConfig(devConfigInfo);
  }

  private static String addArrayToMaskProperty(
    String jsonString,
    String newArray
  ) {
    try {
      JSONObject jsonObject = new JSONObject(jsonString);
      //            JSONArray maskArray = jsonObject.getJSONArray("Mask");

      JSONArray newArrayJson = new JSONArray(newArray);
      jsonObject.put("Mask", newArrayJson);
      //            maskArray.put(newArrayJson);

      return jsonObject.toString();
    } catch (Exception e) {
      e.printStackTrace();
      return jsonString; // return original JSON in case of an error
    }
  }

  public static void setVideoFullScreen(
    boolean isFullScreen,
    myDomResultInterface resultCb
  ) {
    if (monitorManager != null) {
      monitorManager.setVideoFullScreen(isFullScreen);

      ArrayList dataList = new ArrayList<>();
      dataList.add(monitorManager.isVideoFullScreen());
      resultCb.onSuccess(dataList);
    } else {
      resultCb.onFailed("0", "No Streaming Found");
    }
  }

  public static void isFullScreenStreaming(myDomResultInterface resultCb) {
    if (monitorManager != null) {
      ArrayList dataList = new ArrayList<>();
      dataList.add(monitorManager.isVideoFullScreen());
      resultCb.onSuccess(dataList);
    } else {
      resultCb.onFailed("0", "No Streaming Found");
    }
  }

  static void liveStream(
    Context context,
    String cameraId,
    ViewGroup view,
    myDomResultInterface resultCb
  ) {
    monitorManager =
      DeviceManager.getInstance().createMonitorPlayer(view, cameraId);
    monitorManager.startMonitor();
    monitorManager.setChnId(1);
    monitorManager.setOnAudioDecibelListener(
      new OnAudioDecibelListener() {
        public void onVolume(double v) {}
      }
    );
    monitorManager.setOnMediaManagerListener(
      new MediaManager.OnMediaManagerListener() {
        public void onMediaPlayState(PlayerAttribute attribute, int state) {}

        public void onFailed(
          PlayerAttribute attribute,
          int msgId,
          int errorId
        ) {
          resultCb.onFailed("0", "0");
        }

        public void onShowRateAndTime(
          PlayerAttribute attribute,
          boolean isShowTime,
          String time,
          long rate
        ) {}

        public void onVideoBufferEnd(PlayerAttribute attribute, MsgContent ex) {
          resultCb.onSuccess(new ArrayList<>());
        }

        public void onPlayStateClick(View view) {}
      }
    );
  }

  public static void capture(Context context) {
    String storagePath =
      Environment.getExternalStorageDirectory() +
      File.separator +
      Environment.DIRECTORY_DCIM +
      File.separator +
      "DOM" +
      File.separator +
      "CP_IMAGES" +
      File.separator;

    File domFolder = new File(
      Environment.getExternalStorageDirectory() +
      File.separator +
      Environment.DIRECTORY_DCIM +
      File.separator +
      "DOM"
    );
    File imagesFolder = new File(storagePath);

    if (!domFolder.exists()) {
      domFolder.mkdirs();
    }
    if (!imagesFolder.exists()) {
      imagesFolder.mkdirs();
    }

    if (!FileUtils.isFileAvailable(storagePath)) {
      storagePath =
        Environment.getExternalStorageDirectory() +
        File.separator +
        Environment.DIRECTORY_DCIM +
        File.separator;
    }

    monitorManager.capture(storagePath);
  }

  public static void startRecord() {
    String storagePath =
      Environment.getExternalStorageDirectory() +
      File.separator +
      Environment.DIRECTORY_DCIM +
      File.separator +
      "DOM" +
      File.separator +
      "CP_VIDEOS" +
      File.separator;

    File domFolder = new File(
      Environment.getExternalStorageDirectory() +
      File.separator +
      Environment.DIRECTORY_DCIM +
      File.separator +
      "DOM"
    );
    File videosFolder = new File(storagePath);

    if (!domFolder.exists()) {
      domFolder.mkdirs();
    }
    if (!videosFolder.exists()) {
      videosFolder.mkdirs();
    }

    if (!FileUtils.isFileAvailable(storagePath)) {
      storagePath =
        Environment.getExternalStorageDirectory() +
        File.separator +
        Environment.DIRECTORY_DCIM +
        File.separator;
    }

    if (!monitorManager.isRecord()) {
      monitorManager.startRecord(storagePath);
    }
  }

  public static void stopRecord() {
    if (monitorManager.isRecord()) {
      monitorManager.stopRecord();
    }
  }

  public static void openVoice() {
    monitorManager.openVoiceBySound();
  }

  public static void closeVoice() {
    monitorManager.closeVoiceBySound();
  }

  public static void startSingleIntercomAndSpeak(Context context) {
    if (monitorManager == null) return;

    monitorManager.startTalkByHalfDuplex(context);
  }

  public static void stopSingleIntercomAndHear() {
    if (monitorManager == null) return;

    monitorManager.stopTalkByHalfDuplex();
  }

  public static void startDoubleIntercom(Context context) {
    if (monitorManager == null) return;

    monitorManager.startTalkByDoubleDirection(context, true);
  }

  public static void stopIntercom() {
    if (monitorManager == null) return;

    monitorManager.destroyTalk();
  }

  static void getBatteryPercentage(
    String cameraId,
    myDomResultInterface resultCb
  ) {
    DevReportManager devReportManager = new DevReportManager(
      null,
      SDKCONST.UploadDataType.SDK_ELECT_STATE,
      new DevReportManager.OnDevReportListener() {
        public void onReport(String devId, String stateType, String stateData) {
          ArrayList dataList = new ArrayList<>();
          dataList.add(stateData);
          resultCb.onSuccess(dataList);
        }
      }
    );

    devReportManager.startReceive(cameraId);
  }

  static void getDevWiFiSignalLevel(
    String cameraId,
    myDomResultInterface resultCb
  ) {
    DevConfigManager devConfigManager = DeviceManager
      .getInstance()
      .getDevConfigManager(cameraId);
    DevConfigInfo devConfigInfo = DevConfigInfo.create(
      new DeviceManager.OnDevManagerListener<String>() {
        @Override
        public void onSuccess(String s, int i, String jsonData) {
          if (jsonData != null) {
            HandleConfigData<WifiRouteInfo> handleConfigData = new HandleConfigData<>();
            if (handleConfigData.getDataObj(jsonData, WifiRouteInfo.class)) {
              WifiRouteInfo wifiRouteInfo = handleConfigData.getObj();

              boolean wlanStatus = wifiRouteInfo.isWlanStatus();
              boolean eth0Status = wifiRouteInfo.isEth0Status();
              String wlanMac = wifiRouteInfo.getWlanMac();
              int signalLevel = wifiRouteInfo.getSignalLevel();

              JSONObject jsonObject = new JSONObject();
              try {
                jsonObject.put("wlanStatus", wlanStatus);
                jsonObject.put("eth0Status", eth0Status);
                jsonObject.put("wlanMac", wlanMac);
                jsonObject.put("signalLevel", signalLevel);

                ArrayList dataList = new ArrayList<>();
                dataList.add(jsonObject.toString(jsonObject.length()));
                resultCb.onSuccess(dataList);
              } catch (JSONException e) {
                ArrayList dataList = new ArrayList<>();
                dataList.add(null);
                dataList.add(signalLevel);
                resultCb.onSuccess(dataList);
              }
            }
          }
        }

        public void onFailed(String s, int i, String s1, int i1) {
          resultCb.onFailed("0" + i1, s1);
        }
      }
    );

    devConfigInfo.setCmdId(1020);
    devConfigInfo.setJsonName(JsonConfig.WIFI_ROUTE_INFO);
    devConfigInfo.setChnId(1);
    devConfigManager.setDevCmd(devConfigInfo);
  }

  public int changeStream(int chnId, String cameraId) {
    if (monitorManager != null) {
      monitorManager.setStreamType(
        monitorManager.getStreamType() == SDKCONST.StreamType.Extra
          ? SDKCONST.StreamType.Main
          : SDKCONST.StreamType.Extra
      );
      monitorManager.stopPlay();
      monitorManager.startMonitor();
      return monitorManager.getStreamType();
    }

    return SDKCONST.StreamType.Extra;
  }
}
