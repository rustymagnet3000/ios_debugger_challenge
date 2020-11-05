#ifndef jailbreak_checks_h
#define jailbreak_checks_h

@import Foundation;
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/stat.h>

/* TODO: add IN_PROGRESS define */
#define CLEAN_DEVICE            0x00        // 0b00000000
#define JAILBROKEN              0x01        // 0b00000001
#define SANDBOX_ESCAPE          0x02        // 0b00000010
#define CYDIA_PRESENT           0x04        // 0b00000100
#define ELECTRA_PRESENT         0x08        // 0b00001000
#define JB_DYLIB_PRESENT        0x16        // 0b00010000
#define MAX_BITS                5           // max value where Bit Fields are OR'd together 0b00011111 = 5 bits == 0x31


@interface YDJailbreakCheck: NSObject{
    unsigned short status : MAX_BITS;
}
-(BOOL)getStatus;
+(BOOL)checkSymLinks;
+(BOOL)checkFileExists;
+(BOOL)checkSandboxFork;
+(BOOL)checkSandboxWrite;

@end

#endif /* jailbreak_checks_h */
