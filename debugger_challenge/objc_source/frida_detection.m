#include "frida_detection.h"

@implementation YDFridaDetection

const char byteArrays[MAX_ARRAYS][MAX_STR_LEN] = {
        { 0x66, 0x72, 0x69, 0x64, 0x61 },// frida
        { 0x66, 0x72, 0x69, 0x64, 0x61, 0x2d, 0x73,0x65,0x72,0x76,0x65,0x72 }, // frida-server
        { 0x46, 0x52, 0x49, 0x44, 0x41 } // FRIDA
};

typedef int (*funcptr)( void );

/* Check if Frida Server detected on Disk. Only a J/B device will be able to hit this path */
/* but it depends on the level of Jailbreak. "Tweaks off" still may not give a Sandbox permission error */

+(BOOL)checkIfFridaInstalled{
    
    NSString *frida_on_filesystem = @"/usr/sbin/frida-server";
    NSURL *theURL = [ NSURL fileURLWithPath:frida_on_filesystem isDirectory:NO ];
    NSError *err;
    
    if ([ theURL checkResourceIsReachableAndReturnError:&err]  == YES )
        return YES;
    
    if ( err != NULL ) {
        NSLog(@"[*]🐝Error in file check: %ld", (long)err.code);
        if ( err.code == 257 )
            NSLog(@"[*]🐝Sandbox permission error.");
    }
    
    FILE *file;
    file = fopen(frida_on_filesystem.fileSystemRepresentation, "r");
    if ( !file )
        NSLog(@"[*]🐝if ObjC APIs fails, fopen also failed!");

    NSLog(@"[*]🐝Trying access() as it is a sits libsystem_kernel.dylib!");
    
    return (access(frida_on_filesystem.fileSystemRepresentation, F_OK) == 0) ? YES : NO;
}

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

/* Check if any Frida strings return a Symbol pointer, at run-time */

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
/* Goal: detect Frida-Gadget.dylib */

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
