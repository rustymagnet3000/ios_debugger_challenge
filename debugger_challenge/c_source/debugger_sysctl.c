#include "debugger_sysctl.h"

bool debugger_sysctl(void)
{
        printf("Apple's recommended sysctl debugger check\n");
        int                 junk;
        int                 mib[4];
        struct kinfo_proc   info;
        size_t              size;
        
        // Initialize the flags so that, if sysctl fails for some bizarre
        // reason, we get a predictable result.
        
        info.kp_proc.p_flag = 0;
        
        // Initialize mib, which tells sysctl the info we want, in this case
        // we're looking for information about a specific process ID.
        
        mib[0] = CTL_KERN;
        mib[1] = KERN_PROC;
        mib[2] = KERN_PROC_PID;
        mib[3] = getpid();
        
        // Call sysctl.
        
        size = sizeof(info);
        junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
        assert(junk == 0);
        
        // We're being debugged if the P_TRACED flag is set.
        int x = (info.kp_proc.p_flag & P_TRACED);
    if (x > 0)
        printf("DEBUGGER DETECTED!\n");
    
    return ( x != 0 );  //0 == no debugger 2048 == debugger
}
