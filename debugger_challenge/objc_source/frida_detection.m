#include "frida_detection.h"

@implementation YDFridaDetection

#pragma mark: Ask Kernal for a Thread List
/*- task_threads() gets the Thread List inside of app's process.
    pthread_from_mach_thread_np() converts the mach thread IDs to pthreads.
    pthread_getname_np() to get names of the threads.
*/
+(BOOL)fridaNamedThreads{
  
    NSInteger countNameThreads = 0;
    thread_act_array_t thread_list;
    mach_msg_type_number_t thread_count = 0;
    const task_t    this_task = mach_task_self();
    const thread_t  this_thread = mach_thread_self();
    
    kern_return_t kr = task_threads (this_task, &thread_list, &thread_count);
    if (kr != KERN_SUCCESS){
        NSLog(@"er ror getting task_threads: %s\n", mach_error_string(kr));
        return NO;
    }
    
    char thread_name[THREAD_NAME_MAX];
    NSMutableArray *namedThreads = [NSMutableArray new];
    
    /* create array of Threads with Names */
    for (int i = 0; i < thread_count; i++){
        pthread_t pt = pthread_from_mach_thread_np (thread_list[i]);
        if (pt) {
            thread_name[0] = '\0';
            int rc = pthread_getname_np (pt, thread_name, THREAD_NAME_MAX);
            uint64_t tid;
            pthread_threadid_np (pt, &tid);
            if (thread_name[0] != '\0' && rc == 0)
                [namedThreads addObject: [NSString stringWithCString: thread_name encoding:NSASCIIStringEncoding]];
        }
    }
    
    /* check each name against Frida strings */
    countNameThreads = [YDFridaDetection loopThroughFridaStrs:namedThreads];
    
    mach_port_deallocate(this_task, this_thread);
    vm_deallocate(this_task, (vm_address_t)thread_list, sizeof(thread_t) * thread_count);

    NSLog(@"🐝%@ check: %@",  NSStringFromSelector(_cmd), namedThreads);
    NSLog(@"🐝Suspected Frida thread count: %ld", (long)countNameThreads);
    return countNameThreads > 0 ? YES : NO;
}



#pragma mark: Check if Frida Server detected on Disk. Only a J/B device will be able to hit this path
+(BOOL)checkIfFridaInstalled{
    
    NSString *frida_on_filesystem = @"/usr/sbin/frida-server";
    NSURL *theURL = [ NSURL fileURLWithPath:frida_on_filesystem isDirectory:NO ];
    NSError *err;
    
    if ([ theURL checkResourceIsReachableAndReturnError:&err]  == YES )
        return YES;
    
    FILE *file;
    file = fopen(frida_on_filesystem.UTF8String, "r");
    
    if ( err != NULL && !file )
        NSLog(@"🐝%@:fopen() and checkResourceIsReachableAndReturnError() failed ( error:%ld )", NSStringFromSelector(_cmd), (long)err.code);
    
    int rst = access(frida_on_filesystem.UTF8String, F_OK);
    NSLog(@"🐝%@:\taccess() returned: %d",  NSStringFromSelector(_cmd), rst);
    return rst == 0 ? YES : NO;
}

#pragma mark: Iterate through local TCP ports. Sending message to identify frida-server */
+(BOOL)checkDefaultPort{
    int result, sock;
    int refused_conns = 0, open_conns = 0, unknown_conns = 0;
    struct sockaddr_in sa = {0};

    sa.sin_family = AF_INET;
    sa.sin_addr.s_addr = inet_addr(HOSTNAME);

    puts("🐝scan started...");
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

    NSLog(@"🐝Completed.\n\tOpen ports: %d\tRefused ports:%d\tUnknown response:%d\n", open_conns, refused_conns, unknown_conns);
    return NO;
}

#pragma mark: Check if any Frida strings return a Symbol pointer, at run-time */
+(BOOL)checkLoadAddress{
     
    funcptr ptr = NULL;

    for (int i=0; i<MAX_FRIDA_STRINGS; i++) {
        NSLog(@"🐝Checking: %s", frida_strings[i]);
        ptr = (funcptr)dlsym( RTLD_DEFAULT, frida_strings[i] );

        if( ptr != NULL )
            return YES;
    }

    return NO;
}

#pragma mark: Iterate through loaded Modules inside the app, at run-time. Goal: detect Frida-Gadget.dylib
+(BOOL)checkModules{
    
    NSInteger countSuspectModules = 0;
    unsigned int count = 0;
    const char **images = objc_copyImageNames ( &count );
    
    NSMutableArray *allModules = [[NSMutableArray alloc] initWithCapacity: count];
    for (int y = 0; y < count; y++)
        [allModules addObject: [NSString stringWithCString: images[y] encoding:NSASCIIStringEncoding]];
    
    countSuspectModules = [YDFridaDetection loopThroughFridaStrs:allModules];
    NSLog(@"🐝Suspect Frida modules count: %ld", (long)countSuspectModules);
    return countSuspectModules > 0 ? YES : NO;
}


+(NSInteger) loopThroughFridaStrs: (NSMutableArray *)strItems {
    
    NSInteger count = 0;
    NSLog(@"\t🐝Checking  %ld string items", strItems.count);
    for (NSString *item in strItems) {
        for (int i=0 ; i<MAX_FRIDA_STRINGS; i++) {
            NSString *friStr= [NSString stringWithUTF8String:frida_strings[i]];
            if ([item containsString:friStr])
                count++;
        }
    }
    return count;
}


@end
