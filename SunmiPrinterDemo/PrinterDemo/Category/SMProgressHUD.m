//
//  SMProgressHUD.m
//  router
//
//  Created by liang on 2019/1/11.
//  Copyright © 2019 Wireless Department. All rights reserved.
//

#import "SMProgressHUD.h"
#import "SVProgressHUD.h"
#import "SunmiHeader.h"
@implementation SMProgressHUD

// 单例
+ (instancetype)sharedManager {
    static SMProgressHUD *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SMProgressHUD alloc] init];
    });
    return manager;
}

// toast
+ (void)toastWithText:(NSString *)string
{

    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    [SVProgressHUD setContainerView:nil];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setBackgroundColor:SM_COLORHEX(0x000000, .6)];
    [SVProgressHUD setForegroundColor:WHITE_COLOR];
    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
    [SVProgressHUD setInfoImage:nil];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 250)];
    [SVProgressHUD setFont:[UIFont fontWithName:Regular_Font size:14]];
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 46)];
    [SVProgressHUD setCornerRadius:6];
    [SVProgressHUD showInfoWithStatus:string];
    [SVProgressHUD dismissWithDelay:3.0];
}

// toast
+ (void)toastWithText:(NSString *)string backColor:(UIColor *)backColor
{

    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    [SVProgressHUD setContainerView:nil];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setBackgroundColor:backColor];
    [SVProgressHUD setForegroundColor:WHITE_COLOR];
    [SVProgressHUD setMaximumDismissTimeInterval:1.5];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 250)];
    [SVProgressHUD setFont:[UIFont fontWithName:Regular_Font size:14]];
    [SVProgressHUD setInfoImage:nil];
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 46)];
    [SVProgressHUD setCornerRadius:6];
    [SVProgressHUD showInfoWithStatus:string];
}

//播放器toast
+(void)playerToastWithString:(NSString *)string
{
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    [SVProgressHUD setContainerView:nil];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMaxSupportedWindowLevel:UIWindowLevelStatusBar];
    [SVProgressHUD setBackgroundColor:SM_COLORHEX(0x000000, .6)];
    [SVProgressHUD setForegroundColor:WHITE_COLOR];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 120)];
    [SVProgressHUD setMinimumSize:CGSizeMake(128, 32)];
    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
    [SVProgressHUD setRingThickness:4.0];
    [SVProgressHUD setRingRadius:16];
    [SVProgressHUD setInfoImage:nil];
    [SVProgressHUD setFont:[UIFont fontWithName:Regular_Font size:12]];
    [SVProgressHUD showInfoWithStatus:string];
}
// 不带文字loading
+ (void)showIndicator {
    
    [SMProgressHUD sharedManager].isCustomDismiss = NO;
    
    if ([SVProgressHUD isVisible]) {
        return;
    }
    [SVProgressHUD setContainerView:nil];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMaxSupportedWindowLevel:UIWindowLevelStatusBar];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:SM_COLORHEX(0xFF6000, 1.0f)];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 0)];
    [SVProgressHUD setRingNoTextRadius:11.0f];
    [SVProgressHUD setRingThickness:2.0f];
    [SVProgressHUD show];
    [SVProgressHUD dismissWithDelay:10.0];
}

+ (void)showWhiteIndicator {
    [SMProgressHUD sharedManager].isCustomDismiss = NO;

    if ([SVProgressHUD isVisible]) {
        return;
    }
    [SVProgressHUD setContainerView:nil];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMaxSupportedWindowLevel:UIWindowLevelStatusBar];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:WHITE_COLOR];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 0)];
    [SVProgressHUD setRingNoTextRadius:11.0f];
    [SVProgressHUD setRingThickness:2.0f];
    [SVProgressHUD show];
    [SVProgressHUD dismissWithDelay:10.0];
}

// 手动关闭loading
+ (void)showIndicatorUntilDone {
    [SMProgressHUD sharedManager].isCustomDismiss = NO;
    if ([SVProgressHUD isVisible]) {
        return;
    }
    [SVProgressHUD setContainerView:nil];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMaxSupportedWindowLevel:UIWindowLevelStatusBar];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:SM_COLORHEX(0xFF6000, 1.0f)];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 0)];
    [SVProgressHUD setRingNoTextRadius:11.0f];
    [SVProgressHUD setRingThickness:2.0f];
    [SVProgressHUD show];
}

// 图文loading
+ (void)showWithStatus:(NSString *)status {
    if ([SVProgressHUD isVisible]) {
        return;
    }
    [SVProgressHUD showWithStatus:status];
    [SVProgressHUD setContainerView:nil];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMinimumSize:CGSizeMake(96 * SCREEN_POINT_375, 96 * SCREEN_POINT_375)];
    [SVProgressHUD setBackgroundColor:SM_COLORHEX(0x777E8C, .64)];
    [SVProgressHUD setForegroundColor:WHITE_COLOR];
    [SVProgressHUD setRingRadius:11 * SCREEN_POINT_375];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 0)];
    [SVProgressHUD setFont:[UIFont fontWithName:Ligth_Font size:12]];
    [SVProgressHUD setCornerRadius:8];
    [SVProgressHUD dismissWithDelay:10.0];
}

// 图文loading delay
+ (void)showWithStatus:(NSString *)status dismissDelay:(NSInteger)delay {
    if ([SVProgressHUD isVisible]) {
        return;
    }
    [SVProgressHUD showWithStatus:status];
    [SVProgressHUD setContainerView:nil];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMinimumSize:CGSizeMake(96 * SCREEN_POINT_375, 96 * SCREEN_POINT_375)];
    [SVProgressHUD setBackgroundColor:SM_COLORHEX(0x777E8C, .64)];
    [SVProgressHUD setForegroundColor:WHITE_COLOR];
    [SVProgressHUD setRingRadius:11 * SCREEN_POINT_375];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 0)];
    [SVProgressHUD setFont:[UIFont fontWithName:Ligth_Font size:12]];
    [SVProgressHUD setCornerRadius:8];
    [SVProgressHUD dismissWithDelay:delay];
}

// 隐藏loading
+ (void)hideIndicator {
    if ([SMProgressHUD sharedManager].isCustomDismiss) {
        
    } else {
        [SVProgressHUD dismiss];
    }
}

// 在某个视图loading
+ (void)loadingInContainerView:(UIView *)containerView {
    
    if ([SVProgressHUD isVisible]) {
        return;
    }
    [SVProgressHUD setContainerView:containerView];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMaxSupportedWindowLevel:UIWindowLevelStatusBar];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:WHITE_COLOR];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 0)];
    [SVProgressHUD setRingThickness:2.0];
    [SVProgressHUD setRingNoTextRadius:11.0f];
    [SVProgressHUD show];
    [SVProgressHUD dismissWithDelay:10.0];
}

// 在某个视图上toast
+ (void)toastWithText:(NSString *)string inContainerView:(UIView *)containerView {
    
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setBackgroundColor:SM_COLORHEX(0x000000, .6)];
    [SVProgressHUD setForegroundColor:WHITE_COLOR];
    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
    [SVProgressHUD setInfoImage:nil];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 250)];
    [SVProgressHUD setFont:[UIFont fontWithName:Regular_Font size:14]];
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 46)];
    [SVProgressHUD setCornerRadius:6];
    [SVProgressHUD showInfoWithStatus:string];
    [SVProgressHUD setContainerView:containerView];
}

#pragma mark ----------------------------------------------------------- web 页面提示
+(void)h5ToastWithText:(NSString *)string type:(NSString *)type duration:(float)duration
{
    //提示文字设置
    [SVProgressHUD setContainerView:nil];
    [SVProgressHUD setBackgroundColor:SM_COLORHEX(0x000000, .6)];
    [SVProgressHUD setForegroundColor:WHITE_COLOR];
    [SVProgressHUD setMaximumDismissTimeInterval:duration];
    if ([type isEqualToString:@"success"]) {
        [SVProgressHUD showSuccessWithStatus:string];
    }else if ([type isEqualToString:@"fail"])
    {
        [SVProgressHUD showErrorWithStatus:string];
    }else
    {
        [SVProgressHUD setInfoImage:nil];
        [SVProgressHUD showInfoWithStatus:string];
    }
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 250*SCREEN_POINT_375)];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:14.0]];
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 48)];
}

@end
