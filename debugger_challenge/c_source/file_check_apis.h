#ifndef file_check_apis_h
#define file_check_apis_h

@import Foundation;
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/stat.h>

@interface YDFileChecker: NSObject

+(BOOL)checkFileExists;
+(BOOL)checkSandboxFork;
+(BOOL)checkSandboxWrite;
@end

#endif /* file_check_apis_h */
