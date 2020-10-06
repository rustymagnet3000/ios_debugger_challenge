#import <Foundation/Foundation.h>
#include "file_check_apis.h"

@implementation YDFileChecker

 +(int64_t) asmSyscallFunction:(const char *) fp{
    int64_t res = 99;                   // signed 64 bit wide int, as api can return -1
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
    return res;
}

+(BOOL)checkFileExists{
    
    BOOL file_exists = NO;
    NSBundle *appbundle = [NSBundle mainBundle];
    NSString *filepath = [appbundle pathForResource:@"Info" ofType:@"plist"];
    const char *fp = filepath.fileSystemRepresentation;
    
    #if defined(__arm64__)
        NSLog(@"access for __arm64__ with ASM instructions");
        int64_t result = [self asmSyscallFunction:fp];
        NSLog(@"Result:%lld", result);
        file_exists = YES;
    #elif defined(__x86_64__)
        NSLog(@"access for __x86_64__");
        int result = access(fp, F_OK);
        printf("[*] result: %d\n", result);
        file_exists == 0 ? YES: NO;
    #else
        NSLog(@"Unknown target.");
        file_exists = NO;
    #endif
    return file_exists;
}
@end
