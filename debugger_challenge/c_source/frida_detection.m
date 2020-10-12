@import Foundation;
#include "frida_detection.h"
#define MAX_ARRAYS 3
#define MAX_STR_LEN 15

/*
   The Array of Byte Arrays is constant.
   It was declared as immutable (const).
   It is wasteful, in terms of space.
   3 (MAX_ARRAYS) * 15 (MAX_STR_LEN) = 35 bytes.
   Only about 22 bytes in chars + 3 NULL terminator (0x00) are actually used.
   The unused bytes are set to NULL.
*/

@implementation YDFridaDetection

const char byteArrays[MAX_ARRAYS][MAX_STR_LEN] = {
        { 0x66, 0x72, 0x69, 0x64, 0x61 },// frida
        { 0x66, 0x72, 0x69, 0x64, 0x61, 0x2d, 0x73,0x65,0x72,0x76,0x65,0x72 }, // frida-server
        { 0x46, 0x52, 0x49, 0x44, 0x41 } // FRIDA
};


typedef int (*funcptr)( void );

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

+(BOOL)checkModules{
    unsigned int count = 0;
    const char **images = objc_copyImageNames(&count);
    
    for (int i=0; i<count; i++) {
        NSLog(@"[*]🐝 %s", images[i]);
    }

    

//    NSString *fridaStr = [[NSString alloc] initWithBytes:byteArrays[i] length:strlen(byteArrays[i]) encoding:NSASCIIStringEncoding ];
//    NSLog(@"[*]🐝Checking: %@", fridaStr);
//    if (NSClassFromString(fridaStr) != nil)
//       NSLog(@"[*]🐝We have a HIT!%s", byteArrays[i]);


    return NO;
}



@end
