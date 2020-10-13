#ifndef frida_detection_h
#define frida_detection_h

@import Foundation;
@import ObjectiveC.runtime;

#import <sys/types.h>       // required for ppid
#import <unistd.h>          // required for ppid
#import <dlfcn.h>           // required for dlsym
#include <sys/sysctl.h>

@interface YDFridaDetection: NSObject
+(BOOL)checkLoadAddress;
+(BOOL)checkModules;
@end

#endif /* frida_detection_h */
