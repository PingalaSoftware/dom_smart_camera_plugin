#import <Flutter/Flutter.h>

@interface DomCameraPlugin : NSObject<FlutterPlugin>

@end

@interface NSMessage : NSObject

@property(nonatomic, strong) NSObject *nsObj;
@property(nonatomic, strong) NSString *strParam;
@property(nonatomic, strong) id objId;
@property(readwrite, assign) void *obj;
@property(readwrite, assign) int param1;
@property(readwrite, assign) int param2;

+ (id)SendMessag:(NSString *) name obj:(void *) obj p1:(int)param1 p2:(int)param2;

@end
