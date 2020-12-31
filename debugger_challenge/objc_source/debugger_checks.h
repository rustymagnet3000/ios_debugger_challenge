#ifndef debugger_checks_h
#define debugger_checks_h

@import Foundation;
#import <unistd.h>
#import <stdlib.h>
#import <assert.h>
#import <pthread.h>
#import <sys/syscall.h>
#import <sys/sysctl.h>
#import <sys/types.h>
#import <mach-o/dyld.h>     // read dynamically loaded libraries
#import <mach/mach.h>       // Kernal call: task_get_exception_ports()
#import <dlfcn.h>           // required for dlsym()

static NSString *const ptrace_str = @"ptrace";



typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);


@interface YDDebuggerChecks: NSObject
+(BOOL)debugger_sysctl;
+(BOOL)debugger_exception_ports;
+(BOOL)checkParent;
+(BOOL)setPtraceWithASM;
+(BOOL)setPtraceWithSymbol;

@end


#endif /* debugger_checks_h */
