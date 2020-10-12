@import Foundation;
#include "frida_detection.h"
#define MAX_ARRAYS 3
#define MAX_STR_LEN 15

@implementation YDFridaDetection

const char byteArrays[MAX_ARRAYS][MAX_STR_LEN] = {
        { 0x66, 0x72, 0x69, 0x64, 0x61 },// frida
        { 0x66, 0x72, 0x69, 0x64, 0x61, 0x2d, 0x73,0x65,0x72,0x76,0x65,0x72 }, // frida-server
        { 0x46, 0x52, 0x49, 0x44, 0x41 } // FRIDA
};

typedef int (*funcptr)( void );

/* check Parent loaded name. Trying to detect Frida-Trace */
+(BOOL)checkParent{
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSString *processName = [processInfo processName];
    int processID = [processInfo processIdentifier];
    pid_t parent = getppid();
    NSLog(@"Process Name: '%@'\tProcess ID:'%d'\tParent'%d'", processName, processID, parent);
    return NO;
}

+(BOOL)checkLoadAddress{
     
    funcptr ptr = NULL;

    for (int i=0; i<MAX_ARRAYS; i++) {
        NSLog(@"[*]🐝Checking: %s", byteArrays[i]);
        ptr = (funcptr)dlsym( RTLD_DEFAULT, byteArrays[i] );

        if( ptr != NULL )
            return YES;
    }

    return NO;
}

/* Iterate through all loaded Modules inside the app, to check for additions at run-time */
/* this only seems to detect Frida-Gadget */

+(BOOL)checkModules{
    unsigned int count = 0;

    const char **images = objc_copyImageNames ( &count );
    for ( int y = 0 ; y < count ; y ++ ) {
        
        for ( int i=0 ; i<MAX_ARRAYS ; i++ ) {
            char *result = nil;
            result = strnstr ( images[y], byteArrays[i], strlen ( images[y] ));
            if( result != nil )
                return YES;
        }
    }
    NSLog(@"[*]🐝No suspect modules found");
    return NO;
}
@end
