#import "DomCameraPlugin.h"
#import "FunSDK/FunSDK.h"
#import "FunSDK/Fun_MC.h"

#import <XMNetInterface/Reachability.h>
#import "XMNetInterface/NetInterface.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if_dl.h>

#import "DataEncrypt.h"
#import "RecordInfo.h"
#import "PictureInfo.h"
#import <Photos/Photos.h>

#import <CoreLocation/CoreLocation.h>
#import "CustomView.h"
#import "CustomViewFactory.h"
#import "PBView.h"
#import "PBViewFactory.h"

#import "DeviceControl.h"
#import "RecordInfo.h"
#import "TimeInfo.h"

#define MAX_FINDFILE_SIZE        10000

@interface DomCameraPlugin () <FlutterStreamHandler>
@property (nonatomic, assign) UI_HANDLE msgHandle;
@property (nonatomic, strong) NSObject<FlutterPluginRegistrar> *pluginRegistrar;
@property (nonatomic, strong) CustomViewFactory *customViewFactory;
@property (nonatomic, strong) PBViewFactory *pbViewFactory;
@property (nonatomic, copy) FlutterEventSink _Nullable eventSink;

@end

@implementation NSMessage
+ (id)SendMessag:(NSString *) name obj:(void *) obj p1:(int)param1 p2:(int)param2 {
    NSMessage *pNew = [NSMessage alloc];
    [pNew setObj:obj];
    [pNew setParam1:param1];
    [pNew setParam2:param2];
    return pNew;
}
@end

@implementation DomCameraPlugin {
    FlutterResult flutterResult;
    NSString *mainUsername;
    NSString *mainPassword;
    NSString *mainCameraId;
    NSMutableArray *fileArray;
    NSString *pictureSaveFilePath;
    BOOL isEnableHumanDetection;
    
    NSMutableArray *fileArrayPlayback;
    BOOL isPlayBackVideoFetching;
    BOOL playBackNotIndex;
    BOOL isFileDownloadEvent;
    NSInteger playBackNotIndexPosition;
    BOOL isGetConfig;
    BOOL isWiFiConfig;
    BOOL isSetRecordConfig;
    NSString *setRecordType;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"dom_camera"
            binaryMessenger:[registrar messenger]];
  DomCameraPlugin* instance = [[DomCameraPlugin alloc] init];
    instance.pluginRegistrar = registrar;

 [registrar addMethodCallDelegate:instance channel:channel];

    [DomCameraPlugin initLanguage];
    [DomCameraPlugin initPlatform];
    [DomCameraPlugin configParam];
    
    NSLog(@"IOS Init");
    
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel
                                         eventChannelWithName:@"dom_camera/playbackListener"
                                         binaryMessenger:registrar.messenger];
    [eventChannel setStreamHandler:instance];
    
    
    instance.customViewFactory = [[CustomViewFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:instance.customViewFactory withId:@"dom_camera_stream"];
    
    instance.pbViewFactory = [[PBViewFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:instance.pbViewFactory withId:@"dom_video_playback"];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    [audioSession requestRecordPermission:^(BOOL recordPermissionGranted) {
        if (recordPermissionGranted) {
            [audioSession requestRecordPermission:^(BOOL playAndRecordPermissionGranted) {
                if (playAndRecordPermissionGranted) {
                    // User granted access to both microphone and speaker
                    NSLog(@"Microphone and Speaker access granted");
                } else {
                    // User denied access to the speaker
                    NSLog(@"Speaker access denied");
                }
            }];
        } else {
            // User denied access to the microphone
            NSLog(@"Microphone access denied");
        }
    }];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    self.msgHandle = FUN_RegWnd((__bridge LP_WND_OBJ)self);

    if ([@"WIFI_PERMISSION" isEqualToString:call.method]) {
        NSLog(@"getting permission called");
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            switch (status) {
                case kCLAuthorizationStatusNotDetermined: {
                    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
                    [locationManager requestWhenInUseAuthorization];
                    NSLog(@"kCLAuthorizationStatusNotDetermined");
                    result(@[@0]);
                    break;
                }
                case kCLAuthorizationStatusAuthorizedWhenInUse:{
                    NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse");
                    result(@[@1]);
      }
                    break;
                case kCLAuthorizationStatusAuthorizedAlways:
                    NSLog(@"kCLAuthorizationStatusAuthorizedAlways");
                    result(@[@1]);
                    break;
                    
                case kCLAuthorizationStatusDenied:
                    NSLog(@"kCLAuthorizationStatusDenied");
                    result(@[@0]);
                    break;
                case kCLAuthorizationStatusRestricted:
                    NSLog(@"kCLAuthorizationStatusDenied");
                    result(@[@0]);
                    break;
            }
    }
    else
        if ([@"LOGIN" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments;
      NSString *userName = arguments[@"userName"];
      NSString *password = arguments[@"password"];
      mainUsername =  userName;
      mainPassword = password;
      
      NSLog(@"Received data from Dart: %@, %@", userName, password);
      
      FUN_SysInit("arsp.xmeye.net; arsp1.xmeye.net; arsp2.xmeye.net", 15010);
      FUN_InitNetSDK();
    

      FUN_SysLoginToXM(self.msgHandle, [userName UTF8String], [password UTF8String],  0);
      flutterResult = result;
  }else  if ([@"STOP_CAMERA_ADD" isEqualToString:call.method]) {
      NSLog(@"STOP_CAMERA_ADD");
      FUN_DevStopAPConfig();
      result(@[]);

  }else  if ([@"ADD_CAMERA_THROUGH_WIFI" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments;
      NSString *ssid = arguments[@"ssid"];
      NSString *password = arguments[@"password"];

      char data[128] = {0};
      char infof[256] = {0};
      int encmode = 1;
      unsigned char mac[6] = {0};
      snprintf(data, 128, "S:%sP:%sT:%d", [ssid UTF8String], [password UTF8String], encmode);
      NSString* sGateway = [NetInterface getDefaultGateway];

      snprintf(infof, 256, "gateway:%s ip:%s submask:%s dns1:%s dns2:%s mac:0", [sGateway UTF8String], [[NetInterface getCurrent_IP_Address] UTF8String],"255.255.255.0",[sGateway UTF8String],[sGateway UTF8String]);
      NSString* sMac = [NetInterface getCurrent_Mac];

      sscanf([sMac UTF8String], "%x:%x:%x:%x:%x:%x", &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]);

      FUN_DevStartAPConfig(self.msgHandle, 3, [ssid UTF8String], data, infof, [sGateway UTF8String], encmode, 0, mac, 180000);
//            result(@[@"testing", sMac]);
      flutterResult = result;

      
  } else  if ([@"CAMERA_LOGIN" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments;
      NSString *cameraId = arguments[@"cameraId"];
      mainCameraId = cameraId;
      FUN_DevLogin(self.msgHandle, [cameraId UTF8String], [mainUsername UTF8String], [mainPassword UTF8String], 0);
      flutterResult = result;
  }
   else  if ([@"LIVE_STREAM" isEqualToString:call.method]) {
     NSDictionary *arguments = call.arguments;
     NSString *cameraId = arguments[@"cameraId"];
     mainCameraId = cameraId;

       [self.customViewFactory startStreaming:cameraId msgHandle:self.msgHandle];
           NSLog(@"After calling");
       flutterResult = result;
 }
  else  if ([@"STOP_STREAM" isEqualToString:call.method]) {
      // stop live stream
      [self.customViewFactory stopStreaming];

      result(@[@"not started yet"]);
 } else if ([@"PTZ_CONTROL" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments;
      NSString *cameraId = arguments[@"cameraId"];
      NSInteger cmd = [arguments[@"cmd"] integerValue];
      BOOL isStop = [arguments[@"isStop"] boolValue];
     NSLog(@"PTZ %@, %ld, %d",cameraId, (long)cmd, isStop);

      if([mainCameraId isEqualToString:cameraId]) {
          FUN_DevPTZControl(self.msgHandle, [mainCameraId UTF8String], 0, (int)cmd, (isStop) ? true: false, 4);
      }
      result(@[]);
  } else if ([@"SET_HUMAN_DETECTION" isEqualToString:call.method]) {
     NSLog(@"SET_HUMAN_DETECTION  CALLED");
      FUN_DevGetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Detect.HumanDetection", 0,0);
      NSDictionary *arguments = call.arguments;
      isEnableHumanDetection = [arguments[@"isEnabled"] boolValue];
 } else if ([@"CAPTURE_IMG" isEqualToString:call.method]) {
     NSLog(@"CAPTURE_IMG  CALLED");
     
     int resultValue = [self.customViewFactory snapImage];
     NSLog(@"got the result capture: %d", resultValue);
     result(@[@1]);
 } else if ([@"IMAGE_LIST" isEqualToString:call.method]) {
     NSLog(@"IMAGE_LIST  CALLED");
     fileArray = [[NSMutableArray alloc] initWithCapacity:0];

     NSDateComponents * components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
      H264_DVR_FINDINFO info;
      memset(&info, 0, sizeof(info));
      info.nChannelN0 = 0;
      info.nFileType  = SDK_PIC_ALL;
      info.startTime.dwYear = (int)[components year];
      info.startTime.dwMonth = (int)[components month];
      info.startTime.dwDay = (int)[components day];
      info.startTime.dwHour = 0;
      info.startTime.dwMinute = 0;
      info.startTime.dwSecond = 0;
      info.endTime.dwYear   = (int)[components year];
      info.endTime.dwMonth  = (int)[components month];
      info.endTime.dwDay    = (int)[components day];
      info.endTime.dwHour   = 23;
      info.endTime.dwMinute = 59;
      info.endTime.dwSecond = 59;
     isPlayBackVideoFetching = false;
      FUN_DevFindFile(self.msgHandle, [mainCameraId UTF8String], &info, 1000);
      flutterResult = result;
} else if ([@"IMAGE_SAVE_LOCAL" isEqualToString:call.method]) {
     NSDictionary *arguments = call.arguments;
     NSInteger position = [arguments[@"position"] integerValue];
     
     PictureInfo *pictureInfo = fileArray[position];

        
     H264_DVR_FILE_DATA fileData = {0};
     fileData.ch = (int)0;
     fileData.size = (int)pictureInfo.fileSize;
     strncpy(fileData.sFileName, [pictureInfo.fileName UTF8String], 108);
     XM_SYSTEM_TIME timeBegin = pictureInfo.timeBegin;
     fileData.stBeginTime.year = (int)timeBegin.year;
     fileData.stBeginTime.month = (int)timeBegin.month;
     fileData.stBeginTime.day = (int)timeBegin.day;
     fileData.stBeginTime.hour = ((int)timeBegin.hour);
     fileData.stBeginTime.minute = (int)timeBegin.minute;
     fileData.stBeginTime.second = (int)timeBegin.second;
     XM_SYSTEM_TIME timeEnd = pictureInfo.timeEnd;
     fileData.stEndTime.year = (int)timeEnd.year;
     fileData.stEndTime.month = (int)timeEnd.month;
     fileData.stEndTime.day = (int)timeEnd.day;
     fileData.stEndTime.hour = ((int)timeEnd.hour);
     fileData.stEndTime.minute = (int)timeEnd.minute;
     fileData.stEndTime.second = (int)timeEnd.second;
    
     NSString *directoryPath = [self getGalleryPath];
     [self checkDirectoryExist:directoryPath];

     NSString *imageDownloadName = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",timeBegin.year,timeBegin.month,timeBegin.day,timeBegin.hour,timeBegin.minute,timeBegin.second];
    pictureSaveFilePath  = [directoryPath stringByAppendingFormat:@"/%@.jpg",imageDownloadName];
     NSLog(@"d-pictureFilePath: %@", pictureSaveFilePath);
     FUN_DevDowonLoadByFile(self.msgHandle, [mainCameraId UTF8String], &fileData, [pictureSaveFilePath UTF8String], 0);

 } else if ([@"DOWNLOAD_FROM_POSITION" isEqualToString:call.method]) {
     NSLog(@"DOWNLOAD_FROM_POSITION");

     NSDictionary *arguments = call.arguments;
     NSInteger position = [arguments[@"position"] integerValue];
     
     RecordInfo *record = fileArrayPlayback[position];
     NSLog(@"%@ ++++++++",record);

     
     H264_DVR_FILE_DATA info;
     memset(&info, 0, sizeof(info));
     info.size  = (int)record.fileSize;
     XM_SYSTEM_TIME timeBegin = record.timeBegin;
     memcpy(&info.stBeginTime,  (char *)&timeBegin, sizeof(SDK_SYSTEM_TIME));
     XM_SYSTEM_TIME timeEnd = record.timeEnd;
     memcpy(&info.stEndTime, (char*)&timeEnd,sizeof(SDK_SYSTEM_TIME));
     strncpy(info.sFileName, [record.fileName UTF8String], sizeof(info.sFileName));
     info.ch = (int)record.channelNo;
  
     NSString *directoryPath = [self getGalleryPath];
     [self checkDirectoryExist:directoryPath];

     NSString *timeString = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",timeBegin.year,timeBegin.month,timeBegin.day,timeBegin.hour,timeBegin.minute,timeBegin.second];
     NSString *movieFilePath  = [directoryPath stringByAppendingFormat:@"/%@.mp4",timeString];
     NSLog(@"movieFile : %@", movieFilePath);
     pictureSaveFilePath  = [directoryPath stringByAppendingFormat:@"/%@.mp4",timeString];
     
     isFileDownloadEvent = true;
     FUN_DevDowonLoadByFile(self.msgHandle, [mainCameraId UTF8String], &info, [movieFilePath UTF8String], 0);
     result(@[@1]);
 } else if ([@"START_AUDIO" isEqualToString:call.method]) {
     int soundValue = 100;
     int resultValue = [self.customViewFactory openSound:soundValue];
     NSLog(@"start intercom %d", resultValue);
     result(@[@1]);
 } else if ([@"STOP_AUDIO" isEqualToString:call.method]) {
     int resultValue = [self.customViewFactory closeSound];
     NSLog(@"stop intercom %d", resultValue);
     result(@[@1]);
 }
 else if ([@"SINGLE_INTERCOM_START" isEqualToString:call.method]) {
      [self.customViewFactory startTalk:self.msgHandle];
     NSLog(@"start intercom");
     result(@[@1]);
 } else if ([@"SINGLE_INTERCOM_STOP" isEqualToString:call.method]) {
    [self.customViewFactory closeTalk];
     NSLog(@"stop intercom");
     result(@[@1]);
 }
 else if ([@"DUAL_INTERCOM_START" isEqualToString:call.method]) {
     [self.customViewFactory startDouTalk:self.msgHandle];
     NSLog(@"DUAL intercom");
     result(@[@1]);
 } else if ([@"DUAL_INTERCOM_STOP" isEqualToString:call.method]) {
    [self.customViewFactory stopDouTalk];
     NSLog(@"DUAL intercom");
     result(@[@1]);
 }
 else if ([@"START_RECORDING" isEqualToString:call.method]) {
     int resultData = [self.customViewFactory startRecord];
     NSLog(@"START_RECORDING %d", resultData);
     result(@[@1]);
 } else if ([@"STOP_RECORDING" isEqualToString:call.method]) {
    int resultData = [self.customViewFactory stopRecord];
     NSLog(@"STOP_RECORDING %d", resultData);
     flutterResult = result;
 }
 else if ([@"PB_PLAY" isEqualToString:call.method]) {
      [self.pbViewFactory resumue];
     flutterResult = result;
 } else if ([@"PB_PAUSE" isEqualToString:call.method]) {
    [self.pbViewFactory pause];
    result(@[@1]);
} else if ([@"PB_OPEN_SOUND" isEqualToString:call.method]) {
    [self.pbViewFactory openSound];
    result(@[@1]);
} else if ([@"PB_CLOSE_SOUND" isEqualToString:call.method]) {
    [self.pbViewFactory closeSound];
    result(@[@1]);
} else if ([@"PB_CAPTURE_SAVE_LOCAL" isEqualToString:call.method]) {
    [self.pbViewFactory snapImage];
    result(@[@1]);
} else if ([@"GET_USER_INFO" isEqualToString:call.method]) {
    FUN_SysGetUerInfo(self.msgHandle, "", "", 0);
    flutterResult = result;
} else if ([@"ADD_CAMERA_THROUGH_SERIAL_NUMBER" isEqualToString:call.method]) {
    NSDictionary *arguments = call.arguments;
    NSString *cameraId = arguments[@"cameraId"];
    NSString *cameraType = arguments[@"cameraType"];

    SDBDeviceInfo devInfo = {0};
    strncpy(devInfo.loginName, [@"admin" UTF8String], sizeof(devInfo.loginName));
    strncpy(devInfo.loginPsw, [@"" UTF8String], sizeof(devInfo.loginPsw));
    strncpy(devInfo.Devmac, [cameraId UTF8String], sizeof(devInfo.Devmac));
    
    strncpy(devInfo.Devname, [cameraId UTF8String], sizeof(devInfo.Devname));
    devInfo.nPort = 34567;
    
    if([@"NORMAL_IPC" isEqualToString:cameraType]) {
        devInfo.nType = 0;
        FUN_SysAdd_Device(self.msgHandle, &devInfo,"","",1);
        flutterResult = result;
    } else if([@"LOW_POWERED" isEqualToString:cameraType]) {
        devInfo.nType = 21;
        FUN_SysAdd_Device(self.msgHandle, &devInfo,"","",1);
        flutterResult = result;
    } else {
        result(@[@false, @"Invalid Type"]);
    }

} else if ([@"GET_CAMERA_STATE" isEqualToString:call.method]) {
    NSLog(@"camera state");
    NSDictionary *arguments = call.arguments;
    NSString *deviceMac = arguments[@"cameraId"];

    std::string myDev;
        myDev.append([deviceMac UTF8String]);
        myDev.append(";");
    NSLog(@"%s", myDev.c_str());
        FUN_SysGetDevState(self.msgHandle, myDev.c_str());
        flutterResult = result;

} else if ([@"PB_SKIP_TIME" isEqualToString:call.method]) {
    NSDictionary *arguments = call.arguments;
    NSInteger position = [arguments[@"skipTime"] integerValue];
    NSLog(@"position: %ld", (long)position);

    [self.pbViewFactory seekToTime:position];
    result(@[@1]);
} else if ([@"STOP_PLAY_BACK" isEqualToString:call.method]) {
    NSLog(@"STOP_PLAY_BACK");
    [self.pbViewFactory stop];
    result(@[@1]);
} else if ([@"PLAY_FROM_POSITION" isEqualToString:call.method]) {
    NSLog(@"PLAY_FROM_POSITION ");

    NSDictionary *arguments = call.arguments;
    NSInteger position = [arguments[@"position"] integerValue];

    if (position < [fileArrayPlayback count]) {
        if(position != 0) {
            playBackNotIndex = true;
            playBackNotIndexPosition = position;
        }
        RecordInfo *recordInfo = fileArrayPlayback[position];
        XM_SYSTEM_TIME startTime = recordInfo.timeBegin;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setYear:startTime.year];
        [components setMonth:startTime.month];
        [components setDay:startTime.day];
        [components setHour:startTime.hour];
        [components setMinute:startTime.minute];
        [components setSecond:startTime.second];
        
        NSDate *startDate = [calendar dateFromComponents:components];
       [self.pbViewFactory startPlayBack:startDate msgHandle:self.msgHandle devId:mainCameraId];
        flutterResult = result;
    } else {
        result(@[@false, @"Invalid Position"]);

    }
} else if ([@"PLAYBACK_LIST" isEqualToString:call.method]) {
     NSLog(@"playback called");
     NSDictionary *arguments = call.arguments;
     NSLog(@"%@", arguments);
        NSString *cameraId = arguments[@"cameraId"];
        NSString *fromDate = arguments[@"fromDate"];
        NSString *fromMonth = arguments[@"fromMonth"];
        NSString *fromYear = arguments[@"fromYear"];
        
        NSString *toDate = arguments[@"toDate"];
        NSString *toMonth = arguments[@"toMonth"];
        NSString *toYear = arguments[@"toYear"];

     
     fileArrayPlayback = [[NSMutableArray alloc] initWithCapacity:0];
     
     ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
     
              NSDateComponents *fromComponents = [[NSDateComponents alloc] init];
              fromComponents.year = [fromYear integerValue];
              fromComponents.month = [fromMonth integerValue];
              fromComponents.day = [fromDate integerValue];;
     
              NSDateComponents *toComponents = [[NSDateComponents alloc] init];
              toComponents.year = [toYear integerValue];
              toComponents.month = [toMonth integerValue];
              toComponents.day = [toDate integerValue];
     
     
     H264_DVR_FINDINFO info;
     memset(&info, 0, sizeof(info));
     info.nChannelN0 = channel.channelNumber;
     info.nFileType  = SDK_RECORD_ALL; //查询全部类型的录像
     info.startTime.dwYear = (int)[fromComponents year];
     info.startTime.dwMonth = (int)[fromComponents month];
     info.startTime.dwDay = (int)[fromComponents day];
     info.startTime.dwHour = 0;
     info.startTime.dwMinute = 0;
     info.startTime.dwSecond = 0;
     info.endTime.dwYear   = (int)[toComponents year];
     info.endTime.dwMonth  = (int)[toComponents month];
     info.endTime.dwDay    = (int)[toComponents day];
     info.endTime.dwHour   = 23;
     info.endTime.dwMinute = 59;
     info.endTime.dwSecond = 59;

     isPlayBackVideoFetching = true;
     NSLog(@"%@", channel);
     FUN_DevFindFile(self.msgHandle, [cameraId UTF8String], &info, MAX_FINDFILE_SIZE);
     
     flutterResult = result;
 } else if ([@"GET_CONFIG" isEqualToString:call.method]) {
     NSLog(@"GET_CONFIG");
     
     NSDictionary *arguments = call.arguments;
     NSString *type = arguments[@"type"];
     
     isGetConfig = true;
     if ([type isEqualToString:@"HUMAN_DETECT"]) {
         FUN_DevGetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Detect.HumanDetection", 0,0);
         flutterResult = result;
     } else if ([type isEqualToString:@"MOVE_DETECT"]) {
         FUN_DevGetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Detect.MotionDetect", 0,0);
         flutterResult = result;
     } else if ([type isEqualToString:@"SIMPLIFY_ENCODE"]) {
         FUN_DevGetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Simplify.Encode", 0,-1);
         flutterResult = result;
     } else if ([type isEqualToString:@"STORAGE_INFO"]) {
         FUN_DevGetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "StorageInfo", 0,-1);
         flutterResult = result;
     } else if ([type isEqualToString:@"CAMERA_PARAM"]) {
         FUN_DevGetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Camera.Param", 0,-1);
         flutterResult = result;
     } else if ([type isEqualToString:@"VIDEO_CONFIG"]) {
         FUN_DevGetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Record", 0,-1);
         flutterResult = result;
     } else if ([type isEqualToString:@"SYSTEM_INFO"]) {
         FUN_DevGetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "SystemInfo", 0,1);
         flutterResult = result;
     } else {
         isGetConfig= false;
         result(@[@false, @"Invalid Type"]);
     }
 } else if ([@"SET_CONFIG" isEqualToString:call.method]) {
     NSLog(@"SET_CONFIG");
     
     NSDictionary *arguments = call.arguments;
     NSString *type = arguments[@"type"];
     NSString *newConfig = arguments[@"newConfig"];
     
     
     NSLog(@"newConfig %@", newConfig);

    if ([type isEqualToString:@"HUMAN_DETECT"]) {
         FUN_DevSetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Detect.HumanDetection", [newConfig UTF8String], (int)[newConfig length]+1, 0);
         flutterResult = result;
     } else if ([type isEqualToString:@"MOVE_DETECT"]) {
         FUN_DevSetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Detect.MotionDetect", [newConfig UTF8String], (int)[newConfig length]+1, 0);
         flutterResult = result;
     } else if ([type isEqualToString:@"SIMPLIFY_ENCODE"]) {
         FUN_DevSetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Simplify.Encode", [newConfig UTF8String], (int)[newConfig length]+1, -1);
         flutterResult = result;
     } else if ([type isEqualToString:@"STORAGE_INFO"]) {
         FUN_DevSetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "StorageInfo", [newConfig UTF8String], (int)[newConfig length]+1, -1);
         flutterResult = result;
     } else if ([type isEqualToString:@"CAMERA_PARAM"]) {
         FUN_DevSetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Camera.Param", [newConfig UTF8String], (int)[newConfig length]+1, -1);
         flutterResult = result;
     } else if ([type isEqualToString:@"VIDEO_CONFIG"]) {
         FUN_DevSetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Record", [newConfig UTF8String], (int)[newConfig length]+1, -1);
         flutterResult = result;
     } else if ([type isEqualToString:@"SYSTEM_INFO"]) {
         FUN_DevSetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "SystemInfo", [newConfig UTF8String], (int)[newConfig length]+1, 1);
         flutterResult = result;
     } else {
         isGetConfig= false;
         result(@[@false, @"Invalid Type"]);
     }
 } else if ([@"GET_CAMERA_NAME" isEqualToString:call.method]) {
     DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:mainCameraId];
     if(devObject != nil){
         result(@[devObject.deviceName]);
     } else {
         result(@[@false, @"No Device Found"]);
     }
 } else if ([@"SET_CAMERA_NAME" isEqualToString:call.method]) {
     NSDictionary *arguments = call.arguments;
     NSString *newName = arguments[@"newName"];
     
      DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:mainCameraId];
      if(devObject != nil){
          DeviceObject *devObj = [[DeviceControl getInstance] GetDeviceObjectBySN:mainCameraId];
          SDBDeviceInfo devInfo = {0};
          strncpy(devInfo.Devmac, [mainCameraId UTF8String], 64);
          strncpy(devInfo.Devname, [newName UTF8String], 128);
          devInfo.nPort = devObj.nPort;
          devInfo.nType = devObj.nType;
          strncpy(devInfo.loginName, [mainUsername UTF8String], 16);
          strncpy(devInfo.loginPsw, [mainPassword UTF8String], 16);
          FUN_SysChangeDevInfo(self.msgHandle, &devInfo, [mainUsername UTF8String], [mainPassword UTF8String]);
          flutterResult = result;
      } else {
          result(@[@false, @"No Device Found"]);
      }
 }
    
 else if ([@"ADD_PRESET" isEqualToString:call.method]) {
     NSDictionary *arguments = call.arguments;
     NSString *presetId = arguments[@"presetId"];
     char cfg[1024];
     NSString *presetPoitnName = [NSString stringWithFormat:@"%@:%ld", [self LanguageManager_TS:"preset"],(long)presetId];
     sprintf(cfg, "{\"OPPTZControl\":{\"Command\":\"SetPreset\",\"Parameter\":{\"Channel\":0,\"Preset\":%d,\"PresetName\":\"%s\"}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",[presetId intValue], [presetPoitnName UTF8String]);
     FUN_DevCmdGeneral(self.msgHandle, [mainCameraId UTF8String], 1400, "OPPTZControl", 4096, 10000,(char *)cfg, (int)strlen(cfg) + 1, -1, 9529);
     flutterResult = result;
 } else if ([@"TURN_TO_PRESET" isEqualToString:call.method]) {
     NSDictionary *arguments = call.arguments;
     NSInteger presetId = [arguments[@"presetId"] integerValue];
     char cfg[1024];
     sprintf(cfg, "{\"OPPTZControl\":{\"Command\":\"GotoPreset\",\"Parameter\":{\"Channel\":0,\"Preset\":%d}}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",presetId);
     
     FUN_DevCmdGeneral(self.msgHandle, [mainCameraId UTF8String], 1400, "OPPTZControl", 4096, 10000,(char *)cfg, (int)strlen(cfg) + 1, -1, 9528);
     flutterResult = result;
 }
    
//    ##############################
 else if ([@"GET_WIFI_SIGNAL" isEqualToString:call.method]) {
     NSLog(@"GET_WIFI_SIGNAL:");
     isWiFiConfig = true;

     FUN_DevGetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "WifiRouteInfo", 0, 0);
//     FUN_DevGetConfig_Json(UI_HANDLE hUser, const char *szDevId, const char *szCommand, int nOutBufLen, int nChannelNO = -1, int nTimeout = 15000, int nSeq = 0);

     flutterResult = result;
 }
 else if ([@"SET_RECORD_TYPE" isEqualToString:call.method]) {
     NSDictionary *arguments = call.arguments;
     
     isSetRecordConfig = true;
     setRecordType = arguments[@"type"];

     FUN_DevGetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Record", 0, -1);
     flutterResult = result;
 }
 else if ([@"GET_BATTERY_PERCENTAGE" isEqualToString:call.method]) {
     NSDictionary *arguments = call.arguments;
     FUN_DevStartUploadData(self.msgHandle, [mainCameraId UTF8String], 5, 209);
     flutterResult = result;
//     int FUN_DevStartUploadData(UI_HANDLE hUser, const char *szDevId, int nUploadDataType, int nSeq);

//     char cfg[1024];
//     sprintf(cfg, "{\"OPPTZControl\":{\"Command\":\"GotoPreset\",\"Parameter\":{\"Channel\":0,\"Preset\":%d}}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",presetId);
//     
//     FUN_DevCmdGeneral(self.msgHandle, [mainCameraId UTF8String], 1400, "OPPTZControl", 4096, 10000,(char *)cfg, (int)strlen(cfg) + 1, -1, 9528);
//     flutterResult = result;
 }
//  else if ([@"IS_FULL_SCREEN_STREAMING" isEqualToString:call.method]) {
//      NSLog(@"IS_FULL_SCREEN_STREAMING");
//      result(@[@1]);

// //     NSDictionary *arguments = call.arguments;
// //     NSInteger presetId = [arguments[@"presetId"] integerValue];
// //     char cfg[1024];
// //     sprintf(cfg, "{\"OPPTZControl\":{\"Command\":\"GotoPreset\",\"Parameter\":{\"Channel\":0,\"Preset\":%d}}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",presetId);
// //     
// //     FUN_DevCmdGeneral(self.msgHandle, [mainCameraId UTF8String], 1400, "OPPTZControl", 4096, 10000,(char *)cfg, (int)strlen(cfg) + 1, -1, 9528);
// //     flutterResult = result;
//  }
//  else if ([@"SHOW_FULL_SCREEN" isEqualToString:call.method]) {
//      NSLog(@"SHOW_FULL_SCREEN");
//      result(@[@1]);

// //     NSDictionary *arguments = call.arguments;
// //     NSInteger presetId = [arguments[@"presetId"] integerValue];
// //     char cfg[1024];
// //     sprintf(cfg, "{\"OPPTZControl\":{\"Command\":\"GotoPreset\",\"Parameter\":{\"Channel\":0,\"Preset\":%d}}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",presetId);
// //     
// //     FUN_DevCmdGeneral(self.msgHandle, [mainCameraId UTF8String], 1400, "OPPTZControl", 4096, 10000,(char *)cfg, (int)strlen(cfg) + 1, -1, 9528);
// //     flutterResult = result;
//  }
 else {
      NSLog(@"called %@", call.method);
    result(FlutterMethodNotImplemented);
  }

}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    NSLog(@"OnCAncle with argument");
    self.eventSink = nil;

    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    NSLog(@"onListenWithArguments %@", arguments);
    self.eventSink = events;
    
    NSDictionary *data = @{@"message": @"this is a test dummy data"};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
    
    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        self.eventSink(jsonString);
    } else {
        NSLog(@"JSON serialization error: %@", error);
    }
    
    return nil;
}

-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    if (msg) {
        NSLog(@"##_____________________");
        NSLog(@"_____________________");
        NSLog(@"_____________________");
        NSLog(@"_____________________");        
        NSLog(@"_____________________");
        NSLog(@"_____________________");
        NSLog(@"_____________________");
        NSLog(@"______MAIN_______________");
        NSLog(@"MSG -- %d", msg->id);


        NSLog(@"param1 %d", msg->param1);
        NSLog(@"param2 %d", msg->param2);
        NSLog(@"param3 %d", msg->param3);
        NSLog(@"szStr %s", msg->szStr);
        NSLog(@"pObject %s", msg->pObject);
        
        NSLog(@"_____________________");
        NSLog(@"_____________________");
        NSLog(@"_____________________");
        NSLog(@"_____________________");
        NSLog(@"_____________________##");
    } else {
        NSLog(@"msg is nil");
    }
    
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            NSString *paramName = [NSString stringWithUTF8String:msg -> szStr];

            if ([paramName isEqualToString:@"OPPTZControl"]  ) {
                if (msg -> seq == 9528) {//jump success
                    if (flutterResult) {
                        flutterResult(@[@1]);
                        flutterResult = nil;
                    }
                } else if (msg -> seq == 9529) {//Set watchpoint callback
                    if (flutterResult) {
                        flutterResult(@[@1]);
                        flutterResult = nil;
                    }
                } else {
                    if (flutterResult) {
                        flutterResult(@[@false, @"Invalid operation"]);
                        flutterResult = nil;
                    }
                }
            }
            
        }
            break;
        case EMSG_SYS_CHANGEDEVINFO:{
            FUN_SysGetDevList(self.msgHandle, [mainUsername UTF8String], [mainPassword UTF8String],0);
            if (flutterResult) {
                flutterResult(@[@1]);
                flutterResult = nil;
            }
        }
            break;
        case EMSG_SYS_GET_DEV_INFO_BY_USER:{
            [self  resiveDevicelist:[NSMessage SendMessag:nil obj:msg->pObject p1:msg->param1 p2:0]];
            if (flutterResult) {
                flutterResult(@[@1]);
                flutterResult = nil;
            }
        }
            break;
        case EMSG_DEV_LOGIN: {
            if (flutterResult) {
                flutterResult(@[@1]);
                flutterResult = nil;
            }
        }
            break;
        case EMSG_SYS_GET_DEV_INFO_BY_USER_XM:{
            FUN_SysGetDevList(self.msgHandle, [mainUsername UTF8String], [mainPassword UTF8String],0);
        }
            break;
        case EMSG_SAVE_IMAGE_FILE:{
            [self saveImageToPhotosAlbum:@(msg->szStr)];
            if (flutterResult) {
                flutterResult(@[@1]);
                flutterResult = nil;
            }
        }
            break;
        case EMSG_STOP_SAVE_MEDIA_FILE: {
            [self saveVideoToPhotosAlbum:@(msg->szStr)];
            if (flutterResult) {
                flutterResult(@[@1]);
                flutterResult = nil;
            }
        }
            break;
        case EMSG_ON_FILE_DLD_COMPLETE: {
            if(isFileDownloadEvent) {
                isFileDownloadEvent = false;
                NSDictionary *jsonDictionary = @{
                    @"key": @"PLAYBACK_DOWNLOAD_PROGRESS",
                    @"progress": @100,
                    @"state": @6
                };
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
                NSString *jsonString;
                if (!jsonData) {
                    NSLog(@"Error creating JSON: %@", error.localizedDescription);
                } else {
                    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
                    if (self.eventSink) {
                        self.eventSink(jsonString);
                    }
                }
                [self saveVideoToPhotosAlbum:pictureSaveFilePath];
            } else {
                [self saveImageToPhotosAlbum:pictureSaveFilePath];
            }
        }
            break;
        case EMSG_ON_FILE_DOWNLOAD: {
            NSDictionary *jsonDictionary = @{
                @"key": @"PLAYBACK_DOWNLOAD_PROGRESS",
                @"progress": @0,
                @"state": @1
            };
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
            NSString *jsonString;
            if (!jsonData) {
                NSLog(@"Error creating JSON: %@", error.localizedDescription);
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                if (self.eventSink) {
                    self.eventSink(jsonString);
                }
            }
        }
            break;
        case EMSG_ON_FILE_DLD_POS: {
            int download = msg->param2;
            int total = msg->param1;
            if ( total>0 ) {
                float progress = download/(float)total;
                
                NSDictionary *jsonDictionary = @{
                    @"key": @"PLAYBACK_DOWNLOAD_PROGRESS",
                    @"progress": @((int)(progress * 100)),
                    @"state": @2
                };
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
                NSString *jsonString;
                if (!jsonData) {
                    NSLog(@"Error creating JSON: %@", error.localizedDescription);
                } else {
                    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    
                    if (self.eventSink) {
                        self.eventSink(jsonString);
                    }
                }
            }
            
        }
            break;
        case EMSG_ON_PLAY_INFO: {
                NSString *inputStringObjC = [NSString stringWithUTF8String:msg->szStr];
                NSArray *components = [inputStringObjC componentsSeparatedByString:@";"];
                NSString *timeString = components.firstObject;
            NSArray *components2 = [inputStringObjC componentsSeparatedByString:@"="];
            NSArray *components3 = [components2.lastObject componentsSeparatedByString:@";"];
            NSNumber *rateNumber = @([components3.firstObject integerValue]);
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *date = [dateFormatter dateFromString:timeString];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *formattedDateString = [dateFormatter stringFromDate:date];
                
                NSDictionary *jsonDictionary = @{
                    @"key": @"PLAYBACK_STREAM_DATA",
                    @"time": formattedDateString,
                    @"rate": rateNumber
                };
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
                NSString *jsonString;
                if (!jsonData) {
                    NSLog(@"Error creating JSON: %@", error.localizedDescription);
                } else {
                    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    if (self.eventSink) {
                        self.eventSink(jsonString);
                    }
                }
        }
            break;
        case EMSG_SEEK_TO_TIME:
        case EMSG_START_PLAY: {
            if(playBackNotIndex) {
                playBackNotIndex = false;
                RecordInfo *recordInfo = fileArrayPlayback[playBackNotIndexPosition];
                XM_SYSTEM_TIME startTime = recordInfo.timeBegin;

                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *todayComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
                NSDate *startOfToday = [calendar dateFromComponents:todayComponents];

                NSDateComponents *startComponents = [[NSDateComponents alloc] init];
                [startComponents setYear:startTime.year];
                [startComponents setMonth:startTime.month];
                [startComponents setDay:startTime.day];
                [startComponents setHour:startTime.hour];
                [startComponents setMinute:startTime.minute];
                [startComponents setSecond:startTime.second];
                NSDate *startDate = [calendar dateFromComponents:startComponents];

                NSTimeInterval timeDifference = [startDate timeIntervalSinceDate:startOfToday];
                
                [self.pbViewFactory seekToTime:(NSInteger)timeDifference];
            }else if (flutterResult) {
                flutterResult(@[]);
                flutterResult = nil;
            }
        }
            break;
        case EMSG_SYS_GET_DEV_STATE:{
                  DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:[self ToNSStr:msg->szStr]];
                  if(devObject != nil){
                      devObject.state = msg->param1;
                      if(msg->param1 > 0){
                          if ([devObject getDeviceTypeLowPowerConsumption]) {
                              devObject.eFunDevStateNotCode = FUN_GetDevState((devObject.deviceMac==nil ? "" : [devObject.deviceMac UTF8String]), EFunDevStateType_IDR);
                              ///The following method has the highest accuracy when called after obtaining the device status callback.
                              int devState = FUN_GetDevState([devObject.deviceMac UTF8String], EFunDevStateType_IDR);
                              if ([[self ToNSStr:msg->szStr] containsString:@"28ec"]) {
                                  if (flutterResult) {
                                      flutterResult(@[[NSNumber numberWithInt:devObject.eFunDevStateNotCode]]);
                                      flutterResult = nil;
                                  }
                              } else {
                                  if (flutterResult) {
                                      flutterResult(@[[NSNumber numberWithInt:devState]]);
                                      flutterResult = nil;
                                  }
                              }
                          } else {
                              if (devObject.state > 0) {
                                  if (flutterResult) {
                                      flutterResult(@[@1]);
                                      flutterResult = nil;
                                  }
                              }else {
                                  if (flutterResult) {
                                      flutterResult(@[@0]);
                                      flutterResult = nil;
                                  }
                              }
                          }
                      }else {
                          if (devObject.state > 0) {
                              if (flutterResult) {
                                  flutterResult(@[@1]);
                                  flutterResult = nil;
                              }
                          }else {
                              if (flutterResult) {
                                  flutterResult(@[@0]);
                                  flutterResult = nil;
                              }
                          }
                      }
                  } else {
                      if (flutterResult) {
                          flutterResult(@[@false, @"No Device Found"]);
                          flutterResult = nil;
                      }
                  }
              }
                  break;
        case EMSG_SYS_ADD_DEVICE:{
            if (msg->param1 < 0) {
                if (flutterResult) {
                    flutterResult(@[@false, [NSNumber numberWithInt:msg->param1]]);
                    flutterResult = nil;
                }
            }else{
                if (flutterResult) {
                    SDBDeviceInfo *pInfo = (SDBDeviceInfo *) msg->pObject;

                    NSString *camID =[NSString stringWithUTF8String:(pInfo->Devmac)];
                    flutterResult(@[camID]);
                    flutterResult = nil;
                }
            }
        }
            break;
        case EMSG_SYS_GET_USER_INFO:
        {
            NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
            if(msg->param1 >= 0)
            {
                char *result = (char *)msg->szStr;
                NSData *resultData = [NSData dataWithBytes:result length:strlen(result)];
                NSError *error;
                userInfoDic = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:&error];
                if (flutterResult) {
                    if (userInfoDic != nil) {
                        NSMutableDictionary *dataDic = [userInfoDic objectForKey:@"data"];
                            flutterResult(@[dataDic]);
                        flutterResult = nil;
                    }
                }
            } else {
                if (flutterResult) {
                    flutterResult(@[@false, @""]);
                    flutterResult = nil;
                }
            }
        }
            break;
        case EMSG_ON_PLAY_BUFFER_END:
            if (flutterResult) {
                flutterResult(@[]);
                flutterResult = nil;
            }
            break;
        case EMSG_DEV_AP_CONFIG:
        {
            SDK_CONFIG_NET_COMMON_V2 *pCfg = (SDK_CONFIG_NET_COMMON_V2 *)msg->pObject;
            NSString* devSn = @"";
            NSString* name = @"";
            int nDevType = 0;
            int nResult = msg->param1;
            if ( nResult>=0 && pCfg) {
                name = [NSString stringWithUTF8String:pCfg->HostName];
                devSn = [NSString stringWithUTF8String:pCfg->sSn];
                nDevType = pCfg->DeviceType;
            }
            [self stopConfig];
            if (flutterResult) {
                flutterResult(@[devSn]);
                flutterResult = nil;
            }
            return;
        }
            break;
        case EMSG_DEV_FIND_FILE: {
            if(isPlayBackVideoFetching) {
                isPlayBackVideoFetching = false;
                NSMutableArray *stringArray = [NSMutableArray array];

                if (msg->param1 < 0) {
                    if (msg->param1 < 0) {
                                   if (flutterResult) {
                                       flutterResult(@[@false, @"No file found"]);
                                       flutterResult = nil;
                                   }
                               }
                }else{

                    int num = msg->param1;
                    H264_DVR_FILE_DATA *pFile = (H264_DVR_FILE_DATA *)msg->pObject;
                    for (int i=0; i<num; i++) {
                        RecordInfo *recordInfo = [RecordInfo new];
                        recordInfo.channelNo   = pFile[i].ch;
                        recordInfo.fileType    = 0; //文件类型是文件名中 中括号中的大写字母表示，例如：[M] 移动侦测,[H]手动录像，[*]普通录像等等。可以参考 SDK_RECORD_ALL 的子类型
                        recordInfo.fileName    = [NSString stringWithUTF8String:pFile[i].sFileName];
                        recordInfo.fileSize    = pFile[i].size;
                        XM_SYSTEM_TIME timeBegin;
                        memcpy(&timeBegin, (char*)&(pFile[i].stBeginTime), sizeof(SDK_SYSTEM_TIME));
                        recordInfo.timeBegin = timeBegin;
                        XM_SYSTEM_TIME timeEnd;
                        memcpy(&timeEnd, (char*)&(pFile[i].stEndTime), sizeof(SDK_SYSTEM_TIME));
                        recordInfo.timeEnd = timeEnd;
                        SDK_SYSTEM_TIME beginTime = pFile[i].stBeginTime;
                        SDK_SYSTEM_TIME endTime = pFile[i].stEndTime;
                        NSString *beginTimeString = timeToString(beginTime);
                        NSString *endTimeString = timeToString(endTime);
                        NSString *formattedString = [NSString stringWithFormat:@"%@__%@", beginTimeString, endTimeString];
                        [stringArray addObject:formattedString];
                
                        [fileArrayPlayback addObject:recordInfo];
                    }
                }
                if (flutterResult) {
                    flutterResult(stringArray);
                    flutterResult = nil;
                }
            } else {
                if (msg->param1 < 0) {
                    if (flutterResult) {
                        flutterResult(@[@false,@"Failed to get device config"]);
                        flutterResult = nil;
                    }
                    return;
                }else{
                    int num = msg->param1;
                    H264_DVR_FILE_DATA *pFile = (H264_DVR_FILE_DATA *)msg->pObject;
                    NSMutableArray *stringArray = [NSMutableArray array];

                    for (int i=0; i<num; i++) {
                        PictureInfo *pictureInfo = [PictureInfo new];
                        
                        pictureInfo.channelNo   = pFile[i].ch;
                        pictureInfo.fileType    = 0;
                        pictureInfo.fileName    = [NSString stringWithUTF8String:pFile[i].sFileName];
                        pictureInfo.fileSize    = pFile[i].size;
                        XM_SYSTEM_TIME timeBegin;
                        memcpy(&timeBegin, (char*)&(pFile[i].stBeginTime), sizeof(SDK_SYSTEM_TIME));
                        pictureInfo.timeBegin = timeBegin;
                        XM_SYSTEM_TIME timeEnd;
                        memcpy(&timeEnd, (char*)&(pFile[i].stEndTime), sizeof(SDK_SYSTEM_TIME));
                        pictureInfo.timeEnd = timeEnd;
                        [fileArray addObject:pictureInfo];

                    }
                    for (PictureInfo *pictureInfo in fileArray) {
                        NSString *formattedFileName = [NSString stringWithFormat:@"H264_DVR_FILE_DATA st_2_fileName=%@, st_3_beginTime=", pictureInfo.fileName];
                        [stringArray addObject:formattedFileName];
                    }
                    NSString *resultString = [stringArray componentsJoinedByString:@""];

                    NSLog(@"result string: %@", resultString);
                    if (flutterResult) {
                        flutterResult(@[resultString]);
                        flutterResult = nil;
                    }
                    return;
                }
            }
            
        
        }
            break;
        case EMSG_DEV_ON_UPLOAD_DATA: {
            NSLog(@"EMSG_DEV_ON_UPLOAD_DATA");
            if (msg->param1 > 0) {
                if (flutterResult) {
                    NSLog(@"EMSG_DEV_ON_UPLOAD_DATA");

                    flutterResult(@[@(msg -> pObject)]);
                    flutterResult = nil;
                }
            } else {
                if (flutterResult) {
                    flutterResult(@[@false, @"Unable to get battery details"]);
                    flutterResult = nil;
                }
            }
        }
            break;
        case EMSG_DEV_GET_CONFIG_JSON:
            NSLog(@"EMSG_DEV_GET_CONFIG_JSON:");
            if(isSetRecordConfig) {
                isSetRecordConfig = false;
                    
                NSData *jsonData = [@(msg->pObject) dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                  options:NSJSONReadingMutableContainers
                                                                                    error:&error];
                NSMutableArray *record = jsonObject[@"Record"];
                if([@"ALWAYS" isEqualToString:setRecordType]) {
                    for (NSMutableDictionary *recordDict in record) {
                        NSMutableArray *mask = recordDict[@"Mask"];
                        for (NSMutableArray *innerMask in mask) {
                            innerMask[0] = @"0x00000007";
                        }
                    }
                }else if([@"ALARM" isEqualToString:setRecordType])  {
                    for (NSMutableDictionary *recordDict in record) {
                        NSMutableArray *mask = recordDict[@"Mask"];
                        for (NSMutableArray *innerMask in mask) {
                            innerMask[0] = @"0x00000006";
                        }
                    }
                } else if([@"NEVER" isEqualToString:setRecordType])  {
                    for (NSMutableDictionary *recordDict in record) {
                        NSMutableArray *mask = recordDict[@"Mask"];
                        for (NSMutableArray *innerMask in mask) {
                            innerMask[0] = @"0x00000000";
                        }
                    }
                }
                       
                
                NSData *updatedJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                                           options:NSJSONWritingPrettyPrinted
                                                                             error:&error];

                NSString *updatedJsonString = [[NSString alloc] initWithData:updatedJsonData
                                                                    encoding:NSUTF8StringEncoding];
                FUN_DevSetConfig_Json(self.msgHandle, [mainCameraId UTF8String], "Record", [updatedJsonString UTF8String], (int)[updatedJsonString length]+1, -1);
            }
            else if([([NSString stringWithUTF8String:msg->szStr]) isEqualToString:@"WifiRouteInfo"]) {
                isWiFiConfig = true;
                NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                NSLog(@"EMSG_DEV_GET_CONFIG_JSON:1");

                NSError *error;
                NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                NSLog(@"EMSG_DEV_GET_CONFIG_JSON:2");

                if (!retDic) {
                    NSLog(@"EMSG_DEV_GET_CONFIG_JSON:2.1");

                    return;
                }
                NSLog(@"EMSG_DEV_GET_CONFIG_JSON:3");

                NSLog(@"retDic %@", retDic);

                NSDictionary *dicInfo = [retDic objectForKey:@"WifiRouteInfo"];
                NSLog(@"EMSG_DEV_GET_CONFIG_JSON:4");

                NSLog(@"dicInfo %@", dicInfo);
//                    NSDictionary *jsonDictionary = @{
//                        @"wlanStatus": @"PLAYBACK_DOWNLOAD_PROGRESS",
//                        @"eth0Status": @100,
//                        @"wlanMac": @6,
//                        @"signalLevel":@""
//                    };
//                    NSError *error;
//                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
//                    NSString *jsonString;
//                    if (!jsonData) {
//                        NSLog(@"Error creating JSON: %@", error.localizedDescription);
//                    } else {
//                        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//                        if (flutterResult) {
//                            flutterResult(@[jsonString]);
//                            flutterResult = nil;
//                        }
//                    }
                
            }
            else
            if (msg->param1 < 0) {
                isWiFiConfig = false;
                isGetConfig = false;
                if (flutterResult) {
                    flutterResult(@[@false,@"Failed to get device config"]);
                    flutterResult = nil;
                }
                return;
            }else{
                if(isGetConfig) {
                    isGetConfig = false;
                    if (flutterResult) {
                        flutterResult(@[@(msg->pObject)]);
                        flutterResult = nil;
                    }
                } else {
                        if (msg->pObject == NULL) {
                            if (flutterResult) {
                                flutterResult(@[@false,@"Failed to get device config"]);
                                flutterResult = nil;
                            }
                            return;
                        }
                        NSData *data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
                        if ( data == nil ){
                            if (flutterResult) {
                                flutterResult(@[@false,@"Failed to get device config"]);
                                flutterResult = nil;
                            }
                            return;
                        }
                        NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                        if ( appData == nil) {
                            if (flutterResult) {
                                flutterResult(@[@false,@"Failed to get device config"]);
                                flutterResult = nil;
                            }
                            return;
                        }
                        NSMutableDictionary *humanDetectionDic;
                        NSString* strConfigName = [appData valueForKey:@"Name"];
                        if ([strConfigName containsString:[NSString stringWithFormat:@"Detect.HumanDetection.[%d]",0]]) {
                            humanDetectionDic = [[appData objectForKey:strConfigName] mutableCopy];
                            NSLog(@"humman detection dic %@", humanDetectionDic);
                            [self updateHumanDetection:humanDetectionDic];
                        }
                }
            }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:
            if (msg->param1 < 0) {
                if (flutterResult) {
                    flutterResult(@[@false,@"Failed to save config changes"]);
                    flutterResult = nil;
                }
                return;
            }else{
                if (flutterResult) {
                    flutterResult(@[@true,@"Config Updated"]);
                    flutterResult = nil;
                }
                return;
            }
            break;
            
        default:
            NSLog(@"got some other value, check msg log above");
            break;
    }
}

- (void)resiveDevicelist:(NSMessage *)msg {
    [[DeviceControl getInstance] clearDeviceArray];
    SDBDeviceInfo *pInfos = (SDBDeviceInfo *)[msg obj];
    for(int i = 0; i < [msg param1]; ++i){
        //把结构体数据转换为对象数据
        DeviceObject *devObject = [self addDevice:&(pInfos[i])];
        NSLog(@"devObject %@",devObject);
        [[DeviceControl getInstance] addDevice:devObject];
    }
    //获取到的数组，和本地已经保存的数组进行对比
    [[DeviceControl getInstance] checkDeviceValid];
    DeviceObject *devObject2 = [[DeviceControl getInstance] GetDeviceObjectBySN:mainCameraId];
    NSLog(@"devObject2: %@",devObject2);
    
}
#pragma mark 读取数据、数组中添加设备
- (DeviceObject *)addDevice:(SDBDeviceInfo *)pInfo {
    DeviceObject *devObject = [[DeviceObject alloc] init];
    devObject.deviceMac = [NSString stringWithUTF8String:(pInfo->Devmac)];
    devObject.deviceName = [NSString stringWithUTF8String:(pInfo->Devname)];
    devObject.loginName = [NSString stringWithUTF8String:(pInfo->loginName)];
    devObject.loginPsw = [NSString stringWithUTF8String:(pInfo->loginPsw)];
    devObject.nPort = pInfo->nPort;
    devObject.nType = pInfo->nType;
    return devObject;
}


-(int)stopConfig{
    FUN_DevStopAPConfig();
    return 0;
}

NSString* timeToString(SDK_SYSTEM_TIME time) {
    NSString *timeString = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", time.year, time.month, time.day, time.hour, time.minute, time.second];
    return timeString;
}


- (NSString *)ToNSStr:(const char*)szStr {
    if (szStr == NULL) {
        NSLog(@"Error szStr is null!");
        return @"";
    }
    NSString *retStr = [NSString stringWithUTF8String:szStr];
    if (retStr == nil || (retStr.length == 0 && strlen(szStr) > 0)) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData *data = [NSData dataWithBytes:szStr length:strlen(szStr)];
        retStr = [[NSString alloc] initWithData:data encoding:enc];
    }
    if (retStr == nil) {
        retStr = @"";
    }
    return retStr;
}
- (NSString *)LanguageManager_TS:(const char*)key {
    const char *value;
    value = Fun_TS(key);
    return [self ToNSStr:value];
}

- (NSString *)getGalleryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *galleryPath = [documentsDirectory stringByAppendingPathComponent:@"/DCIM/DOM"];
    return galleryPath;
}


- (NSString*)checkDirectoryExist:(NSString*)file{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL ifExist = [manager fileExistsAtPath:file isDirectory:&isDir];
    NSLog(@"ifExist %d",ifExist);
    if (!(isDir && ifExist)) {
        BOOL create = [manager createDirectoryAtPath:file withIntermediateDirectories:YES attributes:nil error:nil];
        if (!create) {
        }
    }
    return file;
}

- (void)saveVideoToPhotosAlbum:(NSString *)imagePath {
    // Request authorization to access the Photos library
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            // Save the image to the Photos library
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:imageURL];
            } completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"Image saved to Photos library");
                } else {
                    NSLog(@"Error saving image to Photos library: %@", error);
                }
            }];
        } else {
            NSLog(@"Permission to access Photos library denied");
        }
    }];
}


- (void)saveImageToPhotosAlbum:(NSString *)imagePath {
    // Request authorization to access the Photos library
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            // Save the image to the Photos library
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
                [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:imageURL];
            } completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"Image saved to Photos library");
                } else {
                    NSLog(@"Error saving image to Photos library: %@", error);
                }
            }];
        } else {
            NSLog(@"Permission to access Photos library denied");
        }
    }];
}


- (void)updateHumanDetection:(NSMutableDictionary *)humanDetectionDic {
    NSLog(@"%d",isEnableHumanDetection);
    [humanDetectionDic setObject:@(isEnableHumanDetection) forKey:@"Enable"];

    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:humanDetectionDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *strValues = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"str value %@", strValues);
    FUN_DevSetConfig_Json(self.msgHandle, [mainCameraId UTF8String],"Detect.HumanDetection",[strValues UTF8String] ,(int)[strValues length]+1,0);
}

- (NSString *)getCurrent_IP_Address {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}


+ (void)initLanguage {
    SInitParam pa;
    pa.nAppType = H264_DVR_LOGIN_TYPE_MOBILE;
    strcpy(pa.sLanguage,"en");
    strcpy(pa.nSource, "xmshop");
    FUN_Init(0, &pa);
    Fun_LogInit(FUN_RegWnd((__bridge LP_WND_OBJ)self), "", 0, "", 2);
}

+ (void)initPlatform {
    FUN_XMCloundPlatformInit([@"6360eabe28d6ae7c7ae27b9b" UTF8String], [@"f5e1461fd143a88c20e2f15daae59643" UTF8String], [@"15a50f97a1cc443db1d65dce37adc028" UTF8String], 8);
}


+ (void)configParam {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray lastObject];
    
    FUN_SetFunStrAttr(EFUN_ATTR_CONFIG_PATH, [[path stringByAppendingString:@"/Configs/"] UTF8String]);
    FUN_SetFunStrAttr(EFUN_ATTR_UPDATE_FILE_PATH,[[path stringByAppendingString:@"/Updates/"] UTF8String]);
    FUN_SetFunStrAttr(EFUN_ATTR_TEMP_FILES_PATH,[[path stringByAppendingString:@"/Temps/"] UTF8String]);
    FUN_SetFunStrAttr(EFUN_ATTR_SAVE_LOGIN_USER_INFO,[[path stringByAppendingString:@"/UserInfo.db"] UTF8String]);
    FUN_SetFunStrAttr(EFUN_ATTR_USER_PWD_DB,[[path stringByAppendingString:@"/password.txt"] UTF8String]);
    FUN_SetFunIntAttr(EFUN_ATTR_AUTO_DL_UPGRADE, 0);
    FUN_SetFunIntAttr(EFUN_ATTR_SUP_RPS_VIDEO_DEFAULT, 1);
    FUN_SetFunIntAttr(EFUN_ATTR_SET_NET_TYPE, [DomCameraPlugin getNetworkType]);

    FUN_SysInit([[path stringByAppendingString:@"/DomUser.db"] UTF8String]);
    FUN_SysInitAsAPModel([[path stringByAppendingString:@"/APDevs.db"] UTF8String]);
    
    [[[DataEncrypt alloc] init] initP2PDataEncrypt];
    FUN_SysInit("arsp.xmeye.net;arsp1.xmeye.net;arsp2.xmeye.net", 15010);
    FUN_InitNetSDK();
}

+(int)getNetworkType {
    Reachability*reach=[Reachability reachabilityWithHostName:@"www.apple.com"];
    switch([reach currentReachabilityStatus]){
        case ReachableViaWiFi:
            return 1;
        case ReachableViaWWAN:
            return 2;
        default:
            return 0;
            break;
    }
}

- (void)dealloc {
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}


@end
