import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'handlers/dom_camera_method_channel.dart';

abstract class DomCameraPlatform extends PlatformInterface {
  DomCameraPlatform() : super(token: _token);

  static final Object _token = Object();
  static DomCameraPlatform _instance = MethodChannelDomCamera();
  static DomCameraPlatform get instance => _instance;

  static set instance(DomCameraPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>> iosNetworkPermission() {
    throw UnimplementedError(
        'iosNetworkPermission() has not been implemented.');
  }

  Future<Map<String, dynamic>> addCamera(String wifiSsid, String wifiPassword) {
    throw UnimplementedError('addCamera() has not been implemented.');
  }

  Future<Map<String, dynamic>> cameraLogin(String cameraId) {
    throw UnimplementedError('cameraLogin() has not been implemented.');
  }

  Future<Map<String, dynamic>> getCameraName() {
    throw UnimplementedError('getCameraName() has not been implemented.');
  }

  Future<Map<String, dynamic>> setCameraName(String newName) {
    throw UnimplementedError('setCameraName() has not been implemented.');
  }

  Future<Map<String, dynamic>> setDeviceAlarmCallback(
      String callbackUrl, String? cameraId) {
    throw UnimplementedError(
        'setDeviceAlarmCallback() has not been implemented.');
  }

  Future<Map<String, dynamic>> cameraState(String cameraId) {
    throw UnimplementedError('cameraState() has not been implemented.');
  }

  Future<Map<String, dynamic>> setHumanDetection(bool isEnabled) {
    throw UnimplementedError('setHumanDetection() has not been implemented.');
  }

  Future<Map<String, dynamic>> setRecordType(String type) {
    throw UnimplementedError('setRecordType() has not been implemented.');
  }

  Future<Map<String, dynamic>> isFullScreenStreaming() {
    throw UnimplementedError(
        'isFullScreenStreaming() has not been implemented.');
  }

  Future<Map<String, dynamic>> fullScreenStream(bool isShowFullScreenStream) {
    throw UnimplementedError('fullScreenStream() has not been implemented.');
  }

  Future<Map<String, dynamic>> cameraStream(bool isShowStream) {
    throw UnimplementedError('cameraStream() has not been implemented.');
  }

  Map<String, dynamic> cameraAudio(bool audioState) {
    throw UnimplementedError('cameraAudio() has not been implemented.');
  }

  Map<String, dynamic> interCommunication(bool isStart, bool isSingleChannel) {
    throw UnimplementedError('interCommunication() has not been implemented.');
  }

  Map<String, dynamic> captureImageSaveLocal() {
    throw UnimplementedError(
        'captureImageSaveLocal() has not been implemented.');
  }

  Map<String, dynamic> videoRecordAndSaveLocal(bool isStart) {
    throw UnimplementedError(
        'videoRecordAndSaveLocal() has not been implemented.');
  }

  Map<String, dynamic> cameraMovement(double x, double y) {
    throw UnimplementedError('cameraMovement() has not been implemented.');
  }

  Future<Map<String, dynamic>> imageListInCamera() {
    throw UnimplementedError('ImageListInCamera() has not been implemented.');
  }

  Future<Map<String, dynamic>> imageDownloadFromCamera(int position) {
    throw UnimplementedError(
        'ImageDownloadFromCamera() has not been implemented.');
  }

  Future<Map<String, dynamic>> playbackList(
    String fromDate,
    String fromMonth,
    String fromYear,
    String toDate,
    String toMonth,
    String toYear,
  ) {
    throw UnimplementedError('playbackList() has not been implemented.');
  }

  Map<String, dynamic> stopPlayBack() {
    throw UnimplementedError('stopPlayBack() has not been implemented.');
  }

  Future<Map<String, dynamic>> playFromPosition(int position) {
    throw UnimplementedError('playFromPosition() has not been implemented.');
  }

  Future<Map<String, dynamic>> downloadFromPosition(int position) {
    throw UnimplementedError(
        'downloadFromPosition() has not been implemented.');
  }

  Map<String, dynamic> pausePlayBack() {
    throw UnimplementedError('pausePlayBack() has not been implemented.');
  }

  Map<String, dynamic> rePlayPlayBack() {
    throw UnimplementedError('rePlayPlayBack() has not been implemented.');
  }

  Future<Map<String, dynamic>> skipPlayBack(int hour, int minute, int sec) {
    throw UnimplementedError('skipPlayBack() has not been implemented.');
  }

  Map<String, dynamic> openAudioPlayBack() {
    throw UnimplementedError('openAudioPlayBack() has not been implemented.');
  }

  Map<String, dynamic> closeAudioPlayBack() {
    throw UnimplementedError('closeAudioPlayBack() has not been implemented.');
  }

  Map<String, dynamic> captureImageFromPlayBack() {
    throw UnimplementedError(
        'captureImageFromPlayBack() has not been implemented.');
  }

  Future<Map<String, dynamic>> addCameraWithSerialNumber(
      String cameraId, String cameraType) {
    throw UnimplementedError(
        'addCameraWithSerialNumber() has not been implemented.');
  }

  Future<Map<String, dynamic>> getUserInformation(String cameraId) {
    throw UnimplementedError('getUserInformation() has not been implemented.');
  }

  Future<Map<String, dynamic>> addPresetPoint(int presetId) {
    throw UnimplementedError('addPresetPoint() has not been implemented.');
  }

  Future<Map<String, dynamic>> turnToPreset(int presetId) {
    throw UnimplementedError('turnToPreset() has not been implemented.');
  }

  Future<Map<String, dynamic>> getConfiguration(String type) {
    throw UnimplementedError('getConfiguration() has not been implemented.');
  }

  Future<Map<String, dynamic>> setConfiguration(String type, String newConfig) {
    throw UnimplementedError('setConfiguration() has not been implemented.');
  }

  Future<Map<String, dynamic>> getWifiInfo() {
    throw UnimplementedError('getWifiInfo() has not been implemented.');
  }

  Future<Map<String, dynamic>> getBatteryPercentage() {
    throw UnimplementedError(
        'getBatteryPercentage() has not been implemented.');
  }
}
