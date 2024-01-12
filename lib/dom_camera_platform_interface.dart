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
      String date, String month, String year) {
    throw UnimplementedError(
        'playbackList(String date, String month, String year) has not been implemented.');
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

  Map<String, dynamic> skipPlayBack(int skipTime) {
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
}
