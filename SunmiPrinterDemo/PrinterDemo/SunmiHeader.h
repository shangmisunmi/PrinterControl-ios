//
//  SunmiHeader.h
//  PrinterDemo
//
//  Created by mark on 2020/6/18.
//  Copyright © 2020 mark. All rights reserved.
//

#ifndef SunmiHeader_h
#define SunmiHeader_h

// 状态栏高度
#define kStatusBarHeight ((IS_IPHONE_X || IS_IPHONE_Xr || IS_IPHONE_Xs || IS_IPHONE_Xs_Max)? 44.f : 20.f)
// 不计入状态栏的导航栏高度
#define kNavigationBarHeight 44
// 导航栏高度
#define kAppNavHeight ((IS_IPHONE_X || IS_IPHONE_Xr || IS_IPHONE_Xs || IS_IPHONE_Xs_Max)? 88.f : 64.f)
// tabBar高度
#define kTabbarHeight ((IS_IPHONE_X || IS_IPHONE_Xr || IS_IPHONE_Xs || IS_IPHONE_Xs_Max)? (49.f+34.f) : 49.f)
// 屏幕宽高
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#define kSafeAreaTop ((IS_IPHONE_X || IS_IPHONE_Xr || IS_IPHONE_Xs || IS_IPHONE_Xs_Max)? 24.f : 0)
#define kSafeAreaBottom ((IS_IPHONE_X || IS_IPHONE_Xr || IS_IPHONE_Xs || IS_IPHONE_Xs_Max)? 34.f : 0)


// 适配比例
#define SCREEN_POINT_375 (kScreenWidth < kScreenHeight ? (float)kScreenWidth/375.f : (float)kScreenHeight/375.f)
#define SCREEN_POINT_667 (kScreenWidth < kScreenHeight ? (float)kScreenHeight/667.f : (float)kScreenWidth/667.f)
#define SCREEN_POINT_812 (kScreenWidth < kScreenHeight ? (float)kScreenHeight/812.f : (float)kScreenWidth/812.f)

typedef NS_ENUM(NSUInteger, PrintConnectType) {
    PrintConnectBluetooth = 0,
    PrintConnectIP
};

//判断是否全面屏手机
#define isiPhone_X_type (([[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0)? YES:NO)

//判断是否是ipad
#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//判断iPhone4系列
#define isIPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhone5系列
#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhone6系列
#define isIPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) && !isPad : NO)
//判断iphone6+系列
#define isIPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size)) && !isPad : NO)
//判断IS_IPHONE_X
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1624), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size)) && !isPad : NO)
//判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size)) && !isPad : NO)
/*颜色定义方式
 */
#define SM_COLOR(r, g, b, a)    [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0*a]
#define SM_RGB(r, g, b)         SM_COLOR(r, g, b, 1.0f)
#define SM_COLORHEX(hex, a)     [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1.0*a]

/*具体颜色
 */
#define WHITE_COLOR             [UIColor whiteColor] // 白色
#define kTextfieldBorderColor   SM_COLORHEX(0xFFFFFF,.1)//输入框边框颜色
#define kSunmiLabelAlpha(a)     SM_COLORHEX(0x333C4F,a) // label色
#define kSunmiOrange            SM_COLORHEX(0xFF6000,1) // 按钮橘色 光标
#define kSunmiOrange_A10        SM_COLORHEX(0xFF6000,.1) // 按钮橘色 10%透明
#define kBadgeColor             SM_COLORHEX(0xFF3838,1) // 消息角标颜色
#define COLOR_33                SM_COLORHEX(0x333338,1)
#define COLOR_66                SM_COLORHEX(0x666666,1)
#define COLOR_99                SM_COLORHEX(0x999999,1)
#define COLOR_85                SM_COLORHEX(0x85858A,1)
#define COLOR_85_light          SM_COLORHEX(0x85858A,.6)
#define COLOR_BackGround        SM_COLORHEX(0xFAFAFA,1) // 背景色
#define COLOR_Line              SM_COLORHEX(0xE6E8EB,1) // 分割线颜色
#define COLOR_85_light_gray     SM_COLORHEX(0x85858A,.2)
#define COLOR_Unable            SM_COLORHEX(0xBBBBC7,1) //灰色
#define COLOR_5C                SM_COLORHEX(0x5CC826,1) //绿色

#define COLOR_30                SM_COLORHEX(0x303540,1)
#define COLOR_52                SM_COLORHEX(0x525866,1)
#define COLOR_77                SM_COLORHEX(0x777E8C,1)
#define COLOR_A1                SM_COLORHEX(0xA1A7B3,1)
#define COLOR_4B                SM_COLORHEX(0x4B7AFA,1)
#define COLOR_F5                SM_COLORHEX(0xF5F7FA,1)
#define COLOR_E6                SM_COLORHEX(0xE6E8EB,1)
#define COLOR_shadow            SM_COLORHEX(0x333338,.2)
#define COLOR_FF                SM_COLORHEX(0xFF6666,1)
#define COLOR_B7                SM_COLORHEX(0xB7EB8F,1)
#define COLOR_F6                SM_COLORHEX(0xF6FFED,1)
#define COLOR_FA                SM_COLORHEX(0xFA541C,1)
#define COLOR_18                SM_COLORHEX(0x1890FF,1)
#define COLOR_AD                SM_COLORHEX(0xADB1B9,1)
// 16加粗
#define FONT_16_BOLD   [UIFont boldSystemFontOfSize:16]

#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

static NSString *Medium_Font       = @"PingFangSC-Medium";
static NSString *Regular_Font      = @"PingFangSC-Regular";
static NSString *Semibold_Font     = @"PingFangSC-Semibold";
static NSString *DinM_Font         = @"DIN-MediumItalic";
static NSString *DINPro_Font       = @"DINPro-Medium";
static NSString *Ligth_Font        = @"PingFangSC-Light";
static NSString *Avenir_Font       = @"Avenir-Light";
static NSString *AvenirBlack_Font  = @"Avenir-Black";
static NSString *AvenirBook_Font   = @"Avenir-Book";
static NSString *AvenirHeavy_Font  = @"Avenir-Heavy";

#define serviceString           @"180A"   //0000180a-0000-1000-8000-00805f9b34fb
#define characteristicsString   @"993F"

// 多语言
#define SMLocalizeString(key) [NSBundle.mainBundle localizedStringForKey:(key) value:@"" table:@"Localizable"]


#endif /* SunmiHeader_h */
