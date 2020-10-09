#ifndef frida_detection_h
#define frida_detection_h
#import <Foundation/Foundation.h>
#import <dlfcn.h>           // required for dlsym

@interface YDFridaDetection: NSObject
+(BOOL)checkLoadAddress;
@end

#endif /* frida_detection_h */
