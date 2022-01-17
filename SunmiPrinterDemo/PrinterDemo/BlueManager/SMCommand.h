//
//  SMCommand.h
//  PrinterDemo
//
//  Created by SM1441 on 2021/12/13.
//  Copyright © 2021 mark. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMCommand : NSObject

/**
 *  编码格式: UTF8
 */
+ (NSData *)textTypeUTF8;

/**
 *  其他编码格式
 *  Text type: 1:BIG5 2:Shift JIS 3:GB 18030
 *
 */
+ (NSData *)formatWithTextType:(NSInteger)textType;

/**
 *  打开钱箱
 *
 */
+ (NSData *)openCashBox;

/**
 * 第一次打印
 *
 */
+ (NSData *)printFirst;

/**
 * 打印结果
 *
 */
+ (NSData *)printResult;

@end

NS_ASSUME_NONNULL_END
