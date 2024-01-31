package com.dom.camera.dom_camera;

import static com.manager.db.Define.LOGIN_BY_INTERNET;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.DhcpInfo;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Message;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;

import com.basic.G;
import com.lib.MsgContent;
import com.lib.sdk.struct.SDBDeviceInfo;
import com.manager.account.BaseAccountManager;
import com.manager.account.XMAccountManager;
import com.manager.db.DevDataCenter;
import com.manager.db.XMDevInfo;
import com.manager.device.DeviceManager;
import com.manager.device.config.preset.IPresetManager;

import java.sql.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

public class UserClass {

  static XMAccountManager manager = XMAccountManager.getInstance();
  static DeviceManager deviceManager = DeviceManager.getInstance();
  static String devSn = "";
  private static IPresetManager presetManager;

  static void loginUser(
    String userID,
    String password,
    BaseAccountManager.OnAccountManagerListener result
  ) {
    manager.login(userID, password, LOGIN_BY_INTERNET, result);
  }

  static void DeleteCamera(
    String cameraId,
    BaseAccountManager.OnAccountManagerListener result
  ) {
    manager.deleteDev(cameraId, result);
  }

  static List<HashMap<String, Object>> DeviceList() {
    List<HashMap<String, Object>> devList;

    devList = new ArrayList<>();

    for (String devId : manager.getDevList()) {
      XMDevInfo xmDevInfo = DevDataCenter.getInstance().getDevInfo(devId);
      HashMap<String, Object> map = new HashMap<>();
      map.put("devId", devId);
      map.put("devState", manager.getDevState(devId));
      map.put("devName", xmDevInfo.getDevName());
      devList.add(map);
    }

    return devList;
  }

  static void addDeviceThroughWifi(
    String ssid,
    String password,
    Context context,
    DeviceClass.myDomResultInterface resultListener
  ) {
    WifiManager wifiManager = (WifiManager) context
      .getApplicationContext()
      .getSystemService(Context.WIFI_SERVICE);
    WifiInfo wifiInfo = wifiManager.getConnectionInfo();
    DhcpInfo dhcpInfo = wifiManager.getDhcpInfo();
    ScanResult scanResult = null;
    if (
      ActivityCompat.checkSelfPermission(
        context,
        Manifest.permission.ACCESS_FINE_LOCATION
      ) !=
      PackageManager.PERMISSION_GRANTED
    ) {
      return;
    }

    for (ScanResult result : wifiManager.getScanResults()) {
      if (result.SSID.equals(ssid)) {
        scanResult = result;
        break;
      }
    }

    if (scanResult == null) {
      resultListener.onFailed("0", "Not connect to provided WiFi");
      return;
    }



    deviceManager.startQuickSetWiFi(wifiInfo.getSSID(), password, scanResult.capabilities, dhcpInfo, 1000, (xmDevInfo, errorId) -> {
        manager.addDev(xmDevInfo, true, new BaseAccountManager.OnAccountManagerListener() {
            public void onSuccess(int msgId) {}

            public void onFailed(int msgId, int errorId) {}

            public void onFunSDKResult(Message msg, MsgContent ex) {
              if (errorId == 0) {
                resultListener.onSuccess(
                  new ArrayList<>(Collections.singleton(xmDevInfo.getDevId()))
                );
              } else {
                resultListener.onFailed(
                  "" + errorId,
                  "Failed to connect to Device"
                );
              }
            }
          }
        );
      }
    );
  }

  static void getUserInfo(DeviceClass.myDomResultInterface resultListener) {
    manager.getUserInfo(new BaseAccountManager.OnAccountManagerListener() {
      public void onSuccess(int msgId) {
        if(msgId == 5049 && !devSn.isEmpty()) {
          List<String> devSnList = new ArrayList<>(Arrays.asList(devSn));
          resultListener.onSuccess(devSnList);
        }
      }
      public void onFailed(int msgId, int errorId) {
        System.out.println("getUserInfo: onFailed :" + msgId + " err: " + errorId);
        resultListener.onFailed("0","" + errorId);
      }
      public void onFunSDKResult(Message msg, MsgContent ex) {
        devSn = ex.str;
        List<String> devSnList = new ArrayList<>(Arrays.asList(devSn));
        resultListener.onSuccess(devSnList);
      }
    });
  }

  static void addDev(String devId, String type, DeviceClass.myDomResultInterface resultListener) {
    SDBDeviceInfo deviceInfo = new SDBDeviceInfo();
    G.SetValue(deviceInfo.st_0_Devmac, devId);
    G.SetValue(deviceInfo.st_5_loginPsw, "");
    G.SetValue(deviceInfo.st_4_loginName, "admin");
    G.SetValue(deviceInfo.st_1_Devname, devId);
    if(type.equals("NORMAL_IPC")) {
      deviceInfo.st_7_nType = 0;
    } else if (type.equals("LOW_POWERED")) {
      deviceInfo.st_7_nType = 21;
    } else {
      resultListener.onFailed("0", "Invalid Device Type");
    }

    XMDevInfo xmDevInfo = new XMDevInfo();
    xmDevInfo.sdbDevInfoToXMDevInfo(deviceInfo);
    manager.addDev(xmDevInfo, new BaseAccountManager.OnAccountManagerListener() {
      public void onSuccess(int i) {
        System.out.println("Adding camera: s5 --- ADD DEV: SUCCESS "+ i);
        resultListener.onSuccess(new ArrayList<>(Collections.singleton(xmDevInfo.getDevId())));

      }
      public void onFailed(int i, int errorId) {
        System.out.println("Adding camera: s5 --- ADD DEV: FAILED:"+ i + " error id:" + errorId);
        resultListener.onFailed("0", "Invalid Device Type");
      }
      public void onFunSDKResult(Message message, MsgContent msgContent) {
        System.out.println("Adding camera: s5 --- ADD DEV: onFunSDKResult:"+ message + " msgContent:" + msgContent);
      }
    });
  }

  public interface PresetOperationCallback {
    void onPresetOperationSuccess();
    void onPresetOperationFailed(String errorCode, String errorMessage);
  }

  static void initPresetManager(String cameraId, PresetOperationCallback presetCallback) {
    presetManager = deviceManager.createPresetManager(cameraId, new DeviceManager.OnDevManagerListener() {
      public void onSuccess(String s, int i, Object abilityKey) {
        System.out.println("Preset: add Suc: "+s+" i: "+i+" abilityKey: "+abilityKey);
        presetCallback.onPresetOperationSuccess();
      }

      public void onFailed(String s, int i, String s1, int i1) {
        System.out.println("Preset: add failed: "+s+" i: "+i+" s1: "+s1+ " error id: "+i1);
        presetCallback.onPresetOperationFailed("" + i1, "Unable to set preset!");
      }
    });
  }
  public static void addPreset(String cameraId, int presetId, int chnId, DeviceClass.myDomResultInterface resultListener) {
    System.out.println("Preset: add 1");

    if (presetManager != null) {
      System.out.println("Preset: add 1 if");
      presetManager.addPreset(0, presetId);
      resultListener.onSuccess(new ArrayList<>());
    } else {
      System.out.println("Preset: add 1 else");
      PresetOperationCallback callback = new PresetOperationCallback() {
        public void onPresetOperationSuccess() {
          System.out.println("Preset: add 1 else suc");
          presetManager.addPreset(chnId, presetId);
          resultListener.onSuccess(new ArrayList<>());
        }

        public void onPresetOperationFailed(String errorCode, String errorMessage) {
          System.out.println("Preset: add 1 else fa");
          resultListener.onFailed(errorCode, errorMessage);
        }
      };

      initPresetManager(cameraId, callback);
    }
  }

  public static void turnToPreset(String cameraId, int presetId, int chnNo, DeviceClass.myDomResultInterface resultListener) {
    if (presetManager != null) {
      presetManager.turnPreset(0, presetId);
      resultListener.onSuccess(new ArrayList<>());
    } else {
      PresetOperationCallback callback = new PresetOperationCallback() {
        public void onPresetOperationSuccess() {
          presetManager.turnPreset(chnNo, presetId);
          resultListener.onSuccess(new ArrayList<>());
        }

        public void onPresetOperationFailed(String errorCode, String errorMessage) {
          resultListener.onFailed(errorCode, errorMessage);
        }
      };

      initPresetManager(cameraId, callback);
    }
  }
}
