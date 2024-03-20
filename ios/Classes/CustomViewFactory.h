// CustomViewFactory.h

#import <Flutter/Flutter.h>

@interface CustomViewFactory : NSObject <FlutterPlatformViewFactory>

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (void)startStreaming:(NSString *)cameraId msgHandle:(int)msgHandle;
- (void)stopStreaming;
- (int)openSound:(int)soundValue;
- (int)closeSound;

-(void)startTalk:(int)msgHandle;
-(void)pauseTalk:(int)msgHandle;
- (void)closeTalk;
- (void)startDouTalk:(int)msgHandle;
- (void)stopDouTalk;
- (int)snapImage;
-(int)startRecord;
-(int)stopRecord;

@end
