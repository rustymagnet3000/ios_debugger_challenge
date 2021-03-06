#include "jailbreak_checks.h"

@implementation YDJailbreakCheck

- (instancetype)init{
    self = [super init];
    if (self) {
        status = CLEAN_DEVICE;
        [self checkModules];
        [self checkSuspiciousFiles];
        [self checkSandboxFork];
        [self checkSandboxWrite];
        [self checkSymLinks];
    }
    return self;
}

#pragma mark: Calculate Jailbreak status from bit fields
-(NSString *)getJailbreakStatus{
    int jb_detection_counter = 0;
       
    for (unsigned short i = 0; i < MAX_BITS; i++) {
        if (status & (1 << i))
            jb_detection_counter++;
    }
    printf("🐝Jailbreak detections fired: %d\n", jb_detection_counter);
    switch (jb_detection_counter) {
        case CLEAN_DEVICE:
            return @"Clean device";
        case SUSPECT_JAILBREAK:
            return @"Suspect jailbreak";
        default:
            return @"Jailbroken";
    }
}

#pragma mark: Check whether certain directories/files are symbolic links                */
/* example: /User is a symbolic link for:    /var/mobile                                */
/* ls -lR / | grep ^l                 -> listr all symbolic links on iOS                */
-(void)checkSymLinks{

    NSInteger countSymlinks = sizeof(symlinkStrs) / sizeof(symlinkStrs[0]);
    NSArray *symlinks = [NSArray arrayWithObjects:symlinkStrs count: countSymlinks];

    for (NSString *link in symlinks) {
        struct stat s;
        if (lstat(link.UTF8String, &s) == 0)
        {
            if (S_ISLNK(s.st_mode) == 1){            /* S_ISLNK == symbolic link */
                NSLog (@"🐝Suspicious symlink:%@", link);
                status |= 1 << 2;
            }
        }
    }
    NSLog(@"🐝%@\tchecked:%ld symlinks", NSStringFromSelector(_cmd), (long)countSymlinks);
}


#pragma mark: check if you can write outside of sandbox
#pragma mark: fopen() and NSFileManager() adhere to sandboxing, even on a jailbroken Electra device */
-(void)checkSandboxWrite{

    NSString *fileToWrite = @"/private/t";
    NSError *error;
    NSString *stringToBeWritten = @"Jailbreak \"escape sandbox\" check. Writing meaningless text to a file";

    [stringToBeWritten writeToFile:fileToWrite atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error == nil){
        NSLog (@"🐝Jailbreak found.  No errors writing to: %@", fileToWrite);
        [[NSFileManager defaultManager] removeItemAtPath:fileToWrite error:nil];
        status |= 1 << 1;
    }
    
    if(access (fileToWrite.UTF8String, W_OK ) != -1)
        NSLog (@"🐝No error throw from Access()");

    NSLog(@"🐝%@\tchecked", NSStringFromSelector(_cmd));
}


#pragma mark: Iterate through array of suspicious file locations. looking for presence of file. not assessing  permissions of file
-(void)checkSuspiciousFiles{
    
    NSInteger countSupiciousFiles = sizeof(suspiciousFileStrs) / sizeof(suspiciousFileStrs[0]);
    NSArray *suspiciousFiles = [NSArray arrayWithObjects:suspiciousFileStrs count: countSupiciousFiles];
    
    for (NSString *file in suspiciousFiles) {
        NSURL *theURL = [ NSURL fileURLWithPath:file isDirectory:NO ];
        NSError *err;
        if ([ theURL checkResourceIsReachableAndReturnError:&err]  == YES ){
            NSLog(@"🐝%@\t:%@", NSStringFromSelector(_cmd), file);
            status |= 1 << 3;
        }
    }
    NSLog(@"🐝%@\tchecked:%ld suspicious files", NSStringFromSelector(_cmd), (long)countSupiciousFiles);
}

#pragma mark: Iterate through all loaded Dynamic libraries at run-time. Goal: detection supicious libraries */
-(void)checkModules{
    unsigned int imageNameCount = 0;
    
    NSInteger countsuspectLibraries = sizeof(suspectLibraries) / sizeof(suspectLibraries[0]);
    NSArray *suspiciousLibraries = [NSArray arrayWithObjects:suspectLibraries count: countsuspectLibraries];
    

    const char **images = objc_copyImageNames ( &imageNameCount );
    for (int y = 0 ; y < imageNameCount ; y ++) {

        for (NSString *lib in suspiciousLibraries) {
            NSString *module_in_app = [NSString stringWithUTF8String:images[y]];
            if ([module_in_app containsString:lib]){
                NSLog(@"\t🐝%@\t:%@", NSStringFromSelector(_cmd), module_in_app);
                status |= 1 << 4;
                return;
            }
        }
    }

    NSLog(@"🐝%@\tchecked:%ld modules", NSStringFromSelector(_cmd), (long)imageNameCount);
}


#pragma mark: fork() causes creation of a new process. The child process has a unique process ID.
/*  On a sandboxed iOS app this is restricted.  It will give a -1 response to the parent process, no child process is created
    With the electra iOS jailbreak, fork() didn't work.
    If fork() succeeds, it returns a value of 0 to the child process and returns the process ID of the child process to the parent process. */
-(void)checkSandboxFork{
                
    #if defined(__arm64__)
        int pid = 99;
        pid = fork();
        if ( pid == -1 )
            NSLog(@"\t🐝Expected behaviour from fork() request. Denied with Sandbox error: %d", errno);
        else if ( pid >= 0 )
            status |= 1 << 1;
    
    #elif defined(__x86_64__)
        NSLog(@"[!]Not calling fork() as this works on an iOS simulator");
    #endif
    
    NSLog(@"🐝%@\tchecked", NSStringFromSelector(_cmd));
}

#pragma mark: arm64 asm code to invoke a syscall()
 +(int64_t) asmSyscallFunction:(const char *) fp{

     int64_t res = 99;                   // signed 64 bit wide int, as api can return -1
     #if defined(__arm64__)
     __asm (
            "mov x0, #33\n"              // access syscall number on arm
            "mov x1, %[input_path]\n"    // copy char* to x1
            "mov x2, #0\n"               // File exist check == 0
            "mov x16, #0\n"
            "svc #33\n"
            "mov %[result], x0 \n"
     : [result] "=r" (res)
     : [input_path] "r" (fp)
     : "x0", "x1", "x2", "x16", "memory"
     );
    #endif
    return res;
}

#pragma mark: check whether info.plist file exists at default location
+(BOOL)checkInfoPlistExists{
    int64_t result = -10;
    NSBundle *appbundle = [NSBundle mainBundle];
    NSString *filepath = [appbundle pathForResource:@"Info" ofType:@"plist"];
    __unused const char *fp = filepath.UTF8String;
    
    #if defined(__arm64__)
        NSLog(@"🐝access() call with __arm64__ ASM instructions");
        result = [self asmSyscallFunction:fp];
    #elif defined(__x86_64__)
        NSLog(@"🐝syscall(SYS_access) __x86_64__");
        result = syscall(SYS_access, fp, F_OK);
    #else
        NSLog(@"🐝Unknown target.");
    #endif
    
    NSLog(@"🐝Result:%lld", result);
    return (result == 0) ? YES : NO;;
}


@end
