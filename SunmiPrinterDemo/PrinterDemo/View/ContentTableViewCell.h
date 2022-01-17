//
//  ContentTableViewCell.h
//  PrinterDemo
//
//  Created by mark on 2020/6/19.
//  Copyright © 2020 mark. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContentTableViewCell : UITableViewCell

@property(nonatomic, copy)void (^printerBlock)(NSString *contentText);
@property(nonatomic, copy)void (^cashdrawerBlock)(void);
@property(nonatomic, copy)void (^printResultBlock)(void);
@property(nonatomic, copy)void (^printImageBlock)(void);

@property(nonatomic, assign)BOOL isCanPrinter;


@end

NS_ASSUME_NONNULL_END
