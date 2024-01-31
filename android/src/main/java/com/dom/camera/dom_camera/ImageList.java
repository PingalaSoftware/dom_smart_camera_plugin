package com.dom.camera.dom_camera;

import static com.manager.db.Define.DOWNLOAD_VIDEO_BY_FILE;

import android.os.Environment;
import com.lib.sdk.struct.H264_DVR_FILE_DATA;
import com.manager.db.DownloadInfo;
import com.manager.db.SearchFileInfo;
import com.manager.device.media.download.DownloadManager;
import com.manager.device.media.file.FileManager;
import com.utils.FileUtils;
import com.utils.TimeUtils;
import java.io.File;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;

public class ImageList {

  static String deviceId;
  static DownloadManager downloadManager;
  FileManager fileManager;
  static List<H264_DVR_FILE_DATA> ImageList;

  ImageList(String deviceId, DeviceClass.myDomResultInterface result) {
    this.deviceId = deviceId;
    downloadManager = DownloadManager.getInstance(null);
    fileManager =
      new FileManager(data -> {
        if (data != null) {
          ImageList = (List<H264_DVR_FILE_DATA>) data;
          result.onSuccess(
            new ArrayList<>(Collections.singleton(data.toString()))
          );
        } else {
          result.onFailed("", "");
        }
      });
    SearchPictureByFiles();
  }

  void SearchPictureByFiles() {
    Calendar startTime = Calendar.getInstance();
    startTime.set(Calendar.HOUR_OF_DAY, 0);
    startTime.set(Calendar.MINUTE, 0);
    startTime.set(Calendar.SECOND, 0);

    Calendar endTime = Calendar.getInstance();
    endTime.set(Calendar.HOUR_OF_DAY, 23);
    endTime.set(Calendar.MINUTE, 59);
    endTime.set(Calendar.SECOND, 59);

    SearchFileInfo searchFileInfo = new SearchFileInfo();
    searchFileInfo.setChnId(1);
    searchFileInfo.setStartTime(startTime);
    searchFileInfo.setEndTime(endTime);
    fileManager.searchPictureByFile(deviceId, searchFileInfo);
  }

  public static void downloadFile(
    int position,
    DeviceClass.myDomResultInterface result
  ) {
    if (ImageList == null || position >= ImageList.size()) {
      result.onFailed("0", "0");
      return;
    }

    String storagePath = Environment.getExternalStorageDirectory() + File.separator +
            Environment.DIRECTORY_DCIM + File.separator + "DOM" + File.separator +
            "AL_IMAGES" + File.separator;

    File domFolder = new File(Environment.getExternalStorageDirectory() +
            File.separator + Environment.DIRECTORY_DCIM + File.separator + "DOM");
    File imagesFolder = new File(storagePath);

    if (!domFolder.exists()) {domFolder.mkdirs();}
    if (!imagesFolder.exists()) {imagesFolder.mkdirs();}

    if (!FileUtils.isFileAvailable(storagePath)) {
      storagePath = Environment.getExternalStorageDirectory() + File.separator +
              Environment.DIRECTORY_DCIM + File.separator;
    }

    H264_DVR_FILE_DATA data = ImageList.get(position);
    if (data != null) {
      String fileName = data.getFileName() + ".jpg";
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
    } else result.onFailed("0", "No Image found");
  }
}
