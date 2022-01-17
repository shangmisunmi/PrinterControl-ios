//
//  ContentTableViewCell.m
//  PrinterDemo
//
//  Created by mark on 2020/6/19.
//  Copyright © 2020 mark. All rights reserved.
//

#import "ContentTableViewCell.h"
#import "SunmiHeader.h"
#import "UIView+Frame.h"
@interface ContentTableViewCell()<UITextViewDelegate>

@property(nonatomic, strong)UIView *backView;
@property(nonatomic, strong)UITextView *textView;
@property(nonatomic, strong)UILabel *numLab;
@property(nonatomic, strong)UIButton *printBTN;
@property(nonatomic, strong)UIButton *openButton;
@property(nonatomic, strong)UIButton *resultButton;
@property(nonatomic, strong)UIButton *printImageButton;

@end

@implementation ContentTableViewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.contentView.backgroundColor = COLOR_F5;
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.textView];
    [self.contentView addSubview:self.numLab];
    [self.contentView addSubview:self.printBTN];
    [self.contentView addSubview:self.openButton];
    [self.contentView addSubview:self.resultButton];
    [self.contentView addSubview:self.printImageButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeText:) name:UITextViewTextDidChangeNotification object:self.textView];
    
}

- (void)closeKeyboard {
    [self.textView endEditing:YES];
}

- (void)textViewDidChangeText:(NSNotification *)notification  {

    static int kMaxLength = 200;
    UITextView *textView = (UITextView *)notification.object;
    NSString *toBeString = textView.text;
    NSString *lang = textView.textInputMode.primaryLanguage;
    // zh-Hans表示简体中文输入, 包括简体拼音，健体五笔，简体手写
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，表明输入结束,则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textView.text = [toBeString substringToIndex:kMaxLength];
            }
        }
    }
    else {
        if (toBeString.length > kMaxLength) {
            textView.text = [toBeString substringToIndex:kMaxLength];
        }
    }
    
    NSInteger length = textView.text.length;
    if (length > 0 && self.isCanPrinter) {
        [self.printBTN setBackgroundColor:kSunmiOrange];
    }
    else {
        [self.printBTN setBackgroundColor:[UIColor lightGrayColor]];
    }
    if (length >= 200) {
        self.backView.layer.borderColor = kBadgeColor.CGColor;
    }
    else {
        self.backView.layer.borderColor = COLOR_85_light.CGColor;
    }
    NSString *numStr = [NSString stringWithFormat:@"%ld/200", length];
    [self.numLab setText:numStr];
}


- (UIView *)backView {
    if (_backView == nil) {
        _backView = [[UIView alloc]init];
        _backView.backgroundColor = [UIColor whiteColor];
        ViewBorderRadius(_backView, 4, 1, COLOR_85_light);
    }
    return _backView;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [UITextView new];
        _textView.tintColor = kSunmiOrange;
        _textView.font = [UIFont fontWithName:Regular_Font size:16];
        _textView.textColor = COLOR_33;
        _textView.delegate = self;
    }
    return _textView;
}

- (UILabel *)numLab {
    if (_numLab == nil) {
        _numLab = [[UILabel alloc]init];
        _numLab.text = @"0/200";
        _numLab.textColor = COLOR_77;
        _numLab.textAlignment = NSTextAlignmentRight;
        [_numLab setFont:[UIFont fontWithName:Regular_Font size:12]];
    }
    return _numLab;;
}

- (UIButton *)printBTN {
    if (_printBTN == nil) {
        _printBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        _printBTN.titleLabel.font = [UIFont systemFontOfSize:15];
        [_printBTN setTitle:SMLocalizeString(@"Print") forState:UIControlStateNormal];
        [_printBTN setBackgroundColor:[UIColor lightGrayColor]];
        [_printBTN addTarget:self action:@selector(printerClick:) forControlEvents:UIControlEventTouchUpInside];
        ViewBorderRadius(_printBTN, 8, .1f, [UIColor clearColor]);
    }
    return _printBTN;
}

- (UIButton *)openButton {
    if (_openButton == nil) {
        _openButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _openButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_openButton setTitle:SMLocalizeString(@"Cashdrawer") forState:UIControlStateNormal];
        [_openButton setBackgroundColor:kSunmiOrange];
        [_openButton addTarget:self action:@selector(cashdrawerClick:) forControlEvents:UIControlEventTouchUpInside];
        ViewBorderRadius(_openButton, 8, .1f, [UIColor clearColor]);
    }
    return _openButton;
}

- (UIButton *)resultButton {
    if (_resultButton == nil) {
        _resultButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _resultButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_resultButton setTitle:SMLocalizeString(@"PrintResult") forState:UIControlStateNormal];
        [_resultButton setBackgroundColor:kSunmiOrange];
        [_resultButton addTarget:self action:@selector(printResultClick:) forControlEvents:UIControlEventTouchUpInside];
        ViewBorderRadius(_resultButton, 8, .1f, [UIColor clearColor]);
    }
    
    return _resultButton;
}

- (UIButton *)printImageButton {
    if (_printImageButton == nil) {
        _printImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _printImageButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_printImageButton setTitle:SMLocalizeString(@"PrintImage") forState:UIControlStateNormal];
        [_printImageButton setBackgroundColor:kSunmiOrange];
        [_printImageButton addTarget:self action:@selector(printImageClick:) forControlEvents:UIControlEventTouchUpInside];
        ViewBorderRadius(_printImageButton, 8, .1f, [UIColor clearColor]);
    }
    
    return _printImageButton;
}

- (void)setIsCanPrinter:(BOOL)isCanPrinter {
    _isCanPrinter = isCanPrinter;
    if (isCanPrinter && self.textView.text.length) {
        [self.printBTN setBackgroundColor:kSunmiOrange];
    }
    else {
        [self.printBTN setBackgroundColor:[UIColor lightGrayColor]];
    }
}

- (void)clearContentText {
    self.textView.text = nil;
    [self.numLab setText: @"0/200"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat spacing = 16 * SCREEN_POINT_375;
    self.backView.frame = CGRectMake(spacing, spacing/2, self.contentView.width - 2 * spacing, self.contentView.height - 160);
    self.textView.frame = CGRectMake(spacing/4, spacing/4, self.backView.width - spacing/2, self.backView.height - spacing/2);
    CGFloat labHeight = 20 * SCREEN_POINT_375;
    self.numLab.frame = CGRectMake(self.contentView.width/2 , self.backView.bottom - labHeight - spacing/4, self.backView.right - self.contentView.width/2 - spacing/2, labHeight);
    self.printBTN.frame = CGRectMake(self.contentView.width - 100, self.backView.bottom + 15, 80, 40);
    self.openButton.frame = CGRectMake(self.contentView.width - 220, self.backView.bottom + 15, 100, 40);
    self.resultButton.frame = CGRectMake(self.contentView.width - 100, self.backView.bottom + 65, 80, 40);
    self.printImageButton.frame = CGRectMake(self.contentView.width - 220, self.backView.bottom + 65, 100, 40);
}

- (void)printerClick:(UIButton *)sender {
    if (!self.isCanPrinter) {
        return;
    }
    if (self.textView.text.length) {
        if (self.printerBlock) {
            self.printerBlock(self.textView.text);
        }
    }
}

- (void)cashdrawerClick:(id)sender {
    if (self.cashdrawerBlock) {
        self.cashdrawerBlock();
    }
}

- (void)printResultClick:(id)sender {
    if (self.printResultBlock) {
        self.printResultBlock();
    }
}

- (void)printImageClick:(id)sender {
    if (self.printImageBlock) {
        self.printImageBlock();
    }
}

@end
