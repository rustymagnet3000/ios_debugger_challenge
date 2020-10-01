#ifndef debugger_ptrace_asm_h
#define debugger_ptrace_asm_h

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

#import <Foundation/Foundation.h>
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>
#include <pthread.h>

@interface YDDebuggerPtrace: NSObject

+(void)invokePtrace;

@end


#endif /* debugger_ptrace_asm_h */
