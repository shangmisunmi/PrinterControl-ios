//
//  SMProgressHUD.h
//  router
//
//  Created by liang on 2019/1/11.
//  Copyright © 2019 Wireless Department. All rights reserved.
//

// loading和toast

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
NS_ASSUME_NONNULL_BEGIN

@interface SMProgressHUD : NSObject

// 单例
+ (instancetype)sharedManager;

// 是否是自定义dismiss的toast
@property (nonatomic, assign) BOOL isCustomDismiss;

/* toast文字提示
*/

//普通提示，显示时间1s
+ (void)toastWithText:(NSString *)string;

//+ (void)toastWithText:(NSString *)string backColor:(UIColor *)backColor;

//自定义横屏提示（直播页面用），显示时间1s
+ (void)playerToastWithString:(NSString *)string;

//在某个视图弹出提示，显示时间1s
//+ (void)toastWithText:(NSString *)string inContainerView:(UIView *)containerView;

//web页面提示，显示时间自定
+ (void)h5ToastWithText:(NSString *)string type:(NSString *)type duration:(float )duration;

// 图文loading
+ (void)showWithStatus:(NSString *)status;

// 图文loading delay
+ (void)showWithStatus:(NSString *)status dismissDelay:(NSInteger)delay;

// 转圈，10秒后自动消失
+ (void)showIndicator;

// 白色loading
+ (void)showWhiteIndicator;

//转圈，不会自动消失；调用hideIndicator消失
+ (void)showIndicatorUntilDone;

//白色转圈
//+ (void)loadingInContainerView:(UIView *)containerView;

//loading立即消失
+ (void)hideIndicator;

@end

NS_ASSUME_NONNULL_END
