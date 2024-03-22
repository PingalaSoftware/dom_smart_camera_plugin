// CustomView.m

#import "CustomView.h"
#import "FunSDK/FunSDK.h"
#import "DisplayView.h"
#import <FunSDK/Fun_WebRtcAudio.h>
#import <Photos/Photos.h>

@interface CustomView ()
{
    int talkType;
}
@property (nonatomic, assign) FUN_HANDLE player;
@property (nonatomic, assign) BOOL streamStatus;
@property (nonatomic, assign) BOOL IsYuv;
@end

@implementation CustomView {
    DisplayView* _view;
    NSString *movieFilePath;
}

- (instancetype)initWithFrame:(CGRect)frame
              viewIdentifier:(int64_t)viewId
                   arguments:(id)args
             binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _view = [[DisplayView alloc] initWithFrame:frame];
        self.streamStatus = NO;
    }
    return self;
}

- (UIView*)view {
    return _view;
}

- (void)startStream:(NSString*)cameraId msgHandle:(int)msgHandle {
    if (self.streamStatus) {
        FUN_MediaStop(self.player, 0);
    }
    
    self.player = FUN_MediaRealPlay(msgHandle, [cameraId UTF8String], 0, 1, (__bridge LP_WND_OBJ)_view, 0);
    self.streamStatus = YES;
}

- (void)stopStream {
    FUN_MediaStop(self.player, 0);
    self.streamStatus = NO;
    _view.backgroundColor = [UIColor yellowColor];
}

- (void)dispose {
    [self stopStream];
    _player = 0;
    
    [_view removeFromSuperview];
}

- (int)openSound:(int)soundValue {
    return FUN_MediaSetSound(self.player, soundValue, 0);
}

- (int)closeSound {
    return FUN_MediaSetSound(self.player, 0, 0);
}

- (void)startTalk:(int)msgHandle{
    talkType = 0;
    if (_audioRecode == nil) {
        _audioRecode = [[Recode alloc] init];
    }
    [_audioRecode startRecode:self.deviceMac];
    //先停止音频
    FUN_MediaSetSound(_handle, 0, 0);
    if (_hTalk == 0) {
        //开始对讲,单向对讲首次启动时，回调成功之后暂停设备上传音频数据
       _hTalk = FUN_DevStarTalk(msgHandle, [self.deviceMac UTF8String], FALSE, 0, 0);
    }else{
        //单向对讲后续APP讲话时，暂停设备端上传音频数据
        const char *str = "{\"Name\":\"OPTalk\",\"OPTalk\":{\"Action\":\"PauseUpload\"},\"SessionID\":\"0x00000002\"}";
        FUN_DevCmdGeneral(msgHandle, [self.deviceMac UTF8String], 1430, "PauseUpload", 0, 0, (char*)str, 0, -1, 0);
    }
    //APP停止播放设备音频
    FUN_MediaSetSound(_hTalk, 0, 0);
}

- (void)pauseTalk:(int)msgHandle{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_audioRecode != nil) {
            [_audioRecode stopRecode];
            _audioRecode = nil;
        }
        //恢复设备端上传音频数据
        const char *str = "{\"Name\":\"OPTalk\",\"OPTalk\":{\"Action\":\"ResumeUpload\"},\"SessionID\":\"0x00000002\"}";
        FUN_DevCmdGeneral(msgHandle, [self.deviceMac UTF8String], 1430, "ResumeUpload", 0, 0, (char*)str, 0, -1, 0);
        //app播放设备端音频
        FUN_MediaSetSound(_hTalk, 100, 0);
    });
}
//停止预览->停止对讲，停止音频
-(void)closeTalk{
    if (_hTalk != 0) {
        if (_audioRecode != nil) {
            [_audioRecode stopRecode];
            _audioRecode = nil;
        }
        if (_hTalk != 0) {
            FUN_DevStopTalk(_hTalk);
            FUN_MediaSetSound(_hTalk, 0, 0);
            _hTalk = 0;
        }else{
            FUN_MediaSetSound(_handle, 0, 0);
        }
    }
}

- (void)startDouTalk:(BOOL)needEchoCancellation msgHandle:(int)msgHandle {
    
    //双向对讲的回声消除功能
    SAudioProcessParams info = SAudioProcessParams();
    if (!needEchoCancellation) {//不需要回声消除时不开启
        info.nFuncBit = 1 << E_WEBRTC_AUDIO_FUNC_NS | 1 << E_WEBRTC_AUDIO_FUNC_AGC;
    }
    WebRtcAudio_Init(&info);//音频增益开启
    
    talkType = 1;
    //先停止音频
    FUN_MediaSetSound(_handle, 0, 0);
    
    if (_audioRecode == nil) {
        _audioRecode = [[Recode alloc] init];
    }
    //APP手机音频上传
    [_audioRecode startRecode:self.deviceMac];
    
    if (_hTalk == 0) {
        //开始对讲
        _hTalk = FUN_DevStarTalk(msgHandle, [self.deviceMac UTF8String], FALSE, 0, 0);
    }
    //app播放设备端音频
    FUN_MediaSetSound(_hTalk, 100, 0);
}
- (void)stopDouTalk {
    [self closeTalk];
}
- (BOOL)isSupportTalk{
    //鱼眼灯泡不支持对讲 其他都支持 所以先直接返回ture 后期修改语言灯泡对讲
    return YES;
}
-(int)snapImage{
    NSString *dateString = [self GetSystemTimeString];
    NSString *file = [self getPhotoPath];
    NSString *pictureFilePath = [file stringByAppendingFormat:@"/%@.jpg",dateString];
    int resultData = FUN_MediaSnapImage(self.player, [pictureFilePath UTF8String]);
    return resultData;
}

-(int)startRecord{
    NSString *dateString = [self GetSystemTimeString];
    NSString *file = [self getGalleryPath];
    
    if (self.IsYuv == YES) {
        movieFilePath = [file stringByAppendingFormat:@"/%@.fvideo",dateString];
        int resultData =   FUN_MediaStartRecord(self.player, [movieFilePath UTF8String]);

        return resultData;
    }else{
        movieFilePath = [file stringByAppendingFormat:@"/%@.mp4",dateString];
        int resultData =   FUN_MediaStartRecord(self.player, [movieFilePath UTF8String]);

        return resultData;
    }
}

-(int)stopRecord{
    int resultData = FUN_MediaStopRecord(self.player);
    return resultData;
}

- (NSString *)getGalleryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *galleryPath = [documentsDirectory stringByAppendingPathComponent:@"/DCIM/DOM"];
    [self checkDirectoryExist:galleryPath];
    return galleryPath;
}
- (void)saveMediaToPhotosAlbum:(NSString *)mediaPath isImage:(BOOL)isImage {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                NSURL *mediaURL = [NSURL fileURLWithPath:mediaPath];

                if (isImage) {
                    [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:mediaURL];
                } else {
                    [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:mediaURL];
                }

            } completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"Media saved to Photos library");
                } else {
                    NSLog(@"Error saving media to Photos library: %@", error);
                }
            }];
        } else {
            NSLog(@"Permission to access Photos library denied");
        }
    }];
}

- (NSString *)GetSystemTimeString {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:nowDate];
    return dateString;
}
- (NSString *)getPhotoPath {
    NSString *photosPath = [[self documentsPath] stringByAppendingString:@"/Photos"];
    [self checkDirectoryExist:photosPath];
    return photosPath;
}
-(NSString *)getVideoPath {
    NSString *file = [self cachesPath];
    return [self getVideoPathString:file];
}
- (NSString *)getVideoPathString:(NSString *)file {
    file = [file stringByAppendingPathComponent:@"Video"];
    return [self checkDirectoryExist:file];
}
- (NSString *)cachesPath
{
    static dispatch_once_t onceToken;
    static NSString *cachedPath;
    
    dispatch_once(&onceToken, ^{
        cachedPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    });
    
    return cachedPath;
}
- (NSString *)documentsPath
{
    static dispatch_once_t onceToken;
    static NSString *cachedPath;

    dispatch_once(&onceToken, ^{
        cachedPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    });

    return cachedPath;
}
-(NSString*)checkDirectoryExist:(NSString*)file{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL ifExist = [manager fileExistsAtPath:file isDirectory:&isDir];
    if (!(isDir && ifExist)) {
        BOOL create = [manager createDirectoryAtPath:file withIntermediateDirectories:YES attributes:nil error:nil];
        if (!create) {
        }
    }
    return file;
}

@end
