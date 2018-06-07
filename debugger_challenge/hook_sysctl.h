#ifndef hook_sysctl_h
#define hook_sysctl_h

#import <dlfcn.h>
#import <stdio.h>
#import <dispatch/dispatch.h>
#import <string.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <unistd.h>
#include "debugger_sysctl.h"

// interesting: you don't need to add a header API interface for hook to work
void close_homebrew_sysctl(void);
#endif /* hook_sysctl_h */
