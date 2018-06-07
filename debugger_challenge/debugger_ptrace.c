#include "debugger_ptrace.h"

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);

void crash_on_detection()
{
    printf("*** if there is a debugger attached, expect a segment fault or exit \n");
    ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(RTLD_SELF, "ptrace");
    int x = ptrace_ptr(31, 0, 0, 0); // PTRACE_DENY_ATTACH = 31
}

bool report_on_detection()
{
    ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(RTLD_SELF, "ptrace");
    if (ptrace_ptr(0, 0, 0, 0) == -1)  //  PTRACE_TRACEME = 0,
    {
        printf("I detect a ptrace!\n");
        return true;
    }
    return false;
}

bool debugger_ptrace()
{
    bool ptrace_detected = false;  // this is not a recommended default!
    crash_on_detection();
    return ptrace_detected;
}
