package com.dom.camera.dom_camera;

import static com.manager.db.Define.DOWNLOAD_VIDEO_BY_FILE;
import static com.manager.device.media.MediaManager.PLAY_DEV_PLAYBACK;

import android.os.Environment;
import android.view.ViewGroup;
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
import java.io.File;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class PlayBackClass {

  String deviceID;
  ViewGroup viewGroup;
  DeviceManager deviceManager = DeviceManager.getInstance();
  static RecordManager recordManager;
  static List<H264_DVR_FILE_DATA> dataList;
  static String date;
  static String month;
  static String year;

  public static void downloadVideoFile(
    int position,
    String deviceId,
    DeviceClass.myDomResultInterface result
  ) {
    if (dataList == null || position >= dataList.size()) {
      return;
    }

    String galleryPath =
      Environment.getExternalStorageDirectory() +
      File.separator +
      Environment.DIRECTORY_DCIM +
      File.separator +
      "Camera" +
      File.separator;

    if (!FileUtils.isFileAvailable(galleryPath)) {
      galleryPath =
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
      downloadInfo.setSaveFileName(galleryPath + fileName);
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
    String date,
    String month,
    String year,
    DeviceClass.myDomResultInterface result
  ) {
    this.deviceID = deviceID;
    this.viewGroup = viewGroup;
    this.date = date;
    this.month = month;
    this.year = year;
    recordManager =
      deviceManager.createRecordPlayer(viewGroup, deviceID, PLAY_DEV_PLAYBACK);
    recordManager.setChnId(0);
    searchRecordByFile();
    new XMRecyclerView(viewGroup.getContext(), null);
    recordManager.setOnMediaManagerListener(
      new MediaManager.OnRecordManagerListener() {
        @Override
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
        public void onMediaPlayState(PlayerAttribute attribute, int state) {}

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

        @Override
        public void onShowRateAndTime(
          PlayerAttribute attribute,
          boolean isShowTime,
          String time,
          String rate
        ) {}

        @Override
        public void onVideoBufferEnd(
          PlayerAttribute attribute,
          MsgContent ex
        ) {}
      }
    );
  }

  public static void seekToTime(int times) {
    Calendar searchTime = Calendar.getInstance();
    searchTime.set(Calendar.DAY_OF_MONTH, Integer.valueOf(date));
    searchTime.set(Calendar.MONTH, Integer.valueOf(month) - 1);
    searchTime.set(Calendar.YEAR, Integer.valueOf(year));
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
    String galleryPath =
      Environment.getExternalStorageDirectory() +
      File.separator +
      Environment.DIRECTORY_DCIM +
      File.separator +
      "Camera" +
      File.separator;

    if (!FileUtils.isFileAvailable(galleryPath)) {
      galleryPath =
        Environment.getExternalStorageDirectory() +
        File.separator +
        Environment.DIRECTORY_DCIM +
        File.separator;
    }

    recordManager.capture(galleryPath);
  }

  public static void startPlayRecord(int position) {
    H264_DVR_FILE_DATA recordInfo = dataList.get(position);
    Calendar playCalendar = TimeUtils.getNormalFormatCalender(
      recordInfo.getStartTimeOfYear()
    );
    Calendar endCalendar;
    endCalendar = Calendar.getInstance();
    endCalendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(date));
    endCalendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
    endCalendar.set(Calendar.YEAR, Integer.valueOf(year));
    endCalendar.setTime(playCalendar.getTime());
    endCalendar.set(Calendar.HOUR_OF_DAY, 23);
    endCalendar.set(Calendar.MINUTE, 59);
    endCalendar.set(Calendar.SECOND, 59);
    recordManager.startPlay(playCalendar, endCalendar);
  }

  public void searchRecordByFile() {
    if (recordManager instanceof DevRecordManager) {
      Calendar searchTime = Calendar.getInstance();
      searchTime.set(Calendar.DAY_OF_MONTH, Integer.valueOf(date));
      searchTime.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      searchTime.set(Calendar.YEAR, Integer.valueOf(year));
      searchTime.set(Calendar.HOUR_OF_DAY, 0);
      searchTime.set(Calendar.MINUTE, 0);
      searchTime.set(Calendar.SECOND, 0);

      Calendar endTime = Calendar.getInstance();
      endTime.set(Calendar.DAY_OF_MONTH, Integer.valueOf(date));
      endTime.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      endTime.set(Calendar.YEAR, Integer.valueOf(year));
      endTime.set(Calendar.HOUR_OF_DAY, 23);
      endTime.set(Calendar.MINUTE, 59);
      endTime.set(Calendar.SECOND, 59);

      ((DevRecordManager) recordManager).searchFileByTime(searchTime, endTime);
    }
  }
}
