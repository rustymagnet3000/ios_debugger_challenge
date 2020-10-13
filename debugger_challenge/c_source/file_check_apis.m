#include "file_check_apis.h"


@implementation YDFileChecker

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
    const char *fp = filepath.fileSystemRepresentation;
    
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
