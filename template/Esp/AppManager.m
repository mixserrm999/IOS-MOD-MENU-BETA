// AppManager.m

#import "AppManager.h"

@implementation AppManager

+ (instancetype)sharedInstance {
    static AppManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AppManager alloc] init];
    });
    return sharedInstance;
}

@end
