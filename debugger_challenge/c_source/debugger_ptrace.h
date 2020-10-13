#ifndef debugger_ptrace_h
#define debugger_ptrace_h

@import Foundation;
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>
#include <pthread.h>
#include <sys/syscall.h>
#include <mach-o/dyld.h> // read dynamically loaded libraries
#import <sys/types.h>
#import <dlfcn.h>           // required for dlsym
#define PTRACE_NAME "ptrace"

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);


@interface YDDebuggerPtrace: NSObject
+(BOOL)checkParent;
+(BOOL)setPtraceWithASM;
+(BOOL)setPtraceWithSymbol;

@end


#endif /* debugger_ptrace_h */
