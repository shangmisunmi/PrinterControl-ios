//
//  AppDelegate.m
//  PrinterDemo
//
//  Created by mark on 2020/6/18.
//  Copyright © 2020 mark. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "IQKeyboardManager.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    ViewController *con = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:con];
    
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    [self setupIQKeyboardManager];
    return YES;
}

- (void)setupIQKeyboardManager{
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = NO;
    manager.enableAutoToolbar = YES;
}



@end
