#import "PaytmPlugin.h"
// #import <paytm/paytm-Swift.h>
// #import <Granth-Swift.h>

@implementation PaytmPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftPaytmPlugin registerWithRegistrar:registrar];
    
    
    
}
@end