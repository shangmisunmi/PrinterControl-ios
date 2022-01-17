//
//  SMBaseTableViewCell.m
//  router
//
//  Created by mark on 2019/11/25.
//  Copyright © 2019 Wireless Department. All rights reserved.
//

#import "SMBaseTableViewCell.h"
#import "SunmiHeader.h"
#import "UIView+Frame.h"
@interface SMBaseTableViewCell ()


@end

@implementation SMBaseTableViewCell

+ (CGFloat)cellHeight {
    return 48 * SCREEN_POINT_375;
}

+ (NSString *)cellIdentifier {
    return [NSString stringWithFormat:@"%@", [self class]];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.isIndicate = YES;
        self.leftX = 20 * SCREEN_POINT_375;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.contentView.backgroundColor = COLOR_F5;
        [self setup];
    }
    return self;
}

- (void)setup {
    [self.contentView addSubview:self.mainImg];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.indicateImg];
}

- (UIImageView *)mainImg {
    if (_mainImg == nil) {
        _mainImg = [[UIImageView alloc]init];
        _mainImg.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _mainImg;
}

- (UILabel *)titleLab {
    if (_titleLab == nil) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.font = [UIFont fontWithName:Regular_Font size:16];
        _titleLab.textColor = COLOR_30;
        _titleLab.backgroundColor = COLOR_F5;
//        ViewBorderRadius(_titleLab, 1, 1, [UIColor RandomColor]);
    }
    return _titleLab;
}

- (UIImageView *)indicateImg {
    if (_indicateImg == nil) {
        _indicateImg = [[UIImageView alloc]init];
        _indicateImg.image = [UIImage imageNamed:@"arrow_right"];
        _indicateImg.frame = CGRectMake(0, 0, 16 * SCREEN_POINT_375, 16 * SCREEN_POINT_375);
//        ViewBorderRadius(_indicateImg, 1, 3, [UIColor RandomColor]);
    }
    return _indicateImg;
}

- (void)setIsMainImg:(BOOL)isMainImg {
    _isMainImg = isMainImg;
}

- (void)setIsIndicate:(BOOL)isIndicate {
    _isIndicate = isIndicate;
    [self.indicateImg setHidden:!isIndicate];
}

- (void)setIndicateStr:(NSString *)indicateStr {
    [self.indicateImg setImage:[UIImage imageNamed:indicateStr]];
}

- (void)setMainImgStr:(NSString *)mainImgStr {
    self.mainImg.image = [UIImage imageNamed:mainImgStr];
}

- (void)setLeftX:(CGFloat)leftX {
    _leftX = leftX;
}

- (void)cellSelectedState:(BOOL)isShow {
    if (isShow) {
        self.titleLab.textColor = kSunmiOrange;
        [self.indicateImg setHidden:NO];
        [self.indicateImg setImage:[UIImage imageNamed:@"Checkbox"]];
        
    } else {
        [self.indicateImg setHidden:YES];
        self.titleLab.textColor = COLOR_30;
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat rightSpacing = 16 * SCREEN_POINT_375;
    CGFloat leftSpacing = self.leftX;
    CGFloat topSpacing = 12 * SCREEN_POINT_375;
    CGFloat width = self.contentView.width;
    CGFloat height = self.contentView.height;
    
    CGFloat imgHeight = height - 2 * topSpacing;
    CGFloat titleLabX = leftSpacing;
    if (self.isMainImg) {
        titleLabX = rightSpacing;
        self.mainImg.frame = CGRectMake(leftSpacing, topSpacing, imgHeight, imgHeight);
        [self.mainImg setHidden:NO];
    }
    else {
        self.mainImg.frame = CGRectZero;
        [self.mainImg setHidden:YES];
    }
    
    CGFloat remainWidth = 0;
    CGFloat indicateWidth = 16 * SCREEN_POINT_375;
    if (self.isIndicate) {
        self.indicateImg.origin = CGPointMake(width - indicateWidth - rightSpacing, (height - indicateWidth)/2);
        remainWidth = self.indicateImg.left - titleLabX - rightSpacing;
    }
    else {
        self.indicateImg.frame = CGRectZero;
        remainWidth = width - titleLabX - rightSpacing;
    }

    self.titleLab.frame = CGRectMake(self.mainImg.right + titleLabX, 0, remainWidth - self.mainImg.right, height);
}


@end
