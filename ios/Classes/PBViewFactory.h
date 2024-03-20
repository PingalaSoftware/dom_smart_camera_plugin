// PBViewFactory.h

#import <Flutter/Flutter.h>

@interface PBViewFactory : NSObject <FlutterPlatformViewFactory>

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
-(void)startPlayBack:(NSDate *)date msgHandle:(int)msgHandle devId:(NSString*)devId;
-(void)startPlayCloudVideo:(NSDate *)date msgHandle:(int)msgHandle devId:(NSString*)devId;
-(void)PlaybackList:(NSDate *)date completion:(void (^)(NSArray *))completion;
-(int)pause;
-(int)resumue;
-(int)openSound;
-(int)closeSound;
-(int)snapImage;
-(int)stop;

-(void)seekToTime:(NSInteger)addtime;
@end
