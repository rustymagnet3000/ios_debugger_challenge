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

/* Iterate through local TCP ports  */
/* sending message to identify frida-server */

+(BOOL)checkDefaultPort{

    int result, sock;
    int refused_conns = 0, open_conns = 0, unknown_conns = 0;
    struct sockaddr_in sa = {0};

    sa.sin_family = AF_INET;
    sa.sin_addr.s_addr = inet_addr(HOSTNAME);

    puts("[*]🐝scan started...");
    for( int i = START;  i < END; i++ ){
        sa.sin_port = htons( i );
        sock = socket( AF_INET, SOCK_STREAM, 0 );
        result = connect( sock , ( struct sockaddr *) &sa , sizeof sa );
        if ( result == 0 && ( i = FRIDA_DEFAULT)) {
            NSLog( @"[!]🐝Frida default port open!" );
            return YES;
        }
        else if ( result == -1 ) {
            ( errno == 61 ) ? refused_conns++ : unknown_conns++ ;
        }
        close ( sock );
    }

    NSLog(@"[*]🐝Completed.\n\tOpen ports: %d\tRefused ports:%d\tUnknown response:%d\n", open_conns, refused_conns, unknown_conns);
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
        
        NSLog(@"🍭[*]%s", images[y]);
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
