#import <Foundation/Foundation.h>
#include "file_check_apis.h"

@implementation YDFileChecker


+(BOOL)checkFileExists{
    
    BOOL file_exists = NO;
    NSBundle *appbundle = [NSBundle mainBundle];
    NSString *filepath = [appbundle pathForResource:@"Info" ofType:@"plist"];
    const char *fp = filepath.fileSystemRepresentation;
    
    /* SIGSYS means call was wrong !*/
    
    #if defined(__arm64__)
        NSLog(@"access for __arm64__");

        __asm(
            "mov     x0, x0\n\t"
            "mov     x0, x0"
        );
    
        file_exists = YES;
    #elif defined(__x86_64__)
        NSLog(@"access for __x86_64__");
        int result = access(fp, F_OK);
        printf("[*] result: %d\n", result);
        file_exists == 0 ? YES: NO;
    #else
        NSLog(@"Unknown target.");
        file_exists NO;
    #endif
    return file_exists;
}
@end
