// AppManager.h //

#import <UIKit/UIKit.h>

@interface AppManager : NSObject

@property (nonatomic, strong) UIWindow *mainWindow;

+ (instancetype)sharedInstance;

@end
