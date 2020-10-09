#import <Foundation/Foundation.h>
#include "frida_detection.h"
#define MAX_ARRAYS 3
#define MAX_STR_LEN 15

/*
   The Array of Byte Arrays is constant.
   It was declared as immutable (const).
   It is wasteful, in terms of space.
   3 (MAX_ARRAYS) * 15 (MAX_STR_LEN) = 35 bytes.
   Only about 29 bytes + 5 NULL terminator (0x00) are actually used.
   The unused by are set to NULL.
*/

const char byteArrays[MAX_ARRAYS][MAX_STR_LEN] = {
        { 0x66, 0x72, 0x69, 0x64, 0x61 },// frida
        { 0x66, 0x72, 0x69, 0x64, 0x61, 0x2d, 0x73,0x65,0x72,0x76,0x65,0x72 }, // frida-server
        { 0x46, 0x52, 0x49, 0x44, 0x41 } // FRIDA
};


typedef int (*funcptr)( void );

@implementation YDFridaDetection

+(BOOL)checkLoadAddress{
     
    funcptr funk = NULL;
    const char* fridaSymbol = "FRIDA";
    funk = (funcptr)dlsym( RTLD_DEFAULT, fridaSymbol );

    if( funk != NULL )
        return YES;

    return NO;
}

@end
