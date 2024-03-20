// CustomView.h

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>
#import "Recode.h"

@interface CustomView : NSObject <FlutterPlatformView>
{
    Recode *_audioRecode;
    int _hTalk;
}
@property (nonatomic, strong) NSString *deviceMac;
@property (nonatomic) int channel;
@property (nonatomic) int handle;

- (instancetype)initWithFrame:(CGRect)frame
              viewIdentifier:(int64_t)viewId
                   arguments:(id)args
             binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (void)startStream:(NSString*)cameraId msgHandle:(int)msgHandle;
- (void)stopStream;
- (int)openSound:(int)soundValue;
- (int)closeSound;

-(void)startTalk:(int)msgHandle;
-(void)pauseTalk:(int)msgHandle;
- (void)closeTalk;
- (void)startDouTalk:(BOOL)needEchoCancellation msgHandle:(int)msgHandle;
- (void)stopDouTalk;
- (int)snapImage;
-(int)startRecord;
-(int)stopRecord;

@end
