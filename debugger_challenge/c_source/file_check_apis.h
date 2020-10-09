#ifndef file_check_apis_h
#define file_check_apis_h
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif
#import <Foundation/Foundation.h>
#include <unistd.h>
#include <sys/syscall.h>

@interface YDFileChecker: NSObject

+(BOOL)checkFileExists;

@end

#endif /* file_check_apis_h */
