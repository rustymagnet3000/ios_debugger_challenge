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
#include <mach/mach.h>
#include <pthread.h>

#define HOSTNAME "127.0.0.1"
#define START 26000
#define END 27500
#define FRIDA_DEFAULT 27042
#define MAX_FRIDA_STRINGS 6
#define MAX_STR_LEN 15
#define THREAD_NAME_MAX 30

@interface YDFridaDetection: NSObject
+(BOOL)checkIfFridaInstalled;
+(BOOL)checkDefaultPort;
+(BOOL)checkLoadAddress;
+(BOOL)checkModules;
+(BOOL)fridaNamedThreads;
@end

#endif /* frida_detection_h */
