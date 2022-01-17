//
//  TextCodeView.m
//  PrinterDemo
//
//  Created by mark on 2020/6/29.
//  Copyright © 2020 mark. All rights reserved.
//

#import "TextCodeView.h"
#import "SunmiHeader.h"
#import "UIView+Frame.h"
#import "SMBaseTableViewCell.h"
@interface TextCodeView ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)UIView *backView;
@property(nonatomic, strong)UITableView *listTable;
@property(nonatomic, strong)NSArray <NSString *> *dataSource;
@property(nonatomic, assign)NSInteger selectedItem;

@end

@implementation TextCodeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.backView];
        [self.backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMissView)]];
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = COLOR_F5;
    [self setUserInteractionEnabled:YES];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.dataSource = @[@"UTF8", @"BIG5", @"Shift JIS", @"GB 18030"];
    [self addSubview:self.listTable];
}

- (UIView *)backView {
    if (_backView == nil) {
        _backView = [[UIView alloc]init];
        _backView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = .0f;
    }
    return _backView;
}

- (UITableView *)listTable {
    if (_listTable == nil) {
        _listTable = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listTable.delegate = self;
        _listTable.dataSource = self;
        _listTable.tableFooterView = [UIView new];
        _listTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _listTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _listTable.scrollIndicatorInsets = _listTable.contentInset;
        _listTable.backgroundColor = [UIColor clearColor];
//        _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _listTable;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedItem = selectedIndex;
    [self.listTable reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseId = @"SMBaseTableViewCell";
    SMBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil) {
        cell = [[SMBaseTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    [cell setIsMainImg:NO];
    NSString *title = self.dataSource[indexPath.row];
    cell.titleLab.text = title;
    if (self.selectedItem == indexPath.row) {
        [cell cellSelectedState:YES];
    }
    else {
        [cell cellSelectedState:NO];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedItem = indexPath.row;
    [tableView reloadData];
    
    if (self.selectedBlock) {
        self.selectedBlock(self.selectedItem);
    }
    [self disMissView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50 * SCREEN_POINT_375;
}

- (void)show:(BOOL)animated {
    self.hidden = NO;
    if (self.backView != nil) {
        if (animated) {
            __weak TextCodeView *weakSelf = self;
            CGFloat y = kScreenHeight - self.height;
            [UIView animateWithDuration:0.25f animations:^{
                weakSelf.y = y;
                weakSelf.backView.alpha = .2f;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (void)hide:(BOOL)animated {
    [self endEditing:YES];
    if (self.backView != nil) {
        __weak TextCodeView *weakSelf = self;
        [UIView animateWithDuration:0.25f animations:^{
            weakSelf.y = kScreenHeight;
        } completion:^(BOOL finished) {
            [weakSelf.backView removeFromSuperview];
            [weakSelf removeFromSuperview];
            weakSelf.backView = nil;
        }];
    }
}

- (void)disMissView {
    [self hide:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.listTable.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - kSafeAreaBottom);
//    ViewBorderRadius(self.listTable, 1, 3, [UIColor redColor]);
}


@end
