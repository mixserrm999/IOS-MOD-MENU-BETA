#import "ImGuiLoad.h"
#import "ImGuiDrawView.h"
#import "JHPP.h"
#import "AppManager.h"

@interface ImGuiLoad()
@property (nonatomic, strong) ImGuiDrawView *vna;
@end

@implementation ImGuiLoad

+ (instancetype)share {
    static ImGuiLoad *tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[ImGuiLoad alloc] init];
    });
    return tool;
}

- (void)show {
    if (!_vna) {
        ImGuiDrawView *vc = [[ImGuiDrawView alloc] init];
        _vna = vc;
    }

    UIWindow *window = [AppManager sharedInstance].mainWindow;
    if (window) {
        [ImGuiDrawView showChange:true];
        [window.rootViewController.view addSubview:_vna.view];
    }
}

- (void)hide {
    if (!_vna) {
        ImGuiDrawView *vc = [[ImGuiDrawView alloc] init];
        _vna = vc;
    }

    UIWindow *window = [AppManager sharedInstance].mainWindow;
    if (window) {
        [ImGuiDrawView showChange:false];
        [window.rootViewController.view addSubview:_vna.view];
    }
}

@end

