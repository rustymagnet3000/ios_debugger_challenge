#ifndef frida_detection_h
#define frida_detection_h

@import Foundation;
@import ObjectiveC.runtime;


#import <stdlib.h>
#import <stdio.h>
#import <unistd.h>          // required for ppid
#import <sys/types.h>       // required for ppid
#import <dlfcn.h>           // required for dlsym
#import <sys/sysctl.h>
#import <sys/socket.h>
#import <errno.h>
#import <netdb.h>
#import <arpa/inet.h>

#define HOSTNAME "127.0.0.1"
#define START 27000
#define END 27100
#define FRIDA_DEFAULT 27042

@interface YDFridaDetection: NSObject
+(BOOL)checkDefaultPort;
+(BOOL)checkLoadAddress;
+(BOOL)checkModules;
@end

#endif /* frida_detection_h */
