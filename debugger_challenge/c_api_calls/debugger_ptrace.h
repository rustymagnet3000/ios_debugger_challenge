#include <stdbool.h>
#import <dlfcn.h>
#import <sys/types.h>
#import <stdio.h>
#include <unistd.h>
#include <strings.h>
#include <mach-o/dyld.h> // required to read dynamically loaded libraries
bool debugger_ptrace(void);
