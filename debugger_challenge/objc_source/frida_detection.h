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

static const char frida_strings[MAX_FRIDA_STRINGS][MAX_STR_LEN] = {
        { 0x66, 0x72, 0x69, 0x64, 0x61 },// frida
        { 0x66, 0x72, 0x69, 0x64, 0x61, 0x2d, 0x73,0x65,0x72,0x76,0x65,0x72 }, // frida-server
        { 0x46, 0x52, 0x49, 0x44, 0x41 },
        "frida-gadget",
        "gum-js-loop",
        "gdbus"
};

@interface YDFridaDetection: NSObject
+(BOOL)checkIfFridaInstalled;
+(BOOL)checkDefaultPort;
+(BOOL)checkLoadAddress;
+(BOOL)checkModules;
+(BOOL)fridaNamedThreads;
@end

#endif /* frida_detection_h */
