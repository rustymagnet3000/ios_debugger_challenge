#ifndef thread_chomper_h
#define thread_chomper_h

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

@import Foundation;
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>
#include <pthread.h>

NSMutableArray* _Nonnull yd_start_chomper(void);

#endif /* thread_chomper_h */
