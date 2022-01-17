//
//  TextCodeView.h
//  PrinterDemo
//
//  Created by mark on 2020/6/29.
//  Copyright © 2020 mark. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextCodeView : UIView


@property(nonatomic, copy)void (^selectedBlock) (NSInteger selectedIndex);

@property(nonatomic, assign)NSInteger selectedIndex;

- (void)show:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
