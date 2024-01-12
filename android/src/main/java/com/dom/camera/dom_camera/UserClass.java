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
import androidx.core.app.ActivityCompat;
import com.lib.MsgContent;
import com.manager.account.BaseAccountManager;
import com.manager.account.XMAccountManager;
import com.manager.db.DevDataCenter;
import com.manager.db.XMDevInfo;
import com.manager.device.DeviceManager;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

public class UserClass {

  static XMAccountManager manager = XMAccountManager.getInstance();
  static DeviceManager deviceManager = DeviceManager.getInstance();

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

    deviceManager.startQuickSetWiFi(
      wifiInfo,
      scanResult,
      dhcpInfo,
      password,
      (xmDevInfo, errorId) -> {
        manager.addDev(
          xmDevInfo,
          true,
          new BaseAccountManager.OnAccountManagerListener() {
            @Override
            public void onSuccess(int msgId) {}

            @Override
            public void onFailed(int msgId, int errorId) {}

            @Override
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
}
