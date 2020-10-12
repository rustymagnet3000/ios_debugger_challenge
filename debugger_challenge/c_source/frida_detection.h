#ifndef frida_detection_h
#define frida_detection_h

@import Foundation;
@import ObjectiveC.runtime;

     
#import <dlfcn.h>           // required for dlsym

@interface YDFridaDetection: NSObject
+(BOOL)checkLoadAddress;
+(BOOL)checkModules;
@end

#endif /* frida_detection_h */
