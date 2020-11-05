#include "jailbreak_checks.h"

@implementation YDJailbreakCheck

+(BOOL)checkSymLinks{

    const char *app_path = "/Applications";
    struct stat s;
    if (lstat(app_path, &s) == 0)
    {
        if (S_ISLNK(s.st_mode) == 1)            /* S_ISLNK == symbolic link */
            return YES;
    }
    return NO;
}


+(BOOL)checkSandboxWrite{
    
    /* Should not be able to write outside of my sandbox  */
    /* but fopen and NSFileManager adhere to sandboxing, even on a jailbroken Electra device */
    
    NSLog (@"[*]Sandboxed area:%@", NSHomeDirectory() );
    const char *outside_sandbox = "/private/foobar.txt";
    FILE *fp;
    fp = fopen(outside_sandbox, "w");
    
    if (fp != nil)
        return YES;
    
    NSError *error;
    NSString *stringToBeWritten = @"Jailbreak sandbox check. Writing text to a file.";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error == nil)
    {
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
        return YES;
    }else{
        NSLog (@"[*]Sandboxed error:%@", [error description]);
        return NO;
    }
}
    
+(BOOL)checkSandboxFork{
    
    /*
        fork() causes creation of a new process. The child process has a unique process ID.
        
        On a sandboxed iOS app this is restricted.  It will give a -1 response to the parent process, no child process is created

        With the electra iOS jailbreak, this never passed this test.
     
     */
             
    int pid = 99;
    
    #if defined(__arm64__)
        pid = fork();
        NSLog(@"[*]pid returned from fork():%d", pid);
        if ( pid == -1 )
            NSLog(@"[*]fork() request denied with Sandbox error: %d", errno);
    
    #elif defined(__x86_64__)
        NSLog(@"[!]Not calling fork() as this works on an iOS simulator");
    
    #else
        NSLog(@"[*]Unknown target.");
    
    #endif

    return (pid >= 0) ? YES : NO;   // fork() returns a value of 0 to the child process and returns the process ID of the child process to the parent process.
    
}

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


+(BOOL)checkFileExists{
    int64_t result = -10;
    NSBundle *appbundle = [NSBundle mainBundle];
    NSString *filepath = [appbundle pathForResource:@"Info" ofType:@"plist"];
    __unused const char *fp = filepath.fileSystemRepresentation;
    
    #if defined(__arm64__)
        NSLog(@"[*]access() call with __arm64__ ASM instructions");
        result = [self asmSyscallFunction:fp];
    #elif defined(__x86_64__)
        NSLog(@"[*]syscall(SYS_access) __x86_64__");
        result = syscall(SYS_access, fp, F_OK);
    #else
        NSLog(@"[*]Unknown target.");
    #endif
    
    NSLog(@"[*]Result:%lld", result);
    return (result == 0) ? YES : NO;;
}
@end
