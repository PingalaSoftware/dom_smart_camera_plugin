// PBView.h

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>
#import "Recode.h"

@interface PBView : NSObject <FlutterPlatformView>
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

-(void)startPlayBack:(int)msgHandle devId:(NSString*)devId;
-(void)seekToTime:(NSInteger)addtime;
-(void)startPlayCloudVideo:(NSDate *)date msgHandle:(int)msgHandle devId:(NSString*)devId;
//-(void)PlaybackList:(NSDate *)date completion:(void (^)(NSArray *))completion;
-(int)pause;
-(int)resumue;
-(int)openSound;
-(int)closeSound;
-(int)snapImage;
-(int)stop;
@end
