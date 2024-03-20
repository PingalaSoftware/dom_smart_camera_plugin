// CustomViewFactory.m

#import "CustomViewFactory.h"
#import "CustomView.h"

@implementation CustomViewFactory {
    NSObject<FlutterBinaryMessenger>* _messenger;
    CustomView* _customView;
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
    _customView = [[CustomView alloc] initWithFrame:frame
                                     viewIdentifier:viewId
                                          arguments:args
                                    binaryMessenger:_messenger];
    return _customView;
}

- (void)startStreaming:(NSString *)cameraId msgHandle:(int)msgHandle {
    [_customView startStream:cameraId msgHandle:msgHandle];
}

- (void)stopStreaming {
    [_customView stopStream];
//    _customView = nil;
}

- (int)openSound:(int)soundValue {
    return [_customView openSound:soundValue];
}

- (int)closeSound {
    return [_customView closeSound];
}

- (void)startTalk:(int)msgHandle {
     [_customView startTalk:msgHandle];
}
- (void)pauseTalk: (int)msgHandle {
     [_customView pauseTalk:msgHandle];
}
- (void)closeTalk {
     [_customView closeTalk];
}
- (void)startDouTalk:(int)msgHandle {
     [_customView startDouTalk:YES msgHandle:msgHandle];
}
- (void)stopDouTalk {
     [_customView stopDouTalk];
}
- (int)snapImage {
    return [_customView snapImage];
}
-(int)startRecord {
    return [_customView startRecord];
}
-(int)stopRecord {
    return [_customView stopRecord];
}



@end
