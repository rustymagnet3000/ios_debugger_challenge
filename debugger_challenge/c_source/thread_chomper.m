#include "thread_chomper.h"

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

NSMutableArray *fishyArray;
NSLock *arrayLock;

@interface YDFishClass : NSObject
{
    NSInteger _caught;
    NSString *_name;
}
@property NSInteger caught;
@property NSString *name;
@end

@implementation YDFishClass
@synthesize caught = _caught;
@synthesize name = _name;

@end

typedef void (^SimpleSlowBlock)(YDFishClass *);

SimpleSlowBlock simpleBlock = ^ (YDFishClass *fishObj){
    
    NSTimeInterval blockThreadTimer = 0.05;  // Required to get overlapping thread, while the lock is in place
    uint64_t tid;
    assert(pthread_threadid_np(NULL, &tid)== 0);
    NSLog(@"[+]%@: thread ID: %#08x", [fishObj name], (unsigned int) tid);
    
    for(int i = 0; i <= [fishObj caught]; i++)
    {
        [arrayLock lock]; // NSMutableArray isn't thread-safe
        [fishyArray addObject:[fishObj name]];
        [arrayLock unlock];
        [NSThread sleepForTimeInterval:blockThreadTimer];
    }
};


NSMutableArray* _Nonnull yd_start_chomper(void) {

    fishyArray = [[NSMutableArray alloc] init];
    arrayLock = [[NSLock alloc] init];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            YDFishClass *shark = [[YDFishClass alloc] init];
            shark.caught = 10;
            shark.name = @"Tiger Shark";
            simpleBlock(shark);
        }
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            YDFishClass *jellyfish = [[YDFishClass alloc] init];
            jellyfish.caught = 10;
            jellyfish.name = @"Lemon Shark";
            simpleBlock(jellyfish);
        }
        dispatch_semaphore_signal(semaphore);
    });
    
    // Wait for the above block execution.
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return fishyArray;
}
