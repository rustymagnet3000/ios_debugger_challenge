#include "debugger_ptrace.h"

@implementation YDDebuggerPtrace

//        __asm(
//            "mov x0, #26\n" // ptrace
//            "mov x1, #31\n" // PT_DENY_ATTACH
//            "mov x2, #0\n"
//            "mov x3, #0\n"
//            "mov x16, #0\n"
//            "svc #128\n"
//        );

+(void)setPtraceWithASM {
    NSString *result;
    NSLog(@"About to invoke ptrace call: %d", SYS_syscall);
    
    #if defined(__arm64__)
        result = @"Setting ptrace for __arm64__";
    #elif defined(__x86_64__)
        result = @"Setting ptrace for __x86_64__";
    #else
        result = @"Unknown target. Doing nothing...";
    #endif

    NSLog(@"END:%@", result);

}

+(BOOL) setPtraceDenyAttach{
    
    BOOL ptrace_detected = false;
    printf("*** if there is a debugger attached, expect a segment fault or exit *** \n");
    ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(RTLD_SELF, PTRACE_NAME);
    int x = ptrace_ptr(31, 0, 0, 0); // PTRACE_DENY_ATTACH = 31
    printf("ptrace result handle: %d", x);
    //    if (ptrace_ptr(0, 0, 0, 0) == -1)  //  PTRACE_TRACEME = 0
    
    return ptrace_detected;
}

@end
