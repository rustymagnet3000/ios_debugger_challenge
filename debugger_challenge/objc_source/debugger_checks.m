#include "debugger_checks.h"

@implementation YDDebuggerChecks

+ (void) warning {
    NSLog(@"[*]🐝⚠️ if a debugger attached, expect exit");
}

#pragma mark: Apple's recommended debugger check. Ask sysctl() which sits inside of Kernal for opinion.
+ (BOOL) debugger_sysctl {
        NSLog(@"[*]🐝\n");
        int                 junk;
        int                 mib[4];
        struct kinfo_proc   info;
        size_t              size;
        
        // Initialize the flags so that, if sysctl fails we get a predictable result.
        
        info.kp_proc.p_flag = 0;
        
        // Initialize mib, which tells sysctl the info we want, in this case
        // we're looking for information about a specific process ID.
        
        mib[0] = CTL_KERN;
        mib[1] = KERN_PROC;
        mib[2] = KERN_PROC_PID;
        mib[3] = getpid();
        size = sizeof(info);

        // Call sysctl.
        junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
        assert(junk == 0);
        
        // We're being debugged if the P_TRACED flag is set.
        int x = (info.kp_proc.p_flag & P_TRACED);
    if (x > 0)
        printf("DEBUGGER DETECTED!\n");

    return x > 0 ? YES : NO;            //0 == no debugger 2048 == debugger
}

#pragma mark: Ask Kernal for task_get_exception_ports(). Alternative to sysctl()
+ (BOOL) debugger_exception_ports {

    exception_mask_t       exception_masks[EXC_TYPES_COUNT];
    mach_msg_type_number_t exception_count = 0;
    mach_port_t            exception_ports[EXC_TYPES_COUNT];
    exception_behavior_t   exception_behaviors[EXC_TYPES_COUNT];
    thread_state_flavor_t  exception_flavors[EXC_TYPES_COUNT];
    
   
    kern_return_t kr = task_get_exception_ports(
                                                mach_task_self(),
                                                EXC_MASK_BREAKPOINT,
                                                exception_masks,
                                                &exception_count,
                                                exception_ports,
                                                exception_behaviors,
                                                exception_flavors
                                                );
    if (kr == KERN_SUCCESS) {
        for (mach_msg_type_number_t i = 0; i < exception_count; i++) {
            if (MACH_PORT_VALID(exception_ports[i])) {
                printf("DEBUGGER DETECTED!\n");
                return YES;
            }
        }
    }
    else {
        printf("ERROR: task_get_exception_ports: %s\n", mach_error_string(kr));
        return YES;
    }
    printf("No debugger detected\n");
    return NO;
}

#pragma mark: check Parent loaded name. Trying to detect Frida-Trace.  FAILED -> frida-trace still return a ppid of 1 on jailbroken 11.4 device

+(BOOL)checkParent{
    
    NSProcessInfo *process = [NSProcessInfo processInfo];
    NSString *name = [process processName];

    pid_t pid = getpid();
    pid_t parentpid = getppid();
    NSLog(@"[*]🐝Process Name: '%@'\tProcess ID:'%d'\tParent'%d'\t%@", name, pid, parentpid, [process hostName]);
    
    #if defined(__arm64__)
        return parentpid != 1 ? YES : NO;
    #pragma mark: Broken. Unsure if it is possible to get parent processes name on __x86_64__
    #elif defined(__x86_64__)
        NSLog(@"[*]🐝: Work in progress -> the same getppid() does NOT work on iOS Simulator");
    #endif
    
    return NO;
}

#pragma mark: Set ptrace() to deny_attach a debugger. Invoked with inlined asm code. Uses syscall() to call ptrace.
+ (BOOL) setPtraceWithASM {
    [self warning];
    NSString *message;
    BOOL flag = true;

    #if defined(__arm64__)
        message = @"ptrace for __arm64__";
        __asm(
            "mov x0, #26\n"             // ptrace
            "mov x1, #31\n"             // PT_DENY_ATTACH
            "mov x2, #0\n"
            "mov x3, #0\n"
            "mov x16, #0\n"
            "svc #128\n"
        );
    #elif defined(__x86_64__)
        message = @"ptrace for __x86_64__";
        int result, data = 0;
        pid_t pid = 0;
        caddr_t addr = 0;
        errno = 0;
        result = syscall(SYS_ptrace, 31, pid, addr, data);
        NSString *tempresult = [NSString stringWithFormat:@"ptrace result: %d\t Error: %d", result, errno ];
        message = [message stringByAppendingString:tempresult];
    #else
        message = @"Unknown target.";
    #endif

    flag = false;       // if a debugger was attached, it would have crashed
    NSLog(@"%@", message);
    return flag;
}

#pragma mark: Set ptrace() to deny_attach a debugger. Dynamically linka the ptrace Symbol at runtime on iOS
+ (BOOL) setPtraceWithSymbol{
    [self warning];
    BOOL ptrace_detected = false;
    
    ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(RTLD_SELF, [ptrace_str UTF8String]);
    int x = ptrace_ptr(31, 0, 0, 0); // PTRACE_DENY_ATTACH = 31

    NSLog(@"ptrace result handle: %d", x);
    return ptrace_detected;
}

@end
