package com.dom.camera.dom_camera;

import static com.manager.db.Define.DOWNLOAD_VIDEO_BY_FILE;
import static com.manager.device.media.MediaManager.PLAY_DEV_PLAYBACK;

import android.os.Environment;
import android.view.View;
import android.view.ViewGroup;
import com.google.gson.Gson;
import com.lib.FunSDK;
import com.lib.MsgContent;
import com.lib.sdk.struct.H264_DVR_FILE_DATA;
import com.manager.db.DownloadInfo;
import com.manager.device.DeviceManager;
import com.manager.device.media.MediaManager;
import com.manager.device.media.attribute.PlayerAttribute;
import com.manager.device.media.download.DownloadManager;
import com.manager.device.media.playback.DevRecordManager;
import com.manager.device.media.playback.RecordManager;
import com.utils.FileUtils;
import com.utils.TimeUtils;
import com.xm.ui.widget.XMRecyclerView;
import io.flutter.plugin.common.EventChannel.EventSink;
import java.io.File;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PlayBackClass {

  String deviceID;
  ViewGroup viewGroup;
  DeviceManager deviceManager = DeviceManager.getInstance();
  static RecordManager recordManager;
  static List<H264_DVR_FILE_DATA> dataList;
  static String fromDate;
  static String fromMonth;
  static String fromYear;
  static String toDate;
  static String toMonth;
  static String toYear;
  static boolean isStartPlaybackCalled = false;
  static DeviceClass.myDomResultInterface resultCallback;
  static Calendar playBackEndTime;

  static EventSink eventSink;

  public static void downloadVideoFile(
    int position,
    String deviceId,
    DeviceClass.myDomResultInterface result
  ) {
    if (dataList == null || position >= dataList.size()) {
      return;
    }

    String storagePath =
      Environment.getExternalStorageDirectory() +
      File.separator +
      Environment.DIRECTORY_DCIM +
      File.separator +
      "DOM" +
      File.separator +
      "PB_VIDEOS" +
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

    DownloadManager downloadManager = DownloadManager.getInstance(null);

    H264_DVR_FILE_DATA data = dataList.get(position);
    if (data != null) {
      String fileName = data.getFileName() + ".mp4";
      DownloadInfo downloadInfo = new DownloadInfo();
      downloadInfo.setStartTime(
        TimeUtils.getNormalFormatCalender(data.getStartTimeOfYear())
      );
      downloadInfo.setEndTime(
        TimeUtils.getNormalFormatCalender(data.getEndTimeOfYear())
      );
      downloadInfo.setDevId(deviceId);
      downloadInfo.setObj(data);
      downloadInfo.setDownloadType(DOWNLOAD_VIDEO_BY_FILE);
      downloadInfo.setSaveFileName(storagePath + fileName);
      downloadManager.addDownload(downloadInfo);
      downloadManager.startDownload();
      result.onSuccess(new ArrayList<>());
    } else {
      result.onFailed("0", "0");
    }
  }

  public PlayBackClass(
    String deviceID,
    ViewGroup viewGroup,
    String fromDate,
    String fromMonth,
    String fromYear,
    String toDate,
    String toMonth,
    String toYear,
    DeviceClass.myDomResultInterface result
  ) {
    this.deviceID = deviceID;
    this.viewGroup = viewGroup;
    this.fromDate = fromDate;
    this.fromMonth = fromMonth;
    this.fromYear = fromYear;
    this.toDate = toDate;
    this.toMonth = toMonth;
    this.toYear = toYear;
    recordManager =
      deviceManager.createRecordPlayer(viewGroup, deviceID, PLAY_DEV_PLAYBACK);
    recordManager.setChnId(0);
    recordManager.setTouchable(false);

    searchRecordByFile();
    new XMRecyclerView(viewGroup.getContext(), null);
    recordManager.setOnMediaManagerListener(
      new MediaManager.OnRecordManagerListener() {
        public void searchResult(PlayerAttribute attribute, Object data) {
          if (data != null) {
            if (data instanceof H264_DVR_FILE_DATA[]) {
              dataList = ((DevRecordManager) recordManager).getFileDataList();
            }
            List<String> timeList = new ArrayList<>();

            for (H264_DVR_FILE_DATA fileData : dataList) {
              String getStartTimeOfYear = fileData.getStartTimeOfYear();
              String getEndTimeOfYear = fileData.getEndTimeOfYear();
              timeList.add("" + getStartTimeOfYear + "__" + getEndTimeOfYear);
            }
            result.onSuccess(timeList);
          }
        }

        @Override
        public void onMediaPlayState(PlayerAttribute attribute, int state) {
          System.out.println("onMediaPlayState");
        }

        @Override
        public void onFailed(
          PlayerAttribute attribute,
          int msgId,
          int errorId
        ) {
          if (msgId == 5101) {
            result.onFailed("0" + errorId, "No Data Found");
          } else {
            result.onFailed("" + errorId, "Failed to get list from device!");
          }
        }

        //        public void onShowRateAndTime(
        //          PlayerAttribute attribute,
        //          boolean isShowTime,
        //          String time,
        //          long rate
        //        ) {}

        public void onShowRateAndTime(
          PlayerAttribute attribute,
          boolean isShowTime,
          String time,
          long rate
        ) {
          if (eventSink != null) {
            Map<String, Object> jsonData = new HashMap<>();

            jsonData.put("key", "PLAYBACK_STREAM_DATA");
            jsonData.put("time", time);
            jsonData.put("rate", rate);
            jsonData.put("isShowTime", isShowTime);
            String jsonString = new Gson().toJson(jsonData);

            SimpleDateFormat dateFormat = new SimpleDateFormat(
              "yyyy-MM-dd HH:mm:ss"
            );
            Date parsedDate;
            try {
              parsedDate = dateFormat.parse(time);
            } catch (ParseException e) {
              throw new RuntimeException(e);
            }

            Calendar currentTime = Calendar.getInstance();
            currentTime.setTime(parsedDate);
            if (currentTime.after(playBackEndTime)) {
              recordManager.stopPlay();
            } else {
              eventSink.success(jsonString);
            }
          }
        }

        public void onVideoBufferEnd(PlayerAttribute attribute, MsgContent ex) {
          System.out.println("onVideoBufferEnd");

          if (isStartPlaybackCalled) {
            isStartPlaybackCalled = false;
            resultCallback.onSuccess(new ArrayList<>());
          }
        }

        public void onPlayStateClick(View view) {
          System.out.println("onPlayStateClick");
        }
      }
    );
  }

  public static void seekToTime(int times) {
    Calendar searchTime = Calendar.getInstance();
    searchTime.set(Calendar.DAY_OF_MONTH, Integer.valueOf(fromDate));
    searchTime.set(Calendar.MONTH, Integer.valueOf(fromMonth) - 1);
    searchTime.set(Calendar.YEAR, Integer.valueOf(fromYear));
    searchTime.set(Calendar.HOUR_OF_DAY, 0);
    searchTime.set(Calendar.MINUTE, 0);
    searchTime.set(Calendar.SECOND, 0);

    int[] time = {
      searchTime.get(Calendar.YEAR),
      searchTime.get(Calendar.MONTH) + 1,
      searchTime.get(Calendar.DAY_OF_MONTH),
      0,
      0,
      0,
    };

    int absTime = FunSDK.ToTimeType(time) + times;
    recordManager.seekToTime(times, absTime);
  }

  public static void pausePlayPlayback() {
    recordManager.pausePlay();
  }

  public static void rePlayPlayback() {
    recordManager.rePlay();
  }

  public static void openVoiceBySoundPlayback() {
    recordManager.openVoiceBySound();
  }

  public static void closeVoiceBySoundPlayback() {
    recordManager.closeVoiceBySound();
  }

  public static void captureImagePlayback() {
    String storagePath =
      Environment.getExternalStorageDirectory() +
      File.separator +
      Environment.DIRECTORY_DCIM +
      File.separator +
      "DOM" +
      File.separator +
      "PB_IMAGES" +
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

    recordManager.capture(storagePath);
  }

  public static void startPlayRecord(
    int position,
    EventSink eventSinkCB,
    DeviceClass.myDomResultInterface resultCb
  ) {
    H264_DVR_FILE_DATA recordInfo = dataList.get(position);
    Calendar playCalendar = TimeUtils.getNormalFormatCalender(
      recordInfo.getStartTimeOfYear()
    );
    Calendar playCalendarEndTime = TimeUtils.getNormalFormatCalender(
      recordInfo.getEndTimeOfYear()
    );
    isStartPlaybackCalled = true;
    resultCallback = resultCb;
    eventSink = eventSinkCB;
    playBackEndTime = playCalendarEndTime;
    recordManager.startPlay(playCalendar, playCalendarEndTime);
  }

  public void searchRecordByFile() {
    if (recordManager instanceof DevRecordManager) {
      Calendar searchTime = Calendar.getInstance();
      searchTime.set(Calendar.DAY_OF_MONTH, Integer.valueOf(fromDate));
      searchTime.set(Calendar.MONTH, Integer.valueOf(fromMonth) - 1);
      searchTime.set(Calendar.YEAR, Integer.valueOf(fromYear));
      searchTime.set(Calendar.HOUR_OF_DAY, 0);
      searchTime.set(Calendar.MINUTE, 0);
      searchTime.set(Calendar.SECOND, 0);

      Calendar endTime = Calendar.getInstance();
      endTime.set(Calendar.DAY_OF_MONTH, Integer.valueOf(toDate));
      endTime.set(Calendar.MONTH, Integer.valueOf(toMonth) - 1);
      endTime.set(Calendar.YEAR, Integer.valueOf(toYear));
      endTime.set(Calendar.HOUR_OF_DAY, 23);
      endTime.set(Calendar.MINUTE, 59);
      endTime.set(Calendar.SECOND, 59);

      ((DevRecordManager) recordManager).searchFileByTime(searchTime, endTime);
    }
  }
}
