#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif
#import "MappableView.h"

@interface mappable : NSObject <RCTBridgeModule>

@property MappableView *map;

- (void)initWithKey:(NSString*)apiKey;

@end
