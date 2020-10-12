#ifndef frida_detection_h
#define frida_detection_h

@import Foundation;
@import ObjectiveC.runtime;

#import <sys/types.h>       // required for ppid
#import <unistd.h>          // required for ppid
#import <dlfcn.h>           // required for dlsym

@interface YDFridaDetection: NSObject
+(BOOL)checkParent;
+(BOOL)checkLoadAddress;
+(BOOL)checkModules;
@end

#endif /* frida_detection_h */
