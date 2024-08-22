//
//  ImGuiLoad.m
//  ImGuiTest
//
//  Created by yiming on 2021/6/2..
//
//
// //

#import "ImGuiLoad.h"
#import "ImGuiDrawView.h"
#import "JHPP.h"

@interface ImGuiLoad()
@property (nonatomic, strong) ImGuiDrawView *vna;
@end

UIWindow *DoMainWindow;

@implementation ImGuiLoad

+ (instancetype)share
{
    static ImGuiLoad *tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[ImGuiLoad alloc] init];
    });
    return tool;
}

- (void)show
{
    if (!_vna) {
        ImGuiDrawView *vc = [[ImGuiDrawView alloc] init];
        _vna = vc;
    }


    [ImGuiDrawView showChange:true];
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:_vna.view];
}

- (void)hide
{
    if (!_vna) {
        ImGuiDrawView *vc = [[ImGuiDrawView alloc] init];
        _vna = vc;
    }
    
    [ImGuiDrawView showChange:false];
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:_vna.view];
}

- (void)disableGestures {
    for (UIGestureRecognizer *gesture in [JHPP currentViewController].view.gestureRecognizers) {
        [gesture setEnabled:NO];
    }
}

- (void)enableGestures {
    for (UIGestureRecognizer *gesture in [JHPP currentViewController].view.gestureRecognizers) {
        [gesture setEnabled:YES];
    }
}


@end
