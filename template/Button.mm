#import "include.h"
#include <Foundation/Foundation.h>
#include "Cheat/Patches.h"
#include "Cheat/Menu.h"
#include "Cheat/Handle.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale

@interface ImGuiDrawView () <MTKViewDelegate>

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) UIButton *toggleMenuButton; // Added toggle button.
@property (nonatomic, assign) BOOL isMenuEnabled; // Track menu enabled state separately.

@end

@implementation ImGuiDrawView

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged ||
        gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [gesture translationInView:self.view];
        CGPoint center = self.toggleMenuButton.center;
        center.x += translation.x;
        center.y += translation.y;
        self.toggleMenuButton.center = center;
        [gesture setTranslation:CGPointZero inView:self.view];
    }
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    
    if (!self.device)
        abort();
    
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO &io = ImGui::GetIO();
    (void)io;
    
    ImGui::StyleColorsClassic();
    
    ImFont *font = io.Fonts->AddFontFromMemoryCompressedTTF(
        (void *)Honkai_compressed_data, Honkai_compressed_size, 45.0f, NULL,
        io.Fonts->GetGlyphRangesDefault());
    
    loadSettings(); 
    initPatch();
    
    ImGui_ImplMetal_Init(_device);

    //IMAGE ON BASE64 :: https://www.browserling.com/tools/image-to-base64
    NSString *base64String = @"iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAOwAAADsAEnxA+tAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAB0BJREFUeJztnV1sFFUUx/93drrd3W4/gQq0IoIGC8hnMEFMFPTBhxaSJhrRGINIQkSjgReIMUYTQ18gGJWQ4NeLEmNCgvCgBjEmQA0E2iq0kLRQakEoSz+23e+ZHR+2vO2dZW53utue80v2pTdn5szMr7lz5t65A0w/GgFYLv0aJ/E4JgWt0AkwhYUFIA4LQBwWgDgsAHFYAOLohU5AwmIAG1UCl69ctebZ9S/kOZ0Mf/5xcktH28WliuE/A+jMZz75oFgFWAFgr0pg7UNz8MHHn+Y5nQxdnZebATQrhvehCAXgLoA4LABxWADisADEYQGIwwI4QYhCZ5B33DyirQD2qwRuan7Jt++LQ16nccKjo61/DIc70iq7zcm25RpW1gdhmYbj2F3vbE8eO/pTXHHXOwF8rRhri5vPAUoBVKgEenQd5eVKoQgENURTg0qxubddhWDApxTr0XUvAMdSj1OqGJcT7gKIwwIQhwUgDgtAHBaAOLmqgJUA1qps+Km165qWLH3SeaAQKKtbhBNt/SgJ1jgO7xtOOt/nA3LxZhyhiPMS04gOo37Fc3izqhqW5Tz+8qV/ms61nnEcN04rgDZZY67nALuhOCy7Zdt2tOz/XCUUp3tjOHB2SCm2WHn/6Wo8M9+vFLt757v49vAh1V3vAdAia+QugDgsAHFYAOKwAMRhAYjjngDTcOi0UAjh4mVCZrZqVt7avmPm2+/tcl67CIEzvVGcClUpJRU30hhLuDOkWyiCpRp8utqF3DBjGOseDQCW5Tj24Gf7Yl8d+jIka9cBPCxrDATKUFcvbbalMhpF6MawUux0ZCyhLnXl4nrU1QWUYgOBMj9srjHfAxCHBSAOC0AcFoA4LABxJjQpdDBmSisTTQCLZqnNgQzHTfw3ak4gs+JjTrkHFT6PUqwmgHvR7OdDCKDGr7ZdYIICXB80YEgMqPBp2NgQVNpu10ACJ65EJpJa0bG6zoeGWvXJvd2Dqax/14VATZ26ANwFEIcFIA4LQBwWgDgsAHFYAOIU5SJR82u8eH2VWmlzc8TAqZ5onjPKsGFhAHWVaqesUvEZgNsUpQB+XcAfVEstknQ+Zv6gVPk9mK2YV7HCXQBxWADisADEYQGIwwIQZ3rd0gLwlwg8UlUibb89aiBhZq8USj0Cs8vlp8RfMv2muk87AeaW63h5Wbm0/UhHGP0j2Vf5mhX02MZOR7gLIA4LQBwWgDgsAHFYAOKwAMRhAYjDAhCHBSAOC0AcFoA4LABxWADiFGw0MOgVEJKlilNpC3HDvcmdbqBpQJnNIlAxw4KRLr5jKpgAj9V4UapnF+Be1JS+DVus+DwCi2vlr8N3D6akr3gXEu4CiMMCEIcFIA4LQBwWgDgsAHFcKwOr/Bpqy+RvxN4IG5B9PymVnnoLRScM4GpIXrpGU/Jj0jWBBTXySzEQMTEcc+ecuCZAqUeg2uaV6N5hA8kp9rDHDtOyMBxXq/M1DbbnaiTu3j8EdwHEYQGIwwIQhwUgDgtAHNeqgFQaiKXkd/kKn7+Z0nh1AcngJzyasD1XNhXkhHFNgMGoicEiHP4sFPMqdMwIZC/1EoaF9tuJSc4oA3cBxGEBiMMCEIcFIA4LQBx7Afj7v1OfHNfQtgy8cMfCgbPZP/+qC2AgasCU1Kjzq0uwbLb6N3KmGl5dYF6F/HSOJtIYkozq5Rr9/vt2Ar1D2YeaPRrQ2heDbGD1wh37By62AvSFxnC6V23l7YAuAEIC6ALSOh8AhuJp5WnhA6MGrt5NSts7IW/rC43ZbpvvAYjDAhCHBSAOC0AcFoA4OoB/ZY1mPDIzHurzO9mgx6PDV1aGZKQU4YRPKSmvpsE3xRZmtqzMqJ6MeMpCOKFWBaQiYeipJBLRCFIp+R1/Nsx4JAYgJGvPdZZ3A9jraI/jzF3/Bha+8olKKBpqvWh8Qu27w7mwWyy6vlLH5uUVruz3xJUxdA04u3j36fnxI9w69Z3qrvcAaJE1utYFWNRmfLiI5eJ7EnwPQBwWgDgsAHFYAOKwAMTJNSv4VwBhlQ1H+ruauo98+KLTOCEEUo83IDHahIrqGY73OyugY8Vcd0Yh228lcDeavYS0Y2xkGNfO/YaeSxeV7ugj/V2/ADjuODBDq11jLgHaxn+OCXefR7j7vGMBAMCIbELJ6s1AzPlU6QU1adcE6BlM4prS6mV+XP3rdwycO6a66+MADqoG28FdAHFYAOKwAMRhAYjDAhDHzbWCE1AsIdOm6TPjY/KFdyV49BIko3HEDflIol0Vlk7DdpHqZHQUMARMw3klkDbNJIC448AMrr05WqyD7q8C+F4lsGbZ81iy45s8p5Oh8+BW3Os4qRr+GoAf8phOXuAuwAHTcYibBSAOC0AcFoA4LABxWADiFOybQTloR2Y2q2OSI3fXXD/a0pznfO5v+yiA84rh7fnMhZHTCMBy6dc4iccxKXAXQBwWgDgsAHFYAOKwAMRhAYjzPz/MDZaH83edAAAAAElFTkSuQmCC";
    
    // Decode the Base64 string
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    UIImage *backgroundImage = [UIImage imageWithData:imageData];
    // Initialize toggle menu button
    
    self.toggleMenuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.toggleMenuButton.frame = CGRectMake(10, 50, 60, 60);
    [self.toggleMenuButton setBackgroundImage:backgroundImage forState:UIControlStateNormal]; //comment this if you don't want image
    //self.toggleMenuButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7]; // Black transparent background
    self.toggleMenuButton.layer.cornerRadius = 70; // Rounded corners
    [self.toggleMenuButton setTitle:@"" forState:UIControlStateNormal]; //Here you can set title if you don't want image
    [self.toggleMenuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.toggleMenuButton.alpha = 0.8; // 50% transparent
    [self.toggleMenuButton addTarget:self action:@selector(toggleMenuButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.toggleMenuButton];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.toggleMenuButton addGestureRecognizer:panGesture];
    
    // Initially, enable menu and button interaction
    self.isMenuEnabled = NO;
    
    return self;
}

- (void)toggleMenuButtonTapped {
    self.isMenuEnabled = !self.isMenuEnabled; // Toggle the menu state //
    if (self.isMenuEnabled) {
        // Enable user interaction with the menu
        [self.mtkView setUserInteractionEnabled:YES];
    } else {
        // Disable user interaction with the menu
        [self.mtkView setUserInteractionEnabled:NO];
    }
    [self.view setUserInteractionEnabled:YES]; // Ensure button remains interactive
}

+ (void)showChange:(BOOL)open {
    // This method can be used to control menu visibility elsewhere if needed
    // Keeping it as a placeholder in case you need to change menu visibility
    // directly from other parts of your code.
    // Not necessary for the current implementation based on button toggle.
}

- (MTKView *)mtkView {
    return (MTKView *)self.view;
}

- (void)loadView {
    CGFloat w = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
    CGFloat h = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
}

#pragma mark - Interaction

- (void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);
    
    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded &&
            touch.phase != UITouchPhaseCancelled) {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isMenuEnabled) {
        [super touchesBegan:touches withEvent:event]; // Pass touch events to the superclass (game interaction)
    } else {
        [self updateIOWithTouchEvent:event]; // Handle ImGui touch interaction
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isMenuEnabled) {
        [super touchesMoved:touches withEvent:event]; // Pass touch events to the superclass (game interaction)
    } else {
        [self updateIOWithTouchEvent:event]; // Handle ImGui touch interaction
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isMenuEnabled) {
        [super touchesCancelled:touches withEvent:event]; // Pass touch events to the superclass (game interaction)
    } else {
        [self updateIOWithTouchEvent:event]; // Handle ImGui touch interaction
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isMenuEnabled) {
        [super touchesEnded:touches withEvent:event]; // Pass touch events to the superclass (game interaction)
    } else {
        [self updateIOWithTouchEvent:event]; // Handle ImGui touch interaction
    }
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView *)view {
    ImGuiIO &io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    
    CGFloat framebufferScale = view.window.screen.scale ?: UIScreen.mainScreen.scale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 120);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    embraceTheDarkness(); // theme
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui Jane"];
        
        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        ImFont *font = ImGui::GetFont();
        font->Scale = 15.f / font->FontSize;
        
        CGFloat x = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width) - 360) / 2;
        CGFloat y = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height) - 300) / 2;
        
        ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
        ImGui::SetNextWindowSize(ImVec2(400, 300), ImGuiCond_FirstUseEver);
        
        drawWelcome("Welcome to @@APPNAME@@ Mod Menu!", "Version: @@APPVERSION@@", "@@USER@@");
        
        if (self.isMenuEnabled) {
            drawMenu(YES); // Draw the menu if it's enabled
        }
        
        cheatHandle();
        
        ImGui::Render();
        ImDrawData *draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
        
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    // Handle drawable size change if needed
}

@end
