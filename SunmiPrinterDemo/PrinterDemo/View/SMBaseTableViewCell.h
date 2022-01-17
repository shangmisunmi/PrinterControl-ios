//
//  SMBaseTableViewCell.h
//  router
//
//  Created by mark on 2019/11/25.
//  Copyright © 2019 Wireless Department. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMBaseTableViewCell : UITableViewCell

@property(nonatomic, strong)UIImageView *mainImg;
@property(nonatomic, strong)UILabel *titleLab;
@property(nonatomic, strong)UIImageView *indicateImg;

@property(nonatomic, assign)BOOL isMainImg;   //是否展示图片
@property(nonatomic, assign)BOOL isIndicate; //是否展示箭头(默认YES)
@property(nonatomic, assign)CGFloat leftX;  //设置左边距，默认20
@property(nonatomic, strong)NSString *mainImgStr;
@property(nonatomic, strong)NSString *indicateStr;

- (void)cellSelectedState:(BOOL)isShow; //选中状态
+ (CGFloat)cellHeight;
+ (NSString *)cellIdentifier;

@end

NS_ASSUME_NONNULL_END
