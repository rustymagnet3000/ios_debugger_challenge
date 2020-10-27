#ifndef debugger_checks_h
#define debugger_checks_h

@import Foundation;
#import <unistd.h>
#import <stdlib.h>
#import <assert.h>
#import <pthread.h>
#import <sys/syscall.h>
#import <sys/sysctl.h>
#import <mach-o/dyld.h>    // read dynamically loaded libraries
#import <sys/types.h>
#import <dlfcn.h>           // required for dlsym
#import <mach/mach.h>

#define PTRACE_NAME "ptrace"

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);


@interface YDDebuggerChecks: NSObject
+(BOOL)debugger_sysctl;
+(BOOL)debugger_exception_ports;
+(BOOL)checkParent;
+(BOOL)setPtraceWithASM;
+(BOOL)setPtraceWithSymbol;

@end


#endif /* debugger_checks_h */
