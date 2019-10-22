#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#define targetClassToSwizzle "debugger_challenge.YDURLSession"

@implementation NSURLSession (YDSwizzleNSURLSession)

+ (void)load
{
    NSLog(@"🍭\tConstructor called %@",  NSStringFromClass([self class]));
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = objc_getClass(targetClassToSwizzle);
        if (class == NULL) {
            NSLog(@"🍭\tStopped swizzle or couldn't find %@ instance \n", class);
            return;
        }
        SEL originalSelector = @selector(URLSession:didReceiveChallenge:completionHandler:);
        SEL swizzledSelector = @selector(YDHappyChallenge:didReceiveChallenge:completionHandler:);
        
        Class mySuperClass = class_getSuperclass(class);
        NSLog(@"🍭\tStarted swizzle: %@ && superclass: %@", NSStringFromClass(class), NSStringFromClass(mySuperClass));
        NSLog(@"🍭\tSearched for: \"%@\" selector", NSStringFromSelector(originalSelector));
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        if (originalMethod == NULL || swizzledMethod == NULL) {
            NSLog(@"🍭\tStopped swizzle. originalMethod:  %p swizzledMethod: %p \n", originalMethod, swizzledMethod);
            return;
        } else {
            NSLog(@"🍭\tmethod_exchangeImplementations");
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)YDHappyChallenge:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{

    NSLog(@"🍭\t NSURLSession on: %@", [[challenge protectionSpace] host ]);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, NULL);
}

@end
