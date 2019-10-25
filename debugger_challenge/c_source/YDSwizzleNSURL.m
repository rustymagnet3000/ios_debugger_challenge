#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#define targetClassToSwizzle "NSURL" // note no Module name

@implementation NSURL (YDSwizzleNSURL)
+ (void)load
{
    NSLog(@"🍭\tConstructor called %@",  NSStringFromClass([self class]));
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = objc_getClass(targetClassToSwizzle);
        if (class == NULL) {
            NSLog(@"🍭\tStopped swizzle. Could not find %@ instance \n", class);
            return;
        }
        
        SEL originalSelector = @selector(initWithString:);
        SEL swizzledSelector = @selector(YDHappyURLInspector:);
        
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

- (instancetype)YDHappyURLInspector:(NSString *)string{
    NSLog(@"🍭\t url request: %@", string);
    return [self YDHappyURLInspector: string];
}
@end
