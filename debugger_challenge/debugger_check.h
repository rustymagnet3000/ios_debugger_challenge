#ifndef debugger_check_h
#define debugger_check_h

#include <stdio.h>
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

bool debugger_check(void);

#endif /* debugger_check_h */
