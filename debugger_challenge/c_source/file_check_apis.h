#ifndef file_check_apis_h
#define file_check_apis_h

@import Foundation;
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>

@interface YDFileChecker: NSObject

+(BOOL)checkFileExists;
+(BOOL)checkSandbox;

@end

#endif /* file_check_apis_h */
