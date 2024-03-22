// PBView.m

#import "PBView.h"
#import "FunSDK/FunSDK.h"
#import "DisplayView.h"
#import <FunSDK/Fun_WebRtcAudio.h>
#import <Photos/Photos.h>

#import "CustomView.h"
@interface PBView ()
{
    H264_DVR_FINDINFO Info;
}
@property (nonatomic, assign) FUN_HANDLE player;
@property (nonatomic, assign) BOOL streamStatus;
@property (nonatomic, assign) BOOL IsYuv;
@property (nonatomic, assign) BOOL liveStatus;
@property (nonatomic, assign) BOOL playStatus;
@end

@implementation PBView {
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

- (void)dispose {
    _player = 0;
    
    [_view removeFromSuperview];
}
-(void)seekToTime:(NSInteger)addtime{
    FUN_MediaSeekToTime(self.player, (int)addtime, 0, 0);
}
-(void)startPlayBack:(int)msgHandle devId:(NSString*)devId{
    [self stop];
    struct H264_DVR_FINDINFO requestInfo;
    memset(&requestInfo, 0, sizeof(H264_DVR_FINDINFO));
   
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    
    requestInfo.nChannelN0 = self.channel;
    requestInfo.nFileType = 0;
    requestInfo.startTime.dwYear = (int)[components year];
    requestInfo.startTime.dwMonth = (int)[components month];
    requestInfo.startTime.dwDay = (int)[components day];
    requestInfo.startTime.dwHour = 0;
    requestInfo.startTime.dwMinute = 0;
    requestInfo.startTime.dwSecond = 0;
    
    requestInfo.endTime.dwYear = (int)[components year];
    requestInfo.endTime.dwMonth = (int)[components month];
    requestInfo.endTime.dwDay = (int)[components day];
    requestInfo.endTime.dwHour = 23;
    requestInfo.endTime.dwMinute = 59;
    requestInfo.endTime.dwSecond = 59;
    [self start:requestInfo msgHandle:msgHandle devId:devId];
}
-(int)start:(H264_DVR_FINDINFO)findInfo msgHandle:(int)msgHandle devId:(NSString*)devId{
    Info = findInfo;
    return [self start:msgHandle devId:devId];
}
-(int)start:(int)msgHandle devId:(NSString*)devId
{
    self.liveStatus = YES;
    self.player = FUN_MediaNetRecordPlayByTime(msgHandle, [devId UTF8String], &Info, (__bridge LP_WND_OBJ)_view);
    return self.player;
}

- (void)startPlayCloudVideo:(NSDate*)date msgHandle:(int)msgHandle devId:(NSString*)devId {
    SDK_SYSTEM_TIME beginTime;
    SDK_SYSTEM_TIME endTime;
    beginTime.year = [self getYearFormDate:date];
    beginTime.month = [self getMonthFormDate:date];
    beginTime.day = [self getDayFormDate:date];
    beginTime.hour = [self getHourFormDate:date];
    beginTime.minute = [self getMinuteFormDate:date];
    beginTime.second = [self getSecondFormDate:date];
    
    endTime.year = [self getYearFormDate:date];
    endTime.month = [self getMonthFormDate:date];
    endTime.day = [self getDayFormDate:date];
    endTime.hour = 23;
    endTime.minute = 59;
    endTime.second = 59;
    
    time_t ToTime_t(SDK_SYSTEM_TIME *time);
    int beginTimeInt = (int)ToTime_t(&beginTime);
    
    time_t ToTime_t(SDK_SYSTEM_TIME *time);
    int endTimeInt = (int)ToTime_t(&endTime);
    self.liveStatus = YES;
    self.player = FUN_MediaCloudRecordPlay(msgHandle, [devId UTF8String],0, "", beginTimeInt, endTimeInt, (__bridge LP_WND_OBJ)_view);
}
-(int)openSound{
    return FUN_MediaSetSound(self.player, 100, 0);
}
-(int)closeSound{
    return FUN_MediaSetSound(self.player, 0, 0);
}

-(int)stop{
    self.liveStatus = NO;
    return FUN_MediaStop(self.player, 0);
}
-(int)pause{
    int nRet = -1;
    if ( self.liveStatus == YES ) {
        nRet = FUN_MediaPause(self.player, 1, 0);
        self.playStatus = NO;
    }
    return nRet;
}
-(int)resumue{
    if ( self.playStatus != NO ) {
        return -1;
    }
    self.playStatus = YES;
    return FUN_MediaPause(self.player, 0);
}

-(void)refresh:(int)msgHandle
{
    FUN_MediaRefresh(msgHandle);
}

-(int)setIntelPlay
{
    return Fun_MediaSetIntellPlay(self.player,  ((1 << EMSSubType_INVASION | 1 << EMSSubType_STRANDED) & 0x3FFFFFF), 8);
}
-(int)stopIntelPlay
{
    return Fun_MediaSetIntellPlay(self.player,  ((1 << EMSSubType_INVASION | 1 << EMSSubType_STRANDED) & 0x3FFFFFF), 0);
}

-(void)setPlaySpeed:(int)speed
{
    FUN_MediaSetPlaySpeed(self.player, speed, 0);
}
-(int)snapImage{
    NSString *dateString = [self GetSystemTimeString];
    NSString *file = [self getGalleryPath];
    [self checkDirectoryExist:file];
    
    NSString *pictureFilePath = [file stringByAppendingFormat:@"/%@.jpg",dateString];
    int resultData = FUN_MediaSnapImage(self.player, [pictureFilePath UTF8String], 0);
    return resultData;
}


- (NSString *)GetSystemTimeString {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:nowDate];
    return dateString;
}
- (NSString *)getGalleryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *galleryPath = [documentsDirectory stringByAppendingPathComponent:@"/DCIM/DOM"];
    return galleryPath;
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
- (int)getYearFormDate:(NSDate*)date{
    NSArray *array = [self getDateAray:date];
    if (array!= nil && array.count==3) {
        return [[array objectAtIndex:0] intValue];
    }
    return 2017;
}
- (int)getMonthFormDate:(NSDate*)date{
    NSArray *array = [self getDateAray:date];
    if (array!= nil && array.count==3) {
        return [[array objectAtIndex:1] intValue];
    }
    return 1;
}
- (int)getDayFormDate:(NSDate*)date{
    NSArray *array = [self getDateAray:date];
    if (array!= nil && array.count==3) {
        return [[array objectAtIndex:2] intValue];
    }
    return 1;
}
- (int)getHourFormDate:(NSDate*)date {
    NSArray *array = [self getTimeAray:date];
    if (array!= nil && array.count==3) {
        return [[array objectAtIndex:0] intValue];
    }
    return 0;
}
- (int)getMinuteFormDate:(NSDate*)date {
    NSArray *array = [self getTimeAray:date];
    if (array!= nil && array.count==3) {
        return [[array objectAtIndex:1] intValue];
    }
    return 0;
}
- (int)getSecondFormDate:(NSDate*)date {
    NSArray *array = [self getTimeAray:date];
    if (array!= nil && array.count==3) {
        return [[array objectAtIndex:2] intValue];
    }
    return 0;
}
-(NSArray*)getDateAray:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSArray *array = [dateString componentsSeparatedByString:@"-"];
    if (array == nil || array.count <3) {
        array = [NSArray arrayWithObjects:@"2017",@"1",@"1", nil];
    }
    return array;
}
-(NSArray*)getTimeAray:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSArray *array = [dateString componentsSeparatedByString:@":"];
    if (array == nil || array.count <3) {
        array = [NSArray arrayWithObjects:@"0",@"0",@"0", nil];
    }
    return array;
}
@end
