import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dom_camera_platform_interface.dart';
import 'dart:io' show Platform;

class DomCamera {
  final _timerEventChannel = const EventChannel('dom_camera/playbackListener');

  Stream playbackTimerStreamListener() {
    return _timerEventChannel.receiveBroadcastStream();
  }

  Future<Map<String, dynamic>> iosNetworkPermission() {
    return DomCameraPlatform.instance.iosNetworkPermission();
  }

  Future<Map<String, dynamic>> addCamera(String wifiSsid, String wifiPassword) {
    return DomCameraPlatform.instance.addCamera(wifiSsid, wifiPassword);
  }

  Future<Map<String, dynamic>> cameraLogin(String cameraId) {
    return DomCameraPlatform.instance.cameraLogin(cameraId);
  }

  StatefulWidget cameraStreamWidget() {
    if (Platform.isAndroid) {
      return const AndroidView(
        viewType: 'dom_camera_stream',
      );
    } else {
      return const UiKitView(
        viewType: 'dom_camera_stream',
      );
    }
  }

  StatefulWidget videoPlaybackWidget() {
    if (Platform.isAndroid) {
      return const AndroidView(
        viewType: 'dom_video_playback',
      );
    } else {
      return const UiKitView(
        viewType: 'dom_video_playback',
      );
    }
  }

  Future<Map<String, dynamic>> setDeviceAlarmCallback(String callbackUrl,
      [String? cameraId]) {
    return DomCameraPlatform.instance
        .setDeviceAlarmCallback(callbackUrl, cameraId);
  }

  Future<Map<String, dynamic>> cameraState(String cameraId) {
    return DomCameraPlatform.instance.cameraState(cameraId);
  }

  Future<Map<String, dynamic>> setHumanDetection(bool isEnabled) {
    return DomCameraPlatform.instance.setHumanDetection(isEnabled);
  }

  Future<Map<String, dynamic>> getCameraName() {
    return DomCameraPlatform.instance.getCameraName();
  }

  Future<Map<String, dynamic>> setCameraName(String newName) {
    return DomCameraPlatform.instance.setCameraName(newName);
  }

  Future<Map<String, dynamic>> setRecordType(String type) {
    return DomCameraPlatform.instance.setRecordType(type);
  }

  Future<Map<String, dynamic>> startStreaming() {
    return DomCameraPlatform.instance.cameraStream(true);
  }

  Future<Map<String, dynamic>> stopStreaming() {
    return DomCameraPlatform.instance.cameraStream(false);
  }

  Map<String, dynamic> startAudio() {
    return DomCameraPlatform.instance.cameraAudio(true);
  }

  Map<String, dynamic> stopAudio() {
    return DomCameraPlatform.instance.cameraAudio(false);
  }

  Map<String, dynamic> startSingleInterCom() {
    return DomCameraPlatform.instance.interCommunication(true, true);
  }

  Map<String, dynamic> stopSingleInterCom() {
    return DomCameraPlatform.instance.interCommunication(false, true);
  }

  Map<String, dynamic> startDualInterCom() {
    return DomCameraPlatform.instance.interCommunication(true, false);
  }

  Map<String, dynamic> stopDualInterCom() {
    return DomCameraPlatform.instance.interCommunication(false, false);
  }

  Map<String, dynamic> captureImageAndSaveLocal() {
    return DomCameraPlatform.instance.captureImageSaveLocal();
  }

  Map<String, dynamic> startVideRecordAndSaveLocal() {
    return DomCameraPlatform.instance.videoRecordAndSaveLocal(true);
  }

  Map<String, dynamic> stopVideRecordAndSaveLocal() {
    return DomCameraPlatform.instance.videoRecordAndSaveLocal(false);
  }

  Map<String, dynamic> cameraMovement(double x, double y) {
    return DomCameraPlatform.instance.cameraMovement(x, y);
  }

  Future<Map<String, dynamic>> imageListInCamera() {
    return DomCameraPlatform.instance.imageListInCamera();
  }

  Future<Map<String, dynamic>> imageDownloadFromCamera(int position) {
    return DomCameraPlatform.instance.imageDownloadFromCamera(position);
  }

  Future<Map<String, dynamic>> playbackList(
    String fromDate,
    String fromMonth,
    String fromYear,
    String toDate,
    String toMonth,
    String toYear,
  ) {
    return DomCameraPlatform.instance
        .playbackList(fromDate, fromMonth, fromYear, toDate, toMonth, toYear);
  }

  Future<Map<String, dynamic>> playFromPosition(int position) {
    return DomCameraPlatform.instance.playFromPosition(position);
  }

  Future<Map<String, dynamic>> downloadFromPosition(int position) {
    return DomCameraPlatform.instance.downloadFromPosition(position);
  }

  Map<String, dynamic> pausePlayBack() {
    return DomCameraPlatform.instance.pausePlayBack();
  }

  Map<String, dynamic> rePlayPlayBack() {
    return DomCameraPlatform.instance.rePlayPlayBack();
  }

  Map<String, dynamic> skipPlayBack(int hour, int minute, int sec) {
    if (hour > 24) return {"isError": true, "message": "Invalid Hour"};
    if (minute > 60) return {"isError": true, "message": "Invalid Minute"};
    if (sec > 60) return {"isError": true, "message": "Invalid Second"};

    DateTime now = DateTime.now();
    DateTime startOfToday = DateTime(now.year, now.month, now.day, 00, 00, 00);
    DateTime curTime =
        DateTime(now.year, now.month, now.day, hour, minute, sec);
    int skipTime = curTime.difference(startOfToday).inSeconds;

    return DomCameraPlatform.instance.skipPlayBack(skipTime);
  }

  Map<String, dynamic> openAudioPlayBack() {
    return DomCameraPlatform.instance.openAudioPlayBack();
  }

  Map<String, dynamic> closeAudioPlayBack() {
    return DomCameraPlatform.instance.closeAudioPlayBack();
  }

  Map<String, dynamic> captureImageFromPlayBack() {
    return DomCameraPlatform.instance.captureImageFromPlayBack();
  }

  Future<Map<String, dynamic>> addCameraWithSerialNumber(
      String cameraId, String cameraType) {
    return DomCameraPlatform.instance
        .addCameraWithSerialNumber(cameraId, cameraType);
  }

  Future<Map<String, dynamic>> getUserInformation(String cameraId) {
    return DomCameraPlatform.instance.getUserInformation(cameraId);
  }

  Future<Map<String, dynamic>> addPresetPoint(int presetId) {
    return DomCameraPlatform.instance.addPresetPoint(presetId);
  }

  Future<Map<String, dynamic>> turnToPreset(int presetId) {
    return DomCameraPlatform.instance.turnToPreset(presetId);
  }

  Future<Map<String, dynamic>> getHumanDetectConfig() {
    return DomCameraPlatform.instance.getConfiguration("HUMAN_DETECT");
  }

  Future<Map<String, dynamic>> setHumanDetectConfig(String newConfig) {
    return DomCameraPlatform.instance
        .setConfiguration("HUMAN_DETECT", newConfig);
  }

  Future<Map<String, dynamic>> getMoveDetectConfig() {
    return DomCameraPlatform.instance.getConfiguration("MOVE_DETECT");
  }

  Future<Map<String, dynamic>> setMoveDetectConfig(String newConfig) {
    return DomCameraPlatform.instance
        .setConfiguration("MOVE_DETECT", newConfig);
  }

  Future<Map<String, dynamic>> getEncodingConfig() {
    return DomCameraPlatform.instance.getConfiguration("SIMPLIFY_ENCODE");
  }

  Future<Map<String, dynamic>> setEncodingConfig(String newConfig) {
    return DomCameraPlatform.instance
        .setConfiguration("SIMPLIFY_ENCODE", newConfig);
  }

  Future<Map<String, dynamic>> getCameraInfo() {
    return DomCameraPlatform.instance.getConfiguration("SYSTEM_INFO");
  }

  Future<Map<String, dynamic>> setCameraInfo(String newConfig) {
    return DomCameraPlatform.instance
        .setConfiguration("SYSTEM_INFO", newConfig);
  }

  Future<Map<String, dynamic>> getImageConfig() {
    return DomCameraPlatform.instance.getConfiguration("CAMERA_PARAM");
  }

  Future<Map<String, dynamic>> setImageConfig(String newConfig) {
    return DomCameraPlatform.instance
        .setConfiguration("CAMERA_PARAM", newConfig);
  }

  Future<Map<String, dynamic>> getVideoConfig() {
    return DomCameraPlatform.instance.getConfiguration("VIDEO_CONFIG");
  }

  Future<Map<String, dynamic>> setVideoConfig(String newConfig) {
    return DomCameraPlatform.instance
        .setConfiguration("VIDEO_CONFIG", newConfig);
  }

  Future<Map<String, dynamic>> getStorageModifications() {
    return DomCameraPlatform.instance.getConfiguration("STORAGE_INFO");
  }

  Future<Map<String, dynamic>> formatStorage() {
    return DomCameraPlatform.instance.setConfiguration("STORAGE_INFO", "");
  }

  Future<Map<String, dynamic>> getWifiInfo() {
    return DomCameraPlatform.instance.getWifiInfo();
  }

  Future<Map<String, dynamic>> getBatteryPercentage() {
    return DomCameraPlatform.instance.getBatteryPercentage();
  }
}
