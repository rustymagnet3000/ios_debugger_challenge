#ifndef jailbreak_checks_h
#define jailbreak_checks_h

@import Foundation;
@import ObjectiveC.runtime;
#import <unistd.h>
#import <sys/syscall.h>
#import <sys/types.h>
#import <sys/stat.h>

typedef enum : NSUInteger {
    CLEAN_DEVICE = 0,
    SUSPECT_JAILBREAK = 1,
    JAILBROKEN,
} JAILBREAKRESULT;

#define CLEAN_DEVICE            0x00        // 0b00000000
#define JAILBROKEN              0x01        // 0b00000001
#define SANDBOX_ESCAPE          0x02        // 0b00000010
#define SUSPICIOUS_SYM_LINKS    0x04        // 0b00000100
#define SUSPICIOUS_FILES        0x08        // 0b00001000
#define JB_DYLIB_PRESENT        0x16        // 0b00010000
#define MAX_BITS                5           // max value where Bit Fields are OR'd together 0b00011111 = 5 bits == 0x31


static NSString const *symlinkStrs[] =         {
                                                    @"Store",                   // Cydia
                                                    @"TweakInject",
                                                    @"/Applications",
                                                    @"DynamicLibraries",
                                                    @"/var/lib/undecimus/apt",
                                                    @"/usr/libexec"
                                                };

static NSString const *suspiciousFileStrs[] =   {
                                                    @"/bin/bash",
                                                    @"/usr/sbin/sshd",
                                                    @"/bin/sh",
                                                    @"/Applications/Cydia.app",
                                                    @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                                                    @"/var/cache/apt",
                                                    @"/var/lib/cydia"
                                                };

static NSString const *suspectLibraries[] =     {
                                                    @"SubstrateLoader.dylib",
                                                    @"MobileSubstrate.dylib",
                                                    @"TweakInject.dylib",
                                                    @"CydiaSubstrate",
                                                    @"cynject",
                                                };

@interface YDJailbreakCheck: NSObject{
    unsigned short status : MAX_BITS;
}

-(NSString *)getJailbreakStatus;
+(BOOL)checkInfoPlistExists;
-(void)checkModules;
-(void)checkSuspiciousFiles;
-(void)checkSandboxFork;
-(void)checkSandboxWrite;
-(void)checkSymLinks;
@end

#endif /* jailbreak_checks_h */
