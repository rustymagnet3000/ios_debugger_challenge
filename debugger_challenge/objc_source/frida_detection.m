#include "frida_detection.h"

@implementation YDFridaDetection

const char byteArrays[MAX_FRIDA_STRINGS][MAX_STR_LEN] = {
        { 0x66, 0x72, 0x69, 0x64, 0x61 },// frida
        { 0x66, 0x72, 0x69, 0x64, 0x61, 0x2d, 0x73,0x65,0x72,0x76,0x65,0x72 }, // frida-server
        { 0x46, 0x52, 0x49, 0x44, 0x41 },
        "frida-gadget",
        "gum-js-loop",
        "gdbus"
};

typedef int (*funcptr)( void );

#pragma mark: Ask Kernal for the Thread List - task_threads() - inside of app's process. Convert mach thread IDs to pthreads, using pthread_from_mach_thread_np().  Check for names of threads.  Checking for Frida named Threads.
+(BOOL)fridaNamedThreads{
  
    thread_act_array_t thread_list;
    mach_msg_type_number_t thread_count = 0;
    const task_t    this_task = mach_task_self();
    const thread_t  this_thread = mach_thread_self();
    
    kern_return_t kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS){
        NSLog(@"error getting task_threads: %s\n", mach_error_string(kr));
        return NO;
    }
    
    char thread_name[THREAD_NAME_MAX];
    
    for (int i = 0; i < thread_count; i++){
        pthread_t pt = pthread_from_mach_thread_np(thread_list[i]);
        if (pt) {
            thread_name[0] = '\0';
            __unused int rc = pthread_getname_np (pt, thread_name, sizeof (thread_name));
            uint64_t tid;
            pthread_threadid_np(pt, &tid);
            NSLog(@"🐝mach thread %u\t\ttid:%#08x\t%s", thread_list[i], (unsigned int) tid, thread_name[0] == '\0' ?  "< not named >" : thread_name);
        }
        else
            NSLog(@"🔸mach thread %u\t\tno pthread found", thread_list[i]);
    }
    mach_port_deallocate(this_task, this_thread);
    vm_deallocate(this_task, (vm_address_t)thread_list, sizeof(thread_t) * thread_count);

    return YES;
}



#pragma mark: Check if Frida Server detected on Disk. Only a J/B device will be able to hit this path
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

#pragma mark: Iterate through local TCP ports. Sending message to identify frida-server */
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

#pragma mark: Check if any Frida strings return a Symbol pointer, at run-time */
+(BOOL)checkLoadAddress{
     
    funcptr ptr = NULL;

    for (int i=0; i<MAX_FRIDA_STRINGS; i++) {
        NSLog(@"[*]🐝Checking: %s", byteArrays[i]);
        ptr = (funcptr)dlsym( RTLD_DEFAULT, byteArrays[i] );

        if( ptr != NULL )
            return YES;
    }

    return NO;
}

#pragma mark: Iterate through loaded Modules inside the app, at run-time. Goal: detect Frida-Gadget.dylib
+(BOOL)checkModules{
    unsigned int count = 0;

    const char **images = objc_copyImageNames ( &count );
    for (int y = 0; y < count; y++) {
        NSLog(@"🍭[*]%s", images[y]);
        for (int i=0 ; i<MAX_FRIDA_STRINGS; i++) {
            char *result = nil;
            result = strnstr ( images[y], byteArrays[i], strlen ( images[y] ));
            if (result != nil)
                return YES;
        }
    }
    NSLog(@"[*]🐝No suspect modules found");
    return NO;
}

+(NSInteger)loopThroughFridaStrings
{
    NSInteger count = 0;

}


@end
