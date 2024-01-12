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
      String date, String month, String year) {
    return DomCameraPlatform.instance.playbackList(date, month, year);
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
}
