// PBViewFactory.m

#import "PBViewFactory.h"
#import "PBView.h"

@interface PBViewFactory ()
@property (nonatomic, strong) NSArray *mainPlaybackList;
@end

@implementation PBViewFactory {
    NSObject<FlutterBinaryMessenger>* _messenger;
    PBView* _PBView;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _messenger = messenger;
    }
    return self;
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(id)args {
    _PBView = [[PBView alloc] initWithFrame:frame
                                     viewIdentifier:viewId
                                          arguments:args
                                    binaryMessenger:_messenger];
    return _PBView;
}
-(void)startPlayBack:(int)msgHandle devId:(NSString*)devId {
    [_PBView startPlayBack:msgHandle devId:devId];
}
-(void)startPlayCloudVideo:(NSDate *)date msgHandle:(int)msgHandle devId:(NSString*)devId {
    [_PBView startPlayCloudVideo:date msgHandle:msgHandle devId:devId];
}

-(void)PlaybackList:(NSDate *)date completion:(void (^)(NSArray *))completion {
    NSLog(@"got access for function");
    NSMutableArray *playbackList = [NSMutableArray array];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];
    NSLog(@"1");
    if ([date compare:currentDate] == NSOrderedDescending) {
        NSLog(@"11");

        // If the date is beyond the current date, respond with an empty array
        self.mainPlaybackList = @[];
    } else if ([calendar isDate:date inSameDayAsDate:currentDate]) {
        NSLog(@"22");
        NSArray *timeRanges = [self generateTimeRangesFromDate:date];
        NSLog(@"got value");
        completion(timeRanges);

        
        
//        self.mainPlaybackList = [playbackList copy];
//        completion(self.mainPlaybackList);


//        NSDateComponents *currentComponents = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
//        currentComponents.second = 0;
//
//        while ([date compare:currentDate] == NSOrderedAscending) {
//            NSDate *startTime = [calendar dateFromComponents:currentComponents];
//            currentComponents.minute += 5;
//            NSDate *endTime = [calendar dateFromComponents:currentComponents];
//
//            if ([endTime compare:currentDate] == NSOrderedDescending) {
//                endTime = currentDate;
//            }
//
//            NSString *timeRange = [NSString stringWithFormat:@"%@__%@", startTime, endTime];
//            [playbackList addObject:timeRange];
//        }
    } else if ([date compare:currentDate] == NSOrderedAscending) {
        NSLog(@"33");

        NSDateComponents *currentComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        currentComponents.hour = 0;
        currentComponents.minute = 0;
        currentComponents.second = 0;

        for (int i = 0; i < 288; i++) {
            NSDate *startTime = [calendar dateFromComponents:currentComponents];
            currentComponents.minute += 5;
            NSDate *endTime = [calendar dateFromComponents:currentComponents];
            NSString *timeRange = [NSString stringWithFormat:@"%@__%@", startTime, endTime];
            [playbackList addObject:timeRange];
        }
    }
    NSLog(@"got playback");
    // Store the playbackList in the global variable
    self.mainPlaybackList = [playbackList copy];
    completion(self.mainPlaybackList);
}
-(int)stop{
    return [_PBView stop];
}
-(int)pause{
    return [_PBView pause];
}
-(int)resumue{
    return  [_PBView resumue];
}
-(int)openSound{
    return [_PBView openSound];
}
-(int)closeSound{
    return [_PBView closeSound];
}
-(int)snapImage{
    return [_PBView snapImage];
}
-(void)seekToTime:(NSInteger)addtime
{
    [_PBView seekToTime:addtime];
}

- (NSArray *)generateTimeRangesFromDate:(NSDate *)startDate {
    NSMutableArray *timeRanges = [NSMutableArray array];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];
    
    NSDateComponents *startComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:startDate];
    startComponents.hour = 0;
    startComponents.minute = 0;
    startComponents.second = 0;
    
    NSDate *currentDateTime = [calendar dateFromComponents:[calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:currentDate]];
    
    while ([startDate compare:currentDateTime] == NSOrderedAscending) {
        NSDate *startTime = [calendar dateFromComponents:startComponents];
        startComponents.minute += 5;
        NSDate *endTime = [calendar dateFromComponents:startComponents];
        
        if ([endTime compare:currentDateTime] == NSOrderedDescending) {
            endTime = currentDateTime;
        }
        
        NSString *timeRange = [NSString stringWithFormat:@"%@__%@", [self stringFromDate:startTime], [self stringFromDate:endTime]];
        [timeRanges addObject:timeRange];
        startDate = endTime;
    }
    
    return [timeRanges copy];
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter stringFromDate:date];
}


@end
