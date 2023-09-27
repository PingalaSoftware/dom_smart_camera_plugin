# dom_camera

Flutter plugin to control DOM Smart Cameras.

## Available Widgets

#### cameraStreamWidget()

For live stream

#### videoPlaybackWidget()

For video playback

## Available Function

#### addCamera(String wifiSsid, String wifiPassword)

#### cameraLogin(String cameraId)

#### setDeviceAlarmCallback(String callbackUrl)

#### setHumanDetection(bool isEnabled)

#### startStreaming()

#### stopStreaming()

#### startAudio()

#### stopAudio()

#### startSingleInterCom()

#### stopSingleInterCom()

#### startDualInterCom()

#### stopDualInterCom()

#### captureImageAndSaveLocal()

#### startVideRecordAndSaveLocal()

#### stopVideRecordAndSaveLocal()

#### cameraMovement(double x, double y)

#### imageListInCamera()

#### imageDownloadFromCamera(int position)

#### playbackList()

#### playFromPosition(int position)

#### downloadFromPosition(int position)

#### pausePlayBack()

#### rePlayPlayBack()

#### skipPlayBack(int hour, int minute, int sec)

#### openAudioPlayBack()

#### closeAudioPlayBack()

### #captureImageFromPlayBack()
