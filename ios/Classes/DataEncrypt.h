#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataEncrypt : NSObject

- (void)initP2PDataEncrypt;
- (void)setP2PDataEncrypt:(BOOL)type;
- (BOOL)getSavedType;
@end

NS_ASSUME_NONNULL_END
