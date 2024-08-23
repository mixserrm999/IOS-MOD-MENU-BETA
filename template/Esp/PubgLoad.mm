//
//  PubgLoad.m
//  pubg
//
//  Created by 李良林 on 2021/2/14.
// //

#import "PubgLoad.h"
#import <UIKit/UIKit.h>
#import "AppManager.h"
#import "JHPP.h"
#import "JHDragView.h"
#import "ImGuiLoad.h"
#import "ImGuiDrawView.h"

@interface PubgLoad()
@property (nonatomic, strong) ImGuiDrawView *vna;
@end

@implementation PubgLoad

static PubgLoad *extraInfo;

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *someWindow = [UIApplication sharedApplication].keyWindow;
        [AppManager sharedInstance].mainWindow = someWindow;
        
        extraInfo = [PubgLoad new];
        [extraInfo initTapGes];
        [extraInfo tapIconView];
        [extraInfo initTapGes2];
        [extraInfo tapIconView2];
    });
}

- (void)initTapGes {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2; // จำนวนครั้งที่แตะ
    tap.numberOfTouchesRequired = 3; // จำนวนการแตะด้วยนิ้ว
    [[JHPP currentViewController].view addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(tapIconView)];
}

- (void)initTapGes2 {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2; // จำนวนครั้งที่แตะ
    tap.numberOfTouchesRequired = 2; // จำนวนการแตะด้วยนิ้ว
    [[JHPP currentViewController].view addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(tapIconView2)];
}

- (void)tapIconView2 {
    if (!_vna) {
        ImGuiDrawView *vc = [[ImGuiDrawView alloc] init];
        _vna = vc;
    }
    
    [ImGuiDrawView showChange:false];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_vna.view];
}

- (void)tapIconView {
    if (!_vna) {
        ImGuiDrawView *vc = [[ImGuiDrawView alloc] init];
        _vna = vc;
    }
    
    [ImGuiDrawView showChange:true];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_vna.view];
}

@end
